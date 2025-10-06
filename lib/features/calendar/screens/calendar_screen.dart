import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/date_utils.dart';
import '../providers/calendar_providers.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/day_detail_modal.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          AppDateUtils.formatMonthYear(selectedMonth),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.secondaryBackground,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.chevron_left),
          onPressed: () {
            final newMonth = DateTime(
              selectedMonth.year,
              selectedMonth.month - 1,
            );
            ref.read(selectedMonthProvider.notifier).state = newMonth;
          },
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.calendar_today),
          onPressed: () {
            final today = DateTime.now();
            ref.read(selectedMonthProvider.notifier).state = today;
            ref.read(selectedDateProvider.notifier).state = today;
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Expanded(
              child: CalendarGrid(
                selectedMonth: selectedMonth,
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  ref.read(selectedDateProvider.notifier).state = date;
                  _showDayDetail(context, date);
                },
                onMonthChanged: (month) {
                  ref.read(selectedMonthProvider.notifier).state = month;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDayDetail(BuildContext context, DateTime date) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => DayDetailModal(date: date),
    );
  }
}
