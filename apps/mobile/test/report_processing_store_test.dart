import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/api_client.dart';
import 'package:mobile/features/reports/report_processing_store.dart';

class FixtureApi extends ApiClient {
  FixtureApi()
    : super(baseUrl: 'http://fixture', onRefreshToken: () async => null) {
    setAccessToken('fixture');
  }
  int snapshots = 0;
  final events = StreamController<List<int>>();
  @override
  Future<Map<String, dynamic>> get(String path, {bool auth = true}) async {
    snapshots++;
    return {
      'data': {
        'cursor': '1',
        'reports': [
          {
            'reportId': 'r',
            'profileId': 'p',
            'version': '1',
            'status': 'queued',
            'stage': 'queued',
          },
        ],
      },
    };
  }

  @override
  Future<http.StreamedResponse> openReportEvents(
    http.Client transport,
    String cursor,
  ) async => http.StreamedResponse(events.stream, 200);
}

Future<void> until(bool Function() condition) async {
  for (var i = 0; i < 100 && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(condition(), isTrue);
}

void main() {
  test(
    'foreground store applies fragmented frames monotonically and clears on logout',
    () async {
      final api = FixtureApi(), store = ReportProcessingStore();
      store.start(api);
      await until(() => store.connection == 'connected');
      final event =
          'event: report.status_changed\r\ndata: {"reportId":"r","profileId":"p",\r\ndata: "version":"2","status":"ready","stage":"complete"}\r\n\r\n';
      for (final byte in utf8.encode(event)) {
        api.events.add([byte]);
      }
      await until(() => store.reports['r']?['status'] == 'ready');
      api.events.add(
        utf8.encode(
          'event: report.status_changed\ndata: {"reportId":"r","version":"1","status":"queued"}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(store.reports['r']?['status'], 'ready');
      expect(store.readyCount, 1);
      expect(api.snapshots, 1);
      store.stop();
      expect(store.reports, isEmpty);
      api.events.add(utf8.encode(event));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(store.reports, isEmpty);
      await api.events.close();
      store.dispose();
    },
  );
}
