import 'package:flutter/material.dart';
import 'package:offline_notes/model/sync_status.dart';

class SyncStatusBadge extends StatelessWidget {
  final SyncStatus status;

  const SyncStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case SyncStatus.synced:
        return const Icon(Icons.cloud_done, color: Colors.green);

      case SyncStatus.pending:
        return const Icon(Icons.cloud_upload, color: Colors.orange);

      case SyncStatus.conflict:
        return const Icon(Icons.warning_amber_rounded, color: Colors.red);
    }
  }
}
