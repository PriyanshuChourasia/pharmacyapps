import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import 'package:dawaidukaan/app/di/injector.dart';

/// Bottom-navigation shell hosting the five app tabs. Each branch keeps its
/// own navigator, so tab state (scroll position, stack) survives switching.
/// The Cart tab shows a live count badge that pops on change.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _cartIndex = 2;

  static const List<(IconData, IconData, String)> _tabs = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.grid_view_outlined, Icons.grid_view_rounded, 'Categories'),
    (Icons.shopping_cart_outlined, Icons.shopping_cart, 'Cart'),
    (Icons.receipt_long_outlined, Icons.receipt_long, 'Orders'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  late final Stream<List<CartItem>> _cart = getIt<CartRepository>().watch();

  @override
  Widget build(BuildContext context) {
    final shell = widget.navigationShell;
    return Scaffold(
      body: shell,
      bottomNavigationBar: StreamBuilder<List<CartItem>>(
        stream: _cart,
        builder: (context, snapshot) {
          final count = (snapshot.data ?? const []).fold(
            0,
            (sum, i) => sum + i.qty,
          );
          return NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: (index) => shell.goBranch(
              index,
              // Tapping the current tab pops that branch to its root.
              initialLocation: index == shell.currentIndex,
            ),
            destinations: [
              for (var i = 0; i < _tabs.length; i++)
                NavigationDestination(
                  icon: i == _cartIndex
                      ? CartBadge(count: count, child: Icon(_tabs[i].$1))
                      : Icon(_tabs[i].$1),
                  selectedIcon: i == _cartIndex
                      ? CartBadge(count: count, child: Icon(_tabs[i].$2))
                      : Icon(_tabs[i].$2),
                  label: _tabs[i].$3,
                ),
            ],
          );
        },
      ),
    );
  }
}
