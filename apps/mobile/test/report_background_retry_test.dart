import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api_client.dart';
import 'package:mobile/features/reports/api_reports_repository.dart';

class RetryApi extends ApiClient {
  RetryApi() : super(baseUrl: 'http://fixture', onRefreshToken: () async => null);
  final calls = <String>[];
  @override
  Future<Map<String, dynamic>> get(String path, {bool auth = true}) async => {
    'data': {
      'id': 'report', 'profileId': 'profile', 'originalFileName': 'test.pdf',
      'contentType': 'application/pdf', 'sizeBytes': 10, 'status': 'queued',
      'createdAt': '2026-10-19T00:00:00Z', 'extractedLabValues': [],
    },
  };
  @override
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    calls.add(path);
    if (path == 'v1/reports/report/retry') {
      throw ApiException('REPORT_ASYNC_RETRY_REQUIRED', 'Use background retry.');
    }
    return {'data': {}};
  }
}
void main() {
  test('retry follows background endpoint when older report metadata omits processingState', () async {
    final api = RetryApi();
    final result = await ApiReportsRepository(api).retryParse('report');
    expect(api.calls, ['v1/reports/report/retry', 'v1/reports/processing/report/retry']);
    expect(result.status, 'queued');
  });
}
