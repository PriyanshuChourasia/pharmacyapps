import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Green circle that scales in (elasticOut), then a check that fades in.
class SuccessCheckAnimation extends StatefulWidget {
  const SuccessCheckAnimation({super.key, this.size = 112});

  final double size;

  @override
  State<SuccessCheckAnimation> createState() => _SuccessCheckAnimationState();
}

class _SuccessCheckAnimationState extends State<SuccessCheckAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.75, curve: Curves.elasticOut),
  );
  late final Animation<double> _check = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 1, curve: Curves.easeOut),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.isDismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: FadeTransition(
          opacity: _check,
          child: Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: widget.size * 0.6,
          ),
        ),
      ),
    );
  }
}
