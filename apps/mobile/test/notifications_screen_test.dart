import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/notifications/notifications_repository.dart';
import 'package:mobile/features/notifications/screens/notifications_screen.dart';

class _Inbox extends Fake implements NotificationsRepository {
  _Inbox(this.items);
  final List<InboxNotification> items;
  String? marked;

  @override
  Future<List<InboxNotification>> getInbox() async => items;

  @override
  Future<void> markInboxRead(String sourceType, String id) async {
    marked = '$sourceType:$id';
  }
}

void main() {
  testWidgets('empty inbox shows preferences route without invented updates', (tester) async {
    final inbox = _Inbox([]);
    var preferencesOpened = false;
    await tester.pumpWidget(MaterialApp(
      home: NotificationsScreen(
        repository: inbox,
        onBack: () {},
        onManagePreferences: () => preferencesOpened = true,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('All quiet for now.'), findsOneWidget);
    expect(find.text('Your report is ready to review'), findsNothing);
    await tester.tap(find.text('Manage notifications'));
    expect(preferencesOpened, isTrue);
  });

  testWidgets('opens only the selected owned notification and records it as read', (tester) async {
    final inbox = _Inbox([
      InboxNotification(
        id: 'event-1',
        sourceType: 'report',
        type: 'report.review_required',
        title: 'Your report is ready to review',
        body: 'Check extracted details against the original report.',
        occurredAt: DateTime(2026, 10, 24),
        deepLink: '/reports/report-1',
        read: false,
      ),
    ]);
    InboxNotification? opened;
    await tester.pumpWidget(MaterialApp(
      home: NotificationsScreen(
        repository: inbox,
        onBack: () {},
        onManagePreferences: () {},
        onOpenRelated: (item) async { opened = item; },
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Your report is ready to review'));
    await tester.pumpAndSettle();
    expect(inbox.marked, 'report:event-1');
    expect(opened?.deepLink, '/reports/report-1');
    await tester.tap(find.text('Unread'));
    await tester.pumpAndSettle();
    expect(find.text('No unread updates'), findsOneWidget);
  });
}
