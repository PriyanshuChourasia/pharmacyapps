import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pharmmed/app/debug/ui_kit_button.dart';
import 'package:pharmmed/app/debug/ui_kit_page.dart';
import 'package:pharmmed/app/shell/app_shell.dart';
import 'package:pharmmed/app/shell/placeholder_page.dart';
import 'package:feature_catalog/feature_catalog.dart';

/// Root router: a stateful bottom-nav shell with five branches
/// (Home · Categories · Cart · Orders · Profile).
///
/// Top-level routes (`/login`, `/checkout`, …) are pushed over the shell and
/// get added in their phases; all paths come from [RoutePaths].
GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: RoutePaths.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                builder: (context, state) => const PlaceholderPage(
                  title: 'Home',
                  icon: Icons.home_outlined,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.categories,
                builder: (context, state) => const CategoriesPage(),
                routes: [
                  GoRoute(
                    path: RoutePaths.search,
                    builder: (context, state) => const SearchPage(),
                  ),
                  GoRoute(
                    path: RoutePaths.productDetailBase + '/:id',
                    builder: (context, state) => ProductDetailPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.cart,
                builder: (context, state) => const PlaceholderPage(
                  title: 'Cart',
                  icon: Icons.shopping_cart_outlined,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.orders,
                builder: (context, state) => const PlaceholderPage(
                  title: 'Orders',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) => PlaceholderPage(
                  title: 'Profile',
                  icon: Icons.person_outline,
                  // Debug-only entry to the UI-kit review page.
                  footer: kDebugMode
                      ? UiKitButton(
                          onOpen: () => context.push(RoutePaths.uiKit),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
      // The UI-kit review page is only reachable in debug builds.
      if (kDebugMode)
        GoRoute(
          path: RoutePaths.uiKit,
          builder: (context, state) => const UiKitPage(),
        ),
    ],
  );
}
