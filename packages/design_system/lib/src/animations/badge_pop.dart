import 'package:flutter/material.dart';

/// Wraps a badge (e.g. the cart count) and plays a scale "pop" whenever
/// [count] changes. Respects `MediaQuery.disableAnimations`.
class BadgePop extends StatefulWidget {
  const BadgePop({super.key, required this.count, required this.child});

  /// The value being displayed; a change triggers the pop.
  final int count;

  /// The badge widget to scale.
  final Widget child;

  @override
  State<BadgePop> createState() => _BadgePopState();
}

class _BadgePopState extends State<BadgePop>
    with SingleTickerProviderStateMixin {
  static final TweenSequence<double> _pop = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(begin: 1.0, end: 1.35)
          .chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 45,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 1.35, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 55,
    ),
  ]);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void didUpdateWidget(covariant BadgePop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Transform.scale(
          scale: _pop.transform(_controller.value),
          child: child,
        );
      },
    );
  }
}
