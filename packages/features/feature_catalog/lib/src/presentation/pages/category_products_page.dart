import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import '../state/category_products_cubit.dart';
import '../state/load_status.dart';
import '../widgets/product_grid.dart';
import '../widgets/product_list_skeleton.dart';

/// One category's products: sort sheet, OTC/Rx filter chips and a grid.
class CategoryProductsPage extends StatelessWidget {
  const CategoryProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryId =
        GoRouterState.of(context).pathParameters[RoutePaths.categoryIdParam] ??
        '';
    return BlocProvider(
      create: (_) => CategoryProductsCubit(
        GetIt.instance<CatalogRepository>(),
        GetIt.instance<CartRepository>(),
        categoryId: categoryId,
      )..load(),
      child: const _CategoryProductsView(),
    );
  }
}

class _CategoryProductsView extends StatelessWidget {
  const _CategoryProductsView();

  void _showSortSheet(BuildContext context) {
    final cubit = context.read<CategoryProductsCubit>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: RadioGroup<ProductSort>(
          groupValue: cubit.state.sort,
          onChanged: (sort) {
            if (sort != null) cubit.setSort(sort);
            Navigator.pop(sheetContext);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Text('Sort by', style: AppTypography.sectionTitle),
              ),
              for (final sort in ProductSort.values)
                RadioListTile<ProductSort>(
                  value: sort,
                  title: Text(sort.label),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title =
        GoRouterState.of(context).uri.queryParameters['name'] ?? 'Medicines';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => context.push(RoutePaths.search),
          ),
        ],
      ),
      body: Column(
        children: [
          BlocBuilder<CategoryProductsCubit, CategoryProductsState>(
            buildWhen: (a, b) => a.filter != b.filter || a.sort != b.sort,
            builder: (context, state) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.sort, size: 18),
                    label: Text(state.sort.label),
                    onPressed: () => _showSortSheet(context),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  for (final filter in ProductFilter.values)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(switch (filter) {
                          ProductFilter.all => 'All',
                          ProductFilter.otc => 'OTC',
                          ProductFilter.rx => 'Rx',
                        }),
                        selected: state.filter == filter,
                        onSelected: (_) => context
                            .read<CategoryProductsCubit>()
                            .setFilter(filter),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<CategoryProductsCubit, CategoryProductsState>(
              builder: (context, state) {
                final cubit = context.read<CategoryProductsCubit>();
                switch (state.status) {
                  case LoadStatus.initial:
                  case LoadStatus.loading:
                    return const ProductListSkeleton();
                  case LoadStatus.error:
                    return EmptyState(
                      icon: Icons.error_outline,
                      title: 'Could not load medicines',
                      message: state.error,
                      actionLabel: 'Retry',
                      onAction: cubit.load,
                    );
                  case LoadStatus.loaded:
                    final products = state.visible;
                    if (products.isEmpty) {
                      return const EmptyState(
                        icon: Icons.filter_alt_off_outlined,
                        title: 'No products match this filter',
                        message: 'Try a different filter.',
                      );
                    }
                    return ProductGrid(
                      products: products,
                      cartQty: state.cartQty,
                      onAdd: cubit.add,
                      onQtyChanged: cubit.setQty,
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
