import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../prayers/repositories/prayer_repository.dart';

// Selected stats month provider
final selectedStatsMonthProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

// Monthly stats provider - Now reactive to Hive changes
final selectedMonthStatsProvider = StreamProvider<MonthlyStats>((ref) {
  final box = ref.watch(prayerLogsBoxProvider);
  final repository = ref.watch(prayerRepositoryProvider);
  final selectedMonth = ref.watch(selectedStatsMonthProvider);

  // Create a stream that emits whenever the Hive box changes
  final controller = StreamController<MonthlyStats>();

  // Initial value
  controller.add(
    repository.getMonthlyStats(
      selectedMonth.year,
      selectedMonth.month,
    ),
  );

  // Listen to box changes
  final subscription = box.watch().listen((_) {
    final currentMonth = ref.read(selectedStatsMonthProvider);
    controller.add(
      repository.getMonthlyStats(
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

// Prayer-wise stats provider - Now reactive to Hive changes
final prayerWiseStatsProvider = StreamProvider<Map<dynamic, PrayerStats>>((ref) {
  final box = ref.watch(prayerLogsBoxProvider);
  final repository = ref.watch(prayerRepositoryProvider);
  final selectedMonth = ref.watch(selectedStatsMonthProvider);

  // Create a stream that emits whenever the Hive box changes
  final controller = StreamController<Map<dynamic, PrayerStats>>();

  // Initial value
  controller.add(
    repository.getPrayerWiseStats(
      selectedMonth.year,
      selectedMonth.month,
    ),
  );

  // Listen to box changes
  final subscription = box.watch().listen((_) {
    final currentMonth = ref.read(selectedStatsMonthProvider);
    controller.add(
      repository.getPrayerWiseStats(
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
