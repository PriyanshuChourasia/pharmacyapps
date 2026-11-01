import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Shimmer skeleton that mimics the product grid while the demo datasource
/// resolves its artificial delay.
class ProductListSkeleton extends StatelessWidget {
  const ProductListSkeleton({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm + 4,
        crossAxisSpacing: AppSpacing.sm + 4,
        childAspectRatio: 0.58,
      ),
      itemCount: count,
      itemBuilder: (context, index) => const ShimmerBox(
        borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
      ),
    );
  }
}
