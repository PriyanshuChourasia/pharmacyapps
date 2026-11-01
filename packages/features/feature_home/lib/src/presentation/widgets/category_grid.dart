import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

/// 4×2 grid of round category images with labels.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key, required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.78,
      ),
      itemCount: categories.length > 8 ? 8 : categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: () => context.push(
            '${RoutePaths.categoryProducts(category.id)}'
            '?name=${Uri.encodeQueryComponent(category.name)}',
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: ProductImage(
                  assetPath: category.imageAsset,
                  icon: categoryIcon(category.iconKey),
                  letter: category.name,
                  width: 64,
                  height: 64,
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              const SizedBox(height: AppSpacing.xs + 2),
              Text(
                category.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
