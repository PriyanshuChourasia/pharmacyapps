import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Formats and shows a price in paise: selling price, struck-through MRP and
/// the discount percentage. Money never leaves integer paise until formatted.
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.pricePaise,
    this.mrpPaise,
    this.showDiscount = true,
    this.style = AppTypography.price,
    this.mrpStyle = AppTypography.priceMuted,
    this.discountStyle = AppTypography.discountLabel,
  });

  /// Selling price in paise.
  final int pricePaise;

  /// MRP in paise; shown struck through when above [pricePaise].
  final int? mrpPaise;

  /// Whether to show the computed `-N%` label when a discount exists.
  final bool showDiscount;

  final TextStyle style;
  final TextStyle mrpStyle;
  final TextStyle discountStyle;

  @override
  Widget build(BuildContext context) {
    final mrp = mrpPaise;
    final showMrp = mrp != null && mrp > pricePaise;
    final discountPercent =
        showMrp && mrp > 0 ? ((mrp - pricePaise) * 100) ~/ mrp : 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(formatPaise(pricePaise), style: style),
        if (showMrp) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(formatPaise(mrp), style: mrpStyle),
        ],
        if (showDiscount && discountPercent > 0) ...[
          const SizedBox(width: AppSpacing.sm),
          Text('-$discountPercent%', style: discountStyle),
        ],
      ],
    );
  }
}
