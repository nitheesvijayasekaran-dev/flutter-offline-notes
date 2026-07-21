import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_notes/providers/api_provider.dart';
import 'package:offline_notes/providers/notes_provider.dart';

class SyncManager {
  SyncManager(this.ref);

  final Ref ref;

  Timer? _timer;
  bool _isSyncing = false;

  Future<void> start() async {
    if (_timer != null) return;

    debugPrint('🚀 SyncManager started');

    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _syncIfNeeded());
  }

  void stop() {
    debugPrint('🛑 SyncManager stopped');

    _timer?.cancel();
    _timer = null;
  }

  Future<void> _syncIfNeeded() async {
    if (_isSyncing) return;

    final repo = ref.read(noteRepositoryProvider);

    final pending = repo.getPendingNotes();

    if (pending.isEmpty) {
      stop();
      return;
    }

    try {
      _isSyncing = true;

      debugPrint('Auto syncing...');

      final connected = await ref.read(connectivityServiceProvider).isConnected;

      if (!connected) {
        debugPrint('Waiting for internet...');
        return;
      }

      await ref.read(notesProvider.notifier).sync();
    } finally {
      _isSyncing = false;
    }
  }
}
