import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/auth/models/user.dart';
import 'package:newlevelhub_mobile/core/auth/models/user_role.dart';
import 'package:newlevelhub_mobile/features/auth/application/auth_controller.dart';
import 'package:newlevelhub_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:newlevelhub_mobile/features/users/presentation/view_models/profile_view_model.dart';

void main() {
  group('ProfileViewModel.logout', () {
    late _FakeAuthRepository repository;
    late AuthController authController;
    late ProfileViewModel viewModel;

    setUp(() {
      repository = _FakeAuthRepository();
      authController = AuthController(authRepository: repository)
        ..setAuthenticatedUser(_user());
      viewModel = ProfileViewModel(
        authRepository: repository,
        authController: authController,
      );
    });

    test('calls AuthRepository.logout', () async {
      await viewModel.logout();

      expect(repository.logoutCalls, 1);
    });

    test('marks the session unauthenticated regardless of the repository outcome', () async {
      repository.exceptionToThrow = Exception('boom');

      await viewModel.logout();

      expect(authController.isAuthenticated, isFalse);
    });

    test('toggles isLoggingOut around the repository call', () async {
      final future = viewModel.logout();
      expect(viewModel.isLoggingOut, isTrue);

      await future;
      expect(viewModel.isLoggingOut, isFalse);
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  int logoutCalls = 0;
  Object? exceptionToThrow;

  @override
  Future<void> logout() async {
    logoutCalls++;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
  }

  @override
  Future<User> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasActiveSession() async => true;

  @override
  Future<void> resendVerificationEmail() async {}

  @override
  Future<void> verifyEmailToken(String token) async {}

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
