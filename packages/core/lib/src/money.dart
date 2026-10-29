/// Formats an amount held in integer paise as an Indian-rupee string with
/// two decimals and Indian digit grouping.
///
/// Examples:
/// - `formatPaise(0)` → `₹0.00`
/// - `formatPaise(49900)` → `₹499.00`
/// - `formatPaise(123450)` → `₹1,234.50`
/// - `formatPaise(12345678)` → `₹1,23,456.78`
/// - `formatPaise(-123450)` → `-₹1,234.50`
///
/// Money is never represented as `double`; this is the single formatting
/// helper used everywhere in the app.
String formatPaise(int paise) {
  final isNegative = paise < 0;
  final abs = paise.abs();
  final rupees = abs ~/ 100;
  final paisePart = abs % 100;
  final grouped = _groupIndian(rupees.toString());
  final sign = isNegative ? '-' : '';
  return '$sign₹$grouped.${paisePart.toString().padLeft(2, '0')}';
}

/// Groups a digit string in the Indian numbering system:
/// the last three digits stay together, the rest in pairs.
/// e.g. `1234567` → `12,34,567`.
String _groupIndian(String digits) {
  if (digits.length <= 3) return digits;
  final tail = digits.substring(digits.length - 3);
  final head = digits.substring(0, digits.length - 3);
  final parts = <String>[];
  var end = head.length;
  while (end > 0) {
    final start = end >= 2 ? end - 2 : 0;
    parts.insert(0, head.substring(start, end));
    end = start;
  }
  return '${parts.join(',')},$tail';
}
