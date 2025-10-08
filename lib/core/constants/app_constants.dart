class AppConstants {
  // App Info
  static const String appName = 'Salah Tracker';
  static const String appVersion = '1.0.1';
  static const String appDescription = 'Islamic Prayer Tracker App';

  // Default Location (Kerala, India)
  static const double defaultLatitude = 11.8745;
  static const double defaultLongitude = 75.3704;
  static const String defaultCity = 'Kannur';
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
  static const String keyInstallationDate = 'installation_date';

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
  static const String actionNotPerformed = 'not_performed';

  // Calculation
  static const int totalPrayersPerDay = 5;
  static const int daysInTypicalMonth = 30;
  static const int totalPrayersPerMonth = totalPrayersPerDay * daysInTypicalMonth;

  // Day Transition Timing
  static const int dayTransitionHour = 0; // Midnight
  static const int dayTransitionMinute = 0;
  static const int forcedTransitionHour = 3; // 3 AM cutoff
  static const int forcedTransitionMinute = 0;
}
