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

  int get hiveTypeId {
    return index;
  }
}
