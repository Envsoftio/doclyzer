import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Formats user-visible dates for the app's active language.
/// API date strings keep their original format.
class AppDateFormat {
  static AppLocalizations? _l10n;
  static bool _dateSymbolsLoaded = false;

  static void configure(AppLocalizations? l10n) {
    _l10n = l10n;
  }

  static void _ensureDateSymbols() {
    if (_dateSymbolsLoaded) return;
    initializeDateFormatting();
    _dateSymbolsLoaded = true;
  }

  static String date(DateTime value, {bool local = true}) {
    _ensureDateSymbols();
    final d = local ? value.toLocal() : value;
    return DateFormat('dd-MMM-yyyy', _l10n?.localeName ?? 'en').format(d);
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
    if (difference.inSeconds < 60) return _l10n?.uiAMomentAgo ?? 'A moment ago';
    if (difference.inMinutes < 60) {
      return _l10n?.uiMinutesAgo('${difference.inMinutes}') ??
          '${difference.inMinutes} min ago';
    }
    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return hours == 1
          ? (_l10n?.uiOneHourAgo ?? '1 hour ago')
          : (_l10n?.uiHoursAgo('$hours') ?? '$hours hours ago');
    }
    return _relativeDays(difference.inDays);
  }

  static String relativeDate(DateTime value, {DateTime? now}) {
    final current = (now ?? DateTime.now()).toLocal();
    final local = value.toLocal();
    final dayDifference = _calendarDaysBetween(current, local);
    if (dayDifference < 0) return _relativeFuture(0, -dayDifference);
    if (dayDifference == 0) return _l10n?.uiToday ?? 'Today';
    if (dayDifference == 1) return _l10n?.uiYesterday ?? 'Yesterday';
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
    if (days < 7) {
      return days == 1
          ? (_l10n?.uiOneDayAgo ?? '1 day ago')
          : (_l10n?.uiDaysAgo('$days') ?? '$days days ago');
    }
    if (days < 30) {
      final count = days ~/ 7;
      return count == 1
          ? (_l10n?.uiOneWeekAgo ?? '1 week ago')
          : (_l10n?.uiWeeksAgo('$count') ?? '$count weeks ago');
    }
    if (days < 365) {
      final count = days ~/ 30;
      return count == 1
          ? (_l10n?.uiOneMonthAgo ?? '1 month ago')
          : (_l10n?.uiMonthsAgo('$count') ?? '$count months ago');
    }
    final count = days ~/ 365;
    return count == 1
        ? (_l10n?.uiOneYearAgo ?? '1 year ago')
        : (_l10n?.uiYearsAgo('$count') ?? '$count years ago');
  }

  static int _calendarDaysBetween(DateTime current, DateTime other) =>
      DateTime.utc(
        current.year,
        current.month,
        current.day,
      ).difference(DateTime.utc(other.year, other.month, other.day)).inDays;

  static String _relativeFuture(int minutes, int days) {
    if (days > 0) {
      return days == 1
          ? (_l10n?.uiInOneDay ?? 'In 1 day')
          : (_l10n?.uiInDays('$days') ?? 'In $days days');
    }
    if (minutes < 1) return _l10n?.uiJustNow ?? 'Just now';
    if (minutes < 60) {
      return _l10n?.uiInMinutes('$minutes') ?? 'In $minutes min';
    }
    final hours = minutes ~/ 60;
    return hours == 1
        ? (_l10n?.uiInOneHour ?? 'In 1 hour')
        : (_l10n?.uiInHours('$hours') ?? 'In $hours hours');
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
          ? (_l10n?.uiToday ?? 'Today')
          : dayDifference == 1
          ? (_l10n?.uiYesterday ?? 'Yesterday')
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
