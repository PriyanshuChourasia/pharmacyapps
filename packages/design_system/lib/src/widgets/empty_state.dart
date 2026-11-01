import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

/// Centered placeholder for empty lists/pages: icon, title, optional
/// message and an optional action button (e.g. "Browse medicines").
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon = Icons.inventory_2_outlined,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.imageAsset,
  });

  /// Optional illustration shown instead of [icon].
  final String? imageAsset;

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageAsset != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: Image.asset(
                  imageAsset!,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(icon, size: 64, color: AppColors.textSecondary),
                ),
              )
            else
              Icon(icon, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.sectionTitle,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                expanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
