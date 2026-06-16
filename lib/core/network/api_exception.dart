/// Unified API error produced by [ErrorParser].
class ApiException implements Exception {
  const ApiException({
    this.code,
    required this.message,
    this.statusCode,
    this.fieldErrors,
  });

  final String? code;
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  /// HTTP 401 — triggers token refresh / logout in the auth interceptor (MOB-006).
  bool get isUnauthorized => statusCode == 401;

  /// First validation message for [fieldName], or null if none.
  String? fieldError(String fieldName) {
    final errors = fieldErrors?[fieldName];
    if (errors == null || errors.isEmpty) return null;
    return errors.first;
  }

  @override
  String toString() =>
      'ApiException(code: $code, statusCode: $statusCode, message: $message)';
}

/// Email not verified (403 + [emailNotVerifiedCode]) — navigate to verification screen.
class EmailNotVerifiedException extends ApiException {
  const EmailNotVerifiedException({
    required super.message,
    super.statusCode = 403,
    super.fieldErrors,
  }) : super(code: emailNotVerifiedCode);

  static const emailNotVerifiedCode = 'EMAIL_NOT_VERIFIED';
}
