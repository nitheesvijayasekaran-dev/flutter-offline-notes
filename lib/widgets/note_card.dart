import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:offline_notes/model/note.dart';
import 'package:offline_notes/widgets/sync_status_badge.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      title: Text(note.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(note.body, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text(DateFormat.yMMMd().add_jm().format(note.updatedAt)),
        ],
      ),
      trailing: Column(
        children: [
          SyncStatusBadge(status: note.syncStatus),
          SizedBox(
            height: 32,
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    ),
  );
}
