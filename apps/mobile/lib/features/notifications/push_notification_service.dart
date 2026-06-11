import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../core/token_storage.dart';
import 'notifications_repository.dart';

class PushNotificationService {
  PushNotificationService({
    required NotificationsRepository notificationsRepository,
    required TokenStorage tokenStorage,
  }) : _notificationsRepository = notificationsRepository,
       _tokenStorage = tokenStorage;

  final NotificationsRepository _notificationsRepository;
  final TokenStorage _tokenStorage;

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _openSubscription;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    final messaging = await _messagingOrNull();
    if (messaging == null) return;

    await _registerCurrentToken(messaging);

    _tokenRefreshSubscription ??= messaging.onTokenRefresh.listen((token) {
      unawaited(_registerProviderToken(token));
    });
    _openSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen((
      message,
    ) {
      unawaited(_trackOpen(message));
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await _trackOpen(initialMessage);
    }
  }

  Future<void> deactivateCurrentToken() async {
    final deviceTokenId = await _tokenStorage.getPushDeviceTokenId();
    if (deviceTokenId == null || deviceTokenId.isEmpty) return;
    try {
      await _notificationsRepository.deactivateDeviceToken(deviceTokenId);
    } catch (_) {
      // Logout/session cleanup must continue even if the API token is already invalid.
    } finally {
      await _tokenStorage.clearPushDeviceTokenId();
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _openSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _openSubscription = null;
    _started = false;
  }

  Future<FirebaseMessaging?> _messagingOrNull() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return null;
      }
      return messaging;
    } catch (_) {
      // Firebase project files/options are environment-specific. Missing config
      // should never block login or navigation.
      return null;
    }
  }

  Future<void> _registerCurrentToken(FirebaseMessaging messaging) async {
    try {
      final providerToken = await messaging.getToken();
      if (providerToken == null || providerToken.isEmpty) return;
      await _registerProviderToken(providerToken);
    } catch (_) {
      return;
    }
  }

  Future<void> _registerProviderToken(String providerToken) async {
    try {
      final installationId = await _tokenStorage.getOrCreateInstallationId();
      final token = await _notificationsRepository.registerDeviceToken(
        RegisterPushTokenInput(
          token: providerToken,
          platform: _platform,
          installationId: installationId,
          appVersion: const String.fromEnvironment(
            'APP_VERSION',
            defaultValue: '1.0.0+1',
          ),
        ),
      );
      await _tokenStorage.savePushDeviceTokenId(token.id);
    } catch (_) {
      return;
    }
  }

  Future<void> _trackOpen(RemoteMessage message) async {
    try {
      final deviceTokenId = await _tokenStorage.getPushDeviceTokenId();
      await _notificationsRepository.trackPushOpen(
        deviceTokenId: deviceTokenId,
        pushSendAuditId: message.data['pushSendAuditId'],
        providerMessageId: message.messageId,
        deepLink: message.data['deepLink'],
        metadata: {
          'notificationType': message.data['notificationType'] ?? '',
          'category': message.data['category'] ?? '',
        },
      );
    } catch (_) {
      return;
    }
  }

  String get _platform {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      default:
        return 'android';
    }
  }
}
