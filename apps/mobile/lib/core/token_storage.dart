import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _keyAccessToken = 'doclyzer_access_token';
const _keyRefreshToken = 'doclyzer_refresh_token';
const _keyInstallationId = 'doclyzer_installation_id';
const _keyPushDeviceTokenId = 'doclyzer_push_device_token_id';
const _keyInterruptedReportUpload = 'doclyzer_interrupted_report_upload';
const _reportUploadKeyPrefix = 'report-upload:';

class TokenStorage {
  TokenStorage()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  final FlutterSecureStorage _storage;
  // Keep the original storage options for existing upload keys on Android.
  final FlutterSecureStorage _uploadKeyStorage = const FlutterSecureStorage();

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

  Future<void> markReportUploadStarted() async {
    await _storage.write(key: _keyInterruptedReportUpload, value: 'true');
  }

  Future<bool> hasInterruptedReportUpload() async =>
      await _storage.read(key: _keyInterruptedReportUpload) == 'true';

  Future<void> clearInterruptedReportUpload() async {
    await _storage.delete(key: _keyInterruptedReportUpload);
  }

  Future<String> getOrCreateReportUploadKey(
    String profileId,
    String hash,
  ) async {
    final storageKey = '$_reportUploadKeyPrefix$profileId:$hash';
    final existing = await _uploadKeyStorage.read(key: storageKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final random = Random.secure();
    final key = List.generate(
      24,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    await _uploadKeyStorage.write(key: storageKey, value: key);
    return key;
  }

  Future<void> clearReportUploadKey(String profileId, String hash) =>
      _uploadKeyStorage.delete(key: '$_reportUploadKeyPrefix$profileId:$hash');

  Future<void> clearReportUploadKeys() async {
    final keys = await _uploadKeyStorage.readAll();
    for (final key in keys.keys.where(
      (key) => key.startsWith(_reportUploadKeyPrefix),
    )) {
      await _uploadKeyStorage.delete(key: key);
    }
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
    await clearInterruptedReportUpload();
    await clearReportUploadKeys();
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
