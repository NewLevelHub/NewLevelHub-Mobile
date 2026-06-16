import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

/// Intercepts incoming deep links (Android App Links / iOS Universal Links
/// on `https://newlevelhub.kz/...`, and the `newlevelhub://...` custom
/// scheme) and routes them into the app's own [GoRouter].
///
/// Platform registration:
/// - Android: `android/app/src/main/AndroidManifest.xml` — `VIEW` intent
///   filters for the `newlevelhub` scheme (custom scheme) and, once the
///   `assetlinks.json` is published, `https://newlevelhub.kz` with
///   `android:autoVerify="true"` (App Links).
/// - iOS: `Info.plist` `CFBundleURLSchemes` (custom scheme, already wired)
///   plus an Associated Domains entitlement (`applinks:newlevelhub.kz`)
///   once the project's apple-app-site-association is published — see
///   `README.md` → "Тестирование deep link".
///
/// Currently only handles the email-verification link
/// (`/verify-email?token=...`, MOB-111). Extend [_handle] when more deep
/// links are added rather than creating a second listener.
class DeepLinkListener {
  DeepLinkListener({required GoRouter router, AppLinks? appLinks})
      : _router = router,
        _appLinks = appLinks ?? AppLinks();

  final GoRouter _router;
  final AppLinks _appLinks;

  StreamSubscription<Uri>? _subscription;

  /// Picks up the link that launched the app (cold start) and starts
  /// listening for links received while the app is already running (warm
  /// start). Call once, e.g. from the root widget's `initState`.
  Future<void> init() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handle(initialUri);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('DeepLinkListener: failed to read initial link: $error\n$stackTrace');
      }
    }

    _subscription = _appLinks.uriLinkStream.listen(
      _handle,
      onError: (Object error, StackTrace stackTrace) {
        if (kDebugMode) {
          debugPrint('DeepLinkListener: uriLinkStream error: $error\n$stackTrace');
        }
      },
    );
  }

  void _handle(Uri uri) {
    if (uri.path != AppRoutes.verifyEmail) {
      return;
    }

    final token = uri.queryParameters['token'];
    if (token == null || token.isEmpty) {
      return;
    }

    _router.go('${AppRoutes.verifyEmail}?token=${Uri.encodeQueryComponent(token)}');
  }

  void dispose() {
    _subscription?.cancel();
  }
}
