import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/report_processing_store.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/report_detail_screen.dart';

class _Reports extends Fake implements ReportsRepository {
  int loads = 0;
  Completer<Report>? nextLoad;

  @override
  Future<Report> getReport(String reportId) async {
    loads++;
    if (nextLoad case final pending?) return pending.future;
    return Report(
      id: reportId,
      profileId: 'profile',
      originalFileName: 'report.pdf',
      contentType: 'application/pdf',
      sizeBytes: 100,
      status: 'parsed',
      createdAt: DateTime(2026),
      extractedLabValues: const [
        ExtractedLabValue(
          parameterName: 'Hb',
          value: '10',
          unit: 'g/dL',
          referenceRange: '12-16',
        ),
      ],
    );
  }
}

class _Profiles extends Fake implements ProfilesRepository {
  @override
  Future<List<Profile>> getProfiles() async => [];
}

void main() {
  testWidgets(
    'a ready event keeps the report visible while refresh is pending',
    (tester) async {
      final store = ReportProcessingStore.instance;
      store.reports.clear();
      final reports = _Reports();
      await tester.pumpWidget(
        MaterialApp(
          home: ReportDetailScreen(
            reportsRepository: reports,
            profilesRepository: _Profiles(),
            reportId: 'report',
            profileId: 'profile',
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      reports.nextLoad = Completer<Report>();
      store.reports['report'] = {
        'version': '1',
        'status': 'ready',
        'acknowledgedAt': 'now',
      };
      store.notifyListeners();
      await tester.pump();
      expect(find.byKey(const Key('report-detail-lab-values')), findsOneWidget);
      expect(find.byKey(const Key('report-detail-refreshing')), findsOneWidget);
      reports.nextLoad!.complete(await _Reports().getReport('report'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('report-detail-refreshing')), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      store.reports.clear();
    },
  );

  testWidgets(
    'detail refreshes for report status changes, not store connection or acknowledgement',
    (tester) async {
      final store = ReportProcessingStore.instance;
      store.reports.clear();
      final reports = _Reports();
      await tester.pumpWidget(
        MaterialApp(
          home: ReportDetailScreen(
            reportsRepository: reports,
            profilesRepository: _Profiles(),
            reportId: 'report',
            profileId: 'profile',
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(reports.loads, 1);
      expect(find.byKey(const Key('report-detail-lab-values')), findsOneWidget);

      store.notifyListeners(); // A reconnect with no matching processing row.
      await tester.pumpAndSettle();
      expect(reports.loads, 1);

      store.reports['report'] = {'version': '1', 'status': 'processing'};
      store.notifyListeners();
      await tester.pumpAndSettle();
      expect(reports.loads, 2);

      store.reports['report']!['acknowledgedAt'] = DateTime.now()
          .toIso8601String();
      store.notifyListeners();
      await tester.pumpAndSettle();
      expect(reports.loads, 2);

      store.reports['report'] = {
        'version': '2',
        'status': 'ready',
        'acknowledgedAt': 'now',
      };
      store.notifyListeners();
      await tester.pumpAndSettle();
      expect(reports.loads, 3);

      await tester.pumpWidget(const SizedBox.shrink());
      store.reports.clear();
    },
  );
}
