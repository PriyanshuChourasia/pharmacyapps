import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

/// Horizontal row of compact product cards synced with the cart.
class ProductRow extends StatelessWidget {
  const ProductRow({
    super.key,
    required this.products,
    required this.cartQty,
    required this.onAdd,
    required this.onQtyChanged,
    required this.onTap,
    this.hero = true,
    this.showDiscountRibbon = false,
  });

  final List<Product> products;
  final Map<String, int> cartQty;
  final Future<String?> Function(Product product) onAdd;
  final Future<String?> Function(String productId, int qty) onQtyChanged;
  final ValueChanged<Product> onTap;
  final bool hero;
  final bool showDiscountRibbon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm + 2),
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            compact: true,
            hero: hero,
            showDiscountRibbon: showDiscountRibbon,
            qty: cartQty[product.id] ?? 0,
            onAdd: onAdd,
            onQtyChanged: (qty) => onQtyChanged(product.id, qty),
            onTap: () => onTap(product),
          );
        },
      ),
    );
  }
}
