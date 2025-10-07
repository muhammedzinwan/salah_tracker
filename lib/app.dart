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
    // Define iOS notification categories with action buttons
    final iosNotificationCategories = <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        AppConstants.notificationCategoryId,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain(
            AppConstants.actionJamaah,
            'Jamaah',
          ),
          DarwinNotificationAction.plain(
            AppConstants.actionAdah,
            'Adah',
          ),
          DarwinNotificationAction.plain(
            AppConstants.actionQalah,
            'Qalah',
          ),
          DarwinNotificationAction.plain(
            AppConstants.actionNotPerformed,
            'Missed',
          ),
        ],
      ),
    ];

    // Initialize notification service
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initialize(
      onNotificationTap: _handleNotificationTap,
      iosNotificationCategories: iosNotificationCategories,
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
    print('🔔 Notification tapped!');
    print('   Action ID: ${response.actionId}');
    print('   Payload: ${response.payload}');

    final notificationService = ref.read(notificationServiceProvider);
    final prayerRepository = ref.read(prayerRepositoryProvider);

    final prayer = notificationService.getPrayerFromPayload(response.payload);
    final status = notificationService.getStatusFromAction(response.actionId);

    print('   Parsed Prayer: $prayer');
    print('   Parsed Status: $status');

    if (prayer != null && status != null) {
      print('   ✅ Logging prayer: ${prayer.displayName} as ${status.displayName}');

      // Log prayer from notification action
      prayerRepository.logPrayer(
        date: DateTime.now(),
        prayer: prayer,
        status: status,
        scheduledTime: DateTime.now(),
      );

      // Cancel the notification after logging
      notificationService.cancelPrayerNotification(prayer);

      print('   ✅ Prayer logged and notification cancelled');
    } else {
      print('   ❌ Failed to parse prayer or status');
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
