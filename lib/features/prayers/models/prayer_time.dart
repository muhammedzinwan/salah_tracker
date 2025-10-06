import 'prayer.dart';

class PrayerTime {
  final Prayer prayer;
  final DateTime time;

  const PrayerTime({
    required this.prayer,
    required this.time,
  });

  bool get isPassed => DateTime.now().isAfter(time);

  Duration get timeUntil {
    final now = DateTime.now();
    return time.difference(now);
  }

  String get formattedTime {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  String toString() => '${prayer.displayName} at $formattedTime';
}
