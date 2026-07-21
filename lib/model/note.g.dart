// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final typeId = 0;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Note(
      localId: fields[0] as String,
      remoteId: fields[1] as String?,
      title: fields[2] as String,
      body: fields[3] as String,
      updatedAt: fields[4] as DateTime,
      lastSyncedAt: fields[5] as DateTime?,
      syncStatus: fields[6] as SyncStatus,
      pendingOperation: fields[7] as PendingOperation,
      isDeleted: fields[8] == null ? false : fields[8] as bool,
      conflictTitle: fields[9] as String?,
      conflictBody: fields[10] as String?,
      conflictUpdatedAt: fields[11] as DateTime?,
      forceUpload: fields[12] == null ? false : fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.remoteId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.body)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.lastSyncedAt)
      ..writeByte(6)
      ..write(obj.syncStatus)
      ..writeByte(7)
      ..write(obj.pendingOperation)
      ..writeByte(8)
      ..write(obj.isDeleted)
      ..writeByte(9)
      ..write(obj.conflictTitle)
      ..writeByte(10)
      ..write(obj.conflictBody)
      ..writeByte(11)
      ..write(obj.conflictUpdatedAt)
      ..writeByte(12)
      ..write(obj.forceUpload);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
