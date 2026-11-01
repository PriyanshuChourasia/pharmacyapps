// Tiny date formatters (no `intl` dependency) for slots and order history.

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _weekdays = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

/// `29 Oct`
String formatDayMonth(DateTime date) =>
    '${date.day} ${_months[date.month - 1]}';

/// `Thu, 29 Oct`
String formatWeekdayDayMonth(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${formatDayMonth(date)}';

/// `4:15 PM`
String formatTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${date.hour < 12 ? 'AM' : 'PM'}';
}

/// `29 Oct 2026, 4:15 PM`
String formatDateTime(DateTime date) =>
    '${formatDayMonth(date)} ${date.year}, ${formatTime(date)}';
