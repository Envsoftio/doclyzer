import '../../core/api_client.dart';
import 'notifications_repository.dart';

class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._client);

  final ApiClient _client;

  @override
  Future<PushDeviceToken> registerDeviceToken(
    RegisterPushTokenInput input,
  ) async {
    final res = await _client.post(
      'v1/notifications/device-tokens',
      body: {
        'token': input.token,
        'platform': input.platform,
        'provider': 'fcm',
        'installationId': input.installationId,
        'appVersion': input.appVersion,
        'preferences': input.preferences,
      },
    );
    return _tokenFromJson(res['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> updatePreferences(
    String deviceTokenId,
    Map<String, bool> preferences,
  ) async {
    await _client.patch(
      'v1/notifications/device-tokens/$deviceTokenId/preferences',
      body: {'preferences': preferences},
    );
  }

  @override
  Future<void> deactivateDeviceToken(String deviceTokenId) async {
    await _client.delete('v1/notifications/device-tokens/$deviceTokenId');
  }

  @override
  Future<void> trackPushOpen({
    String? deviceTokenId,
    String? pushSendAuditId,
    String? providerMessageId,
    String? deepLink,
    Map<String, String>? metadata,
  }) async {
    final body = <String, dynamic>{};
    if (deviceTokenId != null) body['deviceTokenId'] = deviceTokenId;
    if (pushSendAuditId != null) body['pushSendAuditId'] = pushSendAuditId;
    if (providerMessageId != null) {
      body['providerMessageId'] = providerMessageId;
    }
    if (deepLink != null) body['deepLink'] = deepLink;
    if (metadata != null) body['metadata'] = metadata;

    await _client.post('v1/notifications/push-open', body: body);
  }

  PushDeviceToken _tokenFromJson(Map<String, dynamic> json) {
    return PushDeviceToken(
      id: json['id'] as String,
      platform: json['platform'] as String,
      provider: json['provider'] as String? ?? 'fcm',
      active: json['active'] as bool? ?? true,
    );
  }
}
