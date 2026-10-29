import 'package:flutter/material.dart';

/// A rounded skeleton box with a sweeping shimmer gradient — used for
/// loading placeholders during demo-data delays instead of bare spinners.
///
/// Respects `MediaQuery.disableAnimations` (renders a static box then).
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius =
        const BorderRadius.all(Radius.circular(12)),
  });

  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  static const _base = Color(0xFFE6ECEB);
  static const _highlight = Color(0xFFF5F8F7);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: _base,
        borderRadius: widget.borderRadius,
      ),
    );

    if (MediaQuery.disableAnimationsOf(context)) return box;

    return AnimatedBuilder(
      animation: _controller,
      child: box,
      builder: (context, child) {
        // Sweep the highlight from off-left to off-right and back.
        final shift = _controller.value * 2 - 1;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [_base, _highlight, _base],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlideGradient(shift),
            ).createShader(bounds);
          },
          child: child!,
        );
      },
    );
  }
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.shift);

  final double shift;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * shift, 0, 0);
}
