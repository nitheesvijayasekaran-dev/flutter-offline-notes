import 'package:dio/dio.dart';
import 'package:offline_notes/api/api_client.dart';
import 'package:offline_notes/core/constant.dart';
import 'package:offline_notes/model/remote_note.dart';

class NoteApi {
  final Dio _dio = ApiClient.dio;

  /// GET All Notes
  Future<List<RemoteNote>> getNotes() async {
    final response = await _dio.get(ApiConstants.notes);

    return (response.data as List).map((e) => RemoteNote.fromJson(e)).toList();
  }

  /// GET Single Note
  Future<RemoteNote> getNote(String id) async {
    final response = await _dio.get('${ApiConstants.notes}/$id');

    return RemoteNote.fromJson(response.data);
  }

  /// POST
  Future<RemoteNote> createNote(RemoteNote note) async {
    final response = await _dio.post(ApiConstants.notes, data: note.toJson());

    return RemoteNote.fromJson(response.data);
  }

  /// PUT
  Future<RemoteNote> updateNote(RemoteNote note) async {
    final response = await _dio.put(
      '${ApiConstants.notes}/${note.id}',
      data: note.toJson(),
    );

    return RemoteNote.fromJson(response.data);
  }

  /// DELETE
  Future<void> deleteNote(String id) async {
    await _dio.delete('${ApiConstants.notes}/$id');
  }
}
