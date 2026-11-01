import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Sticky "To pay ₹X  [Place order]" bar.
class PlaceOrderBar extends StatelessWidget {
  const PlaceOrderBar({
    super.key,
    required this.payable,
    required this.placing,
    required this.isUpi,
    required this.onPlaceOrder,
  });

  final int payable;
  final bool placing;
  final bool isUpi;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('To pay', style: AppTypography.caption),
                AnimatedMoneyText(
                  payable,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: placing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            isUpi
                                ? 'Processing UPI payment…'
                                : 'Placing your order…',
                          ),
                        ),
                      ],
                    )
                  : AppButton(label: 'Place order', onPressed: onPlaceOrder),
            ),
          ],
        ),
      ),
    );
  }
}
