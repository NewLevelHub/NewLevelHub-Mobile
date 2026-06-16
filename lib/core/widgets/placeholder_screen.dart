import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import '../network/connectivity_probe.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_error_view.dart';

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
  ConnectivityProbeResult? _lastResult;

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
    setState(() {
      _isChecking = false;
      _lastResult = result;
    });
    _showProbeResult(result);
  }

  void _showProbeResult(ConnectivityProbeResult result) {
    if (result is ConnectivityProbePingFailed) return;

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
        break;
    }
  }

  bool get _hasNetworkError => _lastResult is ConnectivityProbePingFailed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          if (kDebugMode) ...[
            IconButton(
              icon: const Icon(Icons.palette_outlined),
              tooltip: 'UI Kit Demo',
              onPressed: () => context.push(AppRoutes.uiKitDemo),
            ),
            IconButton(
              icon: const Icon(Icons.bug_report_outlined),
              tooltip: 'Debug: токен подтверждения email',
              onPressed: () => context.push(AppRoutes.debugVerifyEmailToken),
            ),
          ],
        ],
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
      body: SafeArea(
        child: _hasNetworkError
            ? AppErrorView(
                message: 'Не удалось связаться с сервером.\nПроверьте подключение.',
                onRetry: _runConnectivityProbe,
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.apartment_outlined,
                        size: 72,
                        color: AppColors.brand,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppConfig.appName,
                        style: AppTextStyles.display(context),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Мобильное приложение в разработке',
                        style: AppTextStyles.bodySecondary(context),
                        textAlign: TextAlign.center,
                      ),
                      if (kDebugMode) ...[
                        const SizedBox(height: 32),
                        AppButton(
                          label: 'UI Kit Demo',
                          variant: AppButtonVariant.secondary,
                          onPressed: () => context.push(AppRoutes.uiKitDemo),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
