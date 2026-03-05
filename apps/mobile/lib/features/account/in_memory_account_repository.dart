import 'account_repository.dart';

class InMemoryAccountRepository implements AccountRepository {
  InMemoryAccountRepository({
    String id = 'local-user',
    String email = 'user@example.com',
  })  : _id = id,
        _email = email;

  final String _id;
  final String _email;
  String? _displayName;

  @override
  Future<AccountProfile> getProfile() async {
    return AccountProfile(
      id: _id,
      email: _email,
      displayName: _displayName,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  @override
  Future<AccountProfile> updateProfile({String? displayName}) async {
    if (displayName != null) {
      _displayName = displayName.isEmpty ? null : displayName;
    }
    return getProfile();
  }

  /// Test/dev utility — returns the current displayName.
  String? getLastDisplayNameForTest() => _displayName;
}
