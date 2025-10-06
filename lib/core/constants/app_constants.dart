class AppConstants {
  // App Info
  static const String appName = 'Salah Tracker';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Islamic Prayer Tracker App';

  // Default Location (Mumbai, India)
  static const double defaultLatitude = 19.0760;
  static const double defaultLongitude = 72.8777;
  static const String defaultCity = 'Mumbai';
  static const String defaultCountry = 'India';

  // Database
  static const String prayerLogsBoxName = 'prayer_logs';

  // Shared Preferences Keys
  static const String keyLatitude = 'latitude';
  static const String keyLongitude = 'longitude';
  static const String keyCity = 'city';
  static const String keyCountry = 'country';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyFirstLaunch = 'first_launch';

  // Notification
  static const String notificationChannelId = 'prayer_reminders';
  static const String notificationChannelName = 'Prayer Reminders';
  static const String notificationChannelDescription =
      'Notifications for daily prayer times';
  static const String notificationCategoryId = 'prayer_reminder';

  // Notification Actions
  static const String actionJamaah = 'jamaah';
  static const String actionAdah = 'adah';
  static const String actionQalah = 'qalah';
  static const String actionLater = 'later';

  // Calculation
  static const int totalPrayersPerDay = 5;
  static const int daysInTypicalMonth = 30;
  static const int totalPrayersPerMonth = totalPrayersPerDay * daysInTypicalMonth;
}
