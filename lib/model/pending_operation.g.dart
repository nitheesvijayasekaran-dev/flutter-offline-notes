// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_operation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingOperationAdapter extends TypeAdapter<PendingOperation> {
  @override
  final typeId = 2;

  @override
  PendingOperation read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PendingOperation.none;
      case 1:
        return PendingOperation.create;
      case 2:
        return PendingOperation.update;
      case 3:
        return PendingOperation.delete;
      default:
        return PendingOperation.none;
    }
  }

  @override
  void write(BinaryWriter writer, PendingOperation obj) {
    switch (obj) {
      case PendingOperation.none:
        writer.writeByte(0);
      case PendingOperation.create:
        writer.writeByte(1);
      case PendingOperation.update:
        writer.writeByte(2);
      case PendingOperation.delete:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingOperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
