import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/network/api_exception.dart';
import 'package:newlevelhub_mobile/core/network/error_parser.dart';

void main() {
  group('ErrorParser', () {
    test('parses validation 400 envelope with field details', () {
      final exception = ErrorParser.parse(
        _dioException(
          statusCode: 400,
          data: {
            'success': false,
            'error': {
              'code': 'VALIDATION_ERROR',
              'message': 'Email уже занят',
              'details': {
                'email': ['Пользователь с таким email уже существует.'],
                'password': ['Пароль слишком короткий.'],
              },
            },
          },
        ),
      );

      expect(exception, isA<ApiException>());
      expect(exception.statusCode, 400);
      expect(exception.code, 'VALIDATION_ERROR');
      expect(exception.message, 'Email уже занят');
      expect(exception.fieldErrors, {
        'email': ['Пользователь с таким email уже существует.'],
        'password': ['Пароль слишком короткий.'],
      });
      expect(exception.isUnauthorized, isFalse);
    });

    test('parses simplified DRF detail on 400', () {
      final exception = ErrorParser.parse(
        _dioException(
          statusCode: 400,
          data: {
            'detail': 'Неверные учётные данные',
          },
        ),
      );

      expect(exception.statusCode, 400);
      expect(exception.code, isNull);
      expect(exception.message, 'Неверные учётные данные');
      expect(exception.fieldErrors, isNull);
      expect(exception.isUnauthorized, isFalse);
    });

    test('parses 401 as unauthorized', () {
      final exception = ErrorParser.parse(
        _dioException(
          statusCode: 401,
          data: {
            'success': false,
            'error': {
              'code': 'UNAUTHENTICATED',
              'message': 'Требуется авторизация',
              'details': {},
            },
          },
        ),
      );

      expect(exception.statusCode, 401);
      expect(exception.code, 'UNAUTHENTICATED');
      expect(exception.message, 'Требуется авторизация');
      expect(exception.isUnauthorized, isTrue);
    });

    test('parses 500 with generic server message', () {
      final exception = ErrorParser.parse(
        _dioException(
          statusCode: 500,
          data: {
            'success': false,
            'error': {
              'code': 'SERVER_ERROR',
              'message': 'Internal server error',
              'details': {},
            },
          },
        ),
      );

      expect(exception.statusCode, 500);
      expect(exception.code, 'SERVER_ERROR');
      expect(exception.message, 'Сервис временно недоступен');
      expect(exception.isUnauthorized, isFalse);
    });

    test('parses 403 EMAIL_NOT_VERIFIED as dedicated type', () {
      final exception = ErrorParser.parse(
        _dioException(
          statusCode: 403,
          data: {
            'success': false,
            'error': {
              'code': 'EMAIL_NOT_VERIFIED',
              'message': 'Подтвердите email перед входом',
              'details': {},
            },
          },
        ),
      );

      expect(exception, isA<EmailNotVerifiedException>());
      expect(exception.code, 'EMAIL_NOT_VERIFIED');
      expect(exception.message, 'Подтвердите email перед входом');
      expect(exception.isUnauthorized, isFalse);
    });

    test('parses 429 with rate-limit message', () {
      final exception = ErrorParser.parse(
        _dioException(
          statusCode: 429,
          data: {
            'detail': 'Слишком много попыток',
          },
        ),
      );

      expect(exception.statusCode, 429);
      expect(exception.message, 'Слишком много запросов');
    });
  });
}

DioException _dioException({
  required int statusCode,
  required Map<String, dynamic> data,
}) {
  final requestOptions = RequestOptions(path: '/test');
  return DioException(
    requestOptions: requestOptions,
    response: Response(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: data,
    ),
    type: DioExceptionType.badResponse,
  );
}
