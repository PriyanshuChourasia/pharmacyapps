import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// "Get ₹50 off your first order — use FIRST50" card with copy-to-clipboard.
class PromoStrip extends StatelessWidget {
  const PromoStrip({super.key});

  static const _code = 'FIRST50';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        0,
      ),
      child: Material(
        color: AppColors.primaryLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: () async {
            await Clipboard.setData(const ClipboardData(text: _code));
            if (context.mounted) {
              showAppSnackBar(context, 'Coupon $_code copied');
            }
          },
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  Icons.card_giftcard,
                  color: AppColors.primaryDark,
                  size: 32,
                ),
                SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'Get ₹50 off on your first order\n',
                      style: TextStyle(fontWeight: FontWeight.w700),
                      children: [
                        TextSpan(
                          text: 'Use code ',
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                        TextSpan(
                          text: _code,
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(Icons.copy, color: AppColors.primaryDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
