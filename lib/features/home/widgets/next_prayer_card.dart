import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/date_utils.dart';
import '../providers/home_providers.dart';
import 'quick_log_modal.dart';

class NextPrayerCard extends ConsumerWidget {
  const NextPrayerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextPrayer = ref.watch(nextPrayerProvider);
    final countdownStream = ref.watch(countdownTimerProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryStart.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: nextPrayer == null
          ? _buildAllPrayersComplete(context)
          : _buildNextPrayerInfo(context, ref, nextPrayer, countdownStream),
    );
  }

  Widget _buildAllPrayersComplete(BuildContext context) {
    return Column(
      children: [
        const Icon(
          CupertinoIcons.checkmark_circle_fill,
          size: 48,
          color: CupertinoColors.white,
        ),
        const SizedBox(height: 12),
        const Text(
          'All prayers complete for today',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'May Allah accept your prayers',
          style: TextStyle(
            fontSize: 15,
            color: CupertinoColors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNextPrayerInfo(
    BuildContext context,
    WidgetRef ref,
    dynamic nextPrayer,
    AsyncValue<DateTime> countdownStream,
  ) {
    return Column(
      children: [
        const Text(
          'NEXT PRAYER',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          nextPrayer.prayer.displayName.toUpperCase(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.clock,
              size: 20,
              color: CupertinoColors.white,
            ),
            const SizedBox(width: 8),
            Text(
              AppDateUtils.formatTime12Hour(nextPrayer.time),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        countdownStream.when(
          data: (now) {
            final duration = nextPrayer.time.difference(now);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.timer,
                  size: 18,
                  color: CupertinoColors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  '${AppDateUtils.formatDuration(duration)} remaining',
                  style: const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          onPressed: () {
            final currentPrayer = ref.read(currentPrayerProvider);
            if (currentPrayer != null) {
              showCupertinoModalPopup(
                context: context,
                builder: (context) => QuickLogModal(
                  prayer: currentPrayer.prayer,
                  scheduledTime: currentPrayer.time,
                ),
              );
            }
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.pencil_circle_fill,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Quick Log Prayer',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
