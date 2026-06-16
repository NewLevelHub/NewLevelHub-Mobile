import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/auth/models/user.dart';
import 'package:newlevelhub_mobile/core/auth/models/user_role.dart';
import 'package:newlevelhub_mobile/core/network/api_exception.dart';
import 'package:newlevelhub_mobile/features/auth/application/auth_controller.dart';
import 'package:newlevelhub_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:newlevelhub_mobile/features/auth/presentation/view_models/verify_email_resend_result.dart';
import 'package:newlevelhub_mobile/features/auth/presentation/view_models/verify_email_view_model.dart';

void main() {
  group('VerifyEmailViewModel', () {
    late _FakeAuthRepository repository;
    late AuthController authController;

    setUp(() {
      repository = _FakeAuthRepository();
      authController = AuthController(authRepository: repository);
    });

    VerifyEmailViewModel buildViewModel({String email = 'user@example.com'}) {
      return VerifyEmailViewModel(
        authRepository: repository,
        authController: authController,
        email: email,
        rateLimitCooldown: const Duration(seconds: 30),
      );
    }

    test('loadSession enables resend when an access token exists', () async {
      repository.hasActiveSessionResult = true;
      final viewModel = buildViewModel();

      expect(viewModel.isLoadingSession, isTrue);
      await viewModel.loadSession();

      expect(viewModel.isLoadingSession, isFalse);
      expect(viewModel.canResend, isTrue);
    });

    test('loadSession hides resend with no access token (invite-register)', () async {
      repository.hasActiveSessionResult = false;
      final viewModel = buildViewModel();

      await viewModel.loadSession();

      expect(viewModel.canResend, isFalse);
    });

    test('resend publishes a success message', () async {
      repository.hasActiveSessionResult = true;
      final viewModel = buildViewModel();
      await viewModel.loadSession();

      final result = await viewModel.resend();

      expect(result, isA<VerifyEmailResendSuccess>());
      expect(viewModel.infoMessage, isNotNull);
      expect(viewModel.errorMessage, isNull);
      expect(repository.resendCalls, 1);
    });

    test('resend returns AlreadyVerified on 403', () async {
      repository.hasActiveSessionResult = true;
      repository.exceptionToThrow = const ApiException(
        message: 'Email уже подтверждён',
        statusCode: 403,
      );
      final viewModel = buildViewModel();
      await viewModel.loadSession();

      final result = await viewModel.resend();

      expect(result, isA<VerifyEmailResendAlreadyVerified>());
    });

    test('resend starts a cooldown on 429', () async {
      repository.hasActiveSessionResult = true;
      repository.exceptionToThrow = const ApiException(
        message: 'Слишком много запросов',
        statusCode: 429,
      );
      final viewModel = buildViewModel();
      await viewModel.loadSession();

      final result = await viewModel.resend();

      expect(result, isA<VerifyEmailResendRateLimited>());
      expect(viewModel.isInCooldown, isTrue);
      expect(viewModel.cooldownSeconds, 30);
      expect(viewModel.errorMessage, isNotNull);

      viewModel.dispose();
    });

    test('resend surfaces other failures as errorMessage', () async {
      repository.hasActiveSessionResult = true;
      repository.exceptionToThrow = const ApiException(
        message: 'Сервис временно недоступен',
        statusCode: 500,
      );
      final viewModel = buildViewModel();
      await viewModel.loadSession();

      final result = await viewModel.resend();

      expect(result, isA<VerifyEmailResendFailure>());
      expect(viewModel.errorMessage, 'Сервис временно недоступен');
    });

    test('toggles isResending around the repository call', () async {
      repository.hasActiveSessionResult = true;
      final viewModel = buildViewModel();
      await viewModel.loadSession();

      final future = viewModel.resend();
      expect(viewModel.isResending, isTrue);

      await future;
      expect(viewModel.isResending, isFalse);
    });

    test('logout clears the session and marks unauthenticated', () async {
      final viewModel = buildViewModel();
      authController.setAuthenticatedUser(_user());

      await viewModel.logout();

      expect(repository.logoutCalls, 1);
      expect(authController.isAuthenticated, isFalse);
    });
  });
}

User _user() => User(
      id: 1,
      email: 'user@example.com',
      firstName: 'Анна',
      lastName: 'Иванова',
      fullName: 'Анна Иванова',
      role: UserRole.employee,
      isEmailVerified: false,
      dateJoined: DateTime(2024, 1, 1),
    );

class _FakeAuthRepository implements AuthRepository {
  bool hasActiveSessionResult = false;
  ApiException? exceptionToThrow;
  int resendCalls = 0;
  int logoutCalls = 0;

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
  Future<void> verifyEmailToken(String token) async {}

  @override
  Future<void> logout() async {
    logoutCalls++;
  }

  @override
  Future<User> register({
    required String email,
    required String firstName,
    required String lastName,
    String? phone,
    required String password,
    required String passwordConfirm,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<User> fetchMe() => throw UnimplementedError();

  @override
  Future<bool> refresh() => throw UnimplementedError();
}
