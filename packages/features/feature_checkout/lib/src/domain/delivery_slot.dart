import 'package:core/core.dart';

enum SlotDay { today, tomorrow }

enum SlotTime {
  morning('Morning', '8 AM–12 PM'),
  evening('Evening', '4 PM–8 PM');

  const SlotTime(this.label, this.hours);
  final String label;
  final String hours;
}

/// A chosen delivery day + time window.
class DeliverySlot {
  const DeliverySlot(this.day, this.time);

  final SlotDay day;
  final SlotTime time;

  static DateTime dateOf(SlotDay day, [DateTime? now]) {
    final base = now ?? DateTime.now();
    return DateTime(base.year, base.month, base.day + day.index);
  }

  /// "Today, 29 Oct" / "Tomorrow, 30 Oct"
  static String dayLabel(SlotDay day) =>
      '${day == SlotDay.today ? 'Today' : 'Tomorrow'}, '
      '${formatDayMonth(dateOf(day))}';

  /// "Thu, 29 Oct · 8 AM–12 PM" (stored on the order).
  String get label => '${formatWeekdayDayMonth(dateOf(day))} · ${time.hours}';
}
