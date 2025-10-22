import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../features/prayers/models/prayer_status.dart';
import '../providers/home_providers.dart';
import 'quick_log_modal.dart';

class TodayPrayersList extends ConsumerWidget {
  const TodayPrayersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);
    final prayerLogsAsync = ref.watch(todayPrayerLogsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TODAY\'S PRAYERS',
          style: AppTheme.subhead.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        prayerTimesAsync.when(
          data: (prayerTimes) {
            return prayerLogsAsync.when(
              data: (prayerLogs) {
                return Container(
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
                      for (var i = 0; i < prayerTimes.length; i++) ...[
                        _PrayerRow(
                          prayerTime: prayerTimes[i],
                          log: prayerLogs[prayerTimes[i].prayer],
                        ),
                        if (i < prayerTimes.length - 1)
                          const Divider(
                            height: 1,
                            indent: 60,
                            color: AppColors.tertiaryBackground,
                          ),
                      ],
                    ],
                  ),
                );
              },
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
                  'Error loading prayer logs',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            );
          },
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
              'Error loading prayer times',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrayerRow extends ConsumerWidget {
  final dynamic prayerTime;
  final dynamic log;

  const _PrayerRow({
    required this.prayerTime,
    required this.log,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPassed = prayerTime.isPassed;
    final isLogged = log != null;
    final canBeMarked = prayerTime.canBeMarked;

    // Get contextual prayer name (Jumu'ah for Friday Dhuhr with Jama'ah)
    final prayerName = prayerTime.prayer.getContextualName(
      prayerTime.date ?? DateTime.now(),
      log?.status,
    );

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onPressed: canBeMarked ? () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) => QuickLogModal(
            prayer: prayerTime.prayer,
            scheduledTime: prayerTime.time,
            existingStatus: log?.status,
          ),
        );
      } : null,
      child: Row(
        children: [
          _buildStatusIcon(
            isPassed,
            isLogged,
            log?.status,
            prayerTime.prayer,
            prayerTime.date ?? DateTime.now(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayerName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: canBeMarked
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
                if (isLogged && log != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    log.status.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      color: log.status.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            AppDateUtils.formatTime12Hour(prayerTime.time),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: canBeMarked
                  ? AppColors.textSecondary
                  : AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 8),
          if (!isLogged && isPassed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryStart.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'Mark',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
            )
          else if (!isLogged && !isPassed)
            const Icon(
              CupertinoIcons.clock,
              size: 20,
              color: AppColors.textTertiary,
            )
          else
            const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(
    bool isPassed,
    bool isLogged,
    PrayerStatus? status,
    dynamic prayer,
    DateTime date,
  ) {
    if (isLogged && status != null) {
      // Check if this is Jumu'ah (Friday Dhuhr prayed as Jama'ah)
      final isJumuah = prayer.isJumuah(date, status);

      // Choose different icons based on status
      IconData icon;
      if (isJumuah) {
        // Special star icon for Jumu'ah
        icon = CupertinoIcons.star_fill;
      } else {
        switch (status) {
          case PrayerStatus.missed:
            icon = CupertinoIcons.exclamationmark_triangle_fill;
            break;
          case PrayerStatus.qalah:
            icon = CupertinoIcons.clock_fill;
            break;
          default:
            icon = CupertinoIcons.checkmark_circle_fill;
        }
      }

      return Icon(
        icon,
        size: 32,
        color: status.color,
      );
    } else if (isPassed) {
      return const Icon(
        CupertinoIcons.time,
        size: 32,
        color: AppColors.warning,
      );
    } else {
      return const Icon(
        CupertinoIcons.circle,
        size: 32,
        color: AppColors.textTertiary,
      );
    }
  }
}
