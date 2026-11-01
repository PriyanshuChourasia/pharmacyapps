import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// "100% genuine · Licensed pharmacy · Secure payments" strip.
class TrustStrip extends StatelessWidget {
  const TrustStrip({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.verified_outlined, '100% genuine\nmedicines'),
      (Icons.local_pharmacy_outlined, 'Licensed\npharmacy'),
      (Icons.lock_outline, 'Secure\npayments'),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        0,
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          for (final (icon, label) in items)
            Expanded(
              child: Column(
                children: [
                  Icon(icon, color: AppColors.primary, size: 28),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
