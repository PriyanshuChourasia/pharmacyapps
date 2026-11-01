import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Sticky bar: payable total + "View bill details" + "Proceed to checkout".
class CartBottomBar extends StatelessWidget {
  const CartBottomBar({
    super.key,
    required this.payable,
    required this.onViewBill,
    required this.onCheckout,
  });

  final int payable;
  final VoidCallback onViewBill;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm + 4,
        AppSpacing.md,
        AppSpacing.sm + 4,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onViewBill,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedMoneyText(
                  payable,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'View bill details',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppButton(
              label: 'Proceed to checkout',
              onPressed: onCheckout,
            ),
          ),
        ],
      ),
    );
  }
}
