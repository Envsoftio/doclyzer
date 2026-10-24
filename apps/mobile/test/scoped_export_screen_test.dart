import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/account/data_rights_repository.dart';
import 'package:mobile/features/account/screens/data_rights_screen.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';

class _Rights extends Fake implements DataRightsRepository {
  String? profileId;
  bool? includeOriginals;
  bool? includeResults;

  @override
  Future<ClosureRequest?> getClosureRequest() async => null;

  @override
  Future<DataExportRequest> createScopedExportRequest({
    String? profileId,
    DateTime? from,
    DateTime? to,
    bool includeOriginals = true,
    bool includeResults = true,
  }) async {
    this.profileId = profileId;
    this.includeOriginals = includeOriginals;
    this.includeResults = includeResults;
    return const DataExportRequest(
      requestId: 'one',
      userId: 'owner',
      status: 'pending',
      createdAt: '2026-10-24T00:00:00Z',
    );
  }
}

class _Profiles extends Fake implements ProfilesRepository {
  @override
  Future<List<Profile>> getProfiles() async => [
    Profile(
      id: 'ada',
      name: 'Ada',
      relation: 'Self',
      createdAt: DateTime(2026),
      isActive: true,
    ),
  ];
}

class _Reports extends Fake implements ReportsRepository {
  @override
  Future<List<Report>> listAllReports() async => [];
}

void main() {
  testWidgets('export sends selected profile and content options', (
    tester,
  ) async {
    final rights = _Rights();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: DataRightsScreen(
          mode: DataRightsMode.export,
          dataRightsRepository: rights,
          profilesRepository: _Profiles(),
          reportsRepository: _Reports(),
          onBack: () {},
          onAccountClosed: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('export-profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ada').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('export-originals')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('export-originals')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('export-request-button')));
    await tester.pumpAndSettle();
    expect(rights.profileId, 'ada');
    expect(rights.includeOriginals, false);
    expect(rights.includeResults, true);
  });
}
