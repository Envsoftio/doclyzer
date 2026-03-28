import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/timeline_screen.dart';
import 'mocks.dart';

void main() {
  late MockReportsRepository reportsRepo;
  late MockProfilesRepository profilesRepo;
  late MockSharingRepository sharingRepo;

  setUp(() {
    reportsRepo = MockReportsRepository();
    profilesRepo = MockProfilesRepository();
    sharingRepo = MockSharingRepository();
  });

  testWidgets('Timeline shows loading then empty state when no reports',
      (WidgetTester tester) async {
    when(() => reportsRepo.listReports(any())).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: TimelineScreen(
          reportsRepository: reportsRepo,
          profilesRepository: profilesRepo,
          profileId: 'profile-1',
          profileName: 'Test Profile',
          sharingRepository: sharingRepo,
          onBack: () {},
          onUpgrade: () {},
        ),
      ),
    );

    expect(find.byKey(const Key('timeline-loading')), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('timeline-empty')), findsOneWidget);
    expect(find.text('No reports yet'), findsOneWidget);
    verify(() => reportsRepo.listReports(any())).called(1);
  });

  testWidgets('Timeline shows list when reports exist', (WidgetTester tester) async {
    when(() => reportsRepo.listReports(any())).thenAnswer((_) async => [
          Report(
            id: 'r1',
            profileId: 'profile-1',
            originalFileName: 'lab.pdf',
            contentType: 'application/pdf',
            sizeBytes: 100,
            status: 'parsed',
            createdAt: DateTime(2026, 1, 15),
          ),
        ]);

    await tester.pumpWidget(
      MaterialApp(
        home: TimelineScreen(
          reportsRepository: reportsRepo,
          profilesRepository: profilesRepo,
          profileId: 'profile-1',
          profileName: 'Test Profile',
          sharingRepository: sharingRepo,
          onBack: () {},
          onUpgrade: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('timeline-list')), findsOneWidget);
    expect(find.text('lab.pdf'), findsOneWidget);
  });

  testWidgets('Timeline back button triggers onBack', (WidgetTester tester) async {
    when(() => reportsRepo.listReports(any())).thenAnswer((_) async => []);
    var backCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: TimelineScreen(
          reportsRepository: reportsRepo,
          profilesRepository: profilesRepo,
          profileId: 'profile-1',
          profileName: 'Test Profile',
          sharingRepository: sharingRepo,
          onBack: () => backCalled = true,
          onUpgrade: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('timeline-back')));
    await tester.pumpAndSettle();

    expect(backCalled, isTrue);
  });

  testWidgets('Timeline refetches when profileId changes', (WidgetTester tester) async {
    when(() => reportsRepo.listReports(any())).thenAnswer((invocation) async {
      final id = invocation.positionalArguments.single as String;
      if (id == 'profile-2') {
        return [
          Report(
            id: 'r2',
            profileId: 'profile-2',
            originalFileName: 'other.pdf',
            contentType: 'application/pdf',
            sizeBytes: 200,
            status: 'parsed',
            createdAt: DateTime(2026, 1, 20),
          ),
        ];
      }
      return [];
    });

    await tester.pumpWidget(
      MaterialApp(
        home: TimelineScreen(
          reportsRepository: reportsRepo,
          profilesRepository: profilesRepo,
          profileId: 'profile-1',
          profileName: 'Test Profile',
          sharingRepository: sharingRepo,
          onBack: () {},
          onUpgrade: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('timeline-empty')), findsOneWidget);
    verify(() => reportsRepo.listReports(any())).called(1);

    await tester.pumpWidget(
      MaterialApp(
        home: TimelineScreen(
          reportsRepository: reportsRepo,
          profilesRepository: profilesRepo,
          profileId: 'profile-2',
          profileName: 'Test Profile',
          sharingRepository: sharingRepo,
          onBack: () {},
          onUpgrade: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('timeline-list')), findsOneWidget);
    expect(find.text('other.pdf'), findsOneWidget);
    verify(() => reportsRepo.listReports(any())).called(2);
  });
}
