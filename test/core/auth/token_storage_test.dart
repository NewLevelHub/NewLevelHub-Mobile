import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/auth/token_storage.dart';

void main() {
  group('TokenStorage', () {
    late InMemorySecureStore store;
    late TokenStorage tokenStorage;

    setUp(() {
      store = InMemorySecureStore();
      tokenStorage = TokenStorage(store: store);
    });

    test('save → read returns stored tokens', () async {
      await tokenStorage.saveTokens(
        access: 'access-jwt',
        refresh: 'refresh-jwt',
      );

      expect(await tokenStorage.getAccessToken(), 'access-jwt');
      expect(await tokenStorage.getRefreshToken(), 'refresh-jwt');
    });

    test('hasTokens is true after save', () async {
      expect(await tokenStorage.hasTokens(), isFalse);

      await tokenStorage.saveTokens(
        access: 'access-jwt',
        refresh: 'refresh-jwt',
      );

      expect(await tokenStorage.hasTokens(), isTrue);
    });

    test('clear removes access and refresh', () async {
      await tokenStorage.saveTokens(
        access: 'access-jwt',
        refresh: 'refresh-jwt',
      );

      await tokenStorage.clearTokens();

      expect(await tokenStorage.getAccessToken(), isNull);
      expect(await tokenStorage.getRefreshToken(), isNull);
      expect(await tokenStorage.hasTokens(), isFalse);
    });

    test('save overwrites tokens on refresh rotation', () async {
      await tokenStorage.saveTokens(
        access: 'old-access',
        refresh: 'old-refresh',
      );

      await tokenStorage.saveTokens(
        access: 'new-access',
        refresh: 'new-refresh',
      );

      expect(await tokenStorage.getAccessToken(), 'new-access');
      expect(await tokenStorage.getRefreshToken(), 'new-refresh');
      expect(await tokenStorage.hasTokens(), isTrue);
    });

    test('hasTokens is false when only access is stored', () async {
      await store.write(key: 'auth.access_token', value: 'access-only');

      expect(await tokenStorage.hasTokens(), isFalse);
    });
  });
}

/// In-memory [SecureKeyValueStore] for unit tests (not plain SharedPreferences).
class InMemorySecureStore implements SecureKeyValueStore {
  final Map<String, String> _data = {};

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<String?> read({required String key}) async => _data[key];

  @override
  Future<void> delete({required String key}) async {
    _data.remove(key);
  }
}
