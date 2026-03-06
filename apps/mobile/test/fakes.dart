/// Fake implementations for widget tests. Not used in production.
import 'package:mobile/features/account/account_repository.dart';
import 'package:mobile/features/account/communication_preferences_repository.dart';
import 'package:mobile/features/account/data_rights_repository.dart';
import 'package:mobile/features/account/restriction_repository.dart';
import 'package:mobile/features/auth/sessions_repository.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';

class FakeAccountRepository implements AccountRepository {
  String? _displayName;
  final String id;
  final String email;

  FakeAccountRepository({this.id = 'u1', this.email = 'user@example.com'});

  @override
  Future<AccountProfile> getProfile() async => AccountProfile(
        id: id,
        email: email,
        displayName: _displayName,
        createdAt: DateTime(2026, 1, 1),
      );

  @override
  Future<AccountProfile> updateProfile({String? displayName}) async {
    _displayName = displayName?.trim().isEmpty == true ? null : displayName;
    return getProfile();
  }
}

class FakeRestrictionRepository implements RestrictionRepository {
  FakeRestrictionRepository({RestrictionStatus? initialStatus})
      : _status = initialStatus ?? const RestrictionStatus(isRestricted: false);

  RestrictionStatus _status;

  @override
  Future<RestrictionStatus> getStatus() async => _status;
}

class FakeProfilesRepository implements ProfilesRepository {
  final List<_FakeProfile> _profiles = [];
  String? _activeId;
  final int? maxProfiles;

  FakeProfilesRepository({this.maxProfiles});

  @override
  Future<List<Profile>> getProfiles() async => _profiles
      .map((p) => Profile(
            id: p.id,
            name: p.name,
            dateOfBirth: p.dateOfBirth,
            relation: p.relation,
            createdAt: p.createdAt,
            isActive: p.id == _activeId,
          ))
      .toList();

  @override
  Future<int?> getMaxProfiles() async => maxProfiles;

  @override
  Future<Profile> createProfile({
    required String name,
    String? dateOfBirth,
    String? relation,
  }) async {
    if (maxProfiles != null && _profiles.length >= maxProfiles!) {
      throw ProfileLimitExceededException();
    }
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    _profiles.add(_FakeProfile(
      id: id,
      name: name,
      dateOfBirth: dateOfBirth,
      relation: relation,
      createdAt: DateTime.now(),
    ));
    _activeId ??= id;
    return (await getProfiles()).firstWhere((p) => p.id == id);
  }

  @override
  Future<Profile> updateProfile({
    required String id,
    String? name,
    String? dateOfBirth,
    String? relation,
  }) async {
    final i = _profiles.indexWhere((p) => p.id == id);
    if (i == -1) throw ProfileNotFoundException(id);
    final p = _profiles[i];
    _profiles[i] = _FakeProfile(
      id: p.id,
      name: name ?? p.name,
      dateOfBirth: dateOfBirth ?? p.dateOfBirth,
      relation: relation ?? p.relation,
      createdAt: p.createdAt,
    );
    return (await getProfiles()).firstWhere((x) => x.id == id);
  }

  @override
  Future<void> activateProfile(String id) async {
    _activeId = id;
  }

  @override
  Future<void> deleteProfile(String id) async {
    _profiles.removeWhere((p) => p.id == id);
    if (_activeId == id) {
      _activeId = _profiles.isNotEmpty ? _profiles.first.id : null;
    }
  }
}

class _FakeProfile {
  _FakeProfile({
    required this.id,
    required this.name,
    this.dateOfBirth,
    this.relation,
    required this.createdAt,
  });
  final String id;
  final String name;
  final String? dateOfBirth;
  final String? relation;
  final DateTime createdAt;
}

class FakeSessionsRepository implements SessionsRepository {
  List<DeviceSessionSummary> _sessions = [
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

  @override
  Future<List<DeviceSessionSummary>> getSessions() async =>
      List.unmodifiable(_sessions);

  @override
  Future<void> revokeSession(String sessionId) async {
    _sessions.removeWhere((s) => s.sessionId == sessionId);
  }
}

class FakeCommunicationPreferencesRepository
    implements CommunicationPreferencesRepository {
  bool _productEmails = true;

  @override
  Future<CommunicationPreferences> getPreferences() async =>
      CommunicationPreferences(
        preferences: [
          const CommunicationPreferenceItem(
            category: 'security',
            enabled: true,
            mandatory: true,
          ),
          const CommunicationPreferenceItem(
            category: 'compliance',
            enabled: true,
            mandatory: true,
          ),
          CommunicationPreferenceItem(
            category: 'product',
            enabled: _productEmails,
            mandatory: false,
          ),
        ],
      );

  @override
  Future<CommunicationPreferences> updatePreferences(
    Map<String, bool> updates,
  ) async {
    if (updates.containsKey(commPrefCategoryProduct)) {
      _productEmails = updates[commPrefCategoryProduct]!;
    }
    return getPreferences();
  }
}

class FakeDataRightsRepository implements DataRightsRepository {
  final List<DataExportRequest> _exports = [];
  ClosureRequest? _closure;
  int _nextId = 1;

  @override
  Future<DataExportRequest> createExportRequest() async {
    final r = DataExportRequest(
      requestId: 'e${_nextId++}',
      userId: 'u1',
      status: 'pending',
      createdAt: DateTime.now().toIso8601String(),
    );
    _exports.add(r);
    return r;
  }

  @override
  Future<DataExportRequest> getExportRequest(String requestId) async {
    final r = _exports.where((e) => e.requestId == requestId).firstOrNull;
    if (r == null) throw const DataRightsException('Export request not found');
    // Simulate completed export when checking status
    return DataExportRequest(
      requestId: r.requestId,
      userId: r.userId,
      status: 'completed',
      createdAt: r.createdAt,
      completedAt: DateTime.now().toIso8601String(),
      downloadUrl: 'https://example.com/export/${r.requestId}.zip',
    );
  }

  @override
  Future<ClosureRequest> createClosureRequest({
    required bool confirmClosure,
  }) async {
    if (!confirmClosure) {
      throw const DataRightsException('confirmClosure must be true to proceed');
    }
    final r = ClosureRequest(
      requestId: 'c${_nextId++}',
      userId: 'u1',
      status: 'pending',
      createdAt: DateTime.now().toIso8601String(),
      message: 'Account scheduled for closure.',
    );
    _closure = r;
    return r;
  }

  @override
  Future<ClosureRequest?> getClosureRequest() async => _closure;

  bool hasClosureRequestForTest() => _closure != null;
}
