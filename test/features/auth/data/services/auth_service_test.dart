import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/auth/models/user_role.dart';
import 'package:newlevelhub_mobile/core/network/api_exception.dart';
import 'package:newlevelhub_mobile/features/auth/data/services/auth_service.dart';

void main() {
  late _QueueAdapter adapter;
  late Dio dio;
  late AuthService service;

  setUp(() {
    adapter = _QueueAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/api/v1'));
    dio.httpClientAdapter = adapter;
    service = AuthService(dio);
  });

  group('AuthService.login', () {
    test('parses user + tokens from a 200 response', () async {
      adapter.enqueue(_jsonResponse(200, {
        'user': _userJson(),
        'tokens': {'access': 'access-jwt', 'refresh': 'refresh-jwt'},
      }));

      final result = await service.login(
        email: 'user@example.com',
        password: 'SecurePass123!',
        rememberMe: true,
      );

      expect(result.user.email, 'user@example.com');
      expect(result.user.role, UserRole.employee);
      expect(result.tokens.access, 'access-jwt');
      expect(result.tokens.refresh, 'refresh-jwt');
    });

    test('posts to /auth/login/ with email, password and remember_me', () async {
      adapter.enqueue(_jsonResponse(200, {
        'user': _userJson(),
        'tokens': {'access': 'a', 'refresh': 'r'},
      }));

      await service.login(
        email: 'user@example.com',
        password: 'SecurePass123!',
        rememberMe: false,
      );

      expect(adapter.lastPath, '/api/v1/auth/login/');
      expect(adapter.lastBody, {
        'email': 'user@example.com',
        'password': 'SecurePass123!',
        'remember_me': false,
      });
    });

    test('throws ApiException with the backend message on 400 invalid credentials', () async {
      adapter.enqueue(_jsonResponse(400, {
        'success': false,
        'error': {
          'code': 'VALIDATION_ERROR',
          'message': 'Неверный email или пароль.',
          'details': {},
        },
      }));

      await expectLater(
        service.login(email: 'a@b.c', password: 'wrong', rememberMe: false),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Неверный email или пароль.',
          ),
        ),
      );
    });

    test('throws EmailNotVerifiedException on 403 EMAIL_NOT_VERIFIED', () async {
      adapter.enqueue(_jsonResponse(403, {
        'success': false,
        'error': {
          'code': 'EMAIL_NOT_VERIFIED',
          'message': 'Подтвердите email перед входом',
          'details': {},
        },
      }));

      await expectLater(
        service.login(email: 'a@b.c', password: 'pw', rememberMe: false),
        throwsA(isA<EmailNotVerifiedException>()),
      );
    });

    test('throws ApiException with the blocked-account message on 403 PERMISSION_DENIED', () async {
      adapter.enqueue(_jsonResponse(403, {
        'success': false,
        'error': {
          'code': 'PERMISSION_DENIED',
          'message': 'Аккаунт заблокирован.',
          'details': {},
        },
      }));

      await expectLater(
        service.login(email: 'a@b.c', password: 'pw', rememberMe: false),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Аккаунт заблокирован.')
              .having((e) => e.isUnauthorized, 'isUnauthorized', isFalse),
        ),
      );
    });
  });

  group('AuthService.resendVerificationEmail', () {
    test('posts to /auth/email/resend/ and completes on 200', () async {
      adapter.enqueue(_jsonResponse(200, {'detail': 'Письмо отправлено'}));

      await service.resendVerificationEmail();

      expect(adapter.lastPath, '/api/v1/auth/email/resend/');
    });

    test('throws ApiException(403) when already verified', () async {
      adapter.enqueue(_jsonResponse(403, {'detail': 'Email уже подтверждён'}));

      await expectLater(
        service.resendVerificationEmail(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 403)
              .having((e) => e.message, 'message', 'Email уже подтверждён'),
        ),
      );
    });

    test('throws ApiException(429) when rate-limited', () async {
      adapter.enqueue(_jsonResponse(429, {'detail': 'Слишком много запросов.'}));

      await expectLater(
        service.resendVerificationEmail(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 429),
        ),
      );
    });
  });

  group('AuthService.verifyEmail', () {
    test('gets /auth/email/verify/ with the token query parameter', () async {
      adapter.enqueue(_jsonResponse(200, {'detail': 'Email подтверждён'}));

      await service.verifyEmail('a-token');

      expect(adapter.lastPath, '/api/v1/auth/email/verify/');
    });

    test('throws ApiException(404) when the token does not exist', () async {
      adapter.enqueue(_jsonResponse(404, {
        'success': false,
        'error': {
          'code': 'NOT_FOUND',
          'message': 'Объект не найден.',
          'details': {},
        },
      }));

      await expectLater(
        service.verifyEmail('missing-token'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });

    test('throws ApiException(400) with the plain detail message when already used', () async {
      adapter.enqueue(_jsonResponse(400, {'detail': 'Токен уже использован.'}));

      await expectLater(
        service.verifyEmail('used-token'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', 'Токен уже использован.'),
        ),
      );
    });

    test('throws ApiException(400) with the plain detail message when expired', () async {
      adapter.enqueue(_jsonResponse(400, {'detail': 'Токен истёк.'}));

      await expectLater(
        service.verifyEmail('expired-token'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', 'Токен истёк.'),
        ),
      );
    });
  });
}

Map<String, dynamic> _userJson() => {
      'id': 1,
      'email': 'user@example.com',
      'first_name': 'Анна',
      'last_name': 'Иванова',
      'full_name': 'Анна Иванова',
      'phone': null,
      'position': null,
      'avatar': null,
      'role': 'employee',
      'company': {'id': 10, 'name': 'Acme'},
      'is_email_verified': true,
      'date_joined': '2024-01-01T00:00:00Z',
    };

ResponseBody _jsonResponse(int statusCode, Map<String, dynamic> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

class _QueueAdapter implements HttpClientAdapter {
  final List<ResponseBody> _queue = [];

  String? lastPath;
  Map<String, dynamic>? lastBody;

  void enqueue(ResponseBody response) => _queue.add(response);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastPath = options.uri.path;
    final data = options.data;
    if (data is Map<String, dynamic>) {
      lastBody = data;
    }

    if (_queue.isEmpty) {
      throw DioException(
        requestOptions: options,
        message: 'No mock response queued for ${options.method} ${options.uri.path}',
      );
    }

    return _queue.removeAt(0);
  }

  @override
  void close({bool force = false}) {}
}
