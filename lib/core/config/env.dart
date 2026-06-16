/// Compile-time environment overrides via `--dart-define`.
///
/// Example:
/// `flutter run --dart-define=API_BASE_URL=https://example.com/api/v1`
class Env {
  Env._();

  /// Overrides [ApiConfig.baseUrl] when non-empty.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
}
