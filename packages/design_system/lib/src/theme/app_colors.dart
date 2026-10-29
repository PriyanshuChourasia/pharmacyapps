import 'package:flutter/material.dart';

/// Teal/green medical palette plus semantic accents.
abstract final class AppColors {
  /// Primary brand teal.
  static const Color primary = Color(0xFF00897B);

  /// Darker teal for pressed/contrast states.
  static const Color primaryDark = Color(0xFF00695C);

  /// Light teal tint for tonal surfaces.
  static const Color primaryLight = Color(0xFFB2DFDB);

  /// Secondary accent.
  static const Color accent = Color(0xFF26A69A);

  /// App scaffold background.
  static const Color background = Color(0xFFF3F7F6);

  /// Card/sheet surface.
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF12211F);
  static const Color textSecondary = Color(0xFF5A6B68);

  static const Color success = Color(0xFF2E7D32);
  static const Color danger = Color(0xFFC62828);
  static const Color warning = Color(0xFFEF6C00);

  /// Discount/savings highlight.
  static const Color discount = Color(0xFFD84315);

  /// Rx badge red.
  static const Color rx = Color(0xFFB71C1C);

  /// Hairline borders and dividers.
  static const Color border = Color(0xFFE0E6E4);
}
