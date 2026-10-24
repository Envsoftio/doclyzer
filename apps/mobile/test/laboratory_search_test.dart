import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/timeline_screen.dart';
import 'package:mobile/features/sharing/sharing_repository.dart';
import 'package:mobile/features/support/support_repository.dart';

class _Reports extends Fake implements ReportsRepository {
  final reports = [
    Report(
      id: 'one',
      profileId: 'priya',
      originalFileName: 'October.pdf',
      laboratoryName: 'City Diagnostics',
      contentType: 'application/pdf',
      sizeBytes: 100,
      status: 'parsed',
      createdAt: DateTime.utc(2026, 10, 12),
    ),
    Report(
      id: 'two',
      profileId: 'priya',
      originalFileName: 'September.pdf',
      laboratoryName: 'City Diagnostics',
      contentType: 'application/pdf',
      sizeBytes: 100,
      status: 'parsed',
      createdAt: DateTime.utc(2026, 9, 12),
    ),
  ];

  @override
  Future<List<Report>> listReports(String profileId) async => reports;

  @override
  Future<List<Report>> searchReports(String profileId, String query) async =>
      reports
          .where(
            (r) =>
                r.laboratoryName!.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
}

class _Profiles extends Fake implements ProfilesRepository {
  @override
  Future<List<Profile>> getProfiles() async => [];
}

class _Sharing extends Fake implements SharingRepository {}

class _Support extends Fake implements SupportRepository {}

void main() {
  testWidgets(
    'laboratory search opens its filtered reports and preserves query',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: TimelineScreen(
            reportsRepository: _Reports(),
            profilesRepository: _Profiles(),
            sharingRepository: _Sharing(),
            supportRepository: _Support(),
            profileId: 'priya',
            profileName: 'Priya',
            onBack: () {},
            onUpgrade: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('timeline-search-priya')),
        'city',
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      final laboratory = find.byKey(
        const Key('timeline-laboratory-city diagnostics'),
      );
      expect(laboratory, findsOneWidget);
      await tester.tap(laboratory);
      await tester.pumpAndSettle();
      expect(find.text('2 reports from City Diagnostics'), findsOneWidget);
      expect(find.text('October.pdf'), findsOneWidget);
      expect(find.text('September.pdf'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('city'), findsOneWidget);
    },
  );
}
