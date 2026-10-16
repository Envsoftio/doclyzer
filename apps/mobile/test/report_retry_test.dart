import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/report_detail_screen.dart';

Report report(String status) => Report(
  id: 'report',
  profileId: 'profile',
  originalFileName: 'report.pdf',
  contentType: 'application/pdf',
  sizeBytes: 100,
  status: status,
  createdAt: DateTime(2026),
);

class Reports extends Fake implements ReportsRepository {
  int retries = 0;
  final result = Completer<Report>();
  @override
  Future<Report> getReport(String id) async => report('failed_transient');
  @override
  Future<Report> retryParse(String id, {bool force = false}) {
    expect(id, 'report');
    expect(force, false);
    retries++;
    return result.future;
  }
}

class Profiles extends Fake implements ProfilesRepository {
  @override
  Future<List<Profile>> getProfiles() async => [];
}

void main() {
  testWidgets(
    'Transient failures expose retry and prevent repeated taps while processing',
    (tester) async {
      final repository = Reports();
      await tester.pumpWidget(
        MaterialApp(
          home: ReportDetailScreen(
            reportsRepository: repository,
            profilesRepository: Profiles(),
            reportId: 'report',
            profileId: 'profile',
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      final retry = find.byKey(const Key('report-detail-retry'));
      expect(retry, findsOneWidget);
      expect(find.textContaining('Your file is saved'), findsOneWidget);
      await tester.ensureVisible(retry);
      await tester.tap(retry);
      await tester.pump();
      expect(repository.retries, 1);
      expect(retry, findsNothing);
      repository.result.complete(report('parsed'));
      await tester.pumpAndSettle();
      expect(retry, findsNothing);
      expect(find.text('Parsed'), findsOneWidget);
    },
  );
}
