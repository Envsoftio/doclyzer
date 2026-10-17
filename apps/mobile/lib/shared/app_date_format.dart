/// Dates shown to people use DD-MMM-YYYY; API dates keep their original format.
class AppDateFormat {
  static const _months = [
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

  static String date(DateTime value, {bool local = true}) {
    final d = local ? value.toLocal() : value;
    return '${d.day.toString().padLeft(2, '0')}-${_months[d.month - 1]}-${d.year.toString().padLeft(4, '0')}';
  }

  static String dateTime(DateTime value) {
    final d = value.toLocal();
    return '${date(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  static String relativeDateTime(DateTime value, {DateTime? now}) {
    final current = (now ?? DateTime.now()).toLocal();
    final difference = current.difference(value.toLocal());
    if (difference.isNegative) {
      return _relativeFuture(
        difference.inMinutes.abs(),
        difference.inDays.abs(),
      );
    }
    if (difference.inSeconds < 60) return 'A moment ago';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    }
    return _relativeDays(difference.inDays);
  }

  static String relativeDate(DateTime value, {DateTime? now}) {
    final current = (now ?? DateTime.now()).toLocal();
    final local = value.toLocal();
    final dayDifference = _calendarDaysBetween(current, local);
    if (dayDifference < 0) return _relativeFuture(0, -dayDifference);
    if (dayDifference == 0) return 'Today';
    if (dayDifference == 1) return 'Yesterday';
    return _relativeDays(dayDifference);
  }

  static String dateWithRelative(
    DateTime value, {
    DateTime? now,
    bool hasTime = true,
  }) {
    final relative = hasTime
        ? relativeDateTime(value, now: now)
        : relativeDate(value, now: now);
    return '$relative · ${date(value)}';
  }

  static String dateTimeWithRelative(DateTime value, {DateTime? now}) =>
      '${relativeDateTime(value, now: now)} · ${dateTime(value)}';

  static String _relativeDays(int days) {
    if (days < 7) return '$days ${days == 1 ? 'day' : 'days'} ago';
    if (days < 30) {
      final count = days ~/ 7;
      return '$count ${count == 1 ? 'week' : 'weeks'} ago';
    }
    if (days < 365) {
      final count = days ~/ 30;
      return '$count ${count == 1 ? 'month' : 'months'} ago';
    }
    final count = days ~/ 365;
    return '$count ${count == 1 ? 'year' : 'years'} ago';
  }

  static int _calendarDaysBetween(DateTime current, DateTime other) =>
      DateTime.utc(
        current.year,
        current.month,
        current.day,
      ).difference(DateTime.utc(other.year, other.month, other.day)).inDays;

  static String _relativeFuture(int minutes, int days) {
    if (days > 0) return 'In $days ${days == 1 ? 'day' : 'days'}';
    if (minutes < 1) return 'Just now';
    if (minutes < 60) return 'In $minutes min';
    final hours = minutes ~/ 60;
    return 'In $hours ${hours == 1 ? 'hour' : 'hours'}';
  }

  /// Preserve an unrecognized lab date instead of guessing its day/month order.
  static String fromRaw(String value) {
    final raw = value.trim();
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return value;
    // Date-only values are calendar dates and must not shift with time zones.
    return date(parsed, local: !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw));
  }

  static String fromRawWithRelative(String value, {DateTime? now}) {
    final raw = value.trim();
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return value;
    final dateOnly = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw);
    if (dateOnly) {
      final current = (now ?? DateTime.now()).toLocal();
      final dayDifference = _calendarDaysBetween(current, parsed);
      final relative = dayDifference < 0
          ? _relativeFuture(0, -dayDifference)
          : dayDifference == 0
          ? 'Today'
          : dayDifference == 1
          ? 'Yesterday'
          : _relativeDays(dayDifference);
      return '$relative · ${date(parsed, local: false)}';
    }
    return dateWithRelative(parsed, now: now);
  }

  static String dateTimeFromRaw(String value) {
    final parsed = DateTime.tryParse(value.trim());
    return parsed == null ? value : dateTime(parsed);
  }

  static String dateTimeFromRawWithRelative(String value, {DateTime? now}) {
    final parsed = DateTime.tryParse(value.trim());
    return parsed == null ? value : dateTimeWithRelative(parsed, now: now);
  }
}
