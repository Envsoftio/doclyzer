import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/token_storage.dart';
import 'notifications_repository.dart';
import 'api_notifications_repository.dart';
import 'push_payload.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // The OS renders background notification messages. No duplicate local notification or UI work.
}

class PushNotificationService {
  PushNotificationService({
    required NotificationsRepository notificationsRepository,
    required TokenStorage tokenStorage,
  }) : _notificationsRepository = notificationsRepository,
       _tokenStorage = tokenStorage;
  final NotificationsRepository _notificationsRepository;
  final TokenStorage _tokenStorage;
  final _local = FlutterLocalNotificationsPlugin();
  FirebaseMessaging? _messaging;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _openSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  bool _started = false;
  bool _localReady = false;
  int _generation = 0;
  Future<void> _registration = Future.value();
  Future<void>? _starting;
  Future<bool> Function(String reportId)? onReportOpen;
  Future<void> Function(String path)? onDestinationOpen;
  VoidCallback? onForegroundReport;
  bool Function()? canNavigate;
  final List<PushPayload> _pending = [];
  final Set<String> _opened = {};
  bool _navigating = false;
  bool _discardRegistration = false;
  Timer? _registrationRetry;
  int _registrationRetryAttempt = 0;

  void _retryRegistration(int generation) {
    if (!_started ||
        generation != _generation ||
        _registrationRetry != null ||
        _registrationRetryAttempt >= 3) {
      return;
    }
    const delays = [2, 5, 15];
    _registrationRetry = Timer(
      Duration(seconds: delays[_registrationRetryAttempt++]),
      () {
        _registrationRetry = null;
        if (_started && generation == _generation) unawaited(synchronize());
      },
    );
  }

  static void _logFailure(String stage, Object error) {
    // Do not log exception messages: network errors may contain private data.
    final code = error is FirebaseException ? error.code : error.runtimeType;
    debugPrint('Push $stage failed ($code)');
  }

  static Future<void> initializeBackgroundHandling() async {
    if (kIsWeb ||
        ![
          TargetPlatform.android,
          TargetPlatform.iOS,
        ].contains(defaultTargetPlatform)) {
      return;
    }
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (error) {
      _logFailure('Firebase configuration', error);
    }
  }

  Future<void> start() =>
      _starting ??= _start().whenComplete(() => _starting = null);
  Future<void> _start() async {
    if (_started) {
      await synchronize();
      return;
    }
    if (kIsWeb ||
        ![
          TargetPlatform.android,
          TargetPlatform.iOS,
        ].contains(defaultTargetPlatform)) {
      return;
    }
    final generation = _generation;
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      if (generation != _generation) return;
      _discardRegistration = false;
      _messaging = FirebaseMessaging.instance;
      _started = true;
      await _initializeLocal();
      // Local notifications render the foreground on both platforms.
      await _messaging!.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
      if (generation != _generation) return;
      _tokenRefreshSubscription = _messaging!.onTokenRefresh.listen(
        (token) => unawaited(synchronize(token: token)),
      );
      _openSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _queueOpen(message.data),
      );
      _foregroundSubscription = FirebaseMessaging.onMessage.listen(
        (message) => unawaited(
          _foreground(message).catchError((Object error) {
            _logFailure('foreground display', error);
          }),
        ),
      );
      final initial = await _messaging!.getInitialMessage();
      if (generation != _generation) return;
      if (initial != null) _queueOpen(initial.data);
      final launch = await _local.getNotificationAppLaunchDetails();
      if (generation != _generation) return;
      if (launch?.didNotificationLaunchApp == true) {
        _localOpen(launch?.notificationResponse?.payload);
      }
      await synchronize();
      await flushPendingNavigation();
    } catch (error) {
      _logFailure('initialization', error);
      _started = false;
      await _tokenRefreshSubscription?.cancel();
      await _openSubscription?.cancel();
      await _foregroundSubscription?.cancel();
      _tokenRefreshSubscription = null;
      _openSubscription = null;
      _foregroundSubscription = null;
      debugPrint('Push initialization unavailable');
    }
  }

  Future<void> _initializeLocal() async {
    if (_localReady) return;
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_doclyzer'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) =>
          _localOpen(response.payload),
    );
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    for (final channel in const [
      AndroidNotificationChannel(
        'transactional_high',
        'Important service updates',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        'transactional_normal',
        'Service updates',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        'marketing',
        'Offers and announcements',
        importance: Importance.defaultImportance,
      ),
    ]) {
      await android?.createNotificationChannel(channel);
    }
    _localReady = true;
  }

  Future<bool> shouldOfferPermissionPrompt() async {
    final messaging = await _permissionMessaging();
    if (messaging == null) return false;
    final settings = await messaging.getNotificationSettings();
    debugPrint('Push permission status: ${settings.authorizationStatus.name}');
    return shouldOfferForStatus(settings.authorizationStatus);
  }

  Future<bool> shouldOpenPermissionSettings() async {
    final messaging = await _permissionMessaging();
    if (messaging == null) return false;
    final settings = await messaging.getNotificationSettings();
    return shouldOpenSettingsForStatus(
      settings.authorizationStatus,
      platform: defaultTargetPlatform,
    );
  }

  Future<bool> isPermissionGranted() async {
    final messaging = await _permissionMessaging();
    if (messaging == null) return false;
    final settings = await messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  static bool canReceiveForStatus(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;

  static bool shouldOfferForStatus(AuthorizationStatus status) =>
      switch (status) {
        AuthorizationStatus.notDetermined ||
        AuthorizationStatus.denied ||
        AuthorizationStatus.deniedPermanently => true,
        AuthorizationStatus.authorized ||
        AuthorizationStatus.provisional => false,
      };

  static bool shouldOpenSettingsForStatus(
    AuthorizationStatus status, {
    required TargetPlatform platform,
  }) =>
      status == AuthorizationStatus.deniedPermanently ||
      (status == AuthorizationStatus.denied && platform == TargetPlatform.iOS);

  Future<bool> requestPermission() async {
    final messaging = await _permissionMessaging();
    if (messaging == null) {
      throw StateError('Push notifications are not configured for this build.');
    }
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    unawaited(
      _analytics('notification_permission_result', {
        'status': settings.authorizationStatus.name,
      }),
    );
    unawaited(start());
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  // Permission UI must not wait for network-dependent token registration.
  Future<FirebaseMessaging?> _permissionMessaging() async {
    if (kIsWeb ||
        ![
          TargetPlatform.android,
          TargetPlatform.iOS,
        ].contains(defaultTargetPlatform)) {
      return null;
    }
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    return _messaging ??= FirebaseMessaging.instance;
  }

  Future<void> setMarketingConsent(bool enabled) async {
    var id = await _tokenStorage.getPushDeviceTokenId();
    if (enabled) {
      if (!await requestPermission()) {
        throw StateError(
          'Allow notifications in device settings, then save again.',
        );
      }
      // An existing registration can save consent immediately. Token refresh
      // must not block this PATCH behind Firebase/network registration work.
      if (id == null) {
        await start().timeout(const Duration(seconds: 10));
        id = await _tokenStorage.getPushDeviceTokenId();
      }
    }
    if (id == null && enabled) {
      throw StateError(
        'Device registration is not ready. Enable notifications and try again.',
      );
    }
    if (id != null) {
      await _notificationsRepository.updatePreferences(id, {
        'marketing': enabled,
      });
    }
  }

  Future<void> synchronize({String? token}) {
    final generation = _generation;
    _registration = _registration.catchError((_) {}).then((_) async {
      if (!_started || generation != _generation || _messaging == null) return;
      try {
        final settings = await _messaging!.getNotificationSettings();
        debugPrint(
          'Push registration permission: ${settings.authorizationStatus.name}',
        );
        // Revoke server eligibility before touching APNs/FCM: token retrieval
        // may fail after the user disables notifications in system settings.
        if (!canReceiveForStatus(settings.authorizationStatus)) {
          final id = await _tokenStorage.getPushDeviceTokenId();
          if (!_started || generation != _generation) return;
          if (id != null) {
            await _notificationsRepository.deactivateDeviceToken(id);
          }
          return;
        }
        if (defaultTargetPlatform == TargetPlatform.iOS &&
            await _messaging!.getAPNSToken() == null) {
          debugPrint('Push registration waiting for APNs token');
          _retryRegistration(generation);
          return;
        }
        final providerToken = token ?? await _messaging!.getToken();
        if (providerToken == null || providerToken.isEmpty) {
          debugPrint('Push registration waiting for FCM token');
          _retryRegistration(generation);
          return;
        }
        final installation = await _tokenStorage.getOrCreateInstallationId();
        final package = await PackageInfo.fromPlatform();
        final device = await DeviceInfoPlugin().deviceInfo;
        final zone = await FlutterTimezone.getLocalTimezone();
        final metadata = <String, String>{
          'appBuildNumber': package.buildNumber,
          'locale': WidgetsBinding.instance.platformDispatcher.locale
              .toLanguageTag(),
          'timezone': zone.identifier,
          'osVersion': Platform.operatingSystemVersion,
          'deviceModel': device is AndroidDeviceInfo
              ? device.model
              : device is IosDeviceInfo
              ? device.utsname.machine
              : 'unknown',
          'deviceType':
              device is IosDeviceInfo &&
                  device.model.toLowerCase().contains('ipad')
              ? 'tablet'
              : 'unknown',
        };
        if (!_started || generation != _generation) return;
        final registered = await _notificationsRepository.registerDeviceToken(
          RegisterPushTokenInput(
            token: providerToken,
            platform: defaultTargetPlatform == TargetPlatform.iOS
                ? 'ios'
                : 'android',
            installationId: installation,
            appVersion: package.version,
            metadata: metadata,
            notificationPermission: switch (settings.authorizationStatus) {
              AuthorizationStatus.authorized => 'authorized',
              AuthorizationStatus.provisional => 'provisional',
              AuthorizationStatus.denied => 'denied',
              _ => 'unknown',
            },
          ),
        );
        // dispose waits for registration before logout revokes this exact installation.
        if (!_discardRegistration) {
          await _tokenStorage.savePushDeviceTokenId(registered.id);
          _registrationRetry?.cancel();
          _registrationRetry = null;
          _registrationRetryAttempt = 0;
          debugPrint('Push device registered with server');
        }
      } catch (error) {
        _logFailure('registration', error);
        _retryRegistration(generation);
      }
    });
    return _registration;
  }

  Future<void> _foreground(RemoteMessage message) async {
    final generation = _generation;
    if (!_started) return;
    final payload = PushPayload.parse(message.data);
    if (payload == null) {
      debugPrint('Push foreground message ignored: unsupported payload');
      return;
    }
    debugPrint('Push foreground message received');
    if (message.data['notificationType'] == 'report.completed') {
      onForegroundReport?.call();
    }
    // Receipt/analytics requests must never delay the local notification.
    unawaited(_event(payload, 'received'));
    unawaited(
      _analytics('push_received', {
        'notification_type': '${message.data['notificationType'] ?? ''}',
      }),
    );
    if (!_started ||
        generation != _generation ||
        message.notification == null) {
      return;
    }
    final marketing = payload.data['category'] == 'marketing';
    await _local.show(
      id:
          (message.data['recipientId'] ??
                  message.data['notificationId'] ??
                  message.messageId ??
                  jsonEncode(message.data))
              .hashCode &
          0x7fffffff,
      title: message.notification!.title,
      body: message.notification!.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          marketing ? 'marketing' : 'transactional_high',
          marketing ? 'Offers and announcements' : 'Important service updates',
          importance: marketing
              ? Importance.defaultImportance
              : Importance.high,
          priority: marketing ? Priority.defaultPriority : Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _localOpen(String? raw) {
    if (raw == null) return;
    try {
      _queueOpen(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      /* Ignore malformed local payload. */
    }
  }

  void _queueOpen(Map<String, dynamic> data) {
    final payload = PushPayload.parse(data);
    if (payload == null) return;
    final key =
        '${data['recipientId'] ?? data['notificationId'] ?? jsonEncode(data)}';
    if (!_opened.add(key)) return;
    _pending.add(payload);
    unawaited(flushPendingNavigation());
  }

  Future<void> flushPendingNavigation() async {
    if (_navigating || !_started || canNavigate?.call() != true) return;
    _navigating = true;
    final generation = _generation;
    try {
      while (_pending.isNotEmpty &&
          _started &&
          canNavigate?.call() == true &&
          generation == _generation) {
        final p = _pending.removeAt(0);
        await _event(p, 'opened');
        await _analytics('push_opened', {
          'notification_type': '${p.data['notificationType'] ?? ''}',
        });
        if (!_started ||
            generation != _generation ||
            canNavigate?.call() != true) {
          _pending.insert(0, p);
          break;
        }
        var navigated = true;
        if (p.reportId != null) {
          navigated = await onReportOpen?.call(p.reportId!) ?? false;
        } else {
          await onDestinationOpen?.call(p.path);
        }
        if (!navigated) continue;
        if (_started && generation == _generation) {
          await _event(p, 'deep_link_opened');
          await _analytics('push_action', {
            'notification_type': '${p.data['notificationType'] ?? ''}',
          });
        }
      }
    } catch (_) {
      debugPrint('Notification destination unavailable');
    } finally {
      _navigating = false;
    }
  }

  Future<void> _event(PushPayload p, String type) async {
    final repo = _notificationsRepository;
    if (repo is ApiNotificationsRepository && p.data['recipientId'] is String) {
      try {
        await repo.trackRecipientEvent(p.data['recipientId'] as String, type);
      } catch (_) {
        /* Best-effort telemetry. */
      }
    }
  }

  Future<void> _analytics(String name, Map<String, Object> values) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: name, parameters: values);
    } catch (_) {
      /* Analytics cannot block navigation. */
    }
  }

  Future<void> invalidateSession() async {
    // This can be invoked by an API request inside _registration. Never await
    // that same registration/start future here: it would deadlock on a 401.
    _started = false;
    _generation++;
    _registrationRetry?.cancel();
    _registrationRetry = null;
    _registrationRetryAttempt = 0;
    _discardRegistration = true;
    await _tokenRefreshSubscription?.cancel();
    await _openSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _openSubscription = null;
    _foregroundSubscription = null;
    try {
      await _messaging?.deleteToken();
    } catch (_) {
      debugPrint('Provider token revocation deferred');
    }
    if (_localReady) await _local.cancelAll();
    await _tokenStorage.clearPushDeviceTokenId();
    _pending.clear();
    _opened.clear();
  }

  Future<void> deactivateCurrentToken() async {
    await dispose();
    final id = await _tokenStorage.getPushDeviceTokenId();
    bool revoked = id == null;
    try {
      if (id != null) await _notificationsRepository.deactivateDeviceToken(id);
      revoked = true;
    } catch (_) {
      /* Revoke provider token below if the session has expired. */
    }
    try {
      await _messaging?.deleteToken();
    } catch (_) {
      if (!revoked) {
        throw StateError(
          'Connect to the internet to safely sign out of push notifications.',
        );
      }
    }
    if (_localReady) await _local.cancelAll();
    await _tokenStorage.clearPushDeviceTokenId();
    _pending.clear();
    _opened.clear();
  }

  Future<void> dispose() async {
    _started = false;
    _generation++;
    _registrationRetry?.cancel();
    _registrationRetry = null;
    _registrationRetryAttempt = 0;
    await _starting;
    await _tokenRefreshSubscription?.cancel();
    await _openSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _openSubscription = null;
    _foregroundSubscription = null;
    await _registration;
    _pending.clear();
  }
}
