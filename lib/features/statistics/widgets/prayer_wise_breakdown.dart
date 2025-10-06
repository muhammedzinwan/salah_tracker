import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/colors.dart';
import '../../../features/prayers/models/prayer.dart';
import '../providers/stats_providers.dart';

class PrayerWiseBreakdown extends ConsumerWidget {
  const PrayerWiseBreakdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerStats = ref.watch(prayerWiseStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PRAYER-WISE BREAKDOWN',
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
              for (var i = 0; i < Prayer.values.length; i++) ...[
                _PrayerStatRow(
                  prayer: Prayer.values[i],
                  stats: prayerStats[Prayer.values[i]]!,
                ),
                if (i < Prayer.values.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      height: 1,
                      color: AppColors.tertiaryBackground,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PrayerStatRow extends StatelessWidget {
  final Prayer prayer;
  final dynamic stats;

  const _PrayerStatRow({
    required this.prayer,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prayer.displayName,
                style: AppTheme.headline,
              ),
              const SizedBox(height: 4),
              Text(
                '${stats.completed}/${stats.total} completed',
                style: AppTheme.footnote,
              ),
            ],
          ),
        ),
        Text(
          _getStarRating(stats.starRating),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 8),
        Text(
          '${stats.completionPercentage.toStringAsFixed(0)}%',
          style: AppTheme.headline.copyWith(
            color: _getPercentageColor(stats.completionPercentage),
          ),
        ),
      ],
    );
  }

  String _getStarRating(int rating) {
    const star = '⭐';
    const emptyStar = '☆';
    return (star * rating) + (emptyStar * (5 - rating));
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 75) return AppColors.primary;
    if (percentage >= 60) return AppColors.warning;
    return AppColors.error;
  }
}
