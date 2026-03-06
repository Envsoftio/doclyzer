import '../../core/api_client.dart';
import 'restriction_repository.dart';

class ApiRestrictionRepository implements RestrictionRepository {
  ApiRestrictionRepository(this._client);

  final ApiClient _client;

  @override
  Future<RestrictionStatus> getStatus() async {
    final data = await _client.get('v1/account/restriction-status');
    final d = data['data'] as Map<String, dynamic>;
    return RestrictionStatus(
      isRestricted: d['isRestricted'] as bool? ?? false,
      rationale: d['rationale'] as String?,
      nextSteps: d['nextSteps'] as String?,
      restrictedActions: (d['restrictedActions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}
