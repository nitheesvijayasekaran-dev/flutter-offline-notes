import 'package:hive_ce_flutter/adapters.dart';
import 'package:offline_notes/hive_registrar.g.dart';
import 'package:offline_notes/model/note.dart';

class HiveService {
  static const _notesBox = 'notes';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapters();

    await Hive.openBox<Note>(_notesBox);
  }

  static Box<Note> get notesBox => Hive.box<Note>(_notesBox);
}
