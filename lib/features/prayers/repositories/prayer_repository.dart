import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer.dart';
import '../models/prayer_status.dart';
import '../models/prayer_log.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/constants/app_constants.dart';

class PrayerRepository {
  final Box<PrayerLog> _logsBox;
  final SharedPreferences? _prefs;
  final Uuid _uuid = const Uuid();

  PrayerRepository(this._logsBox, [this._prefs]);

  /// Log a prayer
  Future<void> logPrayer({
    required DateTime date,
    required Prayer prayer,
    required PrayerStatus status,
    required DateTime scheduledTime,
  }) async {
    final key = _generateKey(date, prayer);
    final log = PrayerLog(
      id: _uuid.v4(),
      date: AppDateUtils.normalizeDate(date),
      prayer: prayer,
      status: status,
      loggedAt: DateTime.now(),
      scheduledTime: scheduledTime,
    );
    await _logsBox.put(key, log);
  }

  /// Get prayer log for specific date and prayer
  PrayerLog? getPrayerLog(DateTime date, Prayer prayer) {
    final key = _generateKey(date, prayer);
    return _logsBox.get(key);
  }

  /// Get all logs for a specific date
  Map<Prayer, PrayerLog?> getLogsForDate(DateTime date) {
    return {
      for (var prayer in Prayer.values) prayer: getPrayerLog(date, prayer),
    };
  }

  /// Get logs for entire month
  List<PrayerLog> getLogsForMonth(int year, int month) {
    return _logsBox.values
        .where((log) => log.date.year == year && log.date.month == month)
        .toList();
  }

  /// Get logs for a date range (respects installation date restrictions)
  List<PrayerLog> getLogsForDateRange(DateTime start, DateTime end) {
    final normalizedStart = AppDateUtils.normalizeDate(start);
    final normalizedEnd = AppDateUtils.normalizeDate(end);

    // Apply installation date restriction
    final restrictedStart = _getValidStartDate(normalizedStart);

    return _logsBox.values.where((log) {
      final logDate = log.date;
      return (logDate.isAtSameMomentAs(restrictedStart) ||
              logDate.isAfter(restrictedStart)) &&
          (logDate.isAtSameMomentAs(normalizedEnd) ||
              logDate.isBefore(normalizedEnd));
    }).toList();
  }

  /// Update existing prayer log
  Future<void> updatePrayerLog({
    required DateTime date,
    required Prayer prayer,
    required PrayerStatus status,
  }) async {
    final key = _generateKey(date, prayer);
    final existingLog = _logsBox.get(key);

    if (existingLog != null) {
      final updatedLog = existingLog.copyWith(
        status: status,
        loggedAt: DateTime.now(),
      );
      await _logsBox.put(key, updatedLog);
    }
  }

  /// Delete prayer log
  Future<void> deletePrayerLog(DateTime date, Prayer prayer) async {
    final key = _generateKey(date, prayer);
    await _logsBox.delete(key);
  }

  /// Clear all data
  Future<void> clearAllData() async {
    await _logsBox.clear();
  }

  /// Export all data to JSON
  Map<String, dynamic> exportData() {
    final logs = _logsBox.values.map((log) => log.toJson()).toList();
    return {
      'version': AppConstants.appVersion,
      'exportDate': DateTime.now().toIso8601String(),
      'totalLogs': logs.length,
      'logs': logs,
    };
  }

  /// Get statistics for a month (respects installation date)
  MonthlyStats getMonthlyStats(int year, int month) {
    final logs = getLogsForMonth(year, month);

    int jamaahCount = 0;
    int adahCount = 0;
    int qalahCount = 0;
    int missedCount = 0;

    for (final log in logs) {
      switch (log.status) {
        case PrayerStatus.jamaah:
          jamaahCount++;
          break;
        case PrayerStatus.adah:
          adahCount++;
          break;
        case PrayerStatus.qalah:
          qalahCount++;
          break;
        case PrayerStatus.notPerformed:
        case PrayerStatus.missed:
          missedCount++;
          break;
      }
    }

    final totalCompleted = jamaahCount + adahCount + qalahCount;

    // Calculate total prayers based on accessible days in the month
    final totalPrayersInMonth = _calculateAccessiblePrayersInMonth(year, month);

    return MonthlyStats(
      year: year,
      month: month,
      jamaahCount: jamaahCount,
      adahCount: adahCount,
      qalahCount: qalahCount,
      missedCount: missedCount,
      totalCompleted: totalCompleted,
      totalPrayers: totalPrayersInMonth,
    );
  }

  /// Calculate the number of accessible prayers in a month (respects installation date)
  int _calculateAccessiblePrayersInMonth(int year, int month) {
    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 0);
    final installationDate = _getInstallationDate();

    DateTime effectiveStart;
    if (installationDate != null) {
      final normalizedInstallation = AppDateUtils.normalizeDate(installationDate);

      // If installation date is after the month start, use installation date
      if (normalizedInstallation.isAfter(monthStart)) {
        // If installation date is after the month end, return 0
        if (normalizedInstallation.isAfter(monthEnd)) {
          return 0;
        }
        effectiveStart = normalizedInstallation;
      } else {
        effectiveStart = monthStart;
      }
    } else {
      effectiveStart = monthStart;
    }

    // Calculate the number of days between effective start and month end
    final accessibleDays = monthEnd.difference(effectiveStart).inDays + 1;

    return accessibleDays * AppConstants.totalPrayersPerDay;
  }

  /// Get prayer-wise breakdown for a month (respects installation date)
  Map<Prayer, PrayerStats> getPrayerWiseStats(int year, int month) {
    final logs = getLogsForMonth(year, month);

    // Calculate accessible days based on installation date
    final accessibleDays = _calculateAccessibleDaysInMonth(year, month);

    final stats = <Prayer, PrayerStats>{};

    for (final prayer in Prayer.values) {
      final prayerLogs = logs.where((log) => log.prayer == prayer);

      int completed = 0;
      int jamaah = 0;
      int adah = 0;
      int qalah = 0;
      int missed = 0;

      for (final log in prayerLogs) {
        if (log.status != PrayerStatus.notPerformed && log.status != PrayerStatus.missed) {
          completed++;
        }
        switch (log.status) {
          case PrayerStatus.jamaah:
            jamaah++;
            break;
          case PrayerStatus.adah:
            adah++;
            break;
          case PrayerStatus.qalah:
            qalah++;
            break;
          case PrayerStatus.notPerformed:
          case PrayerStatus.missed:
            missed++;
            break;
        }
      }

      stats[prayer] = PrayerStats(
        prayer: prayer,
        completed: completed,
        total: accessibleDays,
        jamaahCount: jamaah,
        adahCount: adah,
        qalahCount: qalah,
        missedCount: missed,
      );
    }

    return stats;
  }

  /// Calculate the number of accessible days in a month (respects installation date)
  int _calculateAccessibleDaysInMonth(int year, int month) {
    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 0);
    final installationDate = _getInstallationDate();

    DateTime effectiveStart;
    if (installationDate != null) {
      final normalizedInstallation = AppDateUtils.normalizeDate(installationDate);

      // If installation date is after the month start, use installation date
      if (normalizedInstallation.isAfter(monthStart)) {
        // If installation date is after the month end, return 0
        if (normalizedInstallation.isAfter(monthEnd)) {
          return 0;
        }
        effectiveStart = normalizedInstallation;
      } else {
        effectiveStart = monthStart;
      }
    } else {
      effectiveStart = monthStart;
    }

    // Calculate the number of days between effective start and month end
    return monthEnd.difference(effectiveStart).inDays + 1;
  }

  /// Check if a date is accessible based on installation date
  bool isDateAccessible(DateTime date) {
    final installationDate = _getInstallationDate();
    if (installationDate == null) return true;

    final normalizedDate = AppDateUtils.normalizeDate(date);
    final normalizedInstallation = AppDateUtils.normalizeDate(installationDate);

    return normalizedDate.isAtSameMomentAs(normalizedInstallation) ||
           normalizedDate.isAfter(normalizedInstallation);
  }

  /// Get the installation date from SharedPreferences
  DateTime? _getInstallationDate() {
    if (_prefs == null) return null;

    final dateString = _prefs!.getString(AppConstants.keyInstallationDate);
    if (dateString == null) return null;

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get valid start date for queries (respects installation date)
  DateTime _getValidStartDate(DateTime requestedStart) {
    final installationDate = _getInstallationDate();
    if (installationDate == null) return requestedStart;

    final normalizedInstallation = AppDateUtils.normalizeDate(installationDate);
    final normalizedRequested = AppDateUtils.normalizeDate(requestedStart);

    if (normalizedRequested.isBefore(normalizedInstallation)) {
      return normalizedInstallation;
    }

    return normalizedRequested;
  }

  /// Get accessible date range
  DateRange getAccessibleDateRange() {
    final installationDate = _getInstallationDate();
    final today = AppDateUtils.normalizeDate(DateTime.now());

    if (installationDate == null) {
      return DateRange(start: today, end: today);
    }

    final normalizedInstallation = AppDateUtils.normalizeDate(installationDate);
    return DateRange(start: normalizedInstallation, end: today);
  }

  /// Auto-mark prayer as missed
  Future<void> autoMarkPrayerAsMissed({
    required DateTime date,
    required Prayer prayer,
    required DateTime scheduledTime,
  }) async {
    // Only mark as missed if not already logged
    final existingLog = getPrayerLog(date, prayer);
    if (existingLog != null) return;

    // Only mark if date is accessible
    if (!isDateAccessible(date)) return;

    await logPrayer(
      date: date,
      prayer: prayer,
      status: PrayerStatus.missed,
      scheduledTime: scheduledTime,
    );
  }

  /// Batch auto-mark multiple prayers as missed
  Future<void> batchAutoMarkPrayersAsMissed(
    List<AutoMissedPrayerData> prayersData,
  ) async {
    for (final data in prayersData) {
      await autoMarkPrayerAsMissed(
        date: data.date,
        prayer: data.prayer,
        scheduledTime: data.scheduledTime,
      );
    }
  }

  /// Generate storage key
  String _generateKey(DateTime date, Prayer prayer) {
    return AppDateUtils.generateStorageKey(date, prayer.name);
  }
}

/// Monthly statistics model
class MonthlyStats {
  final int year;
  final int month;
  final int jamaahCount;
  final int adahCount;
  final int qalahCount;
  final int missedCount;
  final int totalCompleted;
  final int totalPrayers;

  const MonthlyStats({
    required this.year,
    required this.month,
    required this.jamaahCount,
    required this.adahCount,
    required this.qalahCount,
    required this.missedCount,
    required this.totalCompleted,
    required this.totalPrayers,
  });

  double get completionPercentage =>
      totalPrayers > 0 ? (totalCompleted / totalPrayers) * 100 : 0;

  double get jamaahPercentage =>
      totalPrayers > 0 ? (jamaahCount / totalPrayers) * 100 : 0;

  double get adahPercentage =>
      totalPrayers > 0 ? (adahCount / totalPrayers) * 100 : 0;

  double get qalahPercentage =>
      totalPrayers > 0 ? (qalahCount / totalPrayers) * 100 : 0;

  double get missedPercentage =>
      totalPrayers > 0 ? (missedCount / totalPrayers) * 100 : 0;
}

/// Per-prayer statistics model
class PrayerStats {
  final Prayer prayer;
  final int completed;
  final int total;
  final int jamaahCount;
  final int adahCount;
  final int qalahCount;
  final int missedCount;

  const PrayerStats({
    required this.prayer,
    required this.completed,
    required this.total,
    required this.jamaahCount,
    required this.adahCount,
    required this.qalahCount,
    required this.missedCount,
  });

  double get completionPercentage =>
      total > 0 ? (completed / total) * 100 : 0;

  int get starRating {
    final percentage = completionPercentage;
    if (percentage >= 90) return 5;
    if (percentage >= 75) return 4;
    if (percentage >= 60) return 3;
    if (percentage >= 40) return 2;
    return 1;
  }
}

/// Data model for auto-missed prayer information
class AutoMissedPrayerData {
  final DateTime date;
  final Prayer prayer;
  final DateTime scheduledTime;

  const AutoMissedPrayerData({
    required this.date,
    required this.prayer,
    required this.scheduledTime,
  });
}

/// Date range model for repository
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  bool contains(DateTime date) {
    final normalizedDate = AppDateUtils.normalizeDate(date);
    return (normalizedDate.isAtSameMomentAs(start) || normalizedDate.isAfter(start)) &&
           (normalizedDate.isAtSameMomentAs(end) || normalizedDate.isBefore(end.add(const Duration(days: 1))));
  }
}
