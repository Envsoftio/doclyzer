import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class ShareAccessCodeStore {
  Future<String?> read(String linkId);
  Future<void> save(String linkId, String code);
  Future<void> delete(String linkId);
}

class SecureShareAccessCodeStore implements ShareAccessCodeStore {
  const SecureShareAccessCodeStore();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String _key(String linkId) => 'share-access-code:$linkId';

  @override
  Future<String?> read(String linkId) => _storage.read(key: _key(linkId));

  @override
  Future<void> save(String linkId, String code) =>
      _storage.write(key: _key(linkId), value: code);

  @override
  Future<void> delete(String linkId) => _storage.delete(key: _key(linkId));
}
