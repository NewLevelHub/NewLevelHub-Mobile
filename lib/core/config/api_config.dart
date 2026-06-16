import 'env.dart';

/// Centralized API and media URL configuration for all network requests.
class ApiConfig {
  ApiConfig._();

  static const String _productionBaseUrl =
      'https://production.newlevelhub.kz/api/v1';

  /// API base URL. Override at build time with
  /// `--dart-define=API_BASE_URL=https://example.com/api/v1`.
  static String get baseUrl =>
      Env.apiBaseUrl.isNotEmpty ? Env.apiBaseUrl : _productionBaseUrl;

  /// Origin for resolving relative media paths (avatars, QR codes, etc.).
  static const String mediaOrigin = 'https://production.newlevelhub.kz';

  static const String defaultLanguage = 'ru';

  /// Default headers for JSON API requests.
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Accept-Language': defaultLanguage,
  };

  /// Default headers for multipart requests (no Content-Type — set by the client).
  static const Map<String, String> multipartHeaders = {
    'Accept': 'application/json',
    'Accept-Language': defaultLanguage,
  };
}

/// Resolves a media path to a full URL.
///
/// Returns an empty string for null or empty input.
/// Absolute URLs (`http…`) are returned unchanged.
/// Relative paths are prefixed with [ApiConfig.mediaOrigin].
String resolveMediaUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  return '${ApiConfig.mediaOrigin}$path';
}
