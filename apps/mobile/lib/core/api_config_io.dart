import 'dart:io' show Platform;

/// Base URL for the Doclyzer API.
/// - Android Emulator: 10.0.2.2 (localhost on device is the emulator)
/// - iOS Simulator / Desktop: localhost
/// - Physical device: pass --dart-define=API_BASE_URL=http://HOST_LAN_IP:4002
const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');

String get apiBaseUrl => _configuredApiBaseUrl.isNotEmpty
    ? _configuredApiBaseUrl
    : Platform.isAndroid
    ? 'http://10.0.2.2:4002'
    : 'http://localhost:4002';
