/// Application route paths for [GoRouter].
abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const verifyEmail = '/verify-email';
  static const invite = '/invite';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const home = '/home';
  static const profile = '/profile';
  static const uiKitDemo = '/ui-kit-demo';

  /// Debug-only manual entry for the email-verification token — fallback
  /// for testing the deep link flow without sending a real email
  /// (`kDebugMode` only, see `DebugDeepLinkScreen`).
  static const debugVerifyEmailToken = '/debug/verify-email-token';

  /// Routes that require an authenticated session.
  static const authRequired = <String>{home, profile};

  /// Custom URL scheme for deep links (full setup in MOB-104, MOB-106).
  static const deepLinkScheme = 'newlevelhub';
}
