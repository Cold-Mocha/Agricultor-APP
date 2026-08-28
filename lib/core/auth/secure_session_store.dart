import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class SecureSessionStore {
  const SecureSessionStore(this._storage);

  static const _ownerKey = 'agrocampo.owner_id';
  static const _refreshKey = 'agrocampo.refresh_token';
  final FlutterSecureStorage _storage;

  Future<String?> readOwnerId() => _storage.read(key: _ownerKey);
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> persist({
    required String ownerId,
    required String refreshToken,
  }) async {
    await _storage.write(key: _ownerKey, value: ownerId);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<void> clearTokensPreservingOwner() =>
      _storage.delete(key: _refreshKey);
}
