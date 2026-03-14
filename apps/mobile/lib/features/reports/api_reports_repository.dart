import '../../core/api_client.dart';
import 'reports_repository.dart';

class ApiReportsRepository implements ReportsRepository {
  ApiReportsRepository(this._client);

  final ApiClient _client;

  @override
  Future<UploadedReport> uploadReport(String filePath,
      {bool forceUploadAnyway = false}) async {
    final queryParams = forceUploadAnyway
        ? <String, String>{'duplicateAction': 'upload_anyway'}
        : null;
    final data = await _client.uploadFile(
      'v1/reports',
      'file',
      filePath,
      queryParams: queryParams,
    );
    final d = data['data'] as Map<String, dynamic>;
    return UploadedReport(
      reportId: d['reportId'] as String,
      profileId: d['profileId'] as String,
      fileName: d['fileName'] as String,
      contentType: d['contentType'] as String,
      sizeBytes: d['sizeBytes'] as int,
      status: d['status'] as String,
    );
  }

  @override
  Future<List<Report>> listReports(String profileId) async {
    final data = await _client.get('v1/reports?profileId=$profileId');
    final list = data['data']?['reports'] as List<dynamic>? ?? [];
    return list.map((d) {
      final map = d as Map<String, dynamic>;
      final createdAt = map['createdAt'] as String?;
    return Report(
      id: map['id'] as String,
      profileId: map['profileId'] as String,
      originalFileName: map['originalFileName'] as String,
      contentType: map['contentType'] as String,
      sizeBytes: map['sizeBytes'] as int,
      status: map['status'] as String,
      createdAt: createdAt != null ? DateTime.parse(createdAt) : DateTime.now(),
      extractedLabValues: const [],
    );
  }).toList();
  }

  @override
  Future<Report> getReport(String reportId) async {
    final data = await _client.get('v1/reports/$reportId');
    final d = data['data'] as Map<String, dynamic>;
    final createdAt = d['createdAt'] as String?;
    final labList = d['extractedLabValues'] as List<dynamic>? ?? [];
    final extractedLabValues = labList.map((e) {
      final m = e as Map<String, dynamic>;
      return ExtractedLabValue(
        parameterName: m['parameterName'] as String? ?? '',
        value: m['value'] as String? ?? '',
        unit: m['unit'] as String?,
        sampleDate: m['sampleDate'] as String?,
      );
    }).toList();
    return Report(
      id: d['id'] as String,
      profileId: d['profileId'] as String,
      originalFileName: d['originalFileName'] as String,
      contentType: d['contentType'] as String,
      sizeBytes: d['sizeBytes'] as int,
      status: d['status'] as String,
      createdAt: createdAt != null ? DateTime.parse(createdAt) : DateTime.now(),
      extractedLabValues: extractedLabValues,
    );
  }

  @override
  Future<Report> retryParse(String reportId) async {
    final data = await _client.post('v1/reports/$reportId/retry');
    final d = data['data'] as Map<String, dynamic>;
    final createdAt = d['createdAt'] as String?;
    return Report(
      id: d['id'] as String,
      profileId: d['profileId'] as String,
      originalFileName: d['originalFileName'] as String,
      contentType: d['contentType'] as String,
      sizeBytes: d['sizeBytes'] as int,
      status: d['status'] as String,
      createdAt: createdAt != null ? DateTime.parse(createdAt) : DateTime.now(),
      extractedLabValues: const [],
    );
  }

  @override
  Future<List<int>> getReportFile(String reportId) async {
    return _client.getBytes('v1/reports/$reportId/file');
  }

  @override
  Future<Report> keepFile(String reportId) async {
    final data = await _client.post('v1/reports/$reportId/keep-file');
    final d = data['data'] as Map<String, dynamic>;
    final createdAt = d['createdAt'] as String?;
    return Report(
      id: d['id'] as String,
      profileId: d['profileId'] as String,
      originalFileName: d['originalFileName'] as String,
      contentType: d['contentType'] as String,
      sizeBytes: d['sizeBytes'] as int,
      status: d['status'] as String,
      createdAt: createdAt != null ? DateTime.parse(createdAt) : DateTime.now(),
      extractedLabValues: const [],
    );
  }
}
