import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Centered spinner with an optional label — used while demo datasources
/// resolve their artificial delay.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  /// Optional label under the spinner, e.g. "Loading medicines…".
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(message!, style: AppTypography.bodySecondary),
          ],
        ],
      ),
    );
  }
}
