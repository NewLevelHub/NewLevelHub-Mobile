import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/network/connectivity_probe.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/router/deep_link_listener.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/services/auth_service.dart';

class NewLevelHubApp extends StatefulWidget {
  const NewLevelHubApp({
    super.key,
    this.runConnectivityProbeOnStart = true,
    this.connectivityProbe,
    this.authController,
    this.dioClient,
  });

  final bool runConnectivityProbeOnStart;
  final ConnectivityProbe? connectivityProbe;
  final AuthController? authController;
  final DioClient? dioClient;

  @override
  State<NewLevelHubApp> createState() => _NewLevelHubAppState();
}

class _NewLevelHubAppState extends State<NewLevelHubApp> {
  late final AuthController _authController;
  late final GoRouter _router;
  late final DeepLinkListener _deepLinkListener;

  @override
  void initState() {
    super.initState();
    _authController = widget.authController ??
        AuthController(
          authRepository: AuthRepositoryImpl(
            authService: AuthService(DioClient.instance.dio),
            tokenStorage: DioClient.instance.tokenStorage,
          ),
        );
    _router = createAppRouter(
      authController: _authController,
      runConnectivityProbeOnStart: widget.runConnectivityProbeOnStart,
      connectivityProbe: widget.connectivityProbe,
    );
    _authController.attachRouter(_router);

    final client = widget.dioClient ?? DioClient.instance;
    client.onSessionExpired = _authController.onSessionExpired;

    _deepLinkListener = DeepLinkListener(router: _router);
    unawaited(_deepLinkListener.init());
  }

  @override
  void dispose() {
    if (widget.dioClient == null) {
      DioClient.instance.onSessionExpired = () {};
    }
    _deepLinkListener.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'New Level Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
