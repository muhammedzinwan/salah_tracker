import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/date_utils.dart';
import '../providers/home_providers.dart';
import '../../../features/prayers/models/prayer_status.dart';

class MonthlyStatsCard extends ConsumerWidget {
  const MonthlyStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(monthlyStatsProvider);
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THIS MONTH (${AppDateUtils.formatMonthName(now).toUpperCase()})',
          style: AppTheme.subhead.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        statsAsync.when(
          data: (stats) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _StatRow(
                icon: CupertinoIcons.checkmark_circle_fill,
                label: 'Jamaah',
                count: stats.jamaahCount,
                total: stats.totalPrayers,
                percentage: stats.jamaahPercentage,
                color: PrayerStatus.jamaah.color,
              ),
              const SizedBox(height: 12),
              _StatRow(
                icon: CupertinoIcons.checkmark_circle,
                label: 'Adah',
                count: stats.adahCount,
                total: stats.totalPrayers,
                percentage: stats.adahPercentage,
                color: PrayerStatus.adah.color,
              ),
              const SizedBox(height: 12),
              _StatRow(
                icon: CupertinoIcons.time,
                label: 'Qalah',
                count: stats.qalahCount,
                total: stats.totalPrayers,
                percentage: stats.qalahPercentage,
                color: PrayerStatus.qalah.color,
              ),
              const SizedBox(height: 12),
              _StatRow(
                icon: CupertinoIcons.xmark_circle,
                label: 'Missed',
                count: stats.missedCount,
                total: stats.totalPrayers,
                percentage: stats.missedPercentage,
                color: PrayerStatus.notPerformed.color,
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: AppColors.tertiaryBackground),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Completed',
                    style: AppTheme.headline,
                  ),
                  Text(
                    '${stats.totalCompleted}/${stats.totalPrayers}',
                    style: AppTheme.title3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Error loading stats',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final int total;
  final double percentage;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.total,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(width: 12),
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
          '($count/$total)',
          style: AppTheme.footnote,
        ),
      ],
    );
  }
}
