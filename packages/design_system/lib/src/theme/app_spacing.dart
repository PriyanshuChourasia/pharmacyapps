/// Spacing and corner-radius tokens. Use these instead of magic numbers so
/// screens stay visually consistent.
abstract final class AppSpacing {
  /// 4 px — icon gaps, tight padding.
  static const double xs = 4;

  /// 8 px — between related elements.
  static const double sm = 8;

  /// 16 px — standard screen padding and section gaps.
  static const double md = 16;

  /// 24 px — between sections.
  static const double lg = 24;

  /// 32 px — large separations.
  static const double xl = 32;

  /// Small corner radius (chips, badges).
  static const double radiusSm = 8;

  /// Medium corner radius (cards, fields).
  static const double radiusMd = 12;

  /// Large corner radius (sheets, banners).
  static const double radiusLg = 20;
}
