import 'sessions_repository.dart';

class InMemorySessionsRepository implements SessionsRepository {
  InMemorySessionsRepository() {
    _sessions = [
      const DeviceSessionSummary(
        sessionId: 'current-session-id',
        ip: '192.168.1.1',
        userAgent: 'Flutter Test (Current)',
        createdAt: '2026-03-06T12:00:00.000Z',
        isCurrent: true,
      ),
      const DeviceSessionSummary(
        sessionId: 'other-session-id',
        ip: '10.0.0.2',
        userAgent: 'Chrome on Android',
        createdAt: '2026-03-05T10:00:00.000Z',
        isCurrent: false,
      ),
    ];
  }

  List<DeviceSessionSummary> _sessions = [];

  @override
  Future<List<DeviceSessionSummary>> getSessions() async {
    return List.unmodifiable(_sessions);
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    final index = _sessions.indexWhere((s) => s.sessionId == sessionId);
    if (index == -1) {
      throw Exception('Session not found');
    }
    _sessions = List.from(_sessions)..removeAt(index);
  }
}
