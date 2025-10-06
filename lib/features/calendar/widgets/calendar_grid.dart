import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/date_utils.dart';
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
    final monthLogs = ref.watch(monthLogsProvider);

    return TableCalendar(
      firstDay: DateTime(2020, 1, 1),
      lastDay: DateTime(2030, 12, 31),
      focusedDay: selectedMonth,
      selectedDayPredicate: (day) => AppDateUtils.isSameDay(day, selectedDate),
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
                missedCount++;
                break;
            }
          }

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

          return Positioned(
            bottom: 2,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}
