import 'package:hive/hive.dart';
import 'prayer.dart';
import 'prayer_status.dart';

part 'prayer_log.g.dart';

@HiveType(typeId: 0)
class PrayerLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int prayerIndex; // Store as int for Hive compatibility

  @HiveField(3)
  final int statusIndex; // Store as int for Hive compatibility

  @HiveField(4)
  final DateTime? loggedAt;

  @HiveField(5)
  final DateTime scheduledTime;

  PrayerLog({
    required this.id,
    required this.date,
    required Prayer prayer,
    required PrayerStatus status,
    this.loggedAt,
    required this.scheduledTime,
  })  : prayerIndex = prayer.index,
        statusIndex = status.index;

  // Constructor for Hive deserialization
  PrayerLog._internal({
    required this.id,
    required this.date,
    required this.prayerIndex,
    required this.statusIndex,
    this.loggedAt,
    required this.scheduledTime,
  });

  Prayer get prayer => Prayer.values[prayerIndex];
  PrayerStatus get status => PrayerStatus.values[statusIndex];

  PrayerLog copyWith({
    String? id,
    DateTime? date,
    Prayer? prayer,
    PrayerStatus? status,
    DateTime? loggedAt,
    DateTime? scheduledTime,
  }) {
    return PrayerLog(
      id: id ?? this.id,
      date: date ?? this.date,
      prayer: prayer ?? this.prayer,
      status: status ?? this.status,
      loggedAt: loggedAt ?? this.loggedAt,
      scheduledTime: scheduledTime ?? this.scheduledTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'prayer': prayer.name,
      'status': status.name,
      'loggedAt': loggedAt?.toIso8601String(),
      'scheduledTime': scheduledTime.toIso8601String(),
    };
  }

  factory PrayerLog.fromJson(Map<String, dynamic> json) {
    return PrayerLog(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      prayer: Prayer.values.firstWhere((e) => e.name == json['prayer']),
      status: PrayerStatus.values.firstWhere((e) => e.name == json['status']),
      loggedAt: json['loggedAt'] != null
          ? DateTime.parse(json['loggedAt'] as String)
          : null,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
    );
  }
}
