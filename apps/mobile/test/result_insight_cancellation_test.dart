import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api_client.dart';
import 'package:mobile/features/reports/api_reports_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/result_insight_screen.dart';

class _PendingClient extends ApiClient {
  _PendingClient(this.pendingCode)
    : super(baseUrl: 'https://example.test', onRefreshToken: () async => null);

  final String pendingCode;
  int calls = 0;

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    calls++;
    throw ApiException(pendingCode, 'Explanation is pending.');
  }
}

void main() {
  const result = ExtractedLabValue(parameterName: 'Hb', value: '10');

  for (final pendingCode in ['RESULT_INSIGHT_PENDING', 'NARRATIVE_PENDING']) {
    test('leaving a result stops $pendingCode retries', () async {
      final client = _PendingClient(pendingCode);
      final cancellation = InsightRequestCancellation();
      final request = ApiReportsRepository(
        client,
      ).getResultInsight('report', result, cancellation: cancellation);
      await Future<void>.delayed(Duration.zero);
      expect(client.calls, 1);

      cancellation.cancel();
      await expectLater(
        request,
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'code',
            'REQUEST_CANCELLED',
          ),
        ),
      );
      expect(client.calls, 1);
    });
  }

  testWidgets('closing the insight screen cancels its retry scope', (
    tester,
  ) async {
    final cancellation = InsightRequestCancellation();
    final response = Completer<ResultInsight>();
    await tester.pumpWidget(
      MaterialApp(
        home: ResultInsightScreen(
          result: result,
          cancellation: cancellation,
          loadInsight: () => response.future,
          onViewTrend: () {},
        ),
      ),
    );
    expect(cancellation.isCancelled, isFalse);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(cancellation.isCancelled, isTrue);
  });
}
