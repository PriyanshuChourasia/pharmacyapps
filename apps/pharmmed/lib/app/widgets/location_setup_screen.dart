import 'dart:convert';
import 'dart:math';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:dawaidukaan/app/services/location_permission_service.dart';

/// KeyValueStore key holding the chosen delivery location as JSON.
const String kUserLocationKey = 'user_location';

/// Whether a delivery location has already been saved.
Future<bool> hasSavedLocation() async {
  final getIt = GetIt.instance;
  if (!getIt.isRegistered<KeyValueStore>()) return false;
  final raw = await getIt<KeyValueStore>().read(kUserLocationKey);
  return raw != null && raw.isNotEmpty;
}

/// Where the flow should resume when the user returns from a settings page.
enum _Resume { none, appSettings, locationSettings }

/// Shown after login / Google / Skip: map illustration in the center and a
/// bottom card with "Enable location" and "Enter location manually".
///
/// "Enable location" runs: 1) permission check/request → 2) device location
/// service check → 3) read + reverse-geocode position → confirm → Home.
class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key, this.service});

  /// Defaults to the [LocationPermissionService] registered in GetIt.
  final LocationPermissionService? service;

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final LocationPermissionService _service =
      widget.service ?? GetIt.instance<LocationPermissionService>();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  bool _busy = false;
  String? _statusText;
  LocationResult? _detected;
  _Resume _resume = _Resume.none;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
      _pulse.value = 0.5;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulse.dispose();
    super.dispose();
  }

  /// Back from app settings / location settings → continue automatically.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _resume == _Resume.none) return;
    final from = _resume;
    _resume = _Resume.none;
    if (from == _Resume.appSettings) {
      _enableLocation(fromSettings: true);
    } else {
      _checkServiceAndDetect(fromSettings: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Flow
  // ---------------------------------------------------------------------------

  bool _isGranted(LocationPermissionStatus s) =>
      s == LocationPermissionStatus.granted ||
      s == LocationPermissionStatus.limited;

  /// Step 1: permission.
  Future<void> _enableLocation({bool fromSettings = false}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _statusText = 'Checking location permission…';
    });

    var status = await _service.status();
    if (!mounted) return;

    if (status == LocationPermissionStatus.denied && !fromSettings) {
      status = await _service.request();
      if (!mounted) return;
    }

    if (_isGranted(status)) {
      _setBusy(false);
      await _checkServiceAndDetect();
      return;
    }

    _setBusy(false);
    switch (status) {
      case LocationPermissionStatus.permanentlyDenied:
        await _showActionSheet(
          icon: Icons.location_disabled_outlined,
          title: 'Location permission is off',
          message:
              'Open Settings → Permissions → Location and allow it, then come back.',
          actionLabel: 'Open settings',
          onAction: () async {
            _resume = _Resume.appSettings;
            await _service.openSettings();
          },
        );
      case LocationPermissionStatus.unknown:
        _snack('Could not check location permission. Please enter your '
            'location manually.');
      default:
        _snack('Location permission is needed to detect your address.');
    }
  }

  /// Step 2: device Location service (GPS) → Step 3: detect.
  Future<void> _checkServiceAndDetect({bool fromSettings = false}) async {
    setState(() {
      _busy = true;
      _statusText = 'Checking device location…';
    });
    final enabled = await _service.isServiceEnabled();
    if (!mounted) return;

    if (!enabled) {
      _setBusy(false);
      if (fromSettings) {
        _snack('Device location is still off.');
      }
      await _showActionSheet(
        icon: Icons.gps_off_outlined,
        title: 'Your device location is off',
        message: 'Turn it on to detect your delivery address.',
        actionLabel: 'Turn on location',
        onAction: () async {
          _resume = _Resume.locationSettings;
          await _service.openLocationSettings();
        },
      );
      return;
    }

    setState(() => _statusText = 'Detecting your location…');
    final result = await _service.currentLocation();
    if (!mounted) return;
    _setBusy(false);

    if (result == null) {
      _snack("Couldn't detect your location. Try again or enter it manually.");
      return;
    }
    setState(() => _detected = result);
  }

  // ---------------------------------------------------------------------------
  // Manual entry + save
  // ---------------------------------------------------------------------------

  Future<void> _enterManually() async {
    final result = await showModalBottomSheet<LocationResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (_) => const _ManualLocationSheet(),
    );
    if (result != null && mounted) {
      await _saveAndGoHome(result, source: 'manual');
    }
  }

  Future<void> _saveAndGoHome(
    LocationResult result, {
    required String source,
  }) async {
    final store = GetIt.instance<KeyValueStore>();
    await store.write(
      kUserLocationKey,
      jsonEncode({
        'lat': result.lat,
        'lng': result.lng,
        'label': result.label,
        'city': result.city,
        'pincode': result.pincode,
        'source': source,
      }),
    );
    if (!mounted) return;
    context.go(RoutePaths.home);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setBusy(bool value) {
    if (!mounted) return;
    setState(() {
      _busy = value;
      if (!value) _statusText = null;
    });
  }

  void _snack(String message) {
    if (mounted) showAppSnackBar(context, message, error: true);
  }

  Future<void> _showActionSheet({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required Future<void> Function() onAction,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.primary),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                style: AppTypography.bodySmall.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: actionLabel,
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  await onAction();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Enter manually',
                variant: AppButtonVariant.ghost,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _enterManually();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(painter: _MapPainter(pulse: _pulse)),
                  Center(child: _Pin(pulse: _pulse)),
                  if (_statusText != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: AppSpacing.lg,
                      child: Center(child: _StatusChip(text: _statusText!)),
                    ),
                ],
              ),
            ),
            _BottomCard(
              busy: _busy,
              detected: _detected,
              onEnable: _enableLocation,
              onManual: _enterManually,
              onConfirm: () => _saveAndGoHome(_detected!, source: 'gps'),
              onChange: () {
                setState(() => _detected = null);
                _enterManually();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomCard extends StatelessWidget {
  const _BottomCard({
    required this.busy,
    required this.detected,
    required this.onEnable,
    required this.onManual,
    required this.onConfirm,
    required this.onChange,
  });

  final bool busy;
  final LocationResult? detected;
  final VoidCallback onEnable;
  final VoidCallback onManual;
  final VoidCallback onConfirm;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final d = detected;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: d == null
            ? [
                Text(
                  'Where should we deliver?',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Allow location to find nearby pharmacies and faster '
                  'delivery, or enter your address yourself.',
                  style: AppTypography.bodySmall.copyWith(fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Enable location',
                  icon: Icons.my_location,
                  loading: busy,
                  onPressed: busy ? null : onEnable,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Enter location manually',
                  icon: Icons.edit_location_alt_outlined,
                  variant: AppButtonVariant.secondary,
                  onPressed: busy ? null : onManual,
                ),
              ]
            : [
                Text(
                  'Deliver to',
                  style: AppTypography.bodySmall.copyWith(fontSize: 13),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        d.label,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(label: 'Confirm & continue', onPressed: onConfirm),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Change',
                  variant: AppButtonVariant.ghost,
                  onPressed: onChange,
                ),
              ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(text, style: AppTypography.bodySmall.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}

/// Pin that bobs gently above its shadow.
class _Pin extends StatelessWidget {
  const _Pin({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, child) {
        final lift = sin(pulse.value * 2 * pi) * 6;
        return Transform.translate(
          offset: Offset(0, -28 + lift),
          child: child,
        );
      },
      child: const Icon(Icons.location_on, size: 56, color: AppColors.primary),
    );
  }
}

/// Map illustration: blocks, parks, roads and a pulse ring at the center.
class _MapPainter extends CustomPainter {
  _MapPainter({required this.pulse}) : super(repaint: pulse);

  final Animation<double> pulse;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEFF4F2),
    );

    // City blocks.
    final block = Paint()..color = const Color(0xFFE2EAE7);
    const cell = 72.0;
    for (var x = -cell / 2; x < size.width; x += cell) {
      for (var y = -cell / 3; y < size.height; y += cell) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 8, y + 8, cell - 16, cell - 16),
            const Radius.circular(6),
          ),
          block,
        );
      }
    }

    // Parks.
    final park = Paint()..color = AppColors.primaryLight.withValues(alpha: 0.7);
    for (final r in [
      Rect.fromLTWH(size.width * 0.08, size.height * 0.12, 110, 70),
      Rect.fromLTWH(size.width * 0.62, size.height * 0.66, 120, 80),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(12)),
        park,
      );
    }

    // Main roads.
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(
        Offset(0, size.height * 0.55),
        Offset(size.width, size.height * 0.42),
        road,
      )
      ..drawLine(
        Offset(size.width * 0.35, 0),
        Offset(size.width * 0.45, size.height),
        road,
      );

    // Pulse ring at the pin position.
    final center = size.center(Offset.zero);
    final t = pulse.value;
    canvas
      ..drawCircle(
        center,
        16 + 60 * t,
        Paint()..color = AppColors.primary.withValues(alpha: 0.25 * (1 - t)),
      )
      ..drawCircle(
        center,
        8,
        Paint()..color = AppColors.primary.withValues(alpha: 0.35),
      );
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) => false;
}

/// Manual address form. Pops a [LocationResult] on save.
class _ManualLocationSheet extends StatefulWidget {
  const _ManualLocationSheet();

  @override
  State<_ManualLocationSheet> createState() => _ManualLocationSheetState();
}

class _ManualLocationSheetState extends State<_ManualLocationSheet> {
  final _form = GlobalKey<FormState>();
  final _pincode = TextEditingController();
  final _area = TextEditingController();
  final _city = TextEditingController();
  final _landmark = TextEditingController();

  @override
  void dispose() {
    _pincode.dispose();
    _area.dispose();
    _city.dispose();
    _landmark.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final landmark = _landmark.text.trim();
    final label = [
      _area.text.trim(),
      if (landmark.isNotEmpty) 'near $landmark',
      _city.text.trim(),
      _pincode.text.trim(),
    ].join(', ');
    Navigator.of(context).pop(
      LocationResult(
        lat: 0,
        lng: 0,
        label: label,
        city: _city.text.trim(),
        pincode: _pincode.text.trim(),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter delivery location',
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _pincode,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Pincode',
                counterText: '',
              ),
              validator: (v) => RegExp(r'^[1-9][0-9]{5}$').hasMatch(v ?? '')
                  ? null
                  : 'Enter a valid 6-digit pincode',
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _area,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Area / street'),
              validator: _required,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _city,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'City'),
              validator: _required,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _landmark,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Landmark (optional)',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: 'Save & continue', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
