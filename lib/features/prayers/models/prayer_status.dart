import 'package:flutter/cupertino.dart';

enum PrayerStatus {
  jamaah,
  adah,
  qalah,
  notPerformed;

  String get displayName {
    switch (this) {
      case PrayerStatus.jamaah:
        return 'Jamaah';
      case PrayerStatus.adah:
        return 'Adah';
      case PrayerStatus.qalah:
        return 'Qalah';
      case PrayerStatus.notPerformed:
        return 'Not Performed';
    }
  }

  String get description {
    switch (this) {
      case PrayerStatus.jamaah:
        return 'In congregation';
      case PrayerStatus.adah:
        return 'On time, alone';
      case PrayerStatus.qalah:
        return 'Late/makeup';
      case PrayerStatus.notPerformed:
        return 'Missed';
    }
  }

  Color get color {
    switch (this) {
      case PrayerStatus.jamaah:
        return CupertinoColors.systemGreen;
      case PrayerStatus.adah:
        return CupertinoColors.systemYellow;
      case PrayerStatus.qalah:
        return CupertinoColors.systemOrange;
      case PrayerStatus.notPerformed:
        return CupertinoColors.systemRed;
    }
  }

  int get hiveTypeId {
    return index;
  }
}
