import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/auth/models/user.dart';
import 'package:newlevelhub_mobile/core/router/auth_notifier.dart';
import 'package:newlevelhub_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:newlevelhub_mobile/features/users/presentation/view_models/profile_view_model.dart';

void main() {
  group('ProfileViewModel.logout', () {
    late _FakeAuthRepository repository;
    late AuthNotifier authNotifier;
    late ProfileViewModel viewModel;

    setUp(() {
      repository = _FakeAuthRepository();
      authNotifier = AuthNotifier()..markAuthenticated();
      viewModel = ProfileViewModel(
        authRepository: repository,
        authNotifier: authNotifier,
      );
    });

    test('calls AuthRepository.logout', () async {
      await viewModel.logout();

      expect(repository.logoutCalls, 1);
    });

    test('marks the session unauthenticated regardless of the repository outcome', () async {
      repository.exceptionToThrow = Exception('boom');

      await viewModel.logout();

      expect(authNotifier.isAuthenticated, isFalse);
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
}
