import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/prayer.dart';
import '../models/prayer_status.dart';
import '../models/prayer_log.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/constants/app_constants.dart';

class PrayerRepository {
  final Box<PrayerLog> _logsBox;
  final Uuid _uuid = const Uuid();

  PrayerRepository(this._logsBox);

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

  /// Get logs for a date range
  List<PrayerLog> getLogsForDateRange(DateTime start, DateTime end) {
    final normalizedStart = AppDateUtils.normalizeDate(start);
    final normalizedEnd = AppDateUtils.normalizeDate(end);

    return _logsBox.values.where((log) {
      final logDate = log.date;
      return (logDate.isAtSameMomentAs(normalizedStart) ||
              logDate.isAfter(normalizedStart)) &&
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

  /// Get statistics for a month
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
          missedCount++;
          break;
      }
    }

    final totalCompleted = jamaahCount + adahCount + qalahCount;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final totalPrayersInMonth = daysInMonth * AppConstants.totalPrayersPerDay;

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

  /// Get prayer-wise breakdown for a month
  Map<Prayer, PrayerStats> getPrayerWiseStats(int year, int month) {
    final logs = getLogsForMonth(year, month);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final stats = <Prayer, PrayerStats>{};

    for (final prayer in Prayer.values) {
      final prayerLogs = logs.where((log) => log.prayer == prayer);

      int completed = 0;
      int jamaah = 0;
      int adah = 0;
      int qalah = 0;
      int missed = 0;

      for (final log in prayerLogs) {
        if (log.status != PrayerStatus.notPerformed) {
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
            missed++;
            break;
        }
      }

      stats[prayer] = PrayerStats(
        prayer: prayer,
        completed: completed,
        total: daysInMonth,
        jamaahCount: jamaah,
        adahCount: adah,
        qalahCount: qalah,
        missedCount: missed,
      );
    }

    return stats;
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
