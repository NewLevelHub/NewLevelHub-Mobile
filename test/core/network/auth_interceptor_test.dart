import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/auth/token_storage.dart';
import 'package:newlevelhub_mobile/core/network/auth_interceptor.dart';

void main() {
  group('AuthInterceptor.isPublicPath', () {
    test('recognizes listed public paths', () {
      for (final path in AuthInterceptor.publicPaths) {
        expect(AuthInterceptor.isPublicPath(path), isTrue);
      }
    });

    test('treats protected paths as non-public', () {
      expect(AuthInterceptor.isPublicPath('/auth/me/'), isFalse);
      expect(AuthInterceptor.isPublicPath('/companies/'), isFalse);
    });
  });

  group('AuthInterceptor', () {
    late InMemorySecureStore store;
    late TokenStorage tokenStorage;
    late _RecordingAdapter adapter;
    late Dio dio;
    var sessionExpiredCalls = 0;

    setUp(() {
      store = InMemorySecureStore();
      tokenStorage = TokenStorage(store: store);
      sessionExpiredCalls = 0;
      adapter = _RecordingAdapter();
      dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/api/v1'));
      final refreshDio = Dio(BaseOptions(baseUrl: 'https://api.example.com/api/v1'));
      dio.httpClientAdapter = adapter;
      refreshDio.httpClientAdapter = adapter;
      dio.interceptors.add(
        AuthInterceptor(
          tokenStorage: tokenStorage,
          onSessionExpired: () => sessionExpiredCalls++,
          dio: dio,
          refreshDio: refreshDio,
        ),
      );
    });

    test('adds Bearer token to protected requests', () async {
      await tokenStorage.saveTokens(
        access: 'stored-access',
        refresh: 'stored-refresh',
      );
      adapter.enqueue(
        _MockResponse.json(200, {'id': 1}),
      );

      await dio.get<Map<String, dynamic>>('/auth/me/');

      expect(adapter.lastAuthorization, 'Bearer stored-access');
    });

    test('does not add Bearer to public paths', () async {
      await tokenStorage.saveTokens(
        access: 'stored-access',
        refresh: 'stored-refresh',
      );
      adapter.enqueue(
        _MockResponse.json(200, {'message': 'pong'}),
      );

      await dio.get<Map<String, dynamic>>('/ping/');

      expect(adapter.lastAuthorization, isNull);
    });

    test('refreshes on 401 and retries the original request', () async {
      await tokenStorage.saveTokens(
        access: 'expired-access',
        refresh: 'valid-refresh',
      );

      adapter
        ..enqueue(_MockResponse.json(401, _unauthenticatedBody))
        ..enqueue(
          _MockResponse.json(200, {
            'access': 'new-access',
            'refresh': 'new-refresh',
          }),
        )
        ..enqueue(_MockResponse.json(200, {'email': 'a@b.c'}));

      final response = await dio.get<Map<String, dynamic>>('/auth/me/');

      expect(response.statusCode, 200);
      expect(response.data?['email'], 'a@b.c');
      expect(adapter.refreshCallCount, 1);
      expect(await tokenStorage.getAccessToken(), 'new-access');
      expect(await tokenStorage.getRefreshToken(), 'new-refresh');
      expect(sessionExpiredCalls, 0);
    });

    test('calls onSessionExpired and clears tokens when refresh fails', () async {
      await tokenStorage.saveTokens(
        access: 'expired-access',
        refresh: 'invalid-refresh',
      );

      adapter
        ..enqueue(_MockResponse.json(401, _unauthenticatedBody))
        ..enqueue(_MockResponse.json(401, _sessionIdleBody));

      await expectLater(
        dio.get<Map<String, dynamic>>('/auth/me/'),
        throwsA(isA<DioException>()),
      );

      expect(adapter.refreshCallCount, 1);
      expect(await tokenStorage.hasTokens(), isFalse);
      expect(sessionExpiredCalls, 1);
    });

    test('parallel 401 responses trigger only one refresh request', () async {
      await tokenStorage.saveTokens(
        access: 'expired-access',
        refresh: 'valid-refresh',
      );

      for (var i = 0; i < 4; i++) {
        adapter.enqueue(_MockResponse.json(401, _unauthenticatedBody));
      }
      adapter.enqueue(
        _MockResponse.json(200, {
          'access': 'new-access',
          'refresh': 'new-refresh',
        }),
      );
      for (var i = 0; i < 4; i++) {
        adapter.enqueue(_MockResponse.json(200, {'ok': true}));
      }

      final results = await Future.wait(
        List.generate(4, (_) => dio.get<Map<String, dynamic>>('/auth/me/')),
      );

      expect(results, hasLength(4));
      expect(adapter.refreshCallCount, 1);
      expect(await tokenStorage.getAccessToken(), 'new-access');
      expect(await tokenStorage.getRefreshToken(), 'new-refresh');
    });

    test('does not retry more than once after refresh', () async {
      await tokenStorage.saveTokens(
        access: 'expired-access',
        refresh: 'valid-refresh',
      );

      adapter
        ..enqueue(_MockResponse.json(401, _unauthenticatedBody))
        ..enqueue(
          _MockResponse.json(200, {
            'access': 'new-access',
            'refresh': 'new-refresh',
          }),
        )
        ..enqueue(_MockResponse.json(401, _unauthenticatedBody));

      await expectLater(
        dio.get<Map<String, dynamic>>('/auth/me/'),
        throwsA(isA<DioException>()),
      );

      expect(adapter.refreshCallCount, 1);
      expect(sessionExpiredCalls, 1);
      expect(await tokenStorage.hasTokens(), isFalse);
    });
  });
}

const _unauthenticatedBody = {
  'success': false,
  'error': {
    'code': 'UNAUTHENTICATED',
    'message': 'Требуется авторизация',
  },
};

const _sessionIdleBody = {
  'success': false,
  'error': {
    'code': 'SESSION_IDLE_TIMEOUT',
    'message': 'Сессия истекла',
  },
};

class _MockResponse {
  static ResponseBody json(int statusCode, Map<String, dynamic> body) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _RecordingAdapter implements HttpClientAdapter {
  final List<ResponseBody> _queue = [];

  int refreshCallCount = 0;
  String? lastAuthorization;

  void enqueue(ResponseBody response) => _queue.add(response);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
  lastAuthorization = options.headers['Authorization']?.toString();

    final path = options.uri.path;
    if (path.contains('/auth/token/refresh/')) {
      refreshCallCount++;
    }

    if (_queue.isEmpty) {
      throw DioException(
        requestOptions: options,
        message: 'No mock response queued for ${options.method} $path',
      );
    }

    return _queue.removeAt(0);
  }

  @override
  void close({bool force = false}) {}
}

class InMemorySecureStore implements SecureKeyValueStore {
  final Map<String, String> _data = {};

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<String?> read({required String key}) async => _data[key];

  @override
  Future<void> delete({required String key}) async {
    _data.remove(key);
  }
}
