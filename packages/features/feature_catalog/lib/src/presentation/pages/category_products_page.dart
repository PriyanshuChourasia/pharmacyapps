import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import '../state/category_products_cubit.dart';
import '../state/load_status.dart';
import '../widgets/product_card.dart';
import '../widgets/product_list_skeleton.dart';

/// One category's products with sort (price ↑/↓, name) and an OTC/Rx filter.
class CategoryProductsPage extends StatelessWidget {
  const CategoryProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryId =
        GoRouterState.of(context).pathParameters['id'] ?? '';
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

  @override
  Widget build(BuildContext context) {
    final title =
        GoRouterState.of(context).uri.queryParameters['name'] ?? 'Medicines';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          BlocBuilder<CategoryProductsCubit, CategoryProductsState>(
            buildWhen: (a, b) => a.sort != b.sort,
            builder: (context, state) => PopupMenuButton<ProductSort>(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort',
              onSelected: (sort) =>
                  context.read<CategoryProductsCubit>().setSort(sort),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: ProductSort.priceAsc,
                  child: Text('Price: low to high'),
                ),
                PopupMenuItem(
                  value: ProductSort.priceDesc,
                  child: Text('Price: high to low'),
                ),
                PopupMenuItem(
                  value: ProductSort.name,
                  child: Text('Name (A–Z)'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: BlocBuilder<CategoryProductsCubit, CategoryProductsState>(
              buildWhen: (a, b) => a.filter != b.filter,
              builder: (context, state) => Row(
                children: [
                  for (final filter in ProductFilter.values)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(switch (filter) {
                          ProductFilter.all => 'All',
                          ProductFilter.otc => 'OTC only',
                          ProductFilter.rx => 'Rx only',
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
                      onAction: () =>
                          context.read<CategoryProductsCubit>().load(),
                    );
                  case LoadStatus.loaded:
                    final products = state.visible;
                    if (products.isEmpty) {
                      return const EmptyState(
                        icon: Icons.filter_alt_off_outlined,
                        title: 'No products match this filter',
                        message: 'Try a different sort or filter.',
                      );
                    }
                    return ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return StaggeredFadeIn(
                          index: index,
                          child: ProductCard(
                            product: product,
                            qty: state.cartQty[product.id] ?? 0,
                            onAdd: (p) =>
                                context.read<CategoryProductsCubit>().add(p),
                            onQtyChanged: (qty) => context
                                .read<CategoryProductsCubit>()
                                .setQty(product.id, qty),
                            onTap: () => context
                                .push(RoutePaths.productDetail(product.id)),
                          ),
                        );
                      },
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
