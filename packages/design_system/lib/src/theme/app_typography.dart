import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Named text styles used across features. Anything not listed here falls
/// back to the theme's default [TextTheme].
abstract final class AppTypography {
  /// Section heading on a screen ("Popular medicines").
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Secondary body text (descriptions, helper copy).
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Small caption (pack size, metadata).
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Selling price.
  static const TextStyle price = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// MRP shown struck through next to the selling price.
  static const TextStyle priceMuted = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    decoration: TextDecoration.lineThrough,
  );

  /// Discount percentage label ("-10%").
  static const TextStyle discountLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.discount,
  );
}
