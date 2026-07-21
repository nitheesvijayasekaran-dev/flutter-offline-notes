import 'package:hive_ce_flutter/hive_ce_flutter.dart';

part 'sync_status.g.dart';

@HiveType(typeId: 1)
enum SyncStatus {
  @HiveField(0)
  synced,

  @HiveField(1)
  pending,

  @HiveField(2)
  conflict,
}
