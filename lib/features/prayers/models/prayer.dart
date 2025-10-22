enum Prayer {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha;

  String get displayName {
    switch (this) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
    }
  }

  String get arabicName {
    switch (this) {
      case Prayer.fajr:
        return 'صلاة الفجر';
      case Prayer.dhuhr:
        return 'صلاة الظهر';
      case Prayer.asr:
        return 'صلاة العصر';
      case Prayer.maghrib:
        return 'صلاة المغرب';
      case Prayer.isha:
        return 'صلاة العشاء';
    }
  }

  /// Returns the contextual display name for the prayer.
  /// Shows "Jumu'ah" for Dhuhr on Fridays ONLY when performed in Jama'ah.
  /// If prayed alone (Adah) or made up later (Qada), it remains "Dhuhr".
  String getContextualName(DateTime date, dynamic status) {
    if (this == Prayer.dhuhr && date.weekday == DateTime.friday) {
      // Jumu'ah is only valid when prayed in congregation
      if (status != null && status.toString().contains('jamaah')) {
        return 'Jumu\'ah';
      }
    }
    return displayName;
  }

  /// Returns the contextual Arabic name for the prayer.
  /// Shows "صلاة الجمعة" for Dhuhr on Fridays ONLY when performed in Jama'ah.
  String getContextualArabicName(DateTime date, dynamic status) {
    if (this == Prayer.dhuhr && date.weekday == DateTime.friday) {
      // Jumu'ah is only valid when prayed in congregation
      if (status != null && status.toString().contains('jamaah')) {
        return 'صلاة الجمعة';
      }
    }
    return arabicName;
  }

  /// Checks if this prayer qualifies as Jumu'ah.
  /// Returns true only for Friday Dhuhr performed in Jama'ah.
  bool isJumuah(DateTime date, dynamic status) {
    return this == Prayer.dhuhr &&
           date.weekday == DateTime.friday &&
           status != null &&
           status.toString().contains('jamaah');
  }

  int get hiveTypeId {
    return index;
  }
}
