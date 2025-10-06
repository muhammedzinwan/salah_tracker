import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/date_utils.dart';
import '../providers/stats_providers.dart';
import '../widgets/stats_summary.dart';
import '../widgets/stats_chart.dart';
import '../widgets/prayer_wise_breakdown.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedStatsMonthProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          AppDateUtils.formatMonthYear(selectedMonth),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.secondaryBackground,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.chevron_left),
          onPressed: () {
            final newMonth = DateTime(
              selectedMonth.year,
              selectedMonth.month - 1,
            );
            ref.read(selectedStatsMonthProvider.notifier).state = newMonth;
          },
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.chevron_right),
          onPressed: () {
            final now = DateTime.now();
            if (selectedMonth.year < now.year ||
                selectedMonth.month < now.month) {
              final newMonth = DateTime(
                selectedMonth.year,
                selectedMonth.month + 1,
              );
              ref.read(selectedStatsMonthProvider.notifier).state = newMonth;
            }
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            StatsSummary(),
            SizedBox(height: 24),
            StatsChart(),
            SizedBox(height: 24),
            PrayerWiseBreakdown(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
