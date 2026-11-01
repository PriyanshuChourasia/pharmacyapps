import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../animations/animated_count_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Bill rows for a [PriceBreakdown]: item total, discounts, delivery and the
/// bold payable total. Used by the cart, checkout and order detail.
class BillDetails extends StatelessWidget {
  const BillDetails({
    super.key,
    required this.breakdown,
    this.totalLabel = 'To pay',
    this.freeDeliveryHint,
  });

  final PriceBreakdown breakdown;
  final String totalLabel;

  /// Optional hint under the delivery row, e.g. "Add ₹40 more for free
  /// delivery".
  final String? freeDeliveryHint;

  @override
  Widget build(BuildContext context) {
    final b = breakdown;
    return Column(
      children: [
        _BillRow(label: 'Item total (MRP)', paise: b.itemMrpTotal),
        if (b.discount > 0)
          _BillRow(
            label: 'Product discount',
            paise: -b.discount,
            color: AppColors.success,
          ),
        if (b.couponDiscount > 0)
          _BillRow(
            label: 'Coupon (${b.couponCode})',
            paise: -b.couponDiscount,
            color: AppColors.success,
          ),
        _BillRow(
          label: 'Delivery fee',
          paise: b.deliveryFee,
          freeText: b.itemMrpTotal > 0 && b.deliveryFee == 0 ? 'FREE' : null,
        ),
        if (freeDeliveryHint != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              freeDeliveryHint!,
              style: const TextStyle(fontSize: 12, color: AppColors.warning),
            ),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Divider(),
        ),
        _BillRow(label: totalLabel, paise: b.payable, bold: true),
      ],
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({
    required this.label,
    required this.paise,
    this.color,
    this.bold = false,
    this.freeText,
  });

  final String label;
  final int paise;
  final Color? color;
  final bool bold;
  final String? freeText;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      color: color ?? AppColors.textPrimary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          if (freeText != null)
            Text(
              freeText!,
              style: style.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            AnimatedMoneyText(paise, style: style),
        ],
      ),
    );
  }
}

/// A formatted paise amount whose text animates when it changes.
class AnimatedMoneyText extends StatelessWidget {
  const AnimatedMoneyText(this.paise, {super.key, this.style});

  final int paise;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return AnimatedCountText(paise, style: style, formatter: Money.format);
  }
}
