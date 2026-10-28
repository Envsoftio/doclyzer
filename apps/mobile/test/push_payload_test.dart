import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/notifications/push_payload.dart';

void main() {
  const id = '11111111-2222-4333-8444-555555555555';
  test(
    'routes versioned campaigns and reports using supported internal paths',
    () {
      expect(
        PushPayload.parse({
          'version': '1',
          'deepLink': '/reports/$id',
        })?.reportId,
        id,
      );
      for (final route in ['/reports', '/account', '/notifications']) {
        expect(
          PushPayload.parse({'version': '1', 'deepLink': route})?.path,
          route,
        );
      }
      expect(
        PushPayload.parse({
          'notificationType': 'report.completed',
          'reportId': id,
        })?.path,
        '/reports/$id',
      );
    },
  );
  test(
    'rejects unknown versions, external destinations and malformed recipient identifiers',
    () {
      for (final input in <Map<String, dynamic>>[
        {'version': '2'},
        {'version': 99},
        {},
        {'version': '1', 'deepLink': 'https://evil.test'},
        {'version': '1', 'deepLink': '//evil.test'},
        {'version': '1', 'deepLink': '/reports/../../account'},
        {'version': '1', 'deepLink': '/reports/not-a-uuid'},
        {'version': '1', 'deepLink': '/account?token=secret'},
        {'version': '1', 'deepLink': 12},
        {'version': '1', 'recipientId': 'bad'},
      ]) {
        expect(PushPayload.parse(input), isNull, reason: '$input');
      }
    },
  );
  test('payload is immutable after validation', () {
    final data = <String, dynamic>{'version': '1', 'deepLink': '/reports'};
    final payload = PushPayload.parse(data)!;
    data['deepLink'] = 'https://evil.test';
    expect(payload.path, '/reports');
    expect(() => payload.data['deepLink'] = '/account', throwsUnsupportedError);
  });
}
