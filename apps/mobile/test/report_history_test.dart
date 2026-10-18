import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/recycle_bin_screen.dart';
import 'package:mobile/features/reports/screens/timeline_screen.dart';
import 'package:mobile/features/sharing/sharing_repository.dart';
import 'package:mobile/features/support/support_repository.dart';

class _Reports extends Fake implements ReportsRepository {
  String? requestedProfile;

  @override
  Future<List<Report>> listReports(String profileId) async {
    requestedProfile = profileId;
    return [
      Report(
        id: 'one',
        profileId: profileId,
        profileName: 'Sam',
        originalFileName: 'blood-work.pdf',
        contentType: 'application/pdf',
        sizeBytes: 100,
        status: 'parsed',
        createdAt: DateTime(2026, 10, 18),
        collectionDate: '2026-10-10',
      ),
      Report(
        id: 'two',
        profileId: profileId,
        profileName: 'Sam',
        originalFileName: 'other.pdf',
        contentType: 'application/pdf',
        sizeBytes: 100,
        status: 'unparsed',
        createdAt: DateTime(2026, 10, 17),
      ),
      Report(
        id: 'three',
        profileId: profileId,
        profileName: 'Sam',
        originalFileName: 'multi-date.pdf',
        contentType: 'application/pdf',
        sizeBytes: 100,
        status: 'parsed',
        createdAt: DateTime(2026, 10, 16),
        collectionDateStatus: 'multiple',
      ),
    ];
  }
}

class _Profiles extends Fake implements ProfilesRepository {
  @override
  Future<List<Profile>> getProfiles() async => [];
}

class _Sharing extends Fake implements SharingRepository {}

class _Support extends Fake implements SupportRepository {}

class _RecycleReports extends Fake implements ReportsRepository {
  bool restored = false;

  @override
  Future<List<Report>> listRecycleBin({String? profileId}) async => restored
      ? []
      : [
          Report(
            id: 'deleted',
            profileId: profileId ?? '',
            originalFileName: 'saved-report.pdf',
            contentType: 'application/pdf',
            sizeBytes: 100,
            status: 'parsed',
            createdAt: DateTime(2026, 10, 18),
            collectionDate: '2026-10-10',
            deletedAt: DateTime(2026, 10, 19),
          ),
        ];

  @override
  Future<Report> restoreReport(String reportId) async {
    restored = true;
    return Report(
      id: reportId,
      profileId: 'sam',
      originalFileName: 'saved-report.pdf',
      contentType: 'application/pdf',
      sizeBytes: 100,
      status: 'parsed',
      createdAt: DateTime(2026, 10, 18),
    );
  }
}

void main() {
  testWidgets(
    'history scopes reports and keeps collection distinct from upload',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final reports = _Reports();
      await tester.pumpWidget(
        MaterialApp(
          home: TimelineScreen(
            reportsRepository: reports,
            profilesRepository: _Profiles(),
            profileId: 'sam',
            profileName: 'Sam',
            sharingRepository: _Sharing(),
            supportRepository: _Support(),
            onBack: () {},
            onUpgrade: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(reports.requestedProfile, 'sam');
      expect(find.text('Collected: 10-Oct-2026'), findsOneWidget);
      expect(find.textContaining('Uploaded:'), findsWidgets);
      expect(find.text('Collected: Multiple collection dates'), findsOneWidget);
      expect(find.text('Collected: Unknown collection date'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'blood');
      await tester.pump();
      expect(find.text('blood-work.pdf'), findsOneWidget);
      expect(find.text('other.pdf'), findsNothing);
      expect(find.text('Original'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'missing');
      await tester.pump();
      expect(find.text('No reports match your search.'), findsOneWidget);
    },
  );

  testWidgets('recycle bin shows report dates and restores in place', (tester) async {
    final reports = _RecycleReports();
    await tester.pumpWidget(
      MaterialApp(
        home: RecycleBinScreen(reportsRepository: reports, profileId: 'sam'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Collected: 10-Oct-2026'), findsOneWidget);
    expect(find.textContaining('Uploaded:'), findsOneWidget);
    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();
    expect(reports.restored, isTrue);
    expect(find.text('Recycle bin is empty.'), findsOneWidget);
  });
}
