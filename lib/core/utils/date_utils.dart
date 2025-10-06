import 'package:intl/intl.dart';

class AppDateUtils {
  /// Normalize date to midnight (00:00:00)
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    final now = normalizeDate(DateTime.now());
    final normalized = normalizeDate(date);
    return normalized.isBefore(now);
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    final now = normalizeDate(DateTime.now());
    final normalized = normalizeDate(date);
    return normalized.isAfter(now);
  }

  /// Format time in 12-hour format (e.g., "5:30 AM")
  static String formatTime12Hour(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  /// Format time in 24-hour format (e.g., "17:30")
  static String formatTime24Hour(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  /// Format date (e.g., "October 6, 2025")
  static String formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  /// Format date short (e.g., "Oct 6")
  static String formatDateShort(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Format day name (e.g., "Saturday")
  static String formatDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Format month name (e.g., "October")
  static String formatMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  /// Format month and year (e.g., "October 2025")
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Get duration string (e.g., "2h 15m")
  static String formatDuration(Duration duration) {
    if (duration.isNegative) {
      return '0m';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Get countdown string for remaining time
  static String formatCountdown(Duration duration) {
    if (duration.isNegative) {
      return 'Passed';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Get first day of month
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get last day of month
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Get number of days in month
  static int getDaysInMonth(DateTime date) {
    return getLastDayOfMonth(date).day;
  }

  /// Get start of week (Sunday)
  static DateTime getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  /// Get end of week (Saturday)
  static DateTime getEndOfWeek(DateTime date) {
    return getStartOfWeek(date).add(const Duration(days: 6));
  }

  /// Generate key for Hive storage (YYYY-MM-DD_prayerName)
  static String generateStorageKey(DateTime date, String prayerName) {
    final normalized = normalizeDate(date);
    return '${normalized.toIso8601String().split('T')[0]}_$prayerName';
  }
}
