import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/network/connectivity_probe.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/router/auth_notifier.dart';
import 'core/theme/app_theme.dart';

class NewLevelHubApp extends StatefulWidget {
  const NewLevelHubApp({
    super.key,
    this.runConnectivityProbeOnStart = true,
    this.connectivityProbe,
    this.authNotifier,
    this.dioClient,
  });

  final bool runConnectivityProbeOnStart;
  final ConnectivityProbe? connectivityProbe;
  final AuthNotifier? authNotifier;
  final DioClient? dioClient;

  @override
  State<NewLevelHubApp> createState() => _NewLevelHubAppState();
}

class _NewLevelHubAppState extends State<NewLevelHubApp> {
  late final AuthNotifier _authNotifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authNotifier = widget.authNotifier ?? AuthNotifier();
    _router = createAppRouter(
      authNotifier: _authNotifier,
      runConnectivityProbeOnStart: widget.runConnectivityProbeOnStart,
      connectivityProbe: widget.connectivityProbe,
    );
    _authNotifier.attachRouter(_router);

    final client = widget.dioClient ?? DioClient.instance;
    client.onSessionExpired = _authNotifier.onSessionExpired;
  }

  @override
  void dispose() {
    if (widget.dioClient == null) {
      DioClient.instance.onSessionExpired = () {};
    }
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
