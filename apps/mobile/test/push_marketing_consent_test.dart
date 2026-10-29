import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/token_storage.dart';
import 'package:mobile/features/notifications/notifications_repository.dart';
import 'package:mobile/features/notifications/push_notification_service.dart';

class _Storage extends Fake implements TokenStorage {
  @override
  Future<String?> getPushDeviceTokenId() async => 'current-device';
}

class _Notifications extends Fake implements NotificationsRepository {
  final updates = <bool>[];
  @override
  Future<void> updatePreferences(
    String id,
    Map<String, bool> preferences,
  ) async {
    expect(id, 'current-device');
    updates.add(preferences['marketing']!);
  }
}

class _Push extends PushNotificationService {
  _Push(_Notifications repo)
    : super(notificationsRepository: repo, tokenStorage: _Storage());
  bool allowed = true;
  int registrationWaits = 0;
  @override
  Future<bool> requestPermission() async => allowed;
  @override
  Future<void> start() {
    registrationWaits++;
    return Completer<void>().future;
  }
}

void main() {
  test(
    'existing device saves consent without waiting on blocked token registration',
    () async {
      final repo = _Notifications();
      final push = _Push(repo);
      await push.setMarketingConsent(true).timeout(const Duration(seconds: 1));
      expect(repo.updates, [true]);
      expect(push.registrationWaits, 0);
      await push.setMarketingConsent(false);
      expect(repo.updates, [true, false]);
    },
  );

  test(
    'denied permission reports failure without enabling device marketing',
    () async {
      final repo = _Notifications();
      final push = _Push(repo)..allowed = false;
      await expectLater(push.setMarketingConsent(true), throwsStateError);
      expect(repo.updates, isEmpty);
    },
  );
}
