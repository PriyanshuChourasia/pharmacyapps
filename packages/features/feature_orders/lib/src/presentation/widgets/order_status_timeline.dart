import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

/// Vertical Placed → Packed → Shipped → Delivered timeline.
class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({
    super.key,
    required this.status,
    required this.placedAt,
  });

  final OrderStatus status;
  final DateTime placedAt;

  @override
  Widget build(BuildContext context) {
    const steps = OrderStatus.values;
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _Step(
            label: steps[i].label,
            detail: i == 0 ? formatDateTime(placedAt) : 'Pending',
            done: steps[i].index <= status.index,
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.detail,
    required this.done,
    required this.isLast,
  });

  final String label;
  final String detail;
  final bool done;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.success : AppColors.border;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: color,
                child: done
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: AppColors.border)),
            ],
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: done
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  Text(detail, style: AppTypography.caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
