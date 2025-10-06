import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer.dart';
import '../models/prayer_status.dart';
import '../../../core/constants/app_constants.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications;
  final SharedPreferences _prefs;

  NotificationService(this._notifications, this._prefs);

  /// Initialize notification service
  Future<void> initialize({
    required Function(NotificationResponse) onNotificationTap,
  }) async {
    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
    );

    // Request permissions
    await requestPermissions();
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    // iOS permissions
    final iosPermission = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Android 13+ permissions
    final androidPermission = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return (iosPermission ?? true) && (androidPermission ?? true);
  }

  /// Check if notifications are enabled
  bool areNotificationsEnabled() {
    return _prefs.getBool(AppConstants.keyNotificationsEnabled) ?? true;
  }

  /// Toggle notifications on/off
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.keyNotificationsEnabled, enabled);
    if (!enabled) {
      await cancelAllNotifications();
    }
  }

  /// Schedule prayer notification
  Future<void> schedulePrayerNotification({
    required Prayer prayer,
    required DateTime scheduledTime,
    required String date,
  }) async {
    if (!areNotificationsEnabled()) return;

    try {
      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      // Only schedule if time is in the future
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        return;
      }

      final payload = jsonEncode({
        'prayer': prayer.name,
        'date': date,
      });

      // Android notification details with actions
      final androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            AppConstants.actionJamaah,
            'Jamaah',
            showsUserInterface: false,
          ),
          const AndroidNotificationAction(
            AppConstants.actionAdah,
            'Adah',
            showsUserInterface: false,
          ),
          const AndroidNotificationAction(
            AppConstants.actionQalah,
            'Qalah',
            showsUserInterface: false,
          ),
          const AndroidNotificationAction(
            AppConstants.actionLater,
            'Later',
            showsUserInterface: false,
          ),
        ],
      );

      // iOS notification details with actions
      const iosDetails = DarwinNotificationDetails(
        categoryIdentifier: AppConstants.notificationCategoryId,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        prayer.index, // Use prayer index as notification ID
        'Time for ${prayer.displayName}',
        'It\'s ${_formatTime(scheduledTime)}',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      // Silently fail - notification scheduling is not critical
      print('Error scheduling notification: $e');
    }
  }

  /// Schedule all daily prayers
  Future<void> scheduleDailyPrayers({
    required Map<Prayer, DateTime> prayerTimes,
    required String date,
  }) async {
    if (!areNotificationsEnabled()) return;

    for (final entry in prayerTimes.entries) {
      await schedulePrayerNotification(
        prayer: entry.key,
        scheduledTime: entry.value,
        date: date,
      );
    }
  }

  /// Cancel a specific prayer notification
  Future<void> cancelPrayerNotification(Prayer prayer) async {
    await _notifications.cancel(prayer.index);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Send test notification
  Future<void> sendTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999, // Test notification ID
      'Test Notification',
      'Prayer notifications are working correctly!',
      notificationDetails,
    );
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Parse notification payload
  Map<String, dynamic>? parsePayload(String? payload) {
    if (payload == null) return null;
    try {
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Get Prayer from payload
  Prayer? getPrayerFromPayload(String? payload) {
    final data = parsePayload(payload);
    if (data == null) return null;

    final prayerName = data['prayer'] as String?;
    if (prayerName == null) return null;

    try {
      return Prayer.values.firstWhere((p) => p.name == prayerName);
    } catch (e) {
      return null;
    }
  }

  /// Get date from payload
  String? getDateFromPayload(String? payload) {
    final data = parsePayload(payload);
    return data?['date'] as String?;
  }

  /// Get PrayerStatus from action ID
  PrayerStatus? getStatusFromAction(String? actionId) {
    if (actionId == null) return null;

    switch (actionId) {
      case AppConstants.actionJamaah:
        return PrayerStatus.jamaah;
      case AppConstants.actionAdah:
        return PrayerStatus.adah;
      case AppConstants.actionQalah:
        return PrayerStatus.qalah;
      default:
        return null;
    }
  }

  /// Format time for notification
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
