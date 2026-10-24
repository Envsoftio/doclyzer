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
  String? requestedRecycleProfile;

  @override
  Future<List<Report>> listRecycleBin({String? profileId}) async {
    requestedRecycleProfile = profileId;
    return [];
  }

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

class _FamilyProfiles extends Fake implements ProfilesRepository {
  @override
  Future<List<Profile>> getProfiles() async => [
    Profile(id: 'sam', name: 'Sam', createdAt: DateTime(2026), isActive: true),
    Profile(
      id: 'alex',
      name: 'Alex',
      createdAt: DateTime(2026),
      isActive: false,
    ),
  ];
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
            profileName: 'Sam',
            originalFileName: 'saved-report.pdf',
            contentType: 'application/pdf',
            sizeBytes: 100,
            status: 'parsed',
            createdAt: DateTime(2026, 10, 18),
            collectionDate: '2026-10-10',
            deletedAt: DateTime(2026, 10, 19),
            purgeAfterAt: DateTime.now().add(const Duration(days: 30)),
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

class _DeletionReports extends Fake implements ReportsRepository {
  _DeletionReports({this.failOneOnEmpty = false});

  bool failOneOnEmpty;
  final ids = <String>{'first', 'second'};
  String? deletedId;
  int emptyCalls = 0;

  @override
  Future<List<Report>> listRecycleBin({String? profileId}) async => ids
      .map(
        (id) => Report(
          id: id,
          profileId: 'sam',
          originalFileName: '$id.pdf',
          contentType: 'application/pdf',
          sizeBytes: 100,
          status: 'parsed',
          createdAt: DateTime(2026, 10, 18),
          deletedAt: DateTime(2026, 10, 19),
          purgeAfterAt: DateTime.now().add(const Duration(days: 30)),
        ),
      )
      .toList();

  @override
  Future<void> permanentlyDeleteReport(String reportId) async {
    deletedId = reportId;
    ids.remove(reportId);
  }

  @override
  Future<RecycleBinEmptyResult> emptyRecycleBin() async {
    emptyCalls += 1;
    if (failOneOnEmpty) {
      ids.remove('first');
      return const RecycleBinEmptyResult(deletedCount: 1, failedCount: 1);
    }
    final count = ids.length;
    ids.clear();
    return RecycleBinEmptyResult(deletedCount: count, failedCount: 0);
  }
}

void main() {
  testWidgets('report list shows one profile switcher without a move action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final reports = _Reports();
    await tester.pumpWidget(
      MaterialApp(
        home: TimelineScreen(
          reportsRepository: reports,
          profilesRepository: _FamilyProfiles(),
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
    expect(find.text('REPORTS FOR'), findsOneWidget);
    expect(find.text('Switch'), findsOneWidget);
    await tester.tap(find.byKey(const Key('timeline-profile-switcher')));
    await tester.pumpAndSettle();
    expect(find.text('Switch active profile'), findsOneWidget);
    expect(find.textContaining('active profile for uploads'), findsOneWidget);
    Navigator.of(tester.element(find.text('Switch active profile'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('Move report'), findsNothing);
    expect(find.text('Original'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('report library actions fit a 390px phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: TimelineScreen(
          reportsRepository: _Reports(),
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
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('timeline-compare-button')), findsOneWidget);
  });

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

      await tester.tap(find.byKey(const Key('timeline-recycle-bin-button')));
      await tester.pumpAndSettle();
      expect(find.text('Recycle bin is empty.'), findsOneWidget);
      expect(reports.requestedRecycleProfile, isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'missing');
      await tester.pump();
      expect(find.text('No reports match your search.'), findsOneWidget);
    },
  );

  testWidgets('recycle bin shows report dates and restores in place', (
    tester,
  ) async {
    final reports = _RecycleReports();
    await tester.pumpWidget(
      MaterialApp(
        home: RecycleBinScreen(reportsRepository: reports, profileId: 'sam'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Collected: 10-Oct-2026'), findsOneWidget);
    expect(find.text('Profile: Sam'), findsOneWidget);
    expect(find.textContaining('Uploaded:'), findsOneWidget);
    expect(find.text('Days left: 30'), findsOneWidget);
    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();
    expect(reports.restored, isTrue);
    expect(find.text('Recycle bin is empty.'), findsOneWidget);
  });

  testWidgets('permanent deletion requires confirmation', (tester) async {
    final reports = _DeletionReports()..ids.remove('second');
    await tester.pumpWidget(
      MaterialApp(home: RecycleBinScreen(reportsRepository: reports)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete permanently'));
    await tester.pumpAndSettle();
    expect(find.text('Delete report permanently?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(reports.deletedId, isNull);
    await tester.tap(find.text('Delete permanently'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete permanently').last);
    await tester.pumpAndSettle();
    expect(reports.deletedId, 'first');
    expect(find.text('Recycle bin is empty.'), findsOneWidget);
  });

  testWidgets('empty bin reports partial failures and can retry', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final reports = _DeletionReports(failOneOnEmpty: true);
    await tester.pumpWidget(
      MaterialApp(home: RecycleBinScreen(reportsRepository: reports)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('recycle-bin-empty')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(reports.emptyCalls, 0);
    await tester.tap(find.byKey(const Key('recycle-bin-empty')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete all'));
    await tester.pumpAndSettle();
    expect(reports.emptyCalls, 1);
    expect(find.text('second.pdf'), findsOneWidget);
    expect(find.textContaining('1 could not be deleted'), findsOneWidget);
    reports.failOneOnEmpty = false;
    await tester.tap(find.byKey(const Key('recycle-bin-empty')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete all'));
    await tester.pumpAndSettle();
    expect(reports.emptyCalls, 2);
    expect(find.text('Recycle bin is empty.'), findsOneWidget);
  });
}
