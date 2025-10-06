import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../prayers/models/prayer_log.dart';

// Selected date provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Selected month provider
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Logs for selected month provider
final monthLogsProvider = Provider<List<PrayerLog>>((ref) {
  final selectedMonth = ref.watch(selectedMonthProvider);
  final repository = ref.watch(prayerRepositoryProvider);

  return repository.getLogsForMonth(
    selectedMonth.year,
    selectedMonth.month,
  );
});

// Logs for selected date provider
final selectedDateLogsProvider = Provider<Map<dynamic, dynamic>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final repository = ref.watch(prayerRepositoryProvider);

  return repository.getLogsForDate(selectedDate);
});
