import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Shimmer blocks for the banner, category grid and two product rows.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget row() => SizedBox(
      height: 240,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, _) => const ShimmerBox(width: 156),
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(height: 92),
          const SizedBox(height: AppSpacing.md),
          const ShimmerBox(height: 160),
          const SizedBox(height: AppSpacing.lg),
          const ShimmerBox(height: 20, width: 160),
          const SizedBox(height: AppSpacing.md),
          for (var r = 0; r < 2; r++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var c = 0; c < 4; c++)
                  const ShimmerBox(
                    width: 64,
                    height: 64,
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const ShimmerBox(height: 20, width: 160),
          const SizedBox(height: AppSpacing.md),
          row(),
          const SizedBox(height: AppSpacing.lg),
          row(),
        ],
      ),
    );
  }
}
