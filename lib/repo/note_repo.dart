import 'package:offline_notes/database/hive_service.dart';
import 'package:offline_notes/model/note.dart';
import 'package:offline_notes/model/pending_operation.dart';
import 'package:offline_notes/model/remote_note.dart';
import 'package:offline_notes/model/sync_status.dart';
import 'package:uuid/uuid.dart';

class NoteRepository {
  final _box = HiveService.notesBox;

  /// Returns all active (non-deleted) notes sorted by latest update.
  List<Note> getAllNotes() =>
      _box.values.where((note) => !note.isDeleted).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  /// Returns all notes that have pending operations.
  /// Includes soft-deleted notes so DELETE operations can be synced.
  List<Note> getPendingNotes() => _box.values
      .where(
        (note) =>
            note.pendingOperation != PendingOperation.none &&
            note.syncStatus == SyncStatus.pending,
      )
      .toList();

  /// Creates a new local note.
  Future<void> createNote({required String title, required String body}) async {
    final note = Note(
      localId: const Uuid().v4(),
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
      pendingOperation: PendingOperation.create,
    );

    await _box.put(note.localId, note);
  }

  /// Updates an existing local note.
  Future<void> updateNote(Note note) async {
    note.updatedAt = DateTime.now();

    // Keep CREATE if the note has never been synced.
    if (note.pendingOperation != PendingOperation.create) {
      note.pendingOperation = PendingOperation.update;
    }

    note.syncStatus = SyncStatus.pending;

    await note.save();
  }

  /// Soft deletes a note.
  Future<void> deleteNote(Note note) async {
    note.updatedAt = DateTime.now();
    note.isDeleted = true;

    if (note.pendingOperation == PendingOperation.create) {
      // Created locally but never synced.
      // Remove completely; no need to notify the server.
      await _box.delete(note.localId);
      return;
    }

    note.pendingOperation = PendingOperation.delete;
    note.syncStatus = SyncStatus.pending;

    await note.save();
  }

  /// Marks a note as successfully synced.
  Future<void> markSynced(Note note, DateTime serverUpdatedAt) async {
    note.syncStatus = SyncStatus.synced;
    note.pendingOperation = PendingOperation.none;

    // Local note now represents the server version
    note.updatedAt = serverUpdatedAt;
    note.lastSyncedAt = serverUpdatedAt;

    note.forceUpload = false;

    await note.save();
  }

  /// Saves any changes made to a note.
  Future<void> save(Note note) async {
    await _box.put(note.localId, note);
  }

  Future<Note?> findByRemoteId(String remoteId) async {
    try {
      return _box.values.firstWhere((note) => note.remoteId == remoteId);
    } catch (_) {
      return null;
    }
  }

  Future<void> insert(Note note) async {
    await _box.put(note.localId, note);
  }

  Future<void> markConflict(Note note, RemoteNote remote) async {
    note.syncStatus = SyncStatus.conflict;
    note.pendingOperation = PendingOperation.update;

    note.conflictTitle = remote.title;
    note.conflictBody = remote.body;
    note.conflictUpdatedAt = remote.updatedAt;

    await note.save();
  }

  Future<void> useLocalVersion(Note note) async {
    note.forceUpload = true;
    note.syncStatus = SyncStatus.pending;
    note.pendingOperation = PendingOperation.update;

    note.conflictTitle = null;
    note.conflictBody = null;
    note.conflictUpdatedAt = null;

    await note.save();
  }

  Future<void> useRemoteVersion(Note note) async {
    note.title = note.conflictTitle!;
    note.body = note.conflictBody!;
    note.updatedAt = note.conflictUpdatedAt!;

    note.syncStatus = SyncStatus.synced;
    note.pendingOperation = PendingOperation.none;

    note.lastSyncedAt = note.conflictUpdatedAt;

    note.conflictTitle = null;
    note.conflictBody = null;
    note.conflictUpdatedAt = null;

    await note.save();
  }
}
