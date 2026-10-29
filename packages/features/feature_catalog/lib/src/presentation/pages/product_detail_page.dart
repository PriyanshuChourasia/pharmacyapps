import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import '../state/load_status.dart';
import '../state/product_detail_cubit.dart';
import '../widgets/product_card.dart';

/// Full product screen: composition, uses, side effects, storage,
/// same-salt substitutes, Hero image, quantity stepper and add/go-to-cart.
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productId =
        GoRouterState.of(context).pathParameters['id'] ?? '';
    return BlocProvider(
      create: (_) => ProductDetailCubit(
        GetIt.instance<CatalogRepository>(),
        GetIt.instance<CartRepository>(),
      )..load(productId),
      child: const _ProductDetailView(),
    );
  }
}

class _ProductDetailView extends StatelessWidget {
  const _ProductDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailCubit, ProductDetailState>(
      builder: (context, state) {
        final product = state.product;
        return Scaffold(
          appBar: AppBar(title: Text(product?.name ?? 'Medicine')),
          body: switch (state.status) {
            LoadStatus.initial || LoadStatus.loading => const _DetailSkeleton(),
            LoadStatus.error => EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load this medicine',
                message: state.error,
              ),
            LoadStatus.loaded when product == null =>
              const EmptyState(title: 'Product not found'),
            LoadStatus.loaded => _DetailBody(state: state, product: product!),
          },
          bottomNavigationBar: product == null
              ? null
              : _BottomBar(state: state, product: product),
        );
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.state, required this.product});

  final ProductDetailState state;
  final Product product;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      children: [
        Hero(
          tag: 'product-image-${product.id}',
          child: ProductImage(
            assetPath: product.imageAsset,
            icon: Icons.medication_outlined,
            letter: product.name,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.zero,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaggeredFadeIn(
                index: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: Theme.of(context).textTheme.headlineSmall!,
                          ),
                        ),
                        if (product.requiresPrescription) ...[
                          const SizedBox(width: AppSpacing.sm),
                          const RxBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${product.manufacturer} · ${product.packSize}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    PriceText(
                      pricePaise: product.price,
                      mrpPaise: product.mrp,
                      style: Theme.of(context).textTheme.headlineSmall!,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      product.inStock
                          ? 'In stock'
                          : 'Out of stock — not orderable',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: product.inStock
                                ? AppColors.success
                                : AppColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              StaggeredFadeIn(
                index: 1,
                child: _Section(
                  title: 'Composition',
                  child: Text(product.salt),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              StaggeredFadeIn(
                index: 2,
                child: _Section(
                  title: 'Uses',
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final use in product.uses)
                        Chip(
                          label: Text(use),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              StaggeredFadeIn(
                index: 3,
                child: _Section(
                  title: 'Side effects',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final effect in product.sideEffects)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(child: Text(effect)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              StaggeredFadeIn(
                index: 4,
                child: _Section(
                  title: 'Storage',
                  child: Text(product.storage),
                ),
              ),
              if (state.substitutes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                StaggeredFadeIn(
                  index: 5,
                  child: _Section(
                    title: 'Substitutes (same composition)',
                    child: SizedBox(
                      height: 116,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.substitutes.length,
                        separatorBuilder: (_, __) => const SizedBox(
                          width: AppSpacing.sm,
                        ),
                        itemBuilder: (context, index) {
                          final sub = state.substitutes[index];
                          return _SubstituteCard(
                            product: sub,
                            onTap: () => context
                                .pushReplacement(RoutePaths.productDetail(sub.id)),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SubstituteCard extends StatelessWidget {
  const _SubstituteCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                ProductImage(
                  assetPath: product.imageAsset,
                  icon: Icons.medication_outlined,
                  letter: product.name,
                  width: 44,
                  height: 44,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      PriceText(
                        pricePaise: product.price,
                        mrpPaise: product.mrp,
                        showDiscount: false,
                      style: Theme.of(context).textTheme.bodySmall!,
                    ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.state, required this.product});

  final ProductDetailState state;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductDetailCubit>();

    final Widget control;
    if (!product.inStock) {
      control = const AppButton(label: 'Out of stock');
    } else if (state.cartQty == 0) {
      control = AppButton(
        label: 'Add to cart',
        icon: Icons.shopping_cart_outlined,
        onPressed: () async => showCartMessage(context, await cubit.add()),
      );
    } else {
      control = Row(
        children: [
          QuantityStepper(
            value: state.cartQty,
            max: CartRepository.maxQuantityPerItem,
            onChanged: (qty) async =>
                showCartMessage(context, await cubit.setQty(qty)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppButton(
              label: 'Go to cart',
              onPressed: () => context.push(RoutePaths.cart),
            ),
          ),
        ],
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: control,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ShimmerBox(
          height: 220,
          borderRadius: BorderRadius.zero,
        ),
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(height: 28, width: 220),
              SizedBox(height: AppSpacing.sm),
              ShimmerBox(height: 16, width: 160),
              SizedBox(height: AppSpacing.md),
              ShimmerBox(height: 22, width: 120),
              SizedBox(height: AppSpacing.lg),
              ShimmerBox(height: 72),
              SizedBox(height: AppSpacing.lg),
              ShimmerBox(height: 72),
            ],
          ),
        ),
      ],
    );
  }
}
