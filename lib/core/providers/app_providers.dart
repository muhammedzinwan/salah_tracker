import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/prayers/models/prayer_log.dart';
import '../../features/prayers/repositories/prayer_repository.dart';
import '../../features/prayers/services/location_service.dart';
import '../../features/prayers/services/prayer_time_service.dart';
import '../../features/prayers/services/notification_service.dart';

// SharedPreferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

// Hive Box Provider
final prayerLogsBoxProvider = Provider<Box<PrayerLog>>((ref) {
  throw UnimplementedError('Hive box not initialized');
});

// Flutter Local Notifications Provider
final flutterLocalNotificationsProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});

// Services
final locationServiceProvider = Provider<LocationService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocationService(prefs);
});

final prayerTimeServiceProvider = Provider<PrayerTimeService>((ref) {
  return PrayerTimeService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final notifications = ref.watch(flutterLocalNotificationsProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationService(notifications, prefs);
});

// Repository
final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  final box = ref.watch(prayerLogsBoxProvider);
  return PrayerRepository(box);
});
