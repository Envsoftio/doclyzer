import 'dart:io' show Platform;

/// Base URL for the Doclyzer API.
/// - Android Emulator: 10.0.2.2 (localhost on device is the emulator)
/// - iOS Simulator / Desktop: localhost
/// - Physical device: set via env or build flavor to your machine's IP
String get apiBaseUrl =>
    Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
