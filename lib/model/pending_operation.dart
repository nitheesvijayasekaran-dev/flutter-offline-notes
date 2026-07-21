import 'package:hive_ce_flutter/hive_ce_flutter.dart';

part 'pending_operation.g.dart';

@HiveType(typeId: 2)
enum PendingOperation {
  @HiveField(0)
  none,

  @HiveField(1)
  create,

  @HiveField(2)
  update,

  @HiveField(3)
  delete,
}
