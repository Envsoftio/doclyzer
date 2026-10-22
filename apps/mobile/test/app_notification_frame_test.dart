import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/navigation/app_notification_frame.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/upload_report_screen.dart';
import 'package:mobile/features/support/support_repository.dart';

class _Reports extends Fake implements ReportsRepository {
  @override
  Future<Report> getReport(String reportId) async => Report(
    id: reportId,
    profileId: 'profile',
    originalFileName: 'new-report.pdf',
    contentType: 'application/pdf',
    sizeBytes: 100,
    status: 'parsed',
    createdAt: DateTime(2026),
    extractedLabValues: const [
      ExtractedLabValue(parameterName: 'Haemoglobin', value: '13.3'),
    ],
  );
}

class _Profiles extends Fake implements ProfilesRepository {
  @override
  Future<List<Profile>> getProfiles() async => [];
}

class _Support extends Fake implements SupportRepository {}

void main() {
  testWidgets('report route survives ready notice appearing and clearing', (
    tester,
  ) async {
    final showNotice = ValueNotifier(false);
    addTearDown(showNotice.dispose);
    final reports = _Reports();
    final profiles = _Profiles();

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => AppNotificationFrame(
          readyNotice: ValueListenableBuilder<bool>(
            valueListenable: showNotice,
            builder: (context, visible, _) => visible
                ? const Material(child: Text('1 report ready'))
                : const SizedBox.shrink(),
          ),
          child: child!,
        ),
        home: UploadReportScreen(
          reportsRepository: reports,
          profilesRepository: profiles,
          supportRepository: _Support(),
          activeProfileName: 'Me',
          onBack: () {},
          onComplete: () {},
          initialReport: const UploadedReport(
            reportId: 'new-report',
            profileId: 'profile',
            fileName: 'new-report.pdf',
            contentType: 'application/pdf',
            sizeBytes: 100,
            status: 'parsed',
          ),
        ),
      ),
    );

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    final frameExpanded = find.byKey(const Key('app-notification-content'));
    final expandedElement = tester.element(frameExpanded);
    await tester.tap(find.byKey(const Key('upload-view-results')));
    showNotice.value = true;
    await tester.pump();
    showNotice.value = false;
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lab-row-Haemoglobin')), findsOneWidget);
    expect(
      tester
          .renderObject(find.byKey(const Key('report-detail-scaffold')))
          .attached,
      isTrue,
    );

    showNotice.value = true;
    await tester.pumpAndSettle();
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)),
      same(navigator),
    );
    expect(tester.element(frameExpanded), same(expandedElement));
    expect(find.byKey(const Key('lab-row-Haemoglobin')), findsOneWidget);
    expect(
      tester
          .renderObject(find.byKey(const Key('report-detail-scaffold')))
          .attached,
      isTrue,
    );

    showNotice.value = false;
    await tester.pumpAndSettle();
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)),
      same(navigator),
    );
    expect(tester.element(frameExpanded), same(expandedElement));
    expect(find.byKey(const Key('lab-row-Haemoglobin')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('report-detail-back')));
    await tester.pumpAndSettle();
    showNotice.value = true;
    await tester.pump();
    await tester.tap(find.byKey(const Key('upload-view-results')));
    showNotice.value = false;
    await tester.pumpAndSettle();
    expect(tester.element(frameExpanded), same(expandedElement));
    expect(find.byKey(const Key('lab-row-Haemoglobin')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
