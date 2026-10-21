import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/report_review_screen.dart';

class _Reports extends Fake implements ReportsRepository {
  int version = 0;
  final applied = <String>{};
  String? reviewedName;
  String? reviewedValue;
  String? reviewedAction;
  int? appliedVersion;

  @override
  Future<ReportReview> getReportReview(String reportId) async => ReportReview(
    candidates: const [
      ReportReviewCandidate(
        id: 'p0-t1000-r0',
        page: 0,
        testRaw: 'Haemoglobin',
        resultRaw: '12.4',
        unitRaw: 'g/dL',
      ),
    ],
    applied: applied,
    reviewVersion: version,
    partial: false,
  );

  @override
  Future<List<int>> getReportFile(String reportId) async => base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/lAAAAABJRU5ErkJggg==',
  );

  @override
  Future<int> reviewReportCandidate(
    String reportId,
    String candidateId, {
    required int expectedVersion,
    required String action,
    required String testRaw,
    required String? resultRaw,
    String? unitRaw,
    String? rangeRaw,
  }) async {
    expect(expectedVersion, version);
    reviewedName = testRaw;
    reviewedValue = resultRaw;
    reviewedAction = action;
    return ++version;
  }

  @override
  Future<void> applyReviewedCandidate(
    String reportId,
    String candidateId, {
    required int expectedVersion,
  }) async {
    appliedVersion = expectedVersion;
    applied.add(candidateId);
  }
}

void main() {
  testWidgets(
    'image suggestion requires source inspection and saves correction',
    (tester) async {
      final reports = _Reports();
      await tester.pumpWidget(
        MaterialApp(
          home: ReportReviewScreen(
            reportsRepository: reports,
            reportId: 'report-1',
            fileName: 'lab.jpeg',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('review-candidate-p0-t1000-r0')));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('review-save-result')))
            .onPressed,
        isNull,
      );
      await tester.tap(find.byKey(const Key('review-view-original')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('image-viewer-screen')), findsOneWidget);
      await tester.tap(find.byKey(const Key('original-inspected')));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('review-source-checked')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('review-source-checked')));
      await tester.enterText(
        find.byKey(const Key('review-result-value')),
        '12.5',
      );
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('review-save-result')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('review-save-result')));
      await tester.pumpAndSettle();

      expect(reports.reviewedName, 'Haemoglobin');
      expect(reports.reviewedValue, '12.5');
      expect(reports.reviewedAction, 'corrected');
      expect(reports.appliedVersion, 1);
      expect(reports.applied, contains('p0-t1000-r0'));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
