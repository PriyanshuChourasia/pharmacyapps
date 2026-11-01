import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

/// One cart line: image, name, pack, price, stepper, line total and remove.
/// Swipe left to remove.
class CartLineTile extends StatelessWidget {
  const CartLineTile({
    super.key,
    required this.item,
    required this.onQtyChanged,
    required this.onRemove,
    this.onTap,
  });

  final CartItem item;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Dismissible(
      key: ValueKey('dismiss-${item.productId}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm + 4,
              AppSpacing.sm + 4,
              AppSpacing.sm + 4,
              0,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductImage(
                      assetPath: product.imageAsset,
                      icon: Icons.medication_outlined,
                      letter: product.name,
                      width: 64,
                      height: 64,
                    ),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              if (product.requiresPrescription) const RxBadge(),
                            ],
                          ),
                          Text(product.packSize, style: AppTypography.caption),
                          const SizedBox(height: AppSpacing.xs),
                          PriceText(
                            pricePaise: product.price,
                            mrpPaise: product.mrp,
                            showDiscount: false,
                            style: AppTypography.price.copyWith(fontSize: 14),
                          ),
                          if (product.discountPercent > 0)
                            Text(
                              '${product.discountPercent}% off',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        QuantityStepper(
                          value: item.qty,
                          max: CartRepository.maxQuantityPerItem + 1,
                          onChanged: onQtyChanged,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AnimatedMoneyText(
                          item.lineTotal,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onRemove,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Remove'),
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
