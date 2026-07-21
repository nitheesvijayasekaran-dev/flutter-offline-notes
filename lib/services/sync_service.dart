import 'package:flutter/foundation.dart';

import 'package:offline_notes/api/note_api.dart';
import 'package:offline_notes/model/note.dart';
import 'package:offline_notes/model/pending_operation.dart';
import 'package:offline_notes/model/remote_note.dart';
import 'package:offline_notes/model/sync_status.dart';
import 'package:offline_notes/repo/note_repo.dart';
import 'package:uuid/uuid.dart';

class SyncService {
  final NoteRepository repository;
  final NoteApi api;

  SyncService({required this.repository, required this.api});

  Future<void> sync() async {
    debugPrint('🔄 Starting sync...');

    await _pushChanges();

    await _pullChanges();

    debugPrint('✅ Sync completed');
  }

  Future<void> _pullChanges() async {
    final remoteNotes = await api.getNotes();

    for (final remote in remoteNotes) {
      final local = await repository.findByRemoteId(remote.id!);

      // New note from server
      if (local == null) {
        await repository.insert(
          Note(
            localId: const Uuid().v4(),
            remoteId: remote.id,
            title: remote.title,
            body: remote.body,
            updatedAt: remote.updatedAt,
            lastSyncedAt: remote.updatedAt,
            syncStatus: SyncStatus.synced,
            pendingOperation: PendingOperation.none,
            isDeleted: remote.isDeleted,
          ),
        );

        continue;
      }

      await _merge(local, remote);
    }
  }

  Future<void> _merge(Note local, RemoteNote remote) async {
    // Never overwrite a conflicted note
    if (local.syncStatus == SyncStatus.conflict) {
      return;
    }

    // Don't overwrite notes that have local pending changes
    if (local.pendingOperation != PendingOperation.none) {
      return;
    }

    local.title = remote.title;
    local.body = remote.body;
    local.updatedAt = remote.updatedAt;
    local.lastSyncedAt = remote.updatedAt;
    local.syncStatus = SyncStatus.synced;

    await local.save();
  }

  Future<void> _pushChanges() async {
    final pendingNotes = repository.getPendingNotes();

    if (pendingNotes.isEmpty) {
      return;
    }

    for (final note in pendingNotes) {
      switch (note.pendingOperation) {
        case PendingOperation.create:
          await _create(note);
          break;

        case PendingOperation.update:
          await _update(note);
          break;

        case PendingOperation.delete:
          await _delete(note);
          break;

        case PendingOperation.none:
          break;
      }
    }
  }

  Future<void> _create(Note note) async {
    final remote = RemoteNote(
      title: note.title,
      body: note.body,
      updatedAt: note.updatedAt,
      isDeleted: note.isDeleted,
    );

    final created = await api.createNote(remote);

    note.remoteId = created.id;

    await repository.markSynced(note, created.updatedAt);

    debugPrint('Created ${note.title}');
  }

  Future<void> _update(Note note) async {
    if (note.remoteId == null) return;

    // Fetch latest version from server
    final remote = await api.getNote(note.remoteId!);

    // Skip conflict detection if user chose Keep Local
    if (!note.forceUpload) {
      final localChanged =
          note.updatedAt.difference(note.lastSyncedAt!).abs() >
          const Duration(seconds: 1);

      final remoteChanged =
          remote.updatedAt.difference(note.lastSyncedAt!).abs() >
          const Duration(seconds: 1);

      // Detect conflict
      if (localChanged && remoteChanged) {
        await repository.markConflict(note, remote);
        return;
      }
    }

    debugPrint('Calling api.updateNote()');
    // Safe to upload
    final update = await api.updateNote(
      RemoteNote(
        id: note.remoteId,
        title: note.title,
        body: note.body,
        updatedAt: note.updatedAt,
        isDeleted: note.isDeleted,
      ),
    );
    debugPrint('api.updateNote() completed');

    await repository.markSynced(note, update.updatedAt);

    debugPrint('✅ Updated ${note.title}');
  }

  Future<void> _delete(Note note) async {
    if (note.remoteId == null) {
      return;
    }

    await api.deleteNote(note.remoteId!);

    await note.delete();

    debugPrint('Deleted ${note.title}');
  }
}
