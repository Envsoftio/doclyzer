import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> openDeviceNotificationSettings() async {
  try {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await const MethodChannel(
        'doclyzer/device_settings',
      ).invokeMethod<void>('openNotifications');
      return true;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await launchUrl(Uri.parse('app-settings:'));
    }
  } catch (_) {
    return false;
  }
  return false;
}
