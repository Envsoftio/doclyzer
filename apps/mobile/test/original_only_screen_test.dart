import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/upload_report_screen.dart';
import 'package:mobile/features/support/support_repository.dart';

class _Reports extends Fake implements ReportsRepository {
  int keepCalls = 0;

  @override
  Future<Report> keepFile(String reportId) async {
    keepCalls++;
    return Report(
      id: reportId,
      profileId: 'profile-1',
      originalFileName: 'CBC.pdf',
      contentType: 'application/pdf',
      sizeBytes: 42,
      status: 'unparsed',
      createdAt: DateTime.utc(2026, 10, 24),
    );
  }
}

class _Profiles extends Fake implements ProfilesRepository {}

class _Support extends Fake implements SupportRepository {}

void main() {
  testWidgets(
    'keeping a failed file shows original-only success without invented results',
    (tester) async {
      final reports = _Reports();
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: UploadReportScreen(
            reportsRepository: reports,
            profilesRepository: _Profiles(),
            supportRepository: _Support(),
            activeProfileName: 'Priya',
            onBack: () {},
            onComplete: () => completed = true,
            initialReport: const UploadedReport(
              reportId: 'report-1',
              profileId: 'profile-1',
              fileName: 'CBC.pdf',
              contentType: 'application/pdf',
              sizeBytes: 42,
              status: 'failed_terminal',
            ),
          ),
        ),
      );
      await tester.ensureVisible(
        find.byKey(const Key('parse-failure-keep-file')),
      );
      await tester.tap(find.byKey(const Key('parse-failure-keep-file')));
      await tester.pumpAndSettle();

      expect(reports.keepCalls, 1);
      expect(completed, isFalse);
      expect(find.text('Your original is saved.'), findsOneWidget);
      expect(
        find.textContaining('No extracted test values were added'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('upload-view-results')), findsNothing);
      expect(find.byKey(const Key('original-only-retry')), findsOneWidget);
    },
  );
}
