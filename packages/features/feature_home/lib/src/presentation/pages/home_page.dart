import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import '../../models/home_banner.dart';
import '../state/home_cubit.dart';
import '../state/home_state.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/brands_row.dart';
import '../widgets/category_grid.dart';
import '../widgets/deals_row.dart';
import '../widgets/home_header.dart';
import '../widgets/home_skeleton.dart';
import '../widgets/product_row.dart';
import '../widgets/promo_strip.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/trust_strip.dart';

/// Shopping-style Home: header with address + search, quick actions,
/// banners, categories, deals, popular, brands and recommendations.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.banners});

  final List<HomeBanner> banners;

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    return BlocProvider(
      create: (_) => HomeCubit(
        getIt<CatalogRepository>(),
        getIt<CartRepository>(),
        getIt<AddressRepository>(),
      )..load(),
      child: _HomeView(banners: banners),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView({required this.banners});

  final List<HomeBanner> banners;

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _dealsKey = GlobalKey();

  void _scrollToDeals() {
    final target = _dealsKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _openProduct(Product p) => context.push(RoutePaths.productDetail(p.id));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final cubit = context.read<HomeCubit>();
          return RefreshIndicator(
            onRefresh: cubit.load,
            edgeOffset: 160,
            child: CustomScrollView(
              slivers: [
                HomeHeader(
                  address: state.address,
                  cartCount: state.cartCount,
                  addresses: cubit.addresses,
                  onSelectAddress: cubit.selectAddress,
                ),
                ..._body(context, state, cubit),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _body(BuildContext context, HomeState state, HomeCubit cubit) {
    switch (state.status) {
      case HomeStatus.loading:
        return const [SliverToBoxAdapter(child: HomeSkeleton())];
      case HomeStatus.error:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'Could not load Home',
              message: state.error,
              actionLabel: 'Retry',
              onAction: cubit.load,
            ),
          ),
        ];
      case HomeStatus.loaded:
        var i = 0;
        Widget fade(Widget child) => SliverToBoxAdapter(
          child: StaggeredFadeIn(index: i++, child: child),
        );
        return [
          fade(QuickActionsRow(onOffers: _scrollToDeals)),
          fade(BannerCarousel(banners: widget.banners)),
          fade(
            SectionHeader(
              title: 'Shop by category',
              actionLabel: 'See all',
              onAction: () => context.go(RoutePaths.categories),
            ),
          ),
          fade(CategoryGrid(categories: state.categories)),
          fade(
            DealsRow(
              key: _dealsKey,
              products: state.deals,
              cartQty: state.cartQty,
              onAdd: cubit.add,
              onQtyChanged: cubit.setQty,
              onTap: _openProduct,
            ),
          ),
          fade(
            SectionHeader(
              title: 'Popular medicines',
              actionLabel: 'See all',
              onAction: () => context.go(RoutePaths.categories),
            ),
          ),
          fade(
            ProductRow(
              products: state.popular,
              cartQty: state.cartQty,
              onAdd: cubit.add,
              onQtyChanged: cubit.setQty,
              onTap: _openProduct,
            ),
          ),
          fade(const PromoStrip()),
          fade(const SectionHeader(title: 'Trusted brands')),
          fade(BrandsRow(brands: state.brands)),
          fade(const SectionHeader(title: 'Recommended for you')),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm + 4,
                crossAxisSpacing: AppSpacing.sm + 4,
                childAspectRatio: 0.58,
              ),
              itemCount: state.recommended.length,
              itemBuilder: (context, index) {
                final product = state.recommended[index];
                return ProductCard(
                  product: product,
                  qty: state.cartQty[product.id] ?? 0,
                  onAdd: cubit.add,
                  onQtyChanged: (qty) => cubit.setQty(product.id, qty),
                  onTap: () => _openProduct(product),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: TrustStrip()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        ];
    }
  }
}
