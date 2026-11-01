import 'package:flutter/material.dart';

import '../animations/badge_pop.dart';
import '../theme/app_colors.dart';

/// Cart icon with a count badge that pops whenever [count] changes.
class CartIconButton extends StatelessWidget {
  const CartIconButton({
    super.key,
    required this.count,
    required this.onTap,
    this.color,
  });

  final int count;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Cart',
      onPressed: onTap,
      color: color,
      icon: CartBadge(
        count: count,
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}

/// Wraps [child] (an icon) with a red count bubble; hidden at zero.
class CartBadge extends StatelessWidget {
  const CartBadge({super.key, required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      backgroundColor: AppColors.rx,
      offset: const Offset(8, -6),
      label: BadgePop(count: count, child: Text(count > 99 ? '99+' : '$count')),
      child: child,
    );
  }
}
