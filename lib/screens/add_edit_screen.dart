import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_notes/model/note.dart';
import 'package:offline_notes/providers/notes_provider.dart';

class NoteAddEditScreen extends ConsumerStatefulWidget {
  final Note? note;

  const NoteAddEditScreen({super.key, this.note});

  @override
  ConsumerState<NoteAddEditScreen> createState() => _NoteAddEditScreenState();
}

class _NoteAddEditScreenState extends ConsumerState<NoteAddEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  bool get isEdit => widget.note != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.note?.title ?? '');

    _bodyController = TextEditingController(text: widget.note?.body ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (isEdit) {
      widget.note!
        ..title = _titleController.text.trim()
        ..body = _bodyController.text.trim();

      await ref.read(notesProvider.notifier).updateNote(widget.note!);
    } else {
      await ref
          .read(notesProvider.notifier)
          .createNote(
            title: _titleController.text.trim(),
            body: _bodyController.text.trim(),
          );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(isEdit ? 'Edit Note' : 'New Note')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter title';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            Expanded(
              child: TextFormField(
                controller: _bodyController,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  alignLabelWithHint: true,
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Text(isEdit ? 'Update Note' : 'Save Note'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
