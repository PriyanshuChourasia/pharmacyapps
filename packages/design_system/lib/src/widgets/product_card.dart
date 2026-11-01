import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_snack_bar.dart';
import 'price_text.dart';
import 'product_image.dart';
import 'quantity_stepper.dart';
import 'rx_badge.dart';

/// Hero tag shared by product cards and the product detail image.
String productHeroTag(String productId) => 'product-$productId';

/// Shopping product card: image, name, pack size, struck-out MRP + price,
/// "xx% off", Rx badge and an Add button that morphs into a
/// [QuantityStepper] once the product is in the cart.
///
/// The default layout is a vertical grid tile; [compact] fixes the width for
/// horizontal rows. Set [hero] to false where the same product can appear
/// twice on one screen (Hero tags must be unique).
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.qty,
    required this.onAdd,
    required this.onQtyChanged,
    this.onTap,
    this.icon = Icons.medication_outlined,
    this.compact = false,
    this.hero = true,
    this.showDiscountRibbon = false,
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
  final bool compact;
  final bool hero;

  /// Shows a "xx% OFF" corner ribbon (deals row).
  final bool showDiscountRibbon;

  @override
  Widget build(BuildContext context) {
    Widget image = ProductImage(
      assetPath: product.imageAsset,
      icon: icon,
      letter: product.name,
      width: double.infinity,
      height: double.infinity,
    );
    if (hero) image = Hero(tag: productHeroTag(product.id), child: image);

    final card = Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: image),
                    if (product.requiresPrescription)
                      const Positioned(top: 4, right: 4, child: RxBadge()),
                    if (showDiscountRibbon && product.discountPercent > 0)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: _Ribbon('${product.discountPercent}% OFF'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                product.packSize,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.xs),
              PriceText(
                pricePaise: product.price,
                mrpPaise: product.mrp,
                showDiscount: false,
                style: AppTypography.price.copyWith(fontSize: 15),
                mrpStyle: AppTypography.priceMuted.copyWith(fontSize: 12),
              ),
              SizedBox(
                height: 16,
                child: product.discountPercent > 0
                    ? Text(
                        '${product.discountPercent}% off',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                height: 36,
                width: double.infinity,
                child: _AddControl(
                  product: product,
                  qty: qty,
                  onAdd: onAdd,
                  onQtyChanged: onQtyChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!compact) return card;
    return SizedBox(width: 156, child: card);
  }
}

class _AddControl extends StatelessWidget {
  const _AddControl({
    required this.product,
    required this.qty,
    required this.onAdd,
    required this.onQtyChanged,
  });

  final Product product;
  final int qty;
  final Future<String?> Function(Product product) onAdd;
  final Future<String?> Function(int qty) onQtyChanged;

  @override
  Widget build(BuildContext context) {
    if (!product.inStock) {
      return OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
        child: const Text('Out of stock', style: TextStyle(fontSize: 12)),
      );
    }
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: qty > 0
          ? FittedBox(
              key: const ValueKey('stepper'),
              child: QuantityStepper(
                value: qty,
                min: 0,
                max: CartRepository.maxQuantityPerItem,
                onChanged: (value) async {
                  final message = await onQtyChanged(value);
                  if (context.mounted) showAppSnackBar(context, message);
                },
              ),
            )
          : FilledButton.icon(
              key: const ValueKey('add'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                minimumSize: const Size.fromHeight(36),
              ),
              onPressed: () async {
                final message = await onAdd(product);
                if (context.mounted) showAppSnackBar(context, message);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
    );
  }
}

class _Ribbon extends StatelessWidget {
  const _Ribbon(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: const BoxDecoration(
        color: AppColors.discount,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusMd),
          bottomRight: Radius.circular(AppSpacing.radiusSm),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
