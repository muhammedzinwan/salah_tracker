import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
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

// Today's prayer times provider
final todayPrayerTimesProvider = FutureProvider((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  final prayerTimeService = ref.watch(prayerTimeServiceProvider);

  final location = locationService.getSavedOrDefaultLocation();

  return await prayerTimeService.getPrayerTimesList(
    latitude: location.latitude,
    longitude: location.longitude,
    date: DateTime.now(),
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

// Today's prayer logs provider - Now reactive to Hive changes
final todayPrayerLogsProvider = StreamProvider<Map<Prayer, PrayerLog?>>((ref) {
  final box = ref.watch(prayerLogsBoxProvider);
  final repository = ref.watch(prayerRepositoryProvider);

  // Create a stream that emits whenever the Hive box changes
  final controller = StreamController<Map<Prayer, PrayerLog?>>();

  // Initial value
  controller.add(repository.getLogsForDate(DateTime.now()));

  // Listen to box changes
  final subscription = box.watch().listen((_) {
    controller.add(repository.getLogsForDate(DateTime.now()));
  });

  // Cleanup when provider is disposed
  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

// Monthly stats provider - Now reactive to Hive changes
final monthlyStatsProvider = StreamProvider<MonthlyStats>((ref) {
  final box = ref.watch(prayerLogsBoxProvider);
  final repository = ref.watch(prayerRepositoryProvider);

  // Create a stream that emits whenever the Hive box changes
  final controller = StreamController<MonthlyStats>();
  final now = DateTime.now();

  // Initial value
  controller.add(repository.getMonthlyStats(now.year, now.month));

  // Listen to box changes
  final subscription = box.watch().listen((_) {
    final currentTime = DateTime.now();
    controller.add(repository.getMonthlyStats(currentTime.year, currentTime.month));
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
