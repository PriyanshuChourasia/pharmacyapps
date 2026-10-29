import 'package:core/core.dart';

/// Small helpers around integer-paise amounts. The canonical formatter is
/// [formatPaise] in `core`; [Money.format] is the shared_models facade.
abstract final class Money {
  /// Formats paise as `₹1,234.50`.
  static String format(int paise) => formatPaise(paise);

  /// Converts whole rupees to paise (e.g. `rupees(499)` → `49900`).
  static int rupees(int value) => value * 100;

  /// [percent] percent of [paise], truncated to whole paise.
  static int percentOf(int paise, int percent) => (paise * percent) ~/ 100;
}
