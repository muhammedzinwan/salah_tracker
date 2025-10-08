import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../prayers/models/prayer_log.dart';
import '../../prayers/models/prayer.dart';

// Selected date provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Selected month provider
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Logs for selected month provider - Now reactive to Hive changes
final monthLogsProvider = StreamProvider<List<PrayerLog>>((ref) {
  final box = ref.watch(prayerLogsBoxProvider);
  final repository = ref.watch(prayerRepositoryProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);

  // Create a stream that emits whenever the Hive box changes
  final controller = StreamController<List<PrayerLog>>();

  // Initial value
  controller.add(
    repository.getLogsForMonth(
      selectedMonth.year,
      selectedMonth.month,
    ),
  );

  // Listen to box changes
  final subscription = box.watch().listen((_) {
    final currentMonth = ref.read(selectedMonthProvider);
    controller.add(
      repository.getLogsForMonth(
        currentMonth.year,
        currentMonth.month,
      ),
    );
  });

  // Cleanup when provider is disposed
  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

// Logs for selected date provider - Now reactive to Hive changes
final selectedDateLogsProvider = StreamProvider<Map<Prayer, dynamic>>((ref) {
  final box = ref.watch(prayerLogsBoxProvider);
  final repository = ref.watch(prayerRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  // Create a stream that emits whenever the Hive box changes
  final controller = StreamController<Map<Prayer, dynamic>>();

  // Initial value
  controller.add(repository.getLogsForDate(selectedDate));

  // Listen to box changes
  final subscription = box.watch().listen((_) {
    final currentDate = ref.read(selectedDateProvider);
    controller.add(repository.getLogsForDate(currentDate));
  });

  // Cleanup when provider is disposed
  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

// Prayer times for selected date provider
final selectedDatePrayerTimesProvider = FutureProvider<Map<Prayer, DateTime>>((ref) async {
  final selectedDate = ref.watch(selectedDateProvider);
  final locationService = ref.watch(locationServiceProvider);
  final prayerTimeService = ref.watch(prayerTimeServiceProvider);

  final location = locationService.getSavedOrDefaultLocation();

  return await prayerTimeService.calculatePrayerTimes(
    latitude: location.latitude,
    longitude: location.longitude,
    date: selectedDate,
  );
});
