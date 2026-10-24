import '../../core/api_client.dart';
import 'sharing_repository.dart';

class ApiSharingRepository implements SharingRepository {
  ApiSharingRepository(this._client);
  final ApiClient _client;

  @override
  Future<ShareLink> createShareLink(
    String profileId, {
    DateTime? expiresAt,
    List<String>? reportIds,
    List<String>? labValueIds,
    bool requireAccessCode = false,
  }) async {
    final body = <String, dynamic>{'profileId': profileId};
    if (expiresAt != null) body['expiresAt'] = expiresAt.toIso8601String();
    if (reportIds != null) body['reportIds'] = reportIds;
    if (labValueIds != null) body['labValueIds'] = labValueIds;
    body['requireAccessCode'] = requireAccessCode;
    final data = await _client.post('v1/sharing/links', body: body);
    return ShareLink.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<ShareLink>> listShareLinks(
    String profileId, {
    bool includePast = false,
  }) async {
    final data = await _client.get(
      'v1/sharing/links?profileId=$profileId${includePast ? '&includePast=true' : ''}',
    );
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => ShareLink.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> revokeShareLink(String id) async {
    await _client.delete('v1/sharing/links/$id');
  }

  @override
  Future<ShareLink> setShareLinkExpiry(String id, DateTime? expiresAt) async {
    final data = await _client.patch(
      'v1/sharing/links/$id/expiry',
      body: {'expiresAt': expiresAt?.toIso8601String()},
    );
    return ShareLink.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<SharePolicy> getSharePolicy() async {
    final data = await _client.get('v1/sharing/policy');
    return SharePolicy.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<SharePolicy> setSharePolicy(int? defaultExpiresInDays) async {
    final data = await _client.put(
      'v1/sharing/policy',
      body: {'defaultExpiresInDays': defaultExpiresInDays},
    );
    return SharePolicy.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<ShareAccessEvent>> listAccessEvents(String linkId) async {
    final data = await _client.get('v1/sharing/links/$linkId/access-events');
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => ShareAccessEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
