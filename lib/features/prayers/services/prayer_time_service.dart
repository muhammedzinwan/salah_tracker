import 'package:adhan/adhan.dart';
import '../models/prayer.dart' as app_prayer;
import '../models/prayer_time.dart';
import '../models/prayer_status.dart';

class PrayerTimeService {
  /// Calculate prayer times for a given location and date
  Future<Map<app_prayer.Prayer, DateTime>> calculatePrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    try {
      // Create coordinates
      final coordinates = Coordinates(latitude, longitude);

      // Use Muslim World League calculation method
      final params = CalculationMethod.muslim_world_league.getParameters();

      // Calculate prayer times for the given date
      final prayerTimes = PrayerTimes(
        coordinates,
        DateComponents.from(date),
        params,
      );

      return {
        app_prayer.Prayer.fajr: prayerTimes.fajr.toLocal(),
        app_prayer.Prayer.dhuhr: prayerTimes.dhuhr.toLocal(),
        app_prayer.Prayer.asr: prayerTimes.asr.toLocal(),
        app_prayer.Prayer.maghrib: prayerTimes.maghrib.toLocal(),
        app_prayer.Prayer.isha: prayerTimes.isha.toLocal(),
      };
    } catch (e) {
      // If calculation fails, return default times for today
      return _getDefaultTimes(date);
    }
  }

  /// Get today's prayer times
  Future<Map<app_prayer.Prayer, DateTime>> getTodayPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    return calculatePrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: DateTime.now(),
    );
  }

  /// Get prayer times as PrayerTime objects
  Future<List<PrayerTime>> getPrayerTimesList({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    final times = await calculatePrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );

    return app_prayer.Prayer.values.map((prayer) {
      return PrayerTime(
        prayer: prayer,
        time: times[prayer]!,
      );
    }).toList();
  }

  /// Get next upcoming prayer
  PrayerTime? getNextPrayer(List<PrayerTime> prayerTimes) {
    final now = DateTime.now();

    for (final prayerTime in prayerTimes) {
      if (prayerTime.time.isAfter(now)) {
        return prayerTime;
      }
    }

    return null; // All prayers for today have passed
  }

  /// Get current prayer (the one that should be prayed now)
  PrayerTime? getCurrentPrayer(List<PrayerTime> prayerTimes) {
    final now = DateTime.now();
    PrayerTime? current;

    for (final prayerTime in prayerTimes) {
      if (prayerTime.time.isBefore(now)) {
        current = prayerTime;
      } else {
        break;
      }
    }

    return current;
  }

  /// Check if a prayer time has passed
  bool hasPrayerTimePassed(DateTime prayerTime) {
    return DateTime.now().isAfter(prayerTime);
  }

  /// Get time until next prayer in minutes
  int getMinutesUntilPrayer(DateTime prayerTime) {
    final now = DateTime.now();
    final difference = prayerTime.difference(now);
    return difference.inMinutes;
  }

  /// Default fallback times (based on typical times)
  Map<app_prayer.Prayer, DateTime> _getDefaultTimes(DateTime date) {
    final today = DateTime(date.year, date.month, date.day);

    return {
      app_prayer.Prayer.fajr: today.add(const Duration(hours: 5, minutes: 30)),
      app_prayer.Prayer.dhuhr: today.add(const Duration(hours: 12, minutes: 30)),
      app_prayer.Prayer.asr: today.add(const Duration(hours: 15, minutes: 45)),
      app_prayer.Prayer.maghrib: today.add(const Duration(hours: 18, minutes: 15)),
      app_prayer.Prayer.isha: today.add(const Duration(hours: 19, minutes: 30)),
    };
  }

  /// Get time remaining as a formatted string
  String getTimeRemaining(DateTime prayerTime) {
    final now = DateTime.now();
    final difference = prayerTime.difference(now);

    if (difference.isNegative) {
      return 'Passed';
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hr $minutes min';
    } else {
      return '$minutes min';
    }
  }

  /// Calculate cutoff times for each prayer (when they should be automatically marked as missed)
  Future<Map<app_prayer.Prayer, DateTime>> calculatePrayerCutoffTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    final prayerTimes = await calculatePrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );

    // Calculate sunrise time for Fajr cutoff
    final coordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.muslim_world_league.getParameters();
    final prayerTimesObj = PrayerTimes(
      coordinates,
      DateComponents.from(date),
      params,
    );

    // Isha cutoff is set to 4 AM (forced transition time) of the next day
    // This ensures Isha is marked as missed before the day transitions
    final nextDay = date.add(const Duration(days: 1));
    final ishaCutoff = DateTime(nextDay.year, nextDay.month, nextDay.day, 4, 0);

    return {
      // Fajr ends at sunrise
      app_prayer.Prayer.fajr: prayerTimesObj.sunrise.toLocal(),
      // Dhuhr ends at Asr time
      app_prayer.Prayer.dhuhr: prayerTimes[app_prayer.Prayer.asr]!,
      // Asr ends at Maghrib time
      app_prayer.Prayer.asr: prayerTimes[app_prayer.Prayer.maghrib]!,
      // Maghrib ends at Isha time
      app_prayer.Prayer.maghrib: prayerTimes[app_prayer.Prayer.isha]!,
      // Isha ends at 4 AM next day (forced transition time)
      app_prayer.Prayer.isha: ishaCutoff,
    };
  }

  /// Check if a prayer should be automatically marked as missed
  Future<bool> shouldBeMarkedAsMissed({
    required app_prayer.Prayer prayer,
    required double latitude,
    required double longitude,
    required DateTime prayerDate,
    PrayerStatus? currentStatus,
  }) async {
    // If already logged (any status), don't mark as missed
    if (currentStatus != null) {
      return false;
    }

    final cutoffTimes = await calculatePrayerCutoffTimes(
      latitude: latitude,
      longitude: longitude,
      date: prayerDate,
    );

    final cutoffTime = cutoffTimes[prayer];
    if (cutoffTime == null) return false;

    // Check if current time is past the cutoff time
    return DateTime.now().isAfter(cutoffTime);
  }

  /// Get all prayers that should be marked as missed for a given date
  Future<List<app_prayer.Prayer>> getPrayersToMarkAsMissed({
    required double latitude,
    required double longitude,
    required DateTime date,
    required Map<app_prayer.Prayer, PrayerStatus?> currentStatuses,
  }) async {
    final prayersToMark = <app_prayer.Prayer>[];

    for (final prayer in app_prayer.Prayer.values) {
      final shouldMark = await shouldBeMarkedAsMissed(
        prayer: prayer,
        latitude: latitude,
        longitude: longitude,
        prayerDate: date,
        currentStatus: currentStatuses[prayer],
      );

      if (shouldMark) {
        prayersToMark.add(prayer);
      }
    }

    return prayersToMark;
  }

  /// Get the next prayer cutoff time
  Future<DateTime?> getNextCutoffTime({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    final cutoffTimes = await calculatePrayerCutoffTimes(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );

    final now = DateTime.now();
    DateTime? nextCutoff;

    for (final cutoffTime in cutoffTimes.values) {
      if (cutoffTime.isAfter(now)) {
        if (nextCutoff == null || cutoffTime.isBefore(nextCutoff)) {
          nextCutoff = cutoffTime;
        }
      }
    }

    return nextCutoff;
  }

  /// Check if we're currently in a prayer's valid time window
  Future<bool> isInValidPrayerWindow({
    required app_prayer.Prayer prayer,
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    final prayerTimes = await calculatePrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );

    final cutoffTimes = await calculatePrayerCutoffTimes(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );

    final prayerTime = prayerTimes[prayer];
    final cutoffTime = cutoffTimes[prayer];

    if (prayerTime == null || cutoffTime == null) return false;

    final now = DateTime.now();
    return now.isAfter(prayerTime) && now.isBefore(cutoffTime);
  }
}
