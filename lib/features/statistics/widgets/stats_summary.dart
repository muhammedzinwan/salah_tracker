import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/colors.dart';
import '../providers/stats_providers.dart';

class StatsSummary extends ConsumerWidget {
  const StatsSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(selectedMonthStatsProvider);

    return statsAsync.when(
      data: (stats) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OVERALL PERFORMANCE',
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
                _SummaryRow(
                  label: 'Total Prayers',
                  value: '${stats.totalPrayers}',
                  subtitle: '5 prayers × ${stats.totalPrayers ~/ 5} days',
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.tertiaryBackground),
                const SizedBox(height: 12),
                _SummaryRow(
                  label: 'Completed',
                  value: '${stats.totalCompleted}',
                  subtitle: '${stats.completionPercentage.toStringAsFixed(1)}%',
                  valueColor: AppColors.success,
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  label: 'Missed',
                  value: '${stats.missedCount}',
                  subtitle: '${stats.missedPercentage.toStringAsFixed(1)}%',
                  valueColor: AppColors.error,
                ),
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
          'Error loading statistics',
          style: TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.subtitle,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.headline,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTheme.footnote,
            ),
          ],
        ),
        Text(
          value,
          style: AppTheme.title1.copyWith(
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
