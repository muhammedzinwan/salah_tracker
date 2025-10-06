import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/providers/app_providers.dart';
import '../../prayers/models/prayer.dart';
import '../../prayers/models/prayer_status.dart';

class DayDetailModal extends ConsumerWidget {
  final DateTime date;

  const DayDetailModal({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(prayerRepositoryProvider);
    final logs = repository.getLogsForDate(date);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 16),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    AppDateUtils.formatDayName(date),
                    style: AppTheme.headline.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppDateUtils.formatDate(date),
                    style: AppTheme.title1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: AppColors.tertiaryBackground),
            // Prayers list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  for (final prayer in Prayer.values) ...[
                    _PrayerDetailRow(
                      prayer: prayer,
                      log: logs[prayer],
                    ),
                    if (prayer != Prayer.values.last)
                      const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 20),
                  _buildSummary(logs),
                ],
              ),
            ),
            // Close button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(Map<Prayer, dynamic> logs) {
    int completed = 0;
    for (final log in logs.values) {
      if (log != null && log.status != PrayerStatus.notPerformed) {
        completed++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.chart_bar_circle_fill,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Summary: $completed/5 prayers completed',
            style: AppTheme.headline,
          ),
        ],
      ),
    );
  }
}

class _PrayerDetailRow extends StatelessWidget {
  final Prayer prayer;
  final dynamic log;

  const _PrayerDetailRow({
    required this.prayer,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    final isLogged = log != null;
    final status = isLogged ? log.status : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: isLogged
            ? Border.all(color: status.color.withOpacity(0.3), width: 2)
            : null,
      ),
      child: Row(
        children: [
          Icon(
            isLogged
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.circle,
            size: 32,
            color: isLogged ? status.color : AppColors.textTertiary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayer.displayName,
                  style: AppTheme.headline,
                ),
                if (isLogged) ...[
                  const SizedBox(height: 4),
                  Text(
                    status.displayName,
                    style: AppTheme.subhead.copyWith(
                      color: status.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Text(
                    'Not logged',
                    style: AppTheme.subhead.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isLogged)
            Icon(
              CupertinoIcons.check_mark,
              color: status.color,
              size: 24,
            )
          else
            const Icon(
              CupertinoIcons.xmark,
              color: AppColors.textTertiary,
              size: 24,
            ),
        ],
      ),
    );
  }
}
