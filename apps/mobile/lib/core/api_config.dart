/// Base URL for the Doclyzer API.
/// Uses 10.0.2.2:3000 on Android (emulator → host). localhost elsewhere.
/// Physical device: use your machine IP (e.g. http://192.168.1.x:3000).
import 'api_config_stub.dart' if (dart.library.io) 'api_config_io.dart' as _config;

String get apiBaseUrl => _config.apiBaseUrl;
