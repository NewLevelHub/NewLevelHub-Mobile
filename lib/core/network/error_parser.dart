import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Parses backend error payloads from [DioException] into [ApiException].
class ErrorParser {
  ErrorParser._();

  static const _tooManyRequestsMessage = 'Слишком много запросов';
  static const _serverErrorMessage = 'Сервис временно недоступен';

  static ApiException parse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final envelope = _parseEnvelope(data, statusCode);
      if (envelope != null) {
        return _applyStatusDefaults(envelope);
      }

      final detail = _parseDetail(data, statusCode);
      if (detail != null) {
        return _applyStatusDefaults(detail);
      }
    }

    return _fallback(error, statusCode);
  }

  static ApiException? _parseEnvelope(
    Map<String, dynamic> data,
    int? statusCode,
  ) {
    final error = data['error'];
    if (error is! Map) {
      return null;
    }

    final code = error['code']?.toString();
    final message = error['message']?.toString();
    if (message == null || message.isEmpty) {
      return null;
    }

    return ApiException(
      code: code,
      message: message,
      statusCode: statusCode,
      fieldErrors: _parseFieldErrors(error['details']),
    );
  }

  static ApiException? _parseDetail(
    Map<String, dynamic> data,
    int? statusCode,
  ) {
    final detail = data['detail'];
    if (detail == null) {
      return null;
    }

    final message = switch (detail) {
      final String value => value,
      final List<dynamic> values when values.isNotEmpty => values.first.toString(),
      _ => null,
    };

    if (message == null || message.isEmpty) {
      return null;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
    );
  }

  static Map<String, List<String>>? _parseFieldErrors(dynamic details) {
    if (details is! Map) {
      return null;
    }

    final result = <String, List<String>>{};
    for (final entry in details.entries) {
      final key = entry.key;
      if (key is! String) {
        continue;
      }

      final messages = _stringList(entry.value);
      if (messages != null && messages.isNotEmpty) {
        result[key] = messages;
      }
    }

    return result.isEmpty ? null : result;
  }

  static List<String>? _stringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).where((s) => s.isNotEmpty).toList();
    }
    if (value is String && value.isNotEmpty) {
      return [value];
    }
    return null;
  }

  static ApiException _applyStatusDefaults(ApiException exception) {
    final status = exception.statusCode;

    if (status == 403 &&
        exception.code == EmailNotVerifiedException.emailNotVerifiedCode) {
      return EmailNotVerifiedException(
        message: exception.message,
        statusCode: status,
        fieldErrors: exception.fieldErrors,
      );
    }

    if (status == 429) {
      return ApiException(
        code: exception.code,
        message: _tooManyRequestsMessage,
        statusCode: status,
        fieldErrors: exception.fieldErrors,
      );
    }

    if (status != null && status >= 500) {
      return ApiException(
        code: exception.code ?? 'SERVER_ERROR',
        message: _serverErrorMessage,
        statusCode: status,
        fieldErrors: exception.fieldErrors,
      );
    }

    return exception;
  }

  static ApiException _fallback(DioException error, int? statusCode) {
    if (statusCode == 401) {
      return ApiException(
        code: 'UNAUTHENTICATED',
        message: error.message ?? 'Требуется авторизация',
        statusCode: statusCode,
      );
    }

    if (statusCode == 429) {
      return const ApiException(
        message: _tooManyRequestsMessage,
        statusCode: 429,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return ApiException(
        code: 'SERVER_ERROR',
        message: _serverErrorMessage,
        statusCode: statusCode,
      );
    }

    return ApiException(
      message: error.message ?? 'Ошибка сети',
      statusCode: statusCode,
    );
  }
}
