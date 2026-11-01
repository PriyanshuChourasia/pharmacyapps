import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

/// 2-column grid of full [ProductCard]s with cart quantities.
class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.cartQty,
    required this.onAdd,
    required this.onQtyChanged,
  });

  final List<Product> products;
  final Map<String, int> cartQty;
  final Future<String?> Function(Product product) onAdd;
  final Future<String?> Function(String productId, int qty) onQtyChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm + 4,
        crossAxisSpacing: AppSpacing.sm + 4,
        childAspectRatio: 0.58,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return StaggeredFadeIn(
          index: index,
          child: ProductCard(
            product: product,
            qty: cartQty[product.id] ?? 0,
            onAdd: onAdd,
            onQtyChanged: (qty) => onQtyChanged(product.id, qty),
            onTap: () => context.push(RoutePaths.productDetail(product.id)),
          ),
        );
      },
    );
  }
}
