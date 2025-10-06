import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/app_providers.dart';
import 'features/home/screens/home_screen.dart';
import 'features/calendar/screens/calendar_screen.dart';
import 'features/statistics/screens/statistics_screen.dart';
import 'features/settings/screens/settings_screen.dart';

class SalahTrackerApp extends ConsumerStatefulWidget {
  const SalahTrackerApp({super.key});

  @override
  ConsumerState<SalahTrackerApp> createState() => _SalahTrackerAppState();
}

class _SalahTrackerAppState extends ConsumerState<SalahTrackerApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize notification service
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initialize(
      onNotificationTap: _handleNotificationTap,
    );

    // Schedule today's prayers
    await _scheduleTodayPrayers();
  }

  Future<void> _scheduleTodayPrayers() async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final prayerTimeService = ref.read(prayerTimeServiceProvider);
      final notificationService = ref.read(notificationServiceProvider);

      final location = locationService.getSavedOrDefaultLocation();
      final prayerTimes = await prayerTimeService.getTodayPrayerTimes(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      final today = DateTime.now();
      final dateString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await notificationService.scheduleDailyPrayers(
        prayerTimes: prayerTimes,
        date: dateString,
      );
    } catch (e) {
      // Silently fail - notifications are not critical for app launch
      print('Error scheduling prayers: $e');
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    final notificationService = ref.read(notificationServiceProvider);
    final prayerRepository = ref.read(prayerRepositoryProvider);

    final prayer = notificationService.getPrayerFromPayload(response.payload);
    final status = notificationService.getStatusFromAction(response.actionId);

    if (prayer != null && status != null) {
      // Log prayer from notification action
      prayerRepository.logPrayer(
        date: DateTime.now(),
        prayer: prayer,
        status: status,
        scheduledTime: DateTime.now(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      home: MainTabView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainTabView extends StatelessWidget {
  const MainTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        iconSize: 28,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_fill),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear_alt_fill),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const HomeScreen();
          case 1:
            return const CalendarScreen();
          case 2:
            return const StatisticsScreen();
          case 3:
            return const SettingsScreen();
          default:
            return const HomeScreen();
        }
      },
    );
  }
}
