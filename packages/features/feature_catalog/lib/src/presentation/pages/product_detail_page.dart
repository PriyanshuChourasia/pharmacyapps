import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import '../state/load_status.dart';
import '../state/product_detail_cubit.dart';
import '../widgets/product_detail_sections.dart';

/// Full product screen: Hero image, price, add-to-cart / stepper, expandable
/// info sections, substitutes and delivery info.
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productId =
        GoRouterState.of(context).pathParameters[RoutePaths.productIdParam] ??
        '';
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
          appBar: AppBar(
            title: Text(product?.name ?? 'Medicine'),
            actions: [
              IconButton(
                tooltip: 'Search',
                icon: const Icon(Icons.search),
                onPressed: () => context.push(RoutePaths.search),
              ),
              CartIconButton(
                count: state.cartCount,
                onTap: () => context.go(RoutePaths.cart),
              ),
            ],
          ),
          body: switch (state.status) {
            LoadStatus.initial || LoadStatus.loading => const DetailSkeleton(),
            LoadStatus.error => EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load this medicine',
              message: state.error,
            ),
            LoadStatus.loaded when product == null => const EmptyState(
              title: 'Product not found',
            ),
            LoadStatus.loaded => _DetailBody(state: state, product: product!),
          },
          bottomNavigationBar: product == null
              ? null
              : _BottomBar(qty: state.cartQty, product: product),
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
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Hero(
            tag: productHeroTag(product.id),
            child: ProductImage(
              assetPath: product.imageAsset,
              icon: Icons.medication_outlined,
              letter: product.name,
              width: double.infinity,
              height: 240,
            ),
          ),
        ),
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: StaggeredFadeIn(
            index: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(product.name, style: textTheme.headlineSmall),
                    ),
                    if (product.requiresPrescription) const RxBadge(),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'by ${product.manufacturer}',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(product.packSize, style: AppTypography.bodySecondary),
                const SizedBox(height: AppSpacing.sm + 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PriceText(
                      pricePaise: product.price,
                      mrpPaise: product.mrp,
                      showDiscount: false,
                      style: textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (product.discountPercent > 0)
                      Text(
                        '${product.discountPercent}% off',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                const Text(
                  'Inclusive of all taxes',
                  style: AppTypography.caption,
                ),
                if (product.requiresPrescription) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'A valid prescription is required to order this medicine.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.rx),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const StaggeredFadeIn(index: 1, child: DeliveryInfoRow()),
        const SizedBox(height: AppSpacing.sm),
        StaggeredFadeIn(index: 2, child: ProductInfoSections(product: product)),
        if (state.substitutes.isNotEmpty)
          StaggeredFadeIn(
            index: 3,
            child: SubstitutesRow(
              substitutes: state.substitutes,
              onTap: (sub) =>
                  context.pushReplacement(RoutePaths.productDetail(sub.id)),
            ),
          ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.qty, required this.product});

  final int qty;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductDetailCubit>();

    final Widget control;
    if (!product.inStock) {
      control = Row(
        children: [
          const Expanded(child: AppButton(label: 'Out of stock')),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: () => showAppSnackBar(
                context,
                "We'll notify you when ${product.name} is back in stock",
              ),
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Notify me'),
            ),
          ),
        ],
      );
    } else if (qty == 0) {
      control = AppButton(
        label: 'Add to cart',
        icon: Icons.add_shopping_cart,
        onPressed: () async {
          final message = await cubit.add();
          if (context.mounted) showAppSnackBar(context, message);
        },
      );
    } else {
      control = Row(
        children: [
          QuantityStepper(
            value: qty,
            min: 0,
            max: CartRepository.maxQuantityPerItem,
            onChanged: (next) async {
              final message = await cubit.setQty(next);
              if (context.mounted) showAppSnackBar(context, message);
            },
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: AppButton(
              label: 'Go to cart',
              icon: Icons.shopping_cart_checkout,
              onPressed: () => context.go(RoutePaths.cart),
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: KeyedSubtree(key: ValueKey(qty == 0), child: control),
        ),
      ),
    );
  }
}
