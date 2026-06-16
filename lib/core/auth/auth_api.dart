import 'package:dio/dio.dart';

/// Auth endpoints used during session validation (splash flow).
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  /// Returns `true` when `GET /auth/me/` responds with HTTP 200.
  Future<bool> validateSession() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me/');
      return response.statusCode == 200;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        return false;
      }
      rethrow;
    }
  }
}
