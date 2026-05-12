import 'package:intl/intl.dart';

/// Utility helpers for formatting dates throughout the app.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _fullDate = DateFormat('dd MMM yyyy');
  static final DateFormat _shortDate = DateFormat('dd MMM');
  static final DateFormat _time = DateFormat('HH:mm');
  static final DateFormat _dayMonth = DateFormat('d MMMM');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _weekday = DateFormat('EEEE');

  /// "12 May 2026"
  static String fullDate(DateTime date) => _fullDate.format(date);

  /// "12 May"
  static String shortDate(DateTime date) => _shortDate.format(date);

  /// "14:30"
  static String time(DateTime date) => _time.format(date);

  /// "12 May" or section header
  static String dayMonth(DateTime date) => _dayMonth.format(date);

  /// "May 2026"
  static String monthYear(DateTime date) => _monthYear.format(date);

  /// "Monday"
  static String weekday(DateTime date) => _weekday.format(date);

  /// Returns a human-friendly relative label.
  /// "Today", "Yesterday", or "12 May 2026".
  static String relative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return _weekday.format(date);
    return _fullDate.format(date);
  }

  /// Group key for transaction list (date without time).
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get start of current week (Monday).
  static DateTime startOfWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Get start of current month.
  static DateTime startOfMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }
}
