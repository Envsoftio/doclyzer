import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/sharing/screens/create_share_link_screen.dart';
import 'package:mobile/features/sharing/share_access_code_store.dart';
import 'package:mobile/features/sharing/sharing_repository.dart';
import 'package:mobile/features/support/support_repository.dart';

class _Reports extends Fake implements ReportsRepository {
  @override
  Future<List<Report>> listReports(String profileId) async => [
    Report(
      id: 'report-1',
      profileId: profileId,
      originalFileName: 'Complete blood count',
      contentType: 'application/pdf',
      sizeBytes: 100,
      status: 'parsed',
      createdAt: DateTime(2026, 10, 12),
    ),
  ];

  @override
  Future<Report> getReport(String id) async => Report(
    id: id,
    profileId: 'profile-1',
    originalFileName: 'Complete blood count',
    contentType: 'application/pdf',
    sizeBytes: 100,
    status: 'parsed',
    createdAt: DateTime(2026, 10, 12),
    extractedLabValues: const [
      ExtractedLabValue(
        id: 'value-1',
        parameterName: 'Hemoglobin',
        value: '13.2',
        unit: 'g/dL',
      ),
    ],
  );
}

class _TwoReports extends _Reports {
  @override
  Future<List<Report>> listReports(String profileId) async => [
    ...await super.listReports(profileId),
    Report(
      id: 'report-2',
      profileId: profileId,
      originalFileName: 'Metabolic panel',
      contentType: 'application/pdf',
      sizeBytes: 100,
      status: 'parsed',
      createdAt: DateTime(2026, 10, 13),
    ),
  ];
}

class _Sharing extends Fake implements SharingRepository {
  final links = <ShareLink>[];
  List<String>? selectedIds;
  List<String>? selectedValues;
  bool? requiresCode;

  @override
  Future<List<ShareLink>> listShareLinks(
    String profileId, {
    bool includePast = false,
  }) async => links;

  @override
  Future<SharePolicy> getSharePolicy() async => const SharePolicy();

  @override
  Future<ShareLink> createShareLink(
    String profileId, {
    DateTime? expiresAt,
    List<String>? reportIds,
    List<String>? labValueIds,
    bool requireAccessCode = false,
  }) async {
    selectedIds = reportIds;
    selectedValues = labValueIds;
    requiresCode = requireAccessCode;
    final link = ShareLink(
      id: 'link-1',
      token: 'token-1',
      shareUrl: 'https://example.test/share/token-1',
      profileId: profileId,
      scope: labValueIds == null ? 'selected_reports' : 'selected_results',
      reportIds: reportIds,
      labValueIds: labValueIds,
      requiresAccessCode: requireAccessCode,
      accessCode: '123456',
      isActive: true,
      createdAt: DateTime(2026, 10, 24),
    );
    links.add(link);
    return link;
  }
}

class _Support extends Fake implements SupportRepository {}

class _CodeStore implements ShareAccessCodeStore {
  final codes = <String, String>{};

  @override
  Future<String?> read(String linkId) async => codes[linkId];

  @override
  Future<void> save(String linkId, String code) async {
    codes[linkId] = code;
  }

  @override
  Future<void> delete(String linkId) async {
    codes.remove(linkId);
  }
}

void main() {
  testWidgets('report entry point preselects only the open report', (
    tester,
  ) async {
    final sharing = _Sharing();
    final codeStore = _CodeStore();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CreateShareLinkScreen(
          profileId: 'profile-1',
          profileName: 'Priya',
          initialReportId: 'report-1',
          sharingRepository: sharing,
          accessCodeStore: codeStore,
          reportsRepository: _TwoReports(),
          supportRepository: _Support(),
          onUpgrade: () {},
        ),
      ),
    );
    await tester.pump();
    expect(
      tester
          .widget<CheckboxListTile>(
            find.byKey(const Key('share-report-report-1')),
          )
          .value,
      isTrue,
    );
    expect(
      tester
          .widget<CheckboxListTile>(
            find.byKey(const Key('share-report-report-2')),
          )
          .value,
      isFalse,
    );
    final create = find.byKey(const Key('create-share-link-button'));
    await tester.ensureVisible(create);
    await tester.tap(create);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create link'));
    await tester.pumpAndSettle();
    expect(sharing.selectedIds, ['report-1']);
  });

  testWidgets('selected reports and access code are reviewed before creating', (
    tester,
  ) async {
    final sharing = _Sharing();
    final codeStore = _CodeStore();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CreateShareLinkScreen(
          profileId: 'profile-1',
          profileName: 'Priya',
          sharingRepository: sharing,
          accessCodeStore: codeStore,
          reportsRepository: _Reports(),
          supportRepository: _Support(),
          onUpgrade: () {},
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Choose reports'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('share-report-report-1')));
    await tester.pump();
    final review = find.byKey(const Key('create-share-link-button'));
    await tester.ensureVisible(review);
    await tester.tap(review);
    await tester.pumpAndSettle();
    expect(find.text('Review sharing'), findsWidgets);
    expect(find.text('1 selected reports'), findsOneWidget);
    expect(sharing.selectedIds, isNull);
    await tester.tap(find.text('Create link'));
    await tester.pumpAndSettle();
    expect(sharing.selectedIds, ['report-1']);
    expect(sharing.requiresCode, isTrue);
    expect(find.byKey(const Key('share-access-code')), findsOneWidget);
    expect(codeStore.codes['link-1'], '123456');
    expect(
      tester.getTopLeft(find.byKey(const Key('share-access-code'))).dy,
      lessThan(400),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CreateShareLinkScreen(
          profileId: 'profile-1',
          profileName: 'Priya',
          sharingRepository: sharing,
          accessCodeStore: codeStore,
          reportsRepository: _Reports(),
          supportRepository: _Support(),
          onUpgrade: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('existing-share-access-code-link-1')),
      findsOneWidget,
    );
  });

  testWidgets('selected test results are sent as a narrow sharing scope', (
    tester,
  ) async {
    final sharing = _Sharing();
    final codeStore = _CodeStore();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CreateShareLinkScreen(
          profileId: 'profile-1',
          profileName: 'Priya',
          sharingRepository: sharing,
          accessCodeStore: codeStore,
          reportsRepository: _Reports(),
          supportRepository: _Support(),
          onUpgrade: () {},
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Choose reports'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('share-report-report-1')));
    await tester.pump();
    final selectResults = find.text('Selected test results');
    await tester.ensureVisible(selectResults);
    await tester.tap(selectResults);
    await tester.pump();
    final value = find.byKey(const Key('share-value-value-1'));
    await tester.ensureVisible(value);
    await tester.tap(value);
    await tester.pump();
    final review = find.byKey(const Key('create-share-link-button'));
    await tester.ensureVisible(review);
    await tester.tap(review);
    await tester.pumpAndSettle();
    expect(find.text('1 selected test results'), findsOneWidget);
    await tester.tap(find.text('Create link'));
    await tester.pumpAndSettle();
    expect(sharing.selectedIds, ['report-1']);
    expect(sharing.selectedValues, ['value-1']);
  });
}
