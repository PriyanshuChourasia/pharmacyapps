import 'package:flutter/material.dart';

/// A number that slides/fades between values (`AnimatedSwitcher` with a
/// vertical slide, `easeOutCubic`). Respects `MediaQuery.disableAnimations`.
class AnimatedCountText extends StatelessWidget {
  const AnimatedCountText(
    this.value, {
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 250),
  });

  /// The number to show.
  final int value;

  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      '$value',
      key: ValueKey<int>(value),
      style: style,
      textAlign: TextAlign.center,
    );

    if (MediaQuery.disableAnimationsOf(context)) return text;

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeOutCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.65),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: text,
    );
  }
}
