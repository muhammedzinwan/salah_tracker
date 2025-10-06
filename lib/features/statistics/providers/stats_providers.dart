import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../prayers/repositories/prayer_repository.dart';

// Selected stats month provider
final selectedStatsMonthProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

// Monthly stats provider
final selectedMonthStatsProvider = Provider<MonthlyStats>((ref) {
  final selectedMonth = ref.watch(selectedStatsMonthProvider);
  final repository = ref.watch(prayerRepositoryProvider);

  return repository.getMonthlyStats(
    selectedMonth.year,
    selectedMonth.month,
  );
});

// Prayer-wise stats provider
final prayerWiseStatsProvider = Provider<Map<dynamic, PrayerStats>>((ref) {
  final selectedMonth = ref.watch(selectedStatsMonthProvider);
  final repository = ref.watch(prayerRepositoryProvider);

  return repository.getPrayerWiseStats(
    selectedMonth.year,
    selectedMonth.month,
  );
});
