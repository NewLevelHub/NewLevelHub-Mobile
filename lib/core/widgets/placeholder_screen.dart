import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../network/connectivity_probe.dart';

/// Temporary home screen until feature modules are implemented.
class PlaceholderScreen extends StatefulWidget {
  const PlaceholderScreen({
    super.key,
    this.connectivityProbe,
    this.runProbeOnStart = true,
  });

  final ConnectivityProbe? connectivityProbe;
  final bool runProbeOnStart;

  @override
  State<PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen> {
  late final ConnectivityProbe _probe =
      widget.connectivityProbe ?? ConnectivityProbe();
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    if (widget.runProbeOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _runConnectivityProbe());
    }
  }

  Future<void> _runConnectivityProbe() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    final result = await _probe.run();

    if (!mounted) return;
    setState(() => _isChecking = false);
    _showProbeResult(result);
  }

  void _showProbeResult(ConnectivityProbeResult result) {
    final messenger = ScaffoldMessenger.of(context);

    switch (result) {
      case ConnectivityProbeOk():
        if (kDebugMode) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('API доступен'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      case ConnectivityProbeHealthUnavailable():
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Сервис временно недоступен. Попробуйте позже.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      case ConnectivityProbePingFailed():
        if (kDebugMode) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Не удалось связаться с API'),
              duration: Duration(seconds: 3),
            ),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
      ),
      floatingActionButton: kDebugMode
          ? FloatingActionButton.extended(
              onPressed: _isChecking ? null : _runConnectivityProbe,
              icon: _isChecking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_find),
              label: const Text('Проверить API'),
            )
          : null,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.apartment_outlined,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                AppConfig.appName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Мобильное приложение в разработке',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
