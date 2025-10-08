import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/providers/date_providers.dart';
import '../providers/calendar_providers.dart';
import '../../prayers/models/prayer_status.dart';

class CalendarGrid extends ConsumerWidget {
  final DateTime selectedMonth;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onMonthChanged;

  const CalendarGrid({
    super.key,
    required this.selectedMonth,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthLogsAsync = ref.watch(monthLogsProvider);
    final installationDateAsync = ref.watch(installationDateProvider);

    return monthLogsAsync.when(
      data: (monthLogs) => TableCalendar(
      firstDay: DateTime(2020, 1, 1),
      lastDay: DateTime(2030, 12, 31),
      focusedDay: selectedMonth,
      selectedDayPredicate: (day) => AppDateUtils.isSameDay(day, selectedDate),
      enabledDayPredicate: (day) => _isDateAccessible(day, installationDateAsync),
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      headerVisible: false,
      onDaySelected: (selectedDay, focusedDay) {
        onDateSelected(selectedDay);
      },
      onPageChanged: (focusedDay) {
        onMonthChanged(focusedDay);
      },
      calendarStyle: CalendarStyle(
        cellMargin: const EdgeInsets.all(4),
        defaultDecoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        selectedDecoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        outsideDecoration: BoxDecoration(
          color: AppColors.tertiaryBackground.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        disabledDecoration: BoxDecoration(
          color: AppColors.tertiaryBackground.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        weekendDecoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        defaultTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        weekendTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        todayTextStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        selectedTextStyle: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        outsideTextStyle: TextStyle(
          color: AppColors.textTertiary.withOpacity(0.5),
          fontSize: 16,
        ),
        disabledTextStyle: TextStyle(
          color: AppColors.textTertiary.withOpacity(0.3),
          fontSize: 16,
        ),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        weekendStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          final dayLogs = monthLogs.where((log) {
            return AppDateUtils.isSameDay(log.date, date);
          }).toList();

          if (dayLogs.isEmpty) return null;

          // Count status types
          int jamaahCount = 0;
          int adahCount = 0;
          int qalahCount = 0;
          int missedCount = 0;

          for (final log in dayLogs) {
            switch (log.status) {
              case PrayerStatus.jamaah:
                jamaahCount++;
                break;
              case PrayerStatus.adah:
                adahCount++;
                break;
              case PrayerStatus.qalah:
                qalahCount++;
                break;
              case PrayerStatus.notPerformed:
              case PrayerStatus.missed:
                missedCount++;
                break;
            }
          }

          // Check if this date has any missed prayers
          final hasMissedPrayers = missedCount > 0;

          // Determine marker color
          Color markerColor;
          if (missedCount > 0) {
            markerColor = PrayerStatus.notPerformed.color;
          } else if (qalahCount > 2) {
            markerColor = PrayerStatus.qalah.color;
          } else if (adahCount > 2) {
            markerColor = PrayerStatus.adah.color;
          } else if (jamaahCount >= 3) {
            markerColor = PrayerStatus.jamaah.color;
          } else {
            markerColor = AppColors.textTertiary;
          }

          return Stack(
            children: [
              // Main status marker (bottom center)
              Positioned(
                bottom: 2,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: markerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              // Red alert indicator for missed prayers (top right)
              if (hasMissedPrayers)
                const Positioned(
                  top: 2,
                  right: 2,
                  child: Icon(
                    CupertinoIcons.exclamationmark_circle_fill,
                    size: 8,
                    color: CupertinoColors.systemRed,
                  ),
                ),
            ],
          );
        },
      ),
    ),
      loading: () => const Center(
        child: CupertinoActivityIndicator(),
      ),
      error: (error, stack) => const Center(
        child: Text(
          'Error loading calendar',
          style: TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  /// Check if a specific date is accessible based on installation date
  bool _isDateAccessible(
    DateTime date,
    AsyncValue<DateTime?> installationDateAsync,
  ) {
    return installationDateAsync.when(
      data: (installationDate) {
        if (installationDate == null) return true; // Allow if no installation date

        // Normalize both dates for comparison
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final normalizedInstallation = DateTime(
          installationDate.year,
          installationDate.month,
          installationDate.day,
        );

        // Allow if date is on or after installation date
        return normalizedDate.isAtSameMomentAs(normalizedInstallation) ||
               normalizedDate.isAfter(normalizedInstallation);
      },
      loading: () => true, // Allow while loading to prevent flicker
      error: (_, __) => true, // Allow on error
    );
  }
}
