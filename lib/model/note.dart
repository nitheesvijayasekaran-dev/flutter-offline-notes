import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:offline_notes/model/pending_operation.dart';
import 'package:offline_notes/model/sync_status.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String localId;

  @HiveField(1)
  String? remoteId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String body;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  DateTime? lastSyncedAt;

  @HiveField(6)
  SyncStatus syncStatus;

  @HiveField(7)
  PendingOperation pendingOperation;

  @HiveField(8)
  bool isDeleted;

  @HiveField(9)
  String? conflictTitle;

  @HiveField(10)
  String? conflictBody;

  @HiveField(11)
  DateTime? conflictUpdatedAt;

  @HiveField(12)
  bool forceUpload;

  Note({
    required this.localId,
    this.remoteId,
    required this.title,
    required this.body,
    required this.updatedAt,
    this.lastSyncedAt,
    required this.syncStatus,
    required this.pendingOperation,
    this.isDeleted = false,
    this.conflictTitle,
    this.conflictBody,
    this.conflictUpdatedAt,
    this.forceUpload = false,
  });
}
