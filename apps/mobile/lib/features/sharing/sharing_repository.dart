class ShareLink {
  const ShareLink({
    required this.id,
    required this.token,
    required this.shareUrl,
    required this.profileId,
    required this.scope,
    required this.isActive,
    required this.createdAt,
    this.expiresAt,
  });
  final String id;
  final String token;
  final String shareUrl;
  final String profileId;
  final String scope;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;

  factory ShareLink.fromJson(Map<String, dynamic> d) {
    return ShareLink(
      id: d['id'] as String,
      token: d['token'] as String,
      shareUrl: d['shareUrl'] as String,
      profileId: d['profileId'] as String,
      scope: d['scope'] as String,
      isActive: d['isActive'] as bool,
      createdAt: DateTime.parse(d['createdAt'] as String),
      expiresAt: d['expiresAt'] != null
          ? DateTime.parse(d['expiresAt'] as String)
          : null,
    );
  }
}

class SharePolicy {
  const SharePolicy({this.defaultExpiresInDays});
  final int? defaultExpiresInDays;

  factory SharePolicy.fromJson(Map<String, dynamic> d) {
    return SharePolicy(
      defaultExpiresInDays: d['defaultExpiresInDays'] as int?,
    );
  }
}

class ShareAccessEvent {
  const ShareAccessEvent({
    required this.id,
    required this.accessedAt,
    required this.outcome,
  });
  final String id;
  final DateTime accessedAt;
  final String outcome; // 'accessed' | 'expired_or_revoked'

  factory ShareAccessEvent.fromJson(Map<String, dynamic> d) {
    return ShareAccessEvent(
      id: d['id'] as String,
      accessedAt: DateTime.parse(d['accessedAt'] as String),
      outcome: d['outcome'] as String,
    );
  }
}

abstract class SharingRepository {
  Future<ShareLink> createShareLink(String profileId, {DateTime? expiresAt});
  Future<List<ShareLink>> listShareLinks(String profileId);
  Future<void> revokeShareLink(String id);
  Future<ShareLink> setShareLinkExpiry(String id, DateTime? expiresAt);
  Future<SharePolicy> getSharePolicy();
  Future<SharePolicy> setSharePolicy(int? defaultExpiresInDays);
  Future<List<ShareAccessEvent>> listAccessEvents(String linkId);
}
