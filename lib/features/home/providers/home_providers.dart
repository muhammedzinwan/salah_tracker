import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/date_providers.dart';
import '../../prayers/models/prayer.dart';
import '../../prayers/models/prayer_time.dart';
import '../../prayers/models/prayer_log.dart';
import '../../prayers/models/prayer_status.dart';
import '../../prayers/repositories/prayer_repository.dart';

// Current location provider
final currentLocationProvider = FutureProvider((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.getCurrentLocation();
});

// Today's prayer times provider (uses smart date logic)
final todayPrayerTimesProvider = FutureProvider((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  final prayerTimeService = ref.watch(prayerTimeServiceProvider);
  final appDate = ref.watch(todayDateProvider);

  final location = locationService.getSavedOrDefaultLocation();

  return await prayerTimeService.getPrayerTimesList(
    latitude: location.latitude,
    longitude: location.longitude,
    date: appDate,
  );
});

// Next prayer provider
final nextPrayerProvider = Provider<PrayerTime?>((ref) {
  final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);

  return prayerTimesAsync.when(
    data: (prayerTimes) {
      final now = DateTime.now();
      for (final prayerTime in prayerTimes) {
        if (prayerTime.time.isAfter(now)) {
          return prayerTime;
        }
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Current prayer provider
final currentPrayerProvider = Provider<PrayerTime?>((ref) {
  final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);

  return prayerTimesAsync.when(
    data: (prayerTimes) {
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
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Today's prayer logs provider - Now reactive to Hive changes and uses smart date
final todayPrayerLogsProvider = StreamProvider<Map<Prayer, PrayerLog?>>((ref) {
  final box = ref.watch(prayerLogsBoxProvider);
  final repository = ref.watch(prayerRepositoryProvider);
  final appDate = ref.watch(todayDateProvider);

  // Create a stream that emits whenever the Hive box changes
  final controller = StreamController<Map<Prayer, PrayerLog?>>();

  // Initial value
  controller.add(repository.getLogsForDate(appDate));

  // Listen to box changes
  final subscription = box.watch().listen((_) {
    final currentDate = ref.read(todayDateProvider);
    controller.add(repository.getLogsForDate(currentDate));
  });

  // Cleanup when provider is disposed
  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

// Monthly stats provider - Now reactive to Hive changes and uses smart date
final monthlyStatsProvider = StreamProvider<MonthlyStats>((ref) {
  final box = ref.watch(prayerLogsBoxProvider);
  final repository = ref.watch(prayerRepositoryProvider);
  final appDate = ref.watch(todayDateProvider);

  // Create a stream that emits whenever the Hive box changes
  final controller = StreamController<MonthlyStats>();

  // Initial value
  controller.add(repository.getMonthlyStats(appDate.year, appDate.month));

  // Listen to box changes
  final subscription = box.watch().listen((_) {
    final currentDate = ref.read(todayDateProvider);
    controller.add(repository.getMonthlyStats(currentDate.year, currentDate.month));
  });

  // Cleanup when provider is disposed
  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

// Timer provider for countdown updates
final countdownTimerProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

// Automatic missed prayer detection provider
final automaticMissedDetectionProvider = StreamProvider<void>((ref) {
  final controller = StreamController<void>();
  Timer? timer;

  // Check every 5 minutes for prayers that should be marked as missed
  timer = Timer.periodic(const Duration(minutes: 5), (_) async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final prayerTimeService = ref.read(prayerTimeServiceProvider);
      final repository = ref.read(prayerRepositoryProvider);
      final appDate = ref.read(todayDateProvider);

      final location = locationService.getSavedOrDefaultLocation();

      // Get current prayer statuses
      final currentLogs = repository.getLogsForDate(appDate);
      final currentStatuses = <Prayer, PrayerStatus?>{};

      for (final prayer in Prayer.values) {
        currentStatuses[prayer] = currentLogs[prayer]?.status;
      }

      // Get prayers that should be marked as missed
      final prayersToMark = await prayerTimeService.getPrayersToMarkAsMissed(
        latitude: location.latitude,
        longitude: location.longitude,
        date: appDate,
        currentStatuses: currentStatuses,
      );

      // Mark prayers as missed
      for (final prayer in prayersToMark) {
        final prayerTimes = await prayerTimeService.calculatePrayerTimes(
          latitude: location.latitude,
          longitude: location.longitude,
          date: appDate,
        );

        final scheduledTime = prayerTimes[prayer];
        if (scheduledTime != null) {
          await repository.logPrayer(
            date: appDate,
            prayer: prayer,
            status: PrayerStatus.missed,
            scheduledTime: scheduledTime,
          );
        }
      }

      if (prayersToMark.isNotEmpty) {
        controller.add(null); // Notify listeners
      }
    } catch (e) {
      // Silently handle errors in background task
    }
  });

  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });

  return controller.stream;
});

// Log prayer action
final logPrayerProvider =
    Provider.family<Future<void>, LogPrayerParams>((ref, params) async {
  final repository = ref.watch(prayerRepositoryProvider);

  await repository.logPrayer(
    date: params.date,
    prayer: params.prayer,
    status: params.status,
    scheduledTime: params.scheduledTime,
  );

  // Refresh providers
  ref.invalidate(todayPrayerLogsProvider);
  ref.invalidate(monthlyStatsProvider);
});

// Parameters for logging prayer
class LogPrayerParams {
  final DateTime date;
  final Prayer prayer;
  final PrayerStatus status;
  final DateTime scheduledTime;

  const LogPrayerParams({
    required this.date,
    required this.prayer,
    required this.status,
    required this.scheduledTime,
  });
}
