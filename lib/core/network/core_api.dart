import 'package:dio/dio.dart';

import 'models/health_response.dart';
import 'models/ping_response.dart';

/// Core system endpoints: ping, health.
class CoreApi {
  CoreApi(this._dio);

  final Dio _dio;

  Future<PingResponse> ping() async {
    final response = await _dio.get<Map<String, dynamic>>('/ping/');
    return PingResponse.fromJson(response.data!);
  }

  /// Returns [HealthResponse] on 200.
  ///
  /// Throws [HealthUnavailableException] when the API responds with 503.
  Future<HealthResponse> health() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/health/',
      options: Options(
        validateStatus: (status) =>
            status != null && (status == 200 || status == 503),
      ),
    );

    final body = HealthResponse.fromJson(response.data!);

    if (response.statusCode == 503) {
      throw HealthUnavailableException(body);
    }

    return body;
  }
}

/// API is reachable but the database is unavailable (HTTP 503).
class HealthUnavailableException implements Exception {
  HealthUnavailableException(this.response);

  final HealthResponse response;

  @override
  String toString() =>
      'HealthUnavailableException(status: ${response.status}, '
      'database: ${response.database})';
}
