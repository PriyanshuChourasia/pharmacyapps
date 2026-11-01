import 'package:core/core.dart';
import 'package:dawaidukaan/app/widgets/splash_screen.dart';
import 'package:dawaidukaan/app/widgets/login_screen.dart';
import 'package:feature_cart/feature_cart.dart';
import 'package:feature_catalog/feature_catalog.dart';
import 'package:feature_checkout/feature_checkout.dart';
import 'package:feature_home/feature_home.dart';
import 'package:feature_orders/feature_orders.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:dawaidukaan/app/assets.dart';

import 'package:dawaidukaan/app/shell/app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Fade-through transition (250 ms) used for every pushed route.
Page<T> _fade<T>(GoRouterState state, Widget child) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      final fadeIn = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final fadeOut = Tween<double>(begin: 1, end: 0.92).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
      );
      return FadeTransition(
        opacity: fadeOut,
        child: FadeTransition(
          opacity: fadeIn,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(fadeIn),
            child: child,
          ),
        ),
      );
    },
  );
}

/// A top-level route pushed over the shell (no bottom nav).
GoRoute _top(String path, Widget Function(GoRouterState state) build) {
  return GoRoute(
    path: path,
    parentNavigatorKey: _rootKey,
    pageBuilder: (context, state) => _fade(state, build(state)),
  );
}

/// Root router: a stateful bottom-nav shell with five branches
/// (Home · Categories · Cart · Orders · Profile) plus top-level routes for
/// search, product, category lists, checkout, login and order success.
GoRouter buildAppRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: RoutePaths.splash,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                builder: (context, state) =>
                    const HomePage(banners: AppAssets.homeBanners),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.categories,
                builder: (context, state) => const CategoriesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.cart,
                builder: (context, state) =>
                    const CartPage(emptyImageAsset: AppAssets.emptyCart),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.orders,
                builder: (context, state) => const OrdersPage(),
                routes: [
                  GoRoute(
                    path: ':${RoutePaths.orderIdParam}',
                    pageBuilder: (context, state) =>
                        _fade(state, const OrderDetailPage()),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'addresses',
                    pageBuilder: (context, state) =>
                        _fade(state, const SavedAddressesPage()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      _top(RoutePaths.search, (_) => const SearchPage()),
      _top(
        '${RoutePaths.categoryProductsBase}/:${RoutePaths.categoryIdParam}',
        (_) => const CategoryProductsPage(),
      ),
      _top(
        '${RoutePaths.productDetailBase}/:${RoutePaths.productIdParam}',
        (_) => const ProductDetailPage(),
      ),
      _top(RoutePaths.checkout, (_) => const CheckoutPage()),
      _top(RoutePaths.addAddress, (_) => const AddAddressPage()),
      _top(RoutePaths.checkoutSuccess, (_) => const OrderSuccessPage()),
      _top(RoutePaths.login, (_) => const LoginScreen()),
    ],
  );
}
