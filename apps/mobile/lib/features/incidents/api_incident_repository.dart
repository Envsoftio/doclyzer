import '../../core/api_client.dart';
import 'incident_repository.dart';

class ApiIncidentRepository implements IncidentRepository {
  ApiIncidentRepository(this._client);

  final ApiClient _client;

  @override
  Future<PublicIncidentStatus?> getActiveIncident() async {
    final data = await _client.get('v1/incidents/active', auth: false);
    final payload = data['data'];
    if (payload == null) {
      return null;
    }
    return PublicIncidentStatus.fromJson(payload as Map<String, dynamic>);
  }
}
