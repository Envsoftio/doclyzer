import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/screens/session_list_screen.dart';
import 'package:mobile/features/auth/sessions_repository.dart';

class _Sessions extends Fake implements SessionsRepository {
  @override
  Future<List<DeviceSessionSummary>> getSessions() async => const [
    DeviceSessionSummary(
      sessionId: 'current',
      ip: '192.0.2.1',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148',
      createdAt: '2026-10-21T10:00:00Z',
      isCurrent: true,
    ),
    DeviceSessionSummary(
      sessionId: 'other',
      ip: '192.0.2.2',
      userAgent: 'Chrome on another device',
      createdAt: '2026-10-20T10:00:00Z',
      isCurrent: false,
    ),
  ];

  @override
  Future<void> revokeSession(String sessionId) async {}
}

void main() {
  for (final textScale in [1.0, 2.0]) {
    testWidgets('session cards stay separated at ${textScale}x text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(320, 900),
              textScaler: TextScaler.linear(textScale),
            ),
            child: SessionListScreen(
              sessionsRepository: _Sessions(),
              onLogout: () {},
              onBack: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final first = find.byKey(const Key('session-item-current'));
      final second = find.byKey(const Key('session-item-other'));
      if (textScale == 1.0) {
        expect(
          tester.getTopLeft(second).dy - tester.getBottomLeft(first).dy,
          16,
        );
      }
      expect(find.byKey(const Key('session-current-current')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
