import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/network/connectivity_probe.dart';
import 'package:newlevelhub_mobile/core/network/core_api.dart';
import 'package:newlevelhub_mobile/core/network/models/health_response.dart';
import 'package:newlevelhub_mobile/core/network/models/ping_response.dart';

class _FakeCoreApi extends CoreApi {
  _FakeCoreApi({
    required this.onPing,
    required this.onHealth,
  }) : super(Dio());

  final Future<PingResponse> Function() onPing;
  final Future<HealthResponse> Function() onHealth;

  @override
  Future<PingResponse> ping() => onPing();

  @override
  Future<HealthResponse> health() => onHealth();
}

void main() {
  group('ConnectivityProbe', () {
    test('returns ok when ping and health succeed', () async {
      const ping = PingResponse(message: 'pong', version: '1');
      const health = HealthResponse(status: 'healthy', database: 'connected');

      final probe = ConnectivityProbe(
        coreApi: _FakeCoreApi(
          onPing: () async => ping,
          onHealth: () async => health,
        ),
      );

      final result = await probe.run();
      expect(result, isA<ConnectivityProbeOk>());
    });

    test('returns health unavailable on 503', () async {
      const ping = PingResponse(message: 'pong', version: '1');
      const unhealthy = HealthResponse(
        status: 'unhealthy',
        database: 'unavailable',
      );

      final probe = ConnectivityProbe(
        coreApi: _FakeCoreApi(
          onPing: () async => ping,
          onHealth: () async => throw HealthUnavailableException(unhealthy),
        ),
      );

      final result = await probe.run();
      expect(result, isA<ConnectivityProbeHealthUnavailable>());
    });

    test('returns ping failed on network error', () async {
      final probe = ConnectivityProbe(
        coreApi: _FakeCoreApi(
          onPing: () async => throw DioException(
            requestOptions: RequestOptions(path: '/ping/'),
            type: DioExceptionType.connectionTimeout,
          ),
          onHealth: () async => const HealthResponse(
            status: 'healthy',
            database: 'connected',
          ),
        ),
      );

      final result = await probe.run();
      expect(result, isA<ConnectivityProbePingFailed>());
    });
  });
}
