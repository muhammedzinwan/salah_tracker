// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerLogAdapter extends TypeAdapter<PrayerLog> {
  @override
  final int typeId = 0;

  @override
  PrayerLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerLog._internal(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      prayerIndex: fields[2] as int,
      statusIndex: fields[3] as int,
      loggedAt: fields[4] as DateTime?,
      scheduledTime: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.prayerIndex)
      ..writeByte(3)
      ..write(obj.statusIndex)
      ..writeByte(4)
      ..write(obj.loggedAt)
      ..writeByte(5)
      ..write(obj.scheduledTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
