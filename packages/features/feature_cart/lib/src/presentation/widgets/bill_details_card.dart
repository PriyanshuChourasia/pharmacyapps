import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

/// "Bill details" card with the free-delivery hint.
class BillDetailsCard extends StatelessWidget {
  const BillDetailsCard({
    super.key,
    required this.breakdown,
    required this.amountForFreeDelivery,
  });

  final PriceBreakdown breakdown;
  final int amountForFreeDelivery;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bill details', style: AppTypography.sectionTitle),
            const SizedBox(height: AppSpacing.sm),
            BillDetails(
              breakdown: breakdown,
              freeDeliveryHint: amountForFreeDelivery > 0
                  ? 'Add ${Money.format(amountForFreeDelivery)} more for free delivery'
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
