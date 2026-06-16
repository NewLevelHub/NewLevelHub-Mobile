class PingResponse {
  const PingResponse({
    required this.message,
    required this.version,
  });

  final String message;
  final String version;

  factory PingResponse.fromJson(Map<String, dynamic> json) {
    return PingResponse(
      message: json['message'] as String,
      version: json['version'] as String,
    );
  }
}
