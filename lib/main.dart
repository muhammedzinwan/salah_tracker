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

  // Set installation date if not already set
  await _setInstallationDateIfNotExists(prefs, prayerLogsBox);

  // Initialize FlutterLocalNotifications
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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

/// Sets the installation date if not already set
/// Uses earliest prayer log date if available, otherwise uses current date
Future<void> _setInstallationDateIfNotExists(
  SharedPreferences prefs,
  Box<PrayerLog> prayerLogsBox,
) async {
  // Check if installation date is already set
  if (prefs.containsKey(AppConstants.keyInstallationDate)) {
    return;
  }

  DateTime installationDate;

  // Check if there are existing prayer logs
  if (prayerLogsBox.isNotEmpty) {
    // Find the earliest prayer log date
    final allLogs = prayerLogsBox.values.toList();
    final earliestLog = allLogs.reduce((a, b) => a.date.isBefore(b.date) ? a : b);
    installationDate = earliestLog.date;
  } else {
    // No existing data, use current date
    installationDate = DateTime.now();
  }

  // Normalize to beginning of day
  final normalizedDate = DateTime(
    installationDate.year,
    installationDate.month,
    installationDate.day,
  );

  // Store the installation date as ISO string
  await prefs.setString(
    AppConstants.keyInstallationDate,
    normalizedDate.toIso8601String(),
  );
}
