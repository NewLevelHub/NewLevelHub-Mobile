import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/auth_notifier.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth_strings.dart';
import 'login_submit_result.dart';

/// Holds the email/password login form state and orchestrates submission
/// through [AuthRepository]. The view only reads state via the public
/// getters and calls [submit] — it never touches the repository directly.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({
    required AuthRepository authRepository,
    required AuthNotifier authNotifier,
  })  : _authRepository = authRepository,
        _authNotifier = authNotifier;

  final AuthRepository _authRepository;
  final AuthNotifier _authNotifier;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String _email = '';
  String _password = '';
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _errorMessage;

  String get email => _email;
  String get password => _password;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;

  /// Top-level error banner text (e.g. invalid credentials, blocked
  /// account, network error) — `null` when there is nothing to show.
  String? get errorMessage => _errorMessage;

  void updateEmail(String value) {
    _email = value;
    _emailError = null;
    _errorMessage = null;
    notifyListeners();
  }

  void updatePassword(String value) {
    _password = value;
    _passwordError = null;
    _errorMessage = null;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  /// Validates the form, then calls [AuthRepository.login] if valid.
  Future<LoginSubmitResult> submit() async {
    final trimmedEmail = _email.trim();
    _emailError = _validateEmail(trimmedEmail);
    _passwordError = _validatePassword(_password);

    if (_emailError != null || _passwordError != null) {
      notifyListeners();
      return const LoginSubmitValidationFailed();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.login(
        email: trimmedEmail,
        password: _password,
        rememberMe: _rememberMe,
      );
      _authNotifier.setAuthenticatedUser(user);
      return const LoginSubmitSuccess();
    } on EmailNotVerifiedException {
      return LoginSubmitEmailNotVerified(trimmedEmail);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return LoginSubmitFailure(e.message);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return AuthStrings.emailRequired;
    if (!_emailPattern.hasMatch(value)) return AuthStrings.emailInvalid;
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return AuthStrings.passwordRequired;
    return null;
  }
}
