import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Shimmer skeleton that mimics a list of product cards while the demo
/// datasource resolves its artificial delay.
class ProductListSkeleton extends StatelessWidget {
  const ProductListSkeleton({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: const ShimmerBox(
          height: 104,
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
        ),
      ),
    );
  }
}
