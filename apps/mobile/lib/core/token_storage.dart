import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _keyAccessToken = 'doclyzer_access_token';
const _keyRefreshToken = 'doclyzer_refresh_token';
const _keyInstallationId = 'doclyzer_installation_id';
const _keyPushDeviceTokenId = 'doclyzer_push_device_token_id';

class TokenStorage {
  TokenStorage()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);
  Future<String?> getPushDeviceTokenId() =>
      _storage.read(key: _keyPushDeviceTokenId);

  Future<void> savePushDeviceTokenId(String id) async {
    await _storage.write(key: _keyPushDeviceTokenId, value: id);
  }

  Future<void> clearPushDeviceTokenId() async {
    await _storage.delete(key: _keyPushDeviceTokenId);
  }

  Future<String> getOrCreateInstallationId() async {
    final existing = await _storage.read(key: _keyInstallationId);
    if (existing != null && existing.isNotEmpty) return existing;
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final id =
        'inst_${DateTime.now().microsecondsSinceEpoch}_${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
    await _storage.write(key: _keyInstallationId, value: id);
    return id;
  }

  Future<void> clear() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await clearPushDeviceTokenId();
  }

  Future<bool> hasTokens() async {
    final access = await getAccessToken();
    final refresh = await getRefreshToken();
    return access != null &&
        access.isNotEmpty &&
        refresh != null &&
        refresh.isNotEmpty;
  }
}
