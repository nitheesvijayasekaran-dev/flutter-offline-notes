import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_notes/api/note_api.dart';
import 'package:offline_notes/manager/sync_manager.dart';
import 'package:offline_notes/providers/notes_provider.dart';
import 'package:offline_notes/services/connectivity_service.dart';
import 'package:offline_notes/services/sync_service.dart';

final noteApiProvider = Provider<NoteApi>((ref) => NoteApi());

final syncServiceProvider = Provider<SyncService>(
  (ref) => SyncService(
    repository: ref.read(noteRepositoryProvider),
    api: ref.read(noteApiProvider),
  ),
);

final syncManagerProvider = Provider<SyncManager>((ref) {
  final manager = SyncManager(ref);
  manager.start();
  ref.onDispose(manager.stop);
  return manager;
});

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(),
);
