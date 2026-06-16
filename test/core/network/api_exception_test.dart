import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/network/api_exception.dart';

void main() {
  group('ApiException.fieldError', () {
    const exception = ApiException(
      message: 'Validation failed',
      fieldErrors: {
        'email': ['Invalid email', 'Required'],
        'password': [],
      },
    );

    test('returns first error for field', () {
      expect(exception.fieldError('email'), 'Invalid email');
    });

    test('returns null for missing field', () {
      expect(exception.fieldError('username'), isNull);
    });

    test('returns null for empty error list', () {
      expect(exception.fieldError('password'), isNull);
    });
  });
}
