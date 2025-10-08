import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/providers/date_providers.dart';
import '../providers/calendar_providers.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/day_detail_modal.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final installationDateAsync = ref.watch(installationDateProvider);

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
          onPressed: _canNavigateToPreviousMonth(selectedMonth, installationDateAsync) ? () {
            final newMonth = DateTime(
              selectedMonth.year,
              selectedMonth.month - 1,
            );
            ref.read(selectedMonthProvider.notifier).state = newMonth;
          } : null,
          child: const Icon(CupertinoIcons.chevron_left),
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
                  if (_isDateAccessible(date, installationDateAsync)) {
                    ref.read(selectedDateProvider.notifier).state = date;
                    _showDayDetail(context, date);
                  } else {
                    _showDateNotAvailableAlert(context);
                  }
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

  /// Check if navigation to previous month is allowed based on installation date
  bool _canNavigateToPreviousMonth(
    DateTime selectedMonth,
    AsyncValue<DateTime?> installationDateAsync,
  ) {
    return installationDateAsync.when(
      data: (installationDate) {
        if (installationDate == null) return true; // Allow if no installation date

        // Calculate the month we would navigate to
        final previousMonth = DateTime(
          selectedMonth.year,
          selectedMonth.month - 1,
        );

        // Normalize installation date to first day of month for comparison
        final installationMonth = DateTime(
          installationDate.year,
          installationDate.month,
        );

        // Allow navigation if previous month is not before installation month
        return !previousMonth.isBefore(installationMonth);
      },
      loading: () => false, // Disable while loading
      error: (_, __) => true, // Allow on error
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
      loading: () => false, // Deny while loading
      error: (_, __) => true, // Allow on error
    );
  }

  /// Show alert when user tries to access a date before installation
  void _showDateNotAvailableAlert(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Date Not Available'),
        content: const Text(
          'This date is before your app installation date and cannot be accessed.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
