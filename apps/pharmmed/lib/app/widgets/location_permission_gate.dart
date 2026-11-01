import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../services/location_permission_service.dart';

/// Full-screen gate shown on app load until the user grants location access.
///
/// PharmMed uses location to show nearby stores and estimate delivery times.
/// Once permission is granted (or already held), [child] — the real app — is
/// shown instead.
class LocationPermissionGate extends StatefulWidget {
  const LocationPermissionGate({
    super.key,
    required this.child,
    required this.service,
  });

  /// The app shell shown once location permission is granted.
  final Widget child;

  final LocationPermissionService service;

  @override
  State<LocationPermissionGate> createState() => _LocationPermissionGateState();
}

class _LocationPermissionGateState extends State<LocationPermissionGate> {
  LocationPermissionStatus _status = LocationPermissionStatus.denied;
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final status = await widget.service.status();
    if (mounted) {
      setState(() => _status = status);
    }
  }

  Future<void> _request() async {
    if (mounted) {
      setState(() => _requesting = true);
    }
    final status = await widget.service.request();
    if (mounted) {
      setState(() {
        _status = status;
        _requesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final granted = _status == LocationPermissionStatus.granted ||
        _status == LocationPermissionStatus.limited;
    if (granted) return widget.child;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 80,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Location access needed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'PharmMed needs your location to show nearby stores and '
                    'estimate delivery times.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_requesting)
                    const SizedBox(
                      height: 48,
                      width: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  else ...[
                    AppButton(
                      label: 'Allow location access',
                      icon: Icons.location_on,
                      variant: AppButtonVariant.primary,
                      onPressed: _request,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_status == LocationPermissionStatus.permanentlyDenied)
                      AppButton(
                        label: 'Open app settings',
                        variant: AppButtonVariant.ghost,
                        onPressed: widget.service.openSettings,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
