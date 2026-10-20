import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api_client.dart';
import 'package:mobile/core/token_storage.dart';
import 'package:mobile/features/reports/api_reports_repository.dart';

class _MemoryTokens extends TokenStorage {
  final keys = <String, String>{};
  bool interrupted = false;

  @override
  Future<String> getOrCreateReportUploadKey(
    String profileId,
    String hash,
  ) async => keys.putIfAbsent('$profileId:$hash', () => 'same-key');

  @override
  Future<void> clearReportUploadKey(String profileId, String hash) async {
    keys.remove('$profileId:$hash');
  }

  @override
  Future<void> markReportUploadStarted() async {
    interrupted = true;
  }

  @override
  Future<bool> hasInterruptedReportUpload() async => interrupted;

  @override
  Future<void> clearInterruptedReportUpload() async {
    interrupted = false;
  }
}

class _UploadClient extends ApiClient {
  _UploadClient()
    : super(baseUrl: 'https://example.test', onRefreshToken: () async => null);

  final sentKeys = <String>[];
  int attempt = 0;

  @override
  Future<Map<String, dynamic>> get(String path, {bool auth = true}) async {
    if (path == 'v1/reports/processing/capabilities') {
      return {
        'data': {'acceptance': true},
      };
    }
    if (path == 'v1/profiles') {
      return {
        'data': <Map<String, dynamic>>[
          {'id': 'profile-1', 'isActive': true},
        ],
      };
    }
    throw StateError('Unexpected GET: $path');
  }

  @override
  Future<Map<String, dynamic>> uploadFile(
    String path,
    String fieldName,
    String filePath, {
    bool auth = true,
    Map<String, String>? queryParams,
    Map<String, String>? extraHeaders,
    Map<String, String>? fields,
  }) async {
    expect(path, 'v1/reports/processing/uploads');
    expect(fields?['profileId'], 'profile-1');
    sentKeys.add(extraHeaders!['Idempotency-Key']!);
    if (attempt++ == 0) {
      throw ApiException('NETWORK_ERROR', 'Connection lost');
    }
    return {
      'data': {
        'reportId': 'report-1',
        'profileId': 'profile-1',
        'fileName': 'test.png',
        'contentType': 'image/png',
        'sizeBytes': 4,
        'status': 'queued',
      },
    };
  }
}

void main() {
  test(
    'lost upload response keeps marker and retries with the same key',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'report-upload-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/test.png');
      await file.writeAsBytes([137, 80, 78, 71]);
      final tokens = _MemoryTokens();
      final client = _UploadClient();
      final repository = ApiReportsRepository(client, tokenStorage: tokens);

      await expectLater(
        repository.uploadReport(file.path),
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'NETWORK_ERROR'),
        ),
      );
      expect(await tokens.hasInterruptedReportUpload(), isTrue);

      final accepted = await repository.uploadReport(file.path);
      expect(accepted.reportId, 'report-1');
      expect(accepted.status, 'queued');
      expect(client.sentKeys, ['same-key', 'same-key']);
      expect(await tokens.hasInterruptedReportUpload(), isFalse);
    },
  );
}
