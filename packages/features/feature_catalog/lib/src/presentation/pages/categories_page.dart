import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import '../catalog_icons.dart';
import '../state/categories_cubit.dart';
import '../state/load_status.dart';

/// Categories tab: a grid of the 8 medicine categories, each opening its
/// product list.
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CategoriesCubit(GetIt.instance<CatalogRepository>())..load(),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          switch (state.status) {
            case LoadStatus.initial:
            case LoadStatus.loading:
              return _skeleton();
            case LoadStatus.error:
              return EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load categories',
                message: state.error,
                actionLabel: 'Retry',
                onAction: () =>
                    context.read<CategoriesCubit>().load(),
              );
            case LoadStatus.loaded:
              return GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.25,
                ),
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return StaggeredFadeIn(
                    index: index,
                    child: _CategoryCard(
                      category: category,
                      onTap: () => context.push('/categories/${category.id}?name=${Uri.encodeComponent(category.name)}'),
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }

  Widget _skeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.25,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ShimmerBox(
        borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = categoryIcon(category.iconKey);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ProductImage(
                assetPath: category.imageAsset,
                icon: icon,
                letter: category.name,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.zero,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: AppColors.primaryDark),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
