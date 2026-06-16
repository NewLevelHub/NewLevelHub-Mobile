import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/config/api_config.dart';
import 'package:newlevelhub_mobile/core/network/core_api.dart';
import 'package:newlevelhub_mobile/core/network/dio_client.dart';
import 'package:newlevelhub_mobile/core/network/interceptors/debug_log_interceptor.dart';
import 'package:newlevelhub_mobile/core/network/models/health_response.dart';
import 'package:newlevelhub_mobile/core/network/models/ping_response.dart';

void main() {
  group('DioClient', () {
    test('singleton returns same instance', () {
      expect(identical(DioClient(), DioClient.instance), isTrue);
    });

    test('dio is configured with prod baseUrl and timeouts', () {
      final dio = DioClient.instance.dio;

      expect(dio.options.baseUrl, ApiConfig.baseUrl);
      expect(dio.options.connectTimeout, const Duration(seconds: 30));
      expect(dio.options.receiveTimeout, const Duration(seconds: 30));
      expect(dio.options.headers['Accept'], 'application/json');
      expect(dio.options.headers['Accept-Language'], 'ru');
    });
  });

  group('DebugLogInterceptor', () {
    test('marks auth paths as sensitive', () {
      expect(DebugLogInterceptor.isSensitivePath('/auth/login/'), isTrue);
      expect(DebugLogInterceptor.isSensitivePath('/auth/register/'), isTrue);
      expect(
        DebugLogInterceptor.isSensitivePath('/auth/token/refresh/'),
        isTrue,
      );
      expect(DebugLogInterceptor.isSensitivePath('/ping/'), isFalse);
    });

    test('logs method and path without request body', () {
      final messages = <String>[];
      final interceptor = DebugLogInterceptor(log: messages.add);
      final handler = _NoOpRequestHandler();

      interceptor.onRequest(
        RequestOptions(
          path: '/auth/login/',
          method: 'POST',
          data: {'email': 'a@b.c', 'password': 'secret'},
        ),
        handler,
      );

      expect(messages, hasLength(1));
      expect(messages.single, contains('POST'));
      expect(messages.single, contains('/auth/login/'));
      expect(messages.single, contains('body redacted'));
      expect(messages.single, isNot(contains('secret')));
    });

    test('logs status code on response', () {
      final messages = <String>[];
      final interceptor = DebugLogInterceptor(log: messages.add);
      final handler = _NoOpResponseHandler();

      interceptor.onResponse(
        Response<dynamic>(
          requestOptions: RequestOptions(path: '/ping/', method: 'GET'),
          statusCode: 200,
          data: {'message': 'pong'},
        ),
        handler,
      );

      expect(messages.single, contains('GET'));
      expect(messages.single, contains('/ping/'));
      expect(messages.single, contains('200'));
      expect(messages.single, isNot(contains('pong')));
    });
  });

  group('CoreApi models', () {
    test('PingResponse.fromJson', () {
      final ping = PingResponse.fromJson({
        'message': 'pong',
        'version': 'beta-test',
      });

      expect(ping.message, 'pong');
      expect(ping.version, 'beta-test');
    });

    test('HealthResponse.fromJson', () {
      final health = HealthResponse.fromJson({
        'status': 'healthy',
        'database': 'connected',
        'deployment_marker': 'x',
        'environment': 'prod',
      });

      expect(health.isHealthy, isTrue);
      expect(health.deploymentMarker, 'x');
      expect(health.environment, 'prod');
    });
  });

  group('CoreApi integration', () {
    test('ping returns 200 from prod API', () async {
      final api = CoreApi(DioClient.instance.dio);
      final ping = await api.ping();

      expect(ping.message, 'pong');
      expect(ping.version, isNotEmpty);
    }, skip: !_hasNetwork);

    test('health returns healthy status from prod API', () async {
      final api = CoreApi(DioClient.instance.dio);
      final health = await api.health();

      expect(health.isHealthy, isTrue);
      expect(health.database, 'connected');
    }, skip: !_hasNetwork);
  });
}

const _hasNetwork = bool.fromEnvironment('RUN_NETWORK_TESTS', defaultValue: false);

class _NoOpRequestHandler extends RequestInterceptorHandler {
  @override
  void next(RequestOptions options) {}
}

class _NoOpResponseHandler extends ResponseInterceptorHandler {
  @override
  void next(Response<dynamic> response) {}
}
