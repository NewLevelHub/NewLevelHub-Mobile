class HealthResponse {
  const HealthResponse({
    required this.status,
    required this.database,
    this.deploymentMarker,
    this.environment,
  });

  final String status;
  final String database;
  final String? deploymentMarker;
  final String? environment;

  bool get isHealthy => status == 'healthy';

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      status: json['status'] as String,
      database: json['database'] as String,
      deploymentMarker: json['deployment_marker'] as String?,
      environment: json['environment'] as String?,
    );
  }
}
