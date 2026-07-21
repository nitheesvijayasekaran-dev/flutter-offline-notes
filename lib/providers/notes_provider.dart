import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_notes/model/note.dart';
import 'package:offline_notes/providers/api_provider.dart';
import 'package:offline_notes/repo/note_repo.dart';
import 'package:offline_notes/services/sync_service.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(),
);

final notesProvider = NotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

class NotesNotifier extends Notifier<List<Note>> {
  late final NoteRepository _repository;
  late final SyncService _syncService;

  @override
  List<Note> build() {
    _repository = ref.read(noteRepositoryProvider);
    _syncService = ref.read(syncServiceProvider);

    return _repository.getAllNotes();
  }

  void refresh() {
    state = _repository.getAllNotes();
  }

  Future<void> sync() async {
    await _syncService.sync();
    refresh();
  }

  Future<void> createNote({required String title, required String body}) async {
    await _repository.createNote(title: title, body: body);

    refresh();
    ref.read(syncManagerProvider).start();
  }

  Future<void> updateNote(Note note) async {
    await _repository.updateNote(note);

    refresh();
    ref.read(syncManagerProvider).start();
  }

  Future<void> deleteNote(Note note) async {
    await _repository.deleteNote(note);

    refresh();
    ref.read(syncManagerProvider).start();
  }

  Future<void> resolveWithLocal(Note note) async {
    try {
      await _repository.useLocalVersion(note);

      await sync();
    } catch (e, s) {
      debugPrint('Resolve local failed: $e');
      debugPrint('$s');
    }

    refresh();
  }

  Future<void> resolveWithRemote(Note note) async {
    await _repository.useRemoteVersion(note);

    refresh();
  }
}
