import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/auth/models/user.dart';
import 'package:newlevelhub_mobile/core/auth/models/user_role.dart';
import 'package:newlevelhub_mobile/core/network/api_exception.dart';
import 'package:newlevelhub_mobile/core/router/auth_notifier.dart';
import 'package:newlevelhub_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:newlevelhub_mobile/features/auth/presentation/view_models/login_submit_result.dart';
import 'package:newlevelhub_mobile/features/auth/presentation/view_models/login_view_model.dart';

void main() {
  group('LoginViewModel.submit', () {
    late _FakeAuthRepository repository;
    late AuthNotifier authNotifier;
    late LoginViewModel viewModel;

    setUp(() {
      repository = _FakeAuthRepository();
      authNotifier = AuthNotifier();
      viewModel = LoginViewModel(
        authRepository: repository,
        authNotifier: authNotifier,
      );
    });

    test('rejects empty email/password without calling the repository', () async {
      final result = await viewModel.submit();

      expect(result, isA<LoginSubmitValidationFailed>());
      expect(viewModel.emailError, isNotNull);
      expect(viewModel.passwordError, isNotNull);
      expect(repository.loginCalls, 0);
    });

    test('rejects a malformed email', () async {
      viewModel.updateEmail('not-an-email');
      viewModel.updatePassword('SecurePass123!');

      final result = await viewModel.submit();

      expect(result, isA<LoginSubmitValidationFailed>());
      expect(viewModel.emailError, isNotNull);
      expect(repository.loginCalls, 0);
    });

    test('passes trimmed email, password and rememberMe to the repository', () async {
      repository.userToReturn = _user();
      viewModel.updateEmail('  user@example.com  ');
      viewModel.updatePassword('SecurePass123!');
      viewModel.setRememberMe(true);

      final result = await viewModel.submit();

      expect(result, isA<LoginSubmitSuccess>());
      expect(repository.lastEmail, 'user@example.com');
      expect(repository.lastPassword, 'SecurePass123!');
      expect(repository.lastRememberMe, isTrue);
    });

    test('marks the session authenticated with the returned user on success', () async {
      final user = _user();
      repository.userToReturn = user;
      viewModel.updateEmail('user@example.com');
      viewModel.updatePassword('SecurePass123!');

      await viewModel.submit();

      expect(authNotifier.isAuthenticated, isTrue);
      expect(authNotifier.currentUser, user);
    });

    test('returns LoginSubmitEmailNotVerified and does not authenticate', () async {
      repository.exceptionToThrow = const EmailNotVerifiedException(
        message: 'Подтвердите email перед входом',
      );
      viewModel.updateEmail('user@example.com');
      viewModel.updatePassword('SecurePass123!');

      final result = await viewModel.submit();

      expect(result, isA<LoginSubmitEmailNotVerified>());
      expect((result as LoginSubmitEmailNotVerified).email, 'user@example.com');
      expect(authNotifier.isAuthenticated, isFalse);
    });

    test('surfaces the backend message as errorMessage on invalid credentials (400)', () async {
      repository.exceptionToThrow = const ApiException(
        message: 'Неверный email или пароль.',
        statusCode: 400,
      );
      viewModel.updateEmail('user@example.com');
      viewModel.updatePassword('wrong-password');

      final result = await viewModel.submit();

      expect(result, isA<LoginSubmitFailure>());
      expect(viewModel.errorMessage, 'Неверный email или пароль.');
      expect(authNotifier.isAuthenticated, isFalse);
    });

    test('surfaces the backend message on a blocked account (403)', () async {
      repository.exceptionToThrow = const ApiException(
        code: 'PERMISSION_DENIED',
        message: 'Аккаунт заблокирован.',
        statusCode: 403,
      );
      viewModel.updateEmail('user@example.com');
      viewModel.updatePassword('SecurePass123!');

      final result = await viewModel.submit();

      expect(result, isA<LoginSubmitFailure>());
      expect(viewModel.errorMessage, 'Аккаунт заблокирован.');
    });

    test('toggles isLoading around the repository call', () async {
      repository.userToReturn = _user();
      viewModel.updateEmail('user@example.com');
      viewModel.updatePassword('SecurePass123!');

      final future = viewModel.submit();
      expect(viewModel.isLoading, isTrue);

      await future;
      expect(viewModel.isLoading, isFalse);
    });

    test('clears previous field errors and banner once a field is edited', () async {
      await viewModel.submit(); // populates emailError/passwordError
      expect(viewModel.emailError, isNotNull);

      viewModel.updateEmail('user@example.com');

      expect(viewModel.emailError, isNull);
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
      isEmailVerified: true,
      dateJoined: DateTime(2024, 1, 1),
    );

class _FakeAuthRepository implements AuthRepository {
  User? userToReturn;
  ApiException? exceptionToThrow;
  int loginCalls = 0;
  String? lastEmail;
  String? lastPassword;
  bool? lastRememberMe;

  @override
  Future<User> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    loginCalls++;
    lastEmail = email;
    lastPassword = password;
    lastRememberMe = rememberMe;

    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }

    return userToReturn!;
  }
}
