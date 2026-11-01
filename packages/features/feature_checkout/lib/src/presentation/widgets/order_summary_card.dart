import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

/// Collapsible item list followed by the bill.
class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.items,
    required this.breakdown,
  });

  final List<CartItem> items;
  final PriceBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final units = items.fold(0, (sum, i) => sum + i.qty);
    return Column(
      children: [
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          shape: const Border(),
          title: Text('$units item${units == 1 ? '' : 's'} in this order'),
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product.name} × ${item.qty}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(Money.format(item.lineTotal)),
                  ],
                ),
              ),
          ],
        ),
        BillDetails(breakdown: breakdown),
      ],
    );
  }
}
