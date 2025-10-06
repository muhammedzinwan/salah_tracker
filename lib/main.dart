import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app.dart';
import 'core/providers/app_providers.dart';
import 'core/constants/app_constants.dart';
import 'features/prayers/models/prayer_log.dart';
import 'features/prayers/models/prayer.dart';
import 'features/prayers/models/prayer_status.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone database
  tz.initializeTimeZones();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(PrayerLogAdapter());

  // Open Hive boxes
  final prayerLogsBox =
      await Hive.openBox<PrayerLog>(AppConstants.prayerLogsBoxName);

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize FlutterLocalNotifications
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Set up notification categories for iOS
  final iosNotificationCategory = DarwinNotificationCategory(
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
        AppConstants.actionLater,
        'Later',
      ),
    ],
  );

  // Initialize notifications with iOS categories
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.initialize(
        const DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        // Note: categories parameter removed - may not be supported in this version
      );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        prayerLogsBoxProvider.overrideWithValue(prayerLogsBox),
        flutterLocalNotificationsProvider
            .overrideWithValue(flutterLocalNotificationsPlugin),
      ],
      child: const SalahTrackerApp(),
    ),
  );
}
