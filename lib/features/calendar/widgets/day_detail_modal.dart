import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/date_utils.dart';
import '../providers/calendar_providers.dart';
import '../../prayers/models/prayer.dart';
import '../../prayers/models/prayer_status.dart';
import 'prayer_log_modal.dart';

class DayDetailModal extends ConsumerWidget {
  final DateTime date;

  const DayDetailModal({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(selectedDateLogsProvider);
    final prayerTimesAsync = ref.watch(selectedDatePrayerTimesProvider);

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
              child: logsAsync.when(
                data: (logs) => prayerTimesAsync.when(
                  data: (prayerTimes) => ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      for (final prayer in Prayer.values) ...[
                        _PrayerDetailRow(
                          prayer: prayer,
                          log: logs[prayer],
                          date: date,
                          scheduledTime: prayerTimes[prayer] ?? DateTime.now(),
                        ),
                        if (prayer != Prayer.values.last)
                          const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 20),
                      _buildSummary(logs),
                    ],
                  ),
                  loading: () => const Center(
                    child: CupertinoActivityIndicator(),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading prayer times',
                      style: AppTheme.subhead.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
                loading: () => const Center(
                  child: CupertinoActivityIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Error loading prayer logs',
                    style: AppTheme.subhead.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
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
  final DateTime date;
  final DateTime scheduledTime;

  const _PrayerDetailRow({
    required this.prayer,
    required this.log,
    required this.date,
    required this.scheduledTime,
  });

  @override
  Widget build(BuildContext context) {
    final isLogged = log != null;
    final status = isLogged ? log.status : null;

    // Only allow marking if prayer time has passed
    final now = DateTime.now();
    final hasPassed = scheduledTime.isBefore(now);
    final canMark = hasPassed;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: canMark ? () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) => PrayerLogModal(
            prayer: prayer,
            date: date,
            scheduledTime: scheduledTime,
            existingStatus: status,
          ),
        );
      } : null,
      child: Container(
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
              _getStatusIcon(isLogged, status),
              size: 32,
              color: isLogged
                ? status.color
                : (canMark ? AppColors.textTertiary : AppColors.textTertiary.withOpacity(0.3)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer.displayName,
                    style: AppTheme.headline.copyWith(
                      color: canMark ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
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
                      canMark ? 'Not logged' : 'Not yet time',
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
            else if (canMark)
              const Icon(
                CupertinoIcons.chevron_right,
                color: AppColors.textTertiary,
                size: 20,
              )
            else
              Icon(
                CupertinoIcons.clock,
                color: AppColors.textTertiary.withOpacity(0.3),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(bool isLogged, PrayerStatus? status) {
    if (isLogged && status != null) {
      switch (status) {
        case PrayerStatus.missed:
          return CupertinoIcons.exclamationmark_triangle_fill;
        case PrayerStatus.qalah:
          return CupertinoIcons.clock_fill;
        default:
          return CupertinoIcons.checkmark_circle_fill;
      }
    }
    return CupertinoIcons.circle;
  }
}
