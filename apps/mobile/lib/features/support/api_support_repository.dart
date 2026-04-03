import '../../core/api_client.dart';
import 'support_models.dart';
import 'support_repository.dart';

class ApiSupportRepository implements SupportRepository {
  ApiSupportRepository(this._client);

  final ApiClient _client;

  @override
  Future<SupportRequestResult> createSupportRequest(
    SupportRequestPayload payload,
  ) async {
    final data = await _client.post(
      'v1/support-requests',
      body: payload.toJson(),
    );
    final response = data['data'] as Map<String, dynamic>;
    return SupportRequestResult(
      id: response['id'] as String,
      correlationId: response['correlationId'] as String? ?? '',
    );
  }
}
