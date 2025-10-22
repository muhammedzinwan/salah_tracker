import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../features/prayers/models/prayer.dart';
import '../../../features/prayers/models/prayer_status.dart';
import '../../../core/providers/app_providers.dart';

class PrayerLogModal extends ConsumerWidget {
  final Prayer prayer;
  final DateTime date;
  final DateTime scheduledTime;
  final PrayerStatus? existingStatus;

  const PrayerLogModal({
    super.key,
    required this.prayer,
    required this.date,
    required this.scheduledTime,
    this.existingStatus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title - use contextual name for Jumu'ah
              Text(
                existingStatus != null
                    ? 'Update ${prayer.getContextualName(date, existingStatus)}'
                    : 'Log ${prayer.displayName}',
                style: AppTheme.title2,
              ),
              const SizedBox(height: 8),
              Text(
                AppDateUtils.formatDate(date),
                style: AppTheme.subhead.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppDateUtils.formatTime12Hour(scheduledTime),
                style: AppTheme.subhead.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              // Status buttons
              Row(
                children: [
                  Expanded(
                    child: _StatusButton(
                      status: PrayerStatus.jamaah,
                      isSelected: existingStatus == PrayerStatus.jamaah,
                      onPressed: () => _logPrayer(
                        context,
                        ref,
                        PrayerStatus.jamaah,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatusButton(
                      status: PrayerStatus.adah,
                      isSelected: existingStatus == PrayerStatus.adah,
                      onPressed: () => _logPrayer(
                        context,
                        ref,
                        PrayerStatus.adah,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatusButton(
                      status: PrayerStatus.qalah,
                      isSelected: existingStatus == PrayerStatus.qalah,
                      onPressed: () => _logPrayer(
                        context,
                        ref,
                        PrayerStatus.qalah,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: AppColors.tertiaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logPrayer(
    BuildContext context,
    WidgetRef ref,
    PrayerStatus status,
  ) async {
    final repository = ref.read(prayerRepositoryProvider);

    if (existingStatus != null) {
      await repository.updatePrayerLog(
        date: date,
        prayer: prayer,
        status: status,
      );
    } else {
      await repository.logPrayer(
        date: date,
        prayer: prayer,
        status: status,
        scheduledTime: scheduledTime,
      );
    }

    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}

class _StatusButton extends StatelessWidget {
  final PrayerStatus status;
  final bool isSelected;
  final VoidCallback onPressed;

  const _StatusButton({
    required this.status,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: isSelected ? status.color : status.color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      onPressed: onPressed,
      child: Column(
        children: [
          Icon(
            _getIcon(),
            size: 28,
            color: isSelected ? CupertinoColors.white : status.color,
          ),
          const SizedBox(height: 6),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? CupertinoColors.white : status.color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (status) {
      case PrayerStatus.jamaah:
        return CupertinoIcons.person_2_fill;
      case PrayerStatus.adah:
        return CupertinoIcons.checkmark_circle_fill;
      case PrayerStatus.qalah:
        return CupertinoIcons.clock_fill;
      case PrayerStatus.notPerformed:
        return CupertinoIcons.xmark_circle_fill;
      case PrayerStatus.missed:
        return CupertinoIcons.exclamationmark_triangle_fill;
    }
  }
}
