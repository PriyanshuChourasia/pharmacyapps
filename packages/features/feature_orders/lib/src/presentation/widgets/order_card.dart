import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

/// Order summary card: id, date, status, thumbnails, total and actions.
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onReorder,
  });

  final Order order;
  final VoidCallback onTap;
  final VoidCallback onReorder;

  @override
  Widget build(BuildContext context) {
    final shown = order.items.take(3).toList();
    final extra = order.items.length - shown.length;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          formatDateTime(order.createdAt),
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(order.status.label),
                    labelStyle: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: AppColors.primaryLight,
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm + 4),
              Row(
                children: [
                  for (final item in shown)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ProductImage(
                        assetPath: item.product.imageAsset,
                        icon: Icons.medication_outlined,
                        letter: item.product.name,
                        width: 44,
                        height: 44,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                    ),
                  if (extra > 0)
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.background,
                      child: Text('+$extra', style: AppTypography.caption),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm + 4),
              Text(
                '${order.itemCount} item${order.itemCount == 1 ? '' : 's'} · '
                '${Money.format(order.breakdown.payable)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: TextButton.icon(
                      onPressed: onReorder,
                      icon: const Icon(Icons.replay, size: 18),
                      label: const Text('Reorder'),
                    ),
                  ),
                  Flexible(
                    child: TextButton(
                      onPressed: onTap,
                      child: const Text('View details ›'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
