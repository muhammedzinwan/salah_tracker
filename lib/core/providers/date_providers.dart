import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../../features/prayers/models/prayer_status.dart';
import 'app_providers.dart';

/// Installation date provider
final installationDateProvider = FutureProvider<DateTime?>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  final dateString = prefs.getString(AppConstants.keyInstallationDate);

  if (dateString == null) return null;

  try {
    return DateTime.parse(dateString);
  } catch (e) {
    return null;
  }
});

/// Current app date provider with Islamic-compliant day transition logic
final currentAppDateProvider = StreamProvider<DateTime>((ref) {
  final controller = StreamController<DateTime>();
  Timer? timer;

  // Start with current date
  DateTime currentAppDate = _normalizeDate(DateTime.now());
  controller.add(currentAppDate);

  // Check every minute for day transitions
  timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
    final now = DateTime.now();
    final normalizedNow = _normalizeDate(now);

    // If we're already on the current calendar date, no transition needed
    if (currentAppDate.isAtSameMomentAs(normalizedNow)) {
      return;
    }

    // Check if we should transition to the new day
    final shouldTransition = await _shouldTransitionToNewDay(ref, now);

    if (shouldTransition) {
      currentAppDate = normalizedNow;
      controller.add(currentAppDate);
    }
  });

  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });

  return controller.stream;
});

/// Determines if the app should transition to a new day based on Islamic logic
Future<bool> _shouldTransitionToNewDay(Ref ref, DateTime now) async {
  try {
    final repository = ref.read(prayerRepositoryProvider);

    // Get yesterday's date (the date we might be transitioning from)
    final yesterday = _normalizeDate(now.subtract(const Duration(days: 1)));

    // If it's past the forced transition time (4 AM), always transition
    if (now.hour >= AppConstants.forcedTransitionHour) {
      // Before transitioning, mark any incomplete prayers from yesterday as missed
      await _markYesterdayIncompletePrayers(ref, yesterday);
      return true;
    }

    // If it's past midnight (00:00) but before forced transition (4 AM)
    if (now.hour >= AppConstants.dayTransitionHour &&
        now.hour < AppConstants.forcedTransitionHour) {

      // Check if all prayers from yesterday are completed
      final yesterdayLogs = repository.getLogsForDate(yesterday);

      // Count completed prayers (exclude null and missed statuses)
      final completedPrayers = yesterdayLogs.values
          .where((log) => log != null &&
                         log.status != PrayerStatus.notPerformed &&
                         log.status != PrayerStatus.missed,)
          .length;

      // If all 5 prayers are completed, transition immediately
      if (completedPrayers == AppConstants.totalPrayersPerDay) {
        return true;
      }

      // If prayers are incomplete, hold the transition
      return false;
    }

    // Before midnight, don't transition
    return false;
  } catch (e) {
    // On error, default to transitioning after forced time
    return now.hour >= AppConstants.forcedTransitionHour;
  }
}

/// Marks yesterday's incomplete prayers as missed during forced transition
Future<void> _markYesterdayIncompletePrayers(Ref ref, DateTime yesterday) async {
  try {
    final repository = ref.read(prayerRepositoryProvider);
    final prayerTimeService = ref.read(prayerTimeServiceProvider);
    final locationService = ref.read(locationServiceProvider);

    final location = locationService.getSavedOrDefaultLocation();
    final yesterdayLogs = repository.getLogsForDate(yesterday);

    // Get prayer times for yesterday
    final prayerTimes = await prayerTimeService.calculatePrayerTimes(
      latitude: location.latitude,
      longitude: location.longitude,
      date: yesterday,
    );

    // Mark each unlogged prayer as missed
    for (final prayer in yesterdayLogs.keys) {
      if (yesterdayLogs[prayer] == null) {
        final scheduledTime = prayerTimes[prayer];
        if (scheduledTime != null) {
          await repository.autoMarkPrayerAsMissed(
            date: yesterday,
            prayer: prayer,
            scheduledTime: scheduledTime,
          );
        }
      }
    }
  } catch (e) {
    // Silently handle errors to prevent blocking day transition
  }
}

/// Validates if a date is accessible based on installation date
final dateAccessibilityProvider = Provider.family<Future<bool>, DateTime>((ref, date) async {
  final installationDateAsync = ref.watch(installationDateProvider);

  return installationDateAsync.when(
    data: (installationDate) {
      if (installationDate == null) return true; // Allow access if no installation date

      final normalizedDate = _normalizeDate(date);
      final normalizedInstallation = _normalizeDate(installationDate);

      // Allow access if date is on or after installation date
      return normalizedDate.isAtSameMomentAs(normalizedInstallation) ||
             normalizedDate.isAfter(normalizedInstallation);
    },
    loading: () => true, // Allow access while loading
    error: (_, __) => true, // Allow access on error
  );
});

/// Helper function to normalize date to beginning of day
DateTime _normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

/// Provider for today's normalized date (respects app date logic)
final todayDateProvider = Provider<DateTime>((ref) {
  final appDateAsync = ref.watch(currentAppDateProvider);

  return appDateAsync.when(
    data: (appDate) => appDate,
    loading: () => _normalizeDate(DateTime.now()),
    error: (_, __) => _normalizeDate(DateTime.now()),
  );
});

/// Provider to check if current time is in "grace period" (after midnight but before forced transition)
final isInGracePeriodProvider = Provider<bool>((ref) {
  final now = DateTime.now();
  return now.hour >= AppConstants.dayTransitionHour &&
         now.hour < AppConstants.forcedTransitionHour;
});

/// Provider for accessible date range
final accessibleDateRangeProvider = FutureProvider<DateRange>((ref) async {
  final installationDateAsync = ref.watch(installationDateProvider);
  final currentDate = ref.watch(todayDateProvider);

  return installationDateAsync.when(
    data: (installationDate) {
      final startDate = installationDate ?? currentDate;
      return DateRange(
        start: _normalizeDate(startDate),
        end: currentDate,
      );
    },
    loading: () => DateRange(start: currentDate, end: currentDate),
    error: (_, __) => DateRange(start: currentDate, end: currentDate),
  );
});

/// Date range model
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  bool contains(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    return (normalizedDate.isAtSameMomentAs(start) || normalizedDate.isAfter(start)) &&
           (normalizedDate.isAtSameMomentAs(end) || normalizedDate.isBefore(end.add(const Duration(days: 1))));
  }
}