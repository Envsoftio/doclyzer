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
    this.preferences = const {
      'billing': true,
      'referrals': true,
      'product': true,
      'adminAnnouncements': true,
    },
  });

  final String token;
  final String platform;
  final String installationId;
  final String appVersion;
  final Map<String, bool> preferences;
}

abstract class NotificationsRepository {
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
