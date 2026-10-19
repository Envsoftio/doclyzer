// Base URL for the Doclyzer API.
// Uses 10.0.2.2:4002 on Android emulators and localhost:4002 elsewhere.
// Physical devices need --dart-define=API_BASE_URL=http://<host-LAN-IP>:4002.
import 'api_config_stub.dart'
    if (dart.library.io) 'api_config_io.dart'
    as config;

String get apiBaseUrl => config.apiBaseUrl;
