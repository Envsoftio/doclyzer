import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/account/data_rights_repository.dart';
import 'fakes.dart';
import 'package:mobile/features/account/screens/data_rights_screen.dart';

Widget _wrap(
  DataRightsRepository repo, {
  VoidCallback? onBack,
  Future<void> Function()? onAccountClosed,
}) {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A7C8C)),
      useMaterial3: true,
    ),
    home: DataRightsScreen(
      dataRightsRepository: repo,
      onBack: onBack ?? () {},
      onAccountClosed: onAccountClosed ?? () async {},
    ),
  );
}

void main() {
  testWidgets('renders export button and close account button',
      (WidgetTester tester) async {
    final repo = FakeDataRightsRepository();
    await tester.pumpWidget(_wrap(repo));

    expect(find.byKey(const Key('export-request-button')), findsOneWidget);
    expect(find.byKey(const Key('close-account-button')), findsOneWidget);
  });

  testWidgets('tapping Export My Data shows status after request',
      (WidgetTester tester) async {
    final repo = FakeDataRightsRepository();
    await tester.pumpWidget(_wrap(repo));

    await tester.tap(find.byKey(const Key('export-request-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('export-status')), findsOneWidget);
    expect(find.byKey(const Key('export-success')), findsOneWidget);
  });

  testWidgets(
      'after export created, tapping Check Status shows completed and download ready',
      (WidgetTester tester) async {
    final repo = FakeDataRightsRepository();
    await tester.pumpWidget(_wrap(repo));

    await tester.tap(find.byKey(const Key('export-request-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('export-check-status-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('export-check-status-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('export-download-ready')), findsOneWidget);
  });

  testWidgets('tapping Close My Account shows confirmation dialog',
      (WidgetTester tester) async {
    final repo = FakeDataRightsRepository();
    await tester.pumpWidget(_wrap(repo));

    await tester.tap(find.byKey(const Key('close-account-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('closure-dialog')), findsOneWidget);
    expect(find.byKey(const Key('closure-impact-text')), findsOneWidget);
    expect(find.byKey(const Key('closure-cancel')), findsOneWidget);
    expect(find.byKey(const Key('closure-confirm')), findsOneWidget);
  });

  testWidgets('tapping Cancel in closure dialog closes dialog without calling API',
      (WidgetTester tester) async {
    final repo = FakeDataRightsRepository();
    await tester.pumpWidget(_wrap(repo));

    await tester.tap(find.byKey(const Key('close-account-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('closure-cancel')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('closure-dialog')), findsNothing);
    expect(repo.hasClosureRequestForTest(), isFalse);
  });

  testWidgets('confirming closure calls API and triggers onAccountClosed callback',
      (WidgetTester tester) async {
    final repo = FakeDataRightsRepository();
    bool closedCalled = false;
    await tester.pumpWidget(_wrap(
      repo,
      onAccountClosed: () async => closedCalled = true,
    ));

    await tester.tap(find.byKey(const Key('close-account-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('closure-confirm')));
    // Use pump instead of pumpAndSettle to avoid timeout from loading indicator animation
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(repo.hasClosureRequestForTest(), isTrue);
    expect(closedCalled, isTrue);
  });

  testWidgets('error from export repository shows inline error',
      (WidgetTester tester) async {
    final repo = _FailingExportRepository();
    await tester.pumpWidget(_wrap(repo));

    await tester.tap(find.byKey(const Key('export-request-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('export-error')), findsOneWidget);
  });
}

class _FailingExportRepository implements DataRightsRepository {
  @override
  Future<DataExportRequest> createExportRequest() async {
    throw const DataRightsException('Server error');
  }

  @override
  Future<DataExportRequest> getExportRequest(String requestId) async {
    throw const DataRightsException('Server error');
  }

  @override
  Future<ClosureRequest> createClosureRequest({
    required bool confirmClosure,
  }) async {
    throw const DataRightsException('Server error');
  }

  @override
  Future<ClosureRequest?> getClosureRequest() async => null;
}
