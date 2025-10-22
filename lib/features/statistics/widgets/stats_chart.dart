import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/colors.dart';
import '../../../features/prayers/models/prayer_status.dart';
import '../providers/stats_providers.dart';

class StatsChart extends ConsumerWidget {
  const StatsChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(selectedMonthStatsProvider);

    return statsAsync.when(
      data: (stats) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BREAKDOWN BY TYPE',
            style: AppTheme.headline,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: stats.totalPrayers.toDouble() * 1.1,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const labels = ['Jamaah', 'Adah', 'Qalah', 'Missed'];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  labels[value.toInt()],
                                  style: AppTheme.caption1,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: [
                        _makeBarGroup(
                          0,
                          stats.jamaahCount.toDouble(),
                          PrayerStatus.jamaah.color,
                        ),
                        _makeBarGroup(
                          1,
                          stats.adahCount.toDouble(),
                          PrayerStatus.adah.color,
                        ),
                        _makeBarGroup(
                          2,
                          stats.qalahCount.toDouble(),
                          PrayerStatus.qalah.color,
                        ),
                        _makeBarGroup(
                          3,
                          stats.missedCount.toDouble(),
                          PrayerStatus.notPerformed.color,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLegend(stats),
              ],
            ),
          ),
        ],
      ),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CupertinoActivityIndicator(),
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Error loading chart',
          style: TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 40,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _buildLegend(dynamic stats) {
    return Column(
      children: [
        _LegendItem(
          color: PrayerStatus.jamaah.color,
          label: 'Jamaah',
          value: stats.jamaahCount,
          percentage: stats.jamaahPercentage,
        ),
        const SizedBox(height: 8),
        _LegendItem(
          color: PrayerStatus.adah.color,
          label: 'Adah',
          value: stats.adahCount,
          percentage: stats.adahPercentage,
        ),
        const SizedBox(height: 8),
        _LegendItem(
          color: PrayerStatus.qalah.color,
          label: 'Qalah',
          value: stats.qalahCount,
          percentage: stats.qalahPercentage,
        ),
        const SizedBox(height: 8),
        _LegendItem(
          color: PrayerStatus.notPerformed.color,
          label: 'Missed',
          value: stats.missedCount,
          percentage: stats.missedPercentage,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  final double percentage;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTheme.body,
          ),
        ),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: AppTheme.headline.copyWith(color: color),
        ),
        const SizedBox(width: 8),
        Text(
          '($value)',
          style: AppTheme.footnote,
        ),
      ],
    );
  }
}
