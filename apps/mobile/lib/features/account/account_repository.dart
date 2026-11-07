class AccountProfile {
  const AccountProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.avatarUrl,
    this.preferredLanguage = 'en',
  });

  final String preferredLanguage;
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime createdAt;
}

class AccountException implements Exception {
  const AccountException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class AccountRepository {
  Future<AccountProfile> getProfile();

  Future<AccountProfile> updateProfile({
    String? displayName,
    String? preferredLanguage,
  });

  Future<AccountProfile> uploadAvatar(String filePath);
}
