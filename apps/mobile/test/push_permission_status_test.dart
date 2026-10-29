import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/notifications/push_notification_service.dart';

void main() {
  test('only authorized and provisional devices remain eligible', () {
    for (final status in AuthorizationStatus.values) {
      expect(
        PushNotificationService.canReceiveForStatus(status),
        status == AuthorizationStatus.authorized ||
            status == AuthorizationStatus.provisional,
        reason: status.name,
      );
    }
  });

  test('every disabled permission state offers the prompt', () {
    for (final status in AuthorizationStatus.values) {
      expect(
        PushNotificationService.shouldOfferForStatus(status),
        status != AuthorizationStatus.authorized &&
            status != AuthorizationStatus.provisional,
        reason: status.name,
      );
    }
  });

  test(
    'permanent denial opens settings; Android soft denial can request again',
    () {
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        expect(
          PushNotificationService.shouldOpenSettingsForStatus(
            AuthorizationStatus.deniedPermanently,
            platform: platform,
          ),
          isTrue,
        );
        expect(
          PushNotificationService.shouldOpenSettingsForStatus(
            AuthorizationStatus.notDetermined,
            platform: platform,
          ),
          isFalse,
        );
      }
      expect(
        PushNotificationService.shouldOpenSettingsForStatus(
          AuthorizationStatus.denied,
          platform: TargetPlatform.android,
        ),
        isFalse,
      );
      expect(
        PushNotificationService.shouldOpenSettingsForStatus(
          AuthorizationStatus.denied,
          platform: TargetPlatform.iOS,
        ),
        isTrue,
      );
    },
  );
}
