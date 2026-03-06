import '../../core/api_client.dart';
import 'sessions_repository.dart';

class ApiSessionsRepository implements SessionsRepository {
  ApiSessionsRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<DeviceSessionSummary>> getSessions() async {
    final data = await _client.get('v1/auth/sessions');
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => _sessionFromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    await _client.delete('v1/auth/sessions/$sessionId');
  }

  DeviceSessionSummary _sessionFromJson(Map<String, dynamic> json) {
    return DeviceSessionSummary(
      sessionId: json['sessionId'] as String,
      ip: json['ip'] as String? ?? '',
      userAgent: json['userAgent'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      isCurrent: json['isCurrent'] as bool? ?? false,
    );
  }
}
