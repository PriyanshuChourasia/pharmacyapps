import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:dawaidukaan/app/widgets/location_setup_screen.dart';

/// Branded launch screen: teal gradient, animated logo mark, app name and
/// tagline. After a short hold it routes to Home when already signed in,
/// otherwise to Login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// How long the splash stays on screen before navigating.
  static const Duration holdDuration = Duration(milliseconds: 2600);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.55, curve: Curves.easeOutBack),
  );
  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.35, curve: Curves.easeOut),
  );
  late final Animation<double> _textFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
  );
  late final Animation<Offset> _textSlide = Tween<Offset>(
    begin: const Offset(0, 0.4),
    end: Offset.zero,
  ).animate(_textFade);
  late final Animation<double> _footerFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.65, 1, curve: Curves.easeOut),
  );

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(SplashScreen.holdDuration, _goNext);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _controller.value = 1;
  }

  Future<void> _goNext() async {
    if (!mounted) return;
    final getIt = GetIt.instance;
    final loggedIn =
        getIt.isRegistered<AuthSession>() && getIt<AuthSession>().isLoggedIn;
    if (!loggedIn) {
      context.go(RoutePaths.login);
      return;
    }
    final hasLocation = await hasSavedLocation();
    if (!mounted) return;
    context.go(hasLocation ? RoutePaths.home : RoutePaths.locationSetup);
  }


  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        // Paint the gradient edge to edge (behind status + navigation bars).
        backgroundColor: AppColors.primaryDark,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Soft decorative rings for depth.
              Positioned(
                top: -size.width * 0.35,
                right: -size.width * 0.3,
                child: _Ring(diameter: size.width * 0.9),
              ),
              Positioned(
                bottom: -size.width * 0.45,
                left: -size.width * 0.35,
                child: _Ring(diameter: size.width * 1.1),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: const _LogoMark(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          children: [
                            const Text(
                              'Dawaidukaan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Care today. Thrive tomorrow.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(flex: 4),
                    FadeTransition(
                      opacity: _footerFade,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '100% genuine medicines',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// White rounded tile with a pharmacy glyph and a small accent cross.
class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.medication_rounded,
            size: 60,
            color: AppColors.primary,
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.discount,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.diameter});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 2,
        ),
      ),
    );
  }
}
