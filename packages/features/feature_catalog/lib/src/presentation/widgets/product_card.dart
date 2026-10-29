import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

/// Shows [message] as a snackbar (cart errors like the quantity limit).
void showCartMessage(BuildContext context, String? message) {
  if (message == null || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Compact catalog card: image, name, manufacturer, pack size, price with
/// struck-through MRP and discount %, Rx badge, and an Add button that
/// morphs into a [QuantityStepper] once the item is in the cart.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.qty,
    required this.onAdd,
    required this.onQtyChanged,
    this.onTap,
    this.icon = Icons.medication_outlined,
  });

  final Product product;

  /// Quantity currently in the cart (0 = not in cart yet).
  final int qty;

  /// Adds one unit; returns an error message or `null`.
  final Future<String?> Function(Product product) onAdd;

  /// Sets the quantity (`0` removes); returns an error message or `null`.
  final Future<String?> Function(int qty) onQtyChanged;

  /// Opens the product detail page.
  final VoidCallback? onTap;

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final inStock = product.inStock;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'product-image-${product.id}',
                child: ProductImage(
                  assetPath: product.imageAsset,
                  icon: icon,
                  letter: product.name,
                  width: 72,
                  height: 72,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        if (product.requiresPrescription) ...[
                          const SizedBox(width: AppSpacing.xs),
                          const RxBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.manufacturer} · ${product.packSize}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    PriceText(
                      pricePaise: product.price,
                      mrpPaise: product.mrp,
                    ),
                    if (!inStock)
                      Text(
                        'Out of stock',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.danger),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                height: 36,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: qty > 0
                      ? QuantityStepper(
                          key: const ValueKey('stepper'),
                          value: qty,
                          max: CartRepository.maxQuantityPerItem,
                          onChanged: (value) async {
                            showCartMessage(
                              context,
                              await onQtyChanged(value),
                            );
                          },
                        )
                      : FilledButton(
                          key: const ValueKey('add'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            minimumSize: const Size(0, 36),
                          ),
                          onPressed: !inStock
                              ? null
                              : () async {
                                  showCartMessage(context, await onAdd(product));
                                },
                          child: const Text('Add'),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
