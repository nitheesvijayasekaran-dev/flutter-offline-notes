import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_notes/model/note.dart';
import 'package:offline_notes/model/sync_status.dart';
import 'package:offline_notes/providers/api_provider.dart';
import 'package:offline_notes/providers/notes_provider.dart';
import 'package:offline_notes/screens/add_edit_screen.dart';
import 'package:offline_notes/widgets/note_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    ref.read(syncManagerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Offline Notes')),
      body: notes.isEmpty
          ? const Center(child: Text('No notes yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];

                return NoteCard(
                  note: note,
                  onTap: () {
                    if (note.syncStatus == SyncStatus.conflict) {
                      showConflictDialog(note);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteAddEditScreen(note: note),
                        ),
                      );
                    }
                  },
                  onDelete: () async {
                    await ref.read(notesProvider.notifier).deleteNote(note);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteAddEditScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> showConflictDialog(Note note) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Conflict Detected'),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Local Version',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(note.title),

            const SizedBox(height: 16),

            const Text(
              'Server Version',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(note.conflictTitle ?? ''),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              await ref.read(notesProvider.notifier).resolveWithRemote(note);
            },
            child: const Text('Use Server'),
          ),

          FilledButton(
            onPressed: () async {
              Navigator.pop(context);

              await ref.read(notesProvider.notifier).resolveWithLocal(note);
            },
            child: const Text('Keep Local'),
          ),
        ],
      ),
    );
  }
}
