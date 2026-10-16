import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/upload_report_screen.dart';
import 'package:mobile/features/support/support_repository.dart';

class _Reports extends Fake implements ReportsRepository {
  String? requestedReportId;
  String status = 'parsed';

  @override
  Future<Report> getReport(String reportId) async {
    requestedReportId = reportId;
    return Report(
      id: reportId,
      profileId: 'profile-1',
      originalFileName: 'blood-test.pdf',
      contentType: 'application/pdf',
      sizeBytes: 100,
      status: status,
      createdAt: DateTime(2026),
      summary: status == 'parsed' ? 'Blood test results are ready.' : null,
    );
  }
}

class _Profiles extends Fake implements ProfilesRepository {
  @override
  Future<List<Profile>> getProfiles() async => [];
}

class _Support extends Fake implements SupportRepository {}

void main() {
  testWidgets('upload success opens the uploaded report in one tap', (
    tester,
  ) async {
    final reports = _Reports();
    await tester.pumpWidget(
      MaterialApp(
        home: UploadReportScreen(
          reportsRepository: reports,
          profilesRepository: _Profiles(),
          supportRepository: _Support(),
          activeProfileName: 'Me',
          onBack: () {},
          onComplete: () {},
          initialReport: const UploadedReport(
            reportId: 'report-1',
            profileId: 'profile-1',
            fileName: 'blood-test.pdf',
            contentType: 'application/pdf',
            sizeBytes: 100,
            status: 'parsed',
          ),
        ),
      ),
    );

    expect(find.text('View results'), findsOneWidget);
    await tester.tap(find.byKey(const Key('upload-view-results')));
    await tester.pumpAndSettle();

    expect(reports.requestedReportId, 'report-1');
    expect(find.byKey(const Key('report-detail-scaffold')), findsOneWidget);
    expect(find.text('Blood test results are ready.'), findsOneWidget);
  });

  testWidgets('processing report can refresh into results', (tester) async {
    final reports = _Reports()..status = 'parsing';
    await tester.pumpWidget(
      MaterialApp(
        home: UploadReportScreen(
          reportsRepository: reports,
          profilesRepository: _Profiles(),
          supportRepository: _Support(),
          activeProfileName: 'Me',
          onBack: () {},
          onComplete: () {},
          initialReport: const UploadedReport(
            reportId: 'report-1',
            profileId: 'profile-1',
            fileName: 'blood-test.pdf',
            contentType: 'application/pdf',
            sizeBytes: 100,
            status: 'parsing',
          ),
        ),
      ),
    );

    expect(find.text('View report status'), findsOneWidget);
    await tester.tap(find.byKey(const Key('upload-view-results')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('report-detail-check-status')), findsOneWidget);

    reports.status = 'parsed';
    await tester.tap(find.byKey(const Key('report-detail-check-status')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('report-detail-check-status')), findsNothing);
    expect(find.text('Blood test results are ready.'), findsOneWidget);
  });
}
