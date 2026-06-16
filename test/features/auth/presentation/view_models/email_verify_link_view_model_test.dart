import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/auth/models/user.dart';
import 'package:newlevelhub_mobile/core/network/api_exception.dart';
import 'package:newlevelhub_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:newlevelhub_mobile/features/auth/presentation/view_models/email_verify_link_result.dart';
import 'package:newlevelhub_mobile/features/auth/presentation/view_models/email_verify_link_view_model.dart';

void main() {
  group('EmailVerifyLinkViewModel.verify', () {
    late _FakeAuthRepository repository;

    setUp(() {
      repository = _FakeAuthRepository();
    });

    EmailVerifyLinkViewModel buildViewModel({String token = 'a-token'}) {
      return EmailVerifyLinkViewModel(authRepository: repository, token: token);
    }

    test('starts in a loading state', () {
      final viewModel = buildViewModel();

      expect(viewModel.isLoading, isTrue);
      expect(viewModel.result, isNull);
    });

    test('reports success on a 200 response', () async {
      final viewModel = buildViewModel();

      await viewModel.verify();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.result, isA<EmailVerifyLinkSuccess>());
      expect(repository.verifiedToken, 'a-token');
    });

    test('treats an empty token as a failure without calling the repository', () async {
      final viewModel = buildViewModel(token: '');

      await viewModel.verify();

      expect(viewModel.result, isA<EmailVerifyLinkFailure>());
      expect(repository.verifyCalls, 0);
    });

    test('maps 404 to EmailVerifyLinkInvalid', () async {
      repository.exceptionToThrow = const ApiException(
        code: 'NOT_FOUND',
        message: 'Объект не найден.',
        statusCode: 404,
      );
      final viewModel = buildViewModel();

      await viewModel.verify();

      expect(viewModel.result, isA<EmailVerifyLinkInvalid>());
    });

    test('maps the backend\'s plain 400 "already used" message to EmailVerifyLinkAlreadyUsed', () async {
      repository.exceptionToThrow = const ApiException(
        message: 'Токен уже использован.',
        statusCode: 400,
      );
      final viewModel = buildViewModel();

      await viewModel.verify();

      expect(viewModel.result, isA<EmailVerifyLinkAlreadyUsed>());
    });

    test('maps the backend\'s plain 400 "expired" message to EmailVerifyLinkExpired', () async {
      repository.exceptionToThrow = const ApiException(
        message: 'Токен истёк.',
        statusCode: 400,
      );
      final viewModel = buildViewModel();

      await viewModel.verify();

      expect(viewModel.result, isA<EmailVerifyLinkExpired>());
    });

    test('falls back to EmailVerifyLinkFailure for any other error', () async {
      repository.exceptionToThrow = const ApiException(
        message: 'Сервис временно недоступен',
        statusCode: 500,
      );
      final viewModel = buildViewModel();

      await viewModel.verify();

      expect(
        viewModel.result,
        isA<EmailVerifyLinkFailure>().having(
          (r) => r.message,
          'message',
          'Сервис временно недоступен',
        ),
      );
    });

    test('reads canResend from hasActiveSession', () async {
      repository.hasActiveSessionResult = true;
      final viewModel = buildViewModel();

      await viewModel.verify();

      expect(viewModel.canResend, isTrue);
    });
  });

  group('EmailVerifyLinkViewModel.resend', () {
    test('is a no-op without an active session', () async {
      final repository = _FakeAuthRepository()..hasActiveSessionResult = false;
      final viewModel = EmailVerifyLinkViewModel(
        authRepository: repository,
        token: 'a-token',
      );
      await viewModel.verify();

      await viewModel.resend();

      expect(repository.resendCalls, 0);
    });

    test('publishes a success message when an access token exists', () async {
      final repository = _FakeAuthRepository()..hasActiveSessionResult = true;
      final viewModel = EmailVerifyLinkViewModel(
        authRepository: repository,
        token: 'a-token',
      );
      await viewModel.verify();

      await viewModel.resend();

      expect(repository.resendCalls, 1);
      expect(viewModel.resendFailed, isFalse);
      expect(viewModel.resendMessage, isNotNull);
    });

    test('surfaces a failure message on error', () async {
      final repository = _FakeAuthRepository()..hasActiveSessionResult = true;
      final viewModel = EmailVerifyLinkViewModel(
        authRepository: repository,
        token: 'a-token',
      );
      await viewModel.verify();
      repository.exceptionToThrow = const ApiException(
        message: 'Слишком много запросов',
        statusCode: 429,
      );

      await viewModel.resend();

      expect(viewModel.resendFailed, isTrue);
      expect(viewModel.resendMessage, 'Слишком много запросов');
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  bool hasActiveSessionResult = false;
  ApiException? exceptionToThrow;
  int verifyCalls = 0;
  int resendCalls = 0;
  String? verifiedToken;

  @override
  Future<User> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasActiveSession() async => hasActiveSessionResult;

  @override
  Future<void> resendVerificationEmail() async {
    resendCalls++;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
  }

  @override
  Future<void> verifyEmailToken(String token) async {
    verifyCalls++;
    verifiedToken = token;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
  }

  @override
  Future<void> logout() async {}
}
