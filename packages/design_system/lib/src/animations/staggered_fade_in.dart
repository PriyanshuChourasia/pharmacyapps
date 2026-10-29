import 'package:flutter/material.dart';

/// Staggered entrance: fades + slides [child] in, delayed by [index] so a
/// grid/list of these appears one item after another (no timers — the delay
/// is baked into the tween interval). Respects `MediaQuery.disableAnimations`.
class StaggeredFadeIn extends StatelessWidget {
  const StaggeredFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.step = const Duration(milliseconds: 50),
    this.maxDelay = const Duration(milliseconds: 400),
    this.duration = const Duration(milliseconds: 300),
  });

  /// Position in the sequence (0-based).
  final int index;

  /// Delay before this item starts animating.
  final Duration step;

  /// Cap on the total delay.
  final Duration maxDelay;

  /// Fade-in duration once the delay has passed.
  final Duration duration;

  /// The widget that fades in.
  final Widget child;

  static const double _slideDistance = 12;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    var delayMs = index * step.inMilliseconds;
    if (delayMs > maxDelay.inMilliseconds) {
      delayMs = maxDelay.inMilliseconds;
    }
    final totalMs = delayMs + duration.inMilliseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      curve: Interval(
        totalMs == 0 ? 0 : delayMs / totalMs,
        1,
        curve: Curves.easeOutCubic,
      ),
      builder: (context, value, staticChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, _slideDistance * (1 - value)),
            child: staticChild,
          ),
        );
      },
      child: child,
    );
  }
}
