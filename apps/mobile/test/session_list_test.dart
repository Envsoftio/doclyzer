import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/auth/screens/session_list_screen.dart';
import 'package:mobile/features/auth/sessions_repository.dart';
import 'fakes.dart';

Widget _wrap(
  SessionsRepository repo, {
  VoidCallback? onLogout,
  VoidCallback? onBack,
}) {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A7C8C)),
      useMaterial3: true,
    ),
    home: SessionListScreen(
      sessionsRepository: repo,
      onLogout: onLogout ?? () {},
      onBack: onBack ?? () {},
    ),
  );
}

void main() {
  testWidgets('sessions render with correct keys', (WidgetTester tester) async {
    final repo = FakeSessionsRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('session-item-current-session-id')), findsOneWidget);
    expect(find.byKey(const Key('session-item-other-session-id')), findsOneWidget);
    expect(find.byKey(const Key('session-revoke-current-session-id')), findsOneWidget);
    expect(find.byKey(const Key('session-revoke-other-session-id')), findsOneWidget);
  });

  testWidgets('tapping revoke shows confirmation dialog', (WidgetTester tester) async {
    final repo = FakeSessionsRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('session-revoke-other-session-id')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('session-revoke-dialog')), findsOneWidget);
    expect(find.byKey(const Key('session-revoke-cancel')), findsOneWidget);
    expect(find.byKey(const Key('session-revoke-confirm')), findsOneWidget);
  });

  testWidgets('tapping Cancel closes dialog and does not call revokeSession', (WidgetTester tester) async {
    final repo = FakeSessionsRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    final initialCount = (await repo.getSessions()).length;

    await tester.tap(find.byKey(const Key('session-revoke-other-session-id')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('session-revoke-cancel')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('session-revoke-dialog')), findsNothing);
    expect((await repo.getSessions()).length, equals(initialCount));
  });

  testWidgets('tapping Revoke calls revokeSession and list refreshes', (WidgetTester tester) async {
    final repo = FakeSessionsRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('session-revoke-other-session-id')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('session-revoke-confirm')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('session-item-other-session-id')), findsNothing);
    expect(find.byKey(const Key('session-item-current-session-id')), findsOneWidget);
  });

  testWidgets('revoking current session calls onLogout callback', (WidgetTester tester) async {
    final repo = FakeSessionsRepository();
    var logoutCalled = false;

    await tester.pumpWidget(_wrap(repo, onLogout: () => logoutCalled = true));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('session-revoke-current-session-id')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('session-revoke-confirm')));
    await tester.pumpAndSettle();

    expect(logoutCalled, isTrue);
  });

  testWidgets('error state shown when repository throws on load', (WidgetTester tester) async {
    final repo = _FailingSessionsRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('session-list-error')), findsOneWidget);
  });
}

class _FailingSessionsRepository implements SessionsRepository {
  @override
  Future<List<DeviceSessionSummary>> getSessions() async {
    throw Exception('Session not found');
  }

  @override
  Future<void> revokeSession(String sessionId) async {}
}
