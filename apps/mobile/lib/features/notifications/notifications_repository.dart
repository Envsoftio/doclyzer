class InboxNotification {
  const InboxNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.occurredAt,
    required this.sourceType,
    required this.read,
    this.deepLink,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime occurredAt;
  final String sourceType;
  final bool read;
  final String? deepLink;
}

class PushDeviceToken {
  const PushDeviceToken({
    required this.id,
    required this.platform,
    required this.provider,
    required this.active,
  });

  final String id;
  final String platform;
  final String provider;
  final bool active;
}

class RegisterPushTokenInput {
  const RegisterPushTokenInput({
    required this.token,
    required this.platform,
    required this.installationId,
    required this.appVersion,
    this.preferences = const {},
    this.notificationPermission = 'unknown',
    this.metadata = const {},
  });

  final String token;
  final String platform;
  final String installationId;
  final String appVersion;
  final String notificationPermission;
  final Map<String, String> metadata;
  final Map<String, bool> preferences;
}

abstract class NotificationsRepository {
  Future<List<InboxNotification>> getInbox();
  Future<void> markInboxRead(String sourceType, String id);
  Future<PushDeviceToken> registerDeviceToken(RegisterPushTokenInput input);
  Future<void> updatePreferences(
    String deviceTokenId,
    Map<String, bool> preferences,
  );
  Future<void> deactivateDeviceToken(String deviceTokenId);
  Future<void> trackPushOpen({
    String? deviceTokenId,
    String? pushSendAuditId,
    String? providerMessageId,
    String? deepLink,
    Map<String, String>? metadata,
  });
}
