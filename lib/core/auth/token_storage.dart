import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Key-value backend used by [TokenStorage]. Implemented by
/// [FlutterSecureKeyValueStore] in production; inject a fake in unit tests.
abstract interface class SecureKeyValueStore {
  Future<void> write({required String key, required String? value});

  Future<String?> read({required String key});

  Future<void> delete({required String key});
}

/// [FlutterSecureStorage] adapter — Keychain on iOS, Keystore-backed
/// encryption on Android (not plain SharedPreferences).
class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  FlutterSecureKeyValueStore({FlutterSecureStorage? storage})
      : _storage = storage ?? _defaultStorage;

  static const FlutterSecureStorage _defaultStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final FlutterSecureStorage _storage;

  @override
  Future<void> write({required String key, required String? value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read({required String key}) =>
      _storage.read(key: key);

  @override
  Future<void> delete({required String key}) =>
      _storage.delete(key: key);
}

/// Secure local storage for JWT access and refresh tokens.
///
/// Persist tokens from `tokens.access` / `tokens.refresh` in login/register
/// responses. Ignore the HttpOnly `refresh_token` cookie — it is for web only.
///
/// After each successful `/auth/token/refresh/`, call [saveTokens] with the
/// new pair; refresh tokens rotate and the previous refresh becomes invalid.
class TokenStorage {
  TokenStorage({SecureKeyValueStore? store})
      : _store = store ?? FlutterSecureKeyValueStore();

  final SecureKeyValueStore _store;

  static const _accessKey = 'auth.access_token';
  static const _refreshKey = 'auth.refresh_token';

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await Future.wait([
      _store.write(key: _accessKey, value: access),
      _store.write(key: _refreshKey, value: refresh),
    ]);
  }

  Future<String?> getAccessToken() => _store.read(key: _accessKey);

  Future<String?> getRefreshToken() => _store.read(key: _refreshKey);

  Future<void> clearTokens() async {
    await Future.wait([
      _store.delete(key: _accessKey),
      _store.delete(key: _refreshKey),
    ]);
  }

  Future<bool> hasTokens() async {
    final access = await getAccessToken();
    final refresh = await getRefreshToken();
    return access != null &&
        access.isNotEmpty &&
        refresh != null &&
        refresh.isNotEmpty;
  }
}
