import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// Phone + OTP login.
///
/// Reached two ways:
/// * from the splash (`go`) — no back stack, so a "Skip" action leads Home;
/// * pushed from checkout / profile — closes with `pop(true)` on success and
///   `pop(false)` when dismissed, which those callers await.
///
/// Demo: any 10-digit number gets an OTP; any 6-digit code verifies.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.session});

  /// Defaults to the [AuthSession] registered in GetIt.
  final AuthSession? session;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _Step { phone, otp }

class _LoginScreenState extends State<LoginScreen> {
  static const int _phoneLength = 10;
  static const int _otpLength = 6;
  static const int _resendSeconds = 30;

  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _otpFocus = FocusNode();

  _Step _step = _Step.phone;
  bool _busy = false;
  String? _error;
  int _resendIn = 0;
  Timer? _resendTimer;

  AuthSession get _session => widget.session ?? GetIt.instance<AuthSession>();

  bool get _phoneValid => _phone.text.length == _phoneLength;
  bool get _otpValid => _otp.text.length == _otpLength;

  @override
  void initState() {
    super.initState();
    _phone.addListener(_onInputChanged);
    _otp.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phone.dispose();
    _otp.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _onInputChanged() => setState(() => _error = null);

  Future<void> _sendOtp() async {
    if (!_phoneValid) {
      setState(() => _error = 'Enter a valid 10-digit mobile number');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    // Demo: pretend to hit the OTP service.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _otp.clear();
    setState(() {
      _busy = false;
      _step = _Step.otp;
    });
    _startResendTimer();
    showAppSnackBar(
      context,
      'OTP sent to +91 ${_phone.text} (demo: any 6 digits)',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _otpFocus.requestFocus();
    });
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendIn = _resendSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _resendIn--);
      if (_resendIn <= 0) t.cancel();
    });
  }

  Future<void> _verify() async {
    if (!_otpValid) {
      setState(() => _error = 'Enter the 6-digit OTP');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    final result = await _session.login(
      identifier: '+91${_phone.text}',
      password: _otp.text,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    result.when(
      onSuccess: (s) =>
          _finish(signedIn: true, greeting: 'Welcome, ${s.userName}!'),
      onFailure: (message, _) => setState(() => _error = message),
    );
  }

  Future<void> _continueWithGoogle() async {
    setState(() => _busy = true);
    // Demo Google sign-in.
    final result = await _session.login(
      identifier: 'customer@gmail.com',
      password: 'google-demo',
      name: 'Customer',
    );
    if (!mounted) return;
    setState(() => _busy = false);
    result.when(
      onSuccess: (s) =>
          _finish(signedIn: true, greeting: 'Welcome, ${s.userName}!'),
      onFailure: (message, _) => setState(() => _error = message),
    );
  }

  void _changeNumber() {
    _resendTimer?.cancel();
    setState(() {
      _step = _Step.phone;
      _error = null;
      _resendIn = 0;
    });
  }

  void _finish({required bool signedIn, String? greeting}) {
    if (greeting != null) showAppSnackBar(context, greeting);
    if (context.canPop()) {
      context.pop(signedIn);
    } else {
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              _Header(canPop: canPop, onClose: () => _finish(signedIn: false)),
              Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: _FormCard(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1,
                          child: child,
                        ),
                      ),
                      child: _step == _Step.phone
                          ? _buildPhoneStep()
                          : _buildOtpStep(),
                    ),
                  ),
                ),
              ),
              const _Footer(),
              SizedBox(
                height: MediaQuery.paddingOf(context).bottom + AppSpacing.md,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      key: const ValueKey(_Step.phone),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Log in or sign up', style: AppTypography.sectionTitle),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          "We'll send a one-time password to verify your number.",
          style: AppTypography.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _phone,
          enabled: !_busy,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.telephoneNumberNational],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(_phoneLength),
          ],
          onSubmitted: (_) => _sendOtp(),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
          decoration: InputDecoration(
            labelText: 'Mobile number',
            hintText: '98765 43210',
            errorText: _error,
            prefixIcon: const _CountryPrefix(),
            suffixIcon: _phoneValid
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : null,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Get OTP',
          icon: Icons.sms_outlined,
          loading: _busy,
          onPressed: _phoneValid ? _sendOtp : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        const _OrDivider(),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton(
          onPressed: _busy ? null : _continueWithGoogle,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GoogleBadge(),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Continue with Google',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      key: const ValueKey(_Step.otp),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Verify your number', style: AppTypography.sectionTitle),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Flexible(
              child: Text(
                'Code sent to +91 ${_phone.text}',
                style: AppTypography.bodySecondary,
              ),
            ),
            TextButton(
              onPressed: _busy ? null : _changeNumber,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
              child: const Text('Change'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _otp,
          focusNode: _otpFocus,
          enabled: !_busy,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(_otpLength),
          ],
          onChanged: (v) {
            if (v.length == _otpLength) _verify();
          },
          onSubmitted: (_) => _verify(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 14,
          ),
          decoration: InputDecoration(
            hintText: '• • • • • •',
            hintStyle: const TextStyle(
              fontSize: 20,
              letterSpacing: 6,
              color: AppColors.textSecondary,
            ),
            counterText: '',
            errorText: _error,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          child: _resendIn > 0
              ? Text(
                  'Resend OTP in 0:${_resendIn.toString().padLeft(2, '0')}',
                  style: AppTypography.caption,
                )
              : TextButton(
                  onPressed: _busy ? null : _sendOtp,
                  child: const Text('Resend OTP'),
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Verify & continue',
          loading: _busy,
          onPressed: _otpValid ? _verify : null,
        ),
      ],
    );
  }
}

/// Curved gradient hero with logo, greeting and trust highlights.
class _Header extends StatelessWidget {
  const _Header({required this.canPop, required this.onClose});

  final bool canPop;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CurveClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.accent,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xl + 56,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: canPop
                      ? IconButton(
                          tooltip: 'Close',
                          onPressed: onClose,
                          icon: const Icon(Icons.close, color: Colors.white),
                        )
                      : TextButton(
                          onPressed: onClose,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Skip'),
                        ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.medication_rounded,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Welcome to Dawaidukaan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Medicines & health essentials, delivered to your door.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _TrustChip(icon: Icons.verified_outlined, label: 'Genuine'),
                    _TrustChip(
                      icon: Icons.local_shipping_outlined,
                      label: 'Fast delivery',
                    ),
                    _TrustChip(icon: Icons.lock_outline, label: 'Secure'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const dip = 36.0;
    return Path()
      ..lineTo(0, size.height - dip)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + dip,
        size.width,
        size.height - dip,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// "🇮🇳 +91 |" prefix inside the phone field.
class _CountryPrefix extends StatelessWidget {
  const _CountryPrefix();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇮🇳', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          const Text(
            '+91',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(width: 1, height: 24, color: AppColors.border),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('or', style: AppTypography.caption),
        ),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

/// Simple multi-colour "G" mark (no bundled asset needed).
class _GoogleBadge extends StatelessWidget {
  const _GoogleBadge();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => const SweepGradient(
        colors: [
          Color(0xFF4285F4),
          Color(0xFF34A853),
          Color(0xFFFBBC05),
          Color(0xFFEA4335),
          Color(0xFF4285F4),
        ],
      ).createShader(rect),
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Text.rich(
        TextSpan(
          text: 'By continuing, you agree to our ',
          children: [
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        style: AppTypography.caption,
      ),
    );
  }
}
