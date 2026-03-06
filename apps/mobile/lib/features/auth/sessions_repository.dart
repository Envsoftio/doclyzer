class DeviceSessionSummary {
  const DeviceSessionSummary({
    required this.sessionId,
    required this.ip,
    required this.userAgent,
    required this.createdAt,
    required this.isCurrent,
  });

  final String sessionId;
  final String ip;
  final String userAgent;
  final String createdAt;
  final bool isCurrent;
}

abstract class SessionsRepository {
  Future<List<DeviceSessionSummary>> getSessions();
  Future<void> revokeSession(String sessionId);
}
