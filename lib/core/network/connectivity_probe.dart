import 'package:dio/dio.dart';

import 'core_api.dart';
import 'dio_client.dart';
import 'models/health_response.dart';
import 'models/ping_response.dart';

/// Result of a ping + health connectivity check against the API.
sealed class ConnectivityProbeResult {
  const ConnectivityProbeResult();
}

class ConnectivityProbeOk extends ConnectivityProbeResult {
  const ConnectivityProbeOk({
    required this.ping,
    required this.health,
  });

  final PingResponse ping;
  final HealthResponse health;
}

class ConnectivityProbeHealthUnavailable extends ConnectivityProbeResult {
  const ConnectivityProbeHealthUnavailable({
    required this.ping,
    required this.health,
  });

  final PingResponse ping;
  final HealthResponse health;
}

class ConnectivityProbePingFailed extends ConnectivityProbeResult {
  const ConnectivityProbePingFailed(this.error);

  final Object error;
}

/// Runs GET /ping/ and GET /health/ using the shared [DioClient].
class ConnectivityProbe {
  ConnectivityProbe({CoreApi? coreApi})
      : _coreApi = coreApi ?? CoreApi(DioClient.instance.dio);

  final CoreApi _coreApi;

  Future<ConnectivityProbeResult> run() async {
    try {
      final ping = await _coreApi.ping();
      try {
        final health = await _coreApi.health();
        return ConnectivityProbeOk(ping: ping, health: health);
      } on HealthUnavailableException catch (e) {
        return ConnectivityProbeHealthUnavailable(
          ping: ping,
          health: e.response,
        );
      }
    } on DioException catch (e) {
      return ConnectivityProbePingFailed(e);
    } catch (e) {
      return ConnectivityProbePingFailed(e);
    }
  }
}
