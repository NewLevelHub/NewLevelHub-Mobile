import 'package:flutter/material.dart';

import 'core/network/connectivity_probe.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/placeholder_screen.dart';

class NewLevelHubApp extends StatelessWidget {
  const NewLevelHubApp({
    super.key,
    this.runConnectivityProbeOnStart = true,
    this.connectivityProbe,
  });

  final bool runConnectivityProbeOnStart;
  final ConnectivityProbe? connectivityProbe;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New Level Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: PlaceholderScreen(
        runProbeOnStart: runConnectivityProbeOnStart,
        connectivityProbe: connectivityProbe,
      ),
    );
  }
}
