import 'package:dio/dio.dart';
import 'package:offline_notes/api/api_client.dart';
import 'package:offline_notes/core/constant.dart';

class ConnectivityService {
  final Dio _dio = ApiClient.dio;

  Future<bool> get isConnected async {
    try {
      await _dio.get(
        ApiConstants.notes,
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );

      return true;
    } on DioException {
      return false;
    }
  }
}
