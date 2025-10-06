import '../../features/prayers/models/prayer.dart';

class PrayerConstants {
  // Prayer names list
  static const List<Prayer> allPrayers = Prayer.values;

  // Default prayer times (fallback if calculation fails)
  static const Map<Prayer, String> defaultTimes = {
    Prayer.fajr: '05:30',
    Prayer.dhuhr: '12:30',
    Prayer.asr: '15:45',
    Prayer.maghrib: '18:15',
    Prayer.isha: '19:30',
  };

  // Prayer descriptions
  static const Map<Prayer, String> descriptions = {
    Prayer.fajr: 'Dawn prayer',
    Prayer.dhuhr: 'Noon prayer',
    Prayer.asr: 'Afternoon prayer',
    Prayer.maghrib: 'Sunset prayer',
    Prayer.isha: 'Night prayer',
  };
}
