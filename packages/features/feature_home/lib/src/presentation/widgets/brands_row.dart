import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Manufacturer chips; tapping one searches for that brand.
class BrandsRow extends StatelessWidget {
  const BrandsRow({super.key, required this.brands});

  final List<String> brands;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final brand = brands[index];
          return ActionChip(
            avatar: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                brand[0],
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            label: Text(brand),
            backgroundColor: AppColors.surface,
            shape: const StadiumBorder(
              side: BorderSide(color: AppColors.border),
            ),
            onPressed: () => context.push(RoutePaths.searchFor(brand)),
          );
        },
      ),
    );
  }
}
