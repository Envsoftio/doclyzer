import '../../core/api_client.dart';
import 'data_rights_repository.dart';

class ApiDataRightsRepository implements DataRightsRepository {
  ApiDataRightsRepository(this._client);

  final ApiClient _client;

  @override
  Future<DataExportRequest> createExportRequest() async {
    final data = await _client.post('v1/account/data-export-requests');
    final d = data['data'] as Map<String, dynamic>;
    return _exportFromJson(d);
  }

  @override
  Future<DataExportRequest> createScopedExportRequest({
    String? profileId,
    DateTime? from,
    DateTime? to,
    bool includeOriginals = true,
    bool includeResults = true,
  }) async {
    final body = <String, dynamic>{
      'includeOriginals': includeOriginals,
      'includeResults': includeResults,
    };
    if (profileId != null) body['profileId'] = profileId;
    if (from != null) body['from'] = from.toUtc().toIso8601String();
    if (to != null) body['to'] = to.toUtc().toIso8601String();
    final data = await _client.post(
      'v1/account/data-export-requests',
      body: body,
    );
    return _exportFromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<DataExportRequest> getExportRequest(String requestId) async {
    try {
      final data = await _client.get(
        'v1/account/data-export-requests/$requestId',
      );
      final d = data['data'] as Map<String, dynamic>;
      return _exportFromJson(d);
    } on ApiException catch (e) {
      if (e.code == 'EXPORT_REQUEST_NOT_FOUND') {
        throw const DataRightsException('Export request not found');
      }
      rethrow;
    }
  }

  @override
  Future<ClosureRequest> createClosureRequest({
    required bool confirmClosure,
    required String password,
  }) async {
    try {
      final data = await _client.post(
        'v1/account/closure-requests',
        body: {'confirmClosure': confirmClosure, 'password': password},
      );
      final d = data['data'] as Map<String, dynamic>;
      return _closureFromJson(d);
    } on ApiException catch (e) {
      if (e.code == 'CLOSURE_CONFIRMATION_REQUIRED') {
        throw const DataRightsException(
          'confirmClosure must be true to proceed',
        );
      }
      if (e.code == 'CLOSURE_REAUTH_FAILED') {
        throw const DataRightsException('Current password is incorrect.');
      }
      rethrow;
    }
  }

  @override
  Future<ClosureRequest?> getClosureRequest() async {
    final data = await _client.get('v1/account/closure-request');
    final wrapper = data['data'] as Map<String, dynamic>;
    final request = wrapper['request'];
    if (request == null) return null;
    return _closureFromJson(request as Map<String, dynamic>);
  }

  @override
  Future<ClosureRequest> restoreClosure() async {
    final data = await _client.post('v1/account/closure-request/restore');
    return _closureFromJson(data['data'] as Map<String, dynamic>);
  }

  DataExportRequest _exportFromJson(Map<String, dynamic> json) {
    return DataExportRequest(
      requestId: json['requestId'] as String,
      userId: json['userId'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      completedAt: json['completedAt'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      failureReason: json['failureReason'] as String?,
    );
  }

  ClosureRequest _closureFromJson(Map<String, dynamic> json) {
    return ClosureRequest(
      requestId: json['requestId'] as String,
      userId: json['userId'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      message: json['message'] as String,
      purgeAfterAt: json['purgeAfterAt'] as String?,
    );
  }
}
