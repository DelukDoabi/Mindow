// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class OutboxStateAdapter extends TypeAdapter<OutboxState> {
  @override
  final typeId = 10;

  @override
  OutboxState read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OutboxState.local;
      case 1:
        return OutboxState.sent;
      case 2:
        return OutboxState.acked;
      default:
        return OutboxState.local;
    }
  }

  @override
  void write(BinaryWriter writer, OutboxState obj) {
    switch (obj) {
      case OutboxState.local:
        writer.writeByte(0);
      case OutboxState.sent:
        writer.writeByte(1);
      case OutboxState.acked:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutboxStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OutboxRecordAdapter extends TypeAdapter<OutboxRecord> {
  @override
  final typeId = 11;

  @override
  OutboxRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OutboxRecord(
      eventId: fields[0] as String,
      aggregateId: fields[1] as String,
      eventType: fields[2] as String,
      schemaVersion: (fields[3] as num).toInt(),
      createdAt: fields[4] as DateTime,
      payloadJson: fields[5] as String,
      state: fields[6] == null ? OutboxState.local : fields[6] as OutboxState,
      receivedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, OutboxRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.eventId)
      ..writeByte(1)
      ..write(obj.aggregateId)
      ..writeByte(2)
      ..write(obj.eventType)
      ..writeByte(3)
      ..write(obj.schemaVersion)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.payloadJson)
      ..writeByte(6)
      ..write(obj.state)
      ..writeByte(7)
      ..write(obj.receivedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutboxRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
