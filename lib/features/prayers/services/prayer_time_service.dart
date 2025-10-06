import 'package:adhan/adhan.dart';
import '../models/prayer.dart' as app_prayer;
import '../models/prayer_time.dart';

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
}
