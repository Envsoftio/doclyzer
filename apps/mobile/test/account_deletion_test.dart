import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/account/data_rights_repository.dart';
import 'package:mobile/features/account/screens/data_rights_screen.dart';

class _PendingDeletion extends Fake implements DataRightsRepository {
  bool restored = false;

  @override
  Future<ClosureRequest?> getClosureRequest() async => const ClosureRequest(
    requestId: 'closure-1',
    userId: 'user-1',
    status: 'pending',
    createdAt: '2026-10-20T00:00:00Z',
    purgeAfterAt: '2026-11-19T00:00:00Z',
    message: 'Pending deletion',
  );

  @override
  Future<ClosureRequest> restoreClosure() async {
    restored = true;
    return const ClosureRequest(
      requestId: 'closure-1',
      userId: 'user-1',
      status: 'restored',
      createdAt: '2026-10-20T00:00:00Z',
      message: 'Restored',
    );
  }
}

class _ActiveAccount extends Fake implements DataRightsRepository {
  String? confirmedPassword;

  @override
  Future<ClosureRequest?> getClosureRequest() async => null;

  @override
  Future<ClosureRequest> createClosureRequest({
    required bool confirmClosure,
    required String password,
  }) async {
    confirmedPassword = password;
    return const ClosureRequest(
      requestId: 'closure-2',
      userId: 'user-2',
      status: 'pending',
      createdAt: '2026-10-20T00:00:00Z',
      message: 'Pending deletion',
    );
  }
}

void main() {
  testWidgets('pending account can restore before returning to normal app', (
    tester,
  ) async {
    final repository = _PendingDeletion();
    var resumed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: DataRightsScreen(
          dataRightsRepository: repository,
          onBack: () {},
          onAccountClosed: () async {},
          onAccountRestored: () async {
            resumed = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Account pending deletion'), findsOneWidget);
    expect(find.text('Export My Data'), findsNothing);
    await tester.tap(find.text('Restore my account'));
    await tester.pumpAndSettle();
    expect(repository.restored, isTrue);
    expect(resumed, isTrue);
  });

  testWidgets('deletion requires a fresh password', (tester) async {
    final repository = _ActiveAccount();
    var signedOut = false;
    await tester.pumpWidget(
      MaterialApp(
        home: DataRightsScreen(
          dataRightsRepository: repository,
          onBack: () {},
          onAccountClosed: () async {
            signedOut = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('close-account-button')));
    await tester.pumpAndSettle();
    final confirm = find.byKey(const Key('closure-confirm'));
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
    await tester.enterText(
      find.widgetWithText(TextField, 'Current password'),
      'example-secret',
    );
    await tester.pumpAndSettle();
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(repository.confirmedPassword, 'example-secret');
    expect(signedOut, isTrue);
  });
}
