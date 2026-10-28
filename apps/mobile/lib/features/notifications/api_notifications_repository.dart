import '../../core/api_client.dart';
import 'notifications_repository.dart';

class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<InboxNotification>> getInbox() async {
    final res = await _client.get('v1/notifications/inbox');
    final data = res['data'] as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? const [];
    return items.map((item) {
      final json = item as Map<String, dynamic>;
      return InboxNotification(
        id: json['id'] as String,
        type: json['type'] as String? ?? 'product',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        occurredAt: DateTime.parse(json['occurredAt'] as String),
        sourceType: json['sourceType'] as String,
        read: json['read'] as bool? ?? false,
        deepLink: json['deepLink'] as String?,
      );
    }).toList();
  }

  @override
  Future<void> markInboxRead(String sourceType, String id) async {
    await _client.post(
      'v1/notifications/inbox/${Uri.encodeComponent(sourceType)}/${Uri.encodeComponent(id)}/read',
    );
  }

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
        if (input.preferences.isNotEmpty) 'preferences': input.preferences,
        'notificationPermission': input.notificationPermission,
        'metadata': input.metadata,
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

  Future<void> trackRecipientEvent(String id, String type) async {
    await _client.post(
      'v1/notifications/events',
      body: {'recipientId': id, 'eventType': type},
    );
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
