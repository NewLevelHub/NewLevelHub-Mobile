import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/config/api_config.dart';
import 'package:newlevelhub_mobile/core/config/env.dart';

void main() {
  group('resolveMediaUrl', () {
    test('returns empty string for null', () {
      expect(resolveMediaUrl(null), '');
    });

    test('returns empty string for empty string', () {
      expect(resolveMediaUrl(''), '');
    });

    test('prefixes relative path with mediaOrigin', () {
      expect(
        resolveMediaUrl('/media/x.jpg'),
        '${ApiConfig.mediaOrigin}/media/x.jpg',
      );
    });

    test('returns absolute URL unchanged', () {
      const url = 'https://cdn.example.com/media/x.jpg';
      expect(resolveMediaUrl(url), url);
    });
  });

  group('ApiConfig', () {
    test('baseUrl resolves from Env or production default', () {
      final expected = Env.apiBaseUrl.isNotEmpty
          ? Env.apiBaseUrl
          : 'https://production.newlevelhub.kz/api/v1';
      expect(ApiConfig.baseUrl, expected);
    });

    test('defaultHeaders include JSON content type and language', () {
      expect(ApiConfig.defaultHeaders, {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'ru',
      });
    });

    test('multipartHeaders omit Content-Type', () {
      expect(ApiConfig.multipartHeaders, {
        'Accept': 'application/json',
        'Accept-Language': 'ru',
      });
      expect(ApiConfig.multipartHeaders.containsKey('Content-Type'), isFalse);
    });
  });
}
