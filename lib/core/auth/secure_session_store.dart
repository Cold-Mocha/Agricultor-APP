import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class StoredSessionMaterial {
  const StoredSessionMaterial({
    required this.ownerId,
    required this.refreshToken,
    required this.biometricEnabled,
  });

  final String ownerId;
  final String refreshToken;
  final bool biometricEnabled;
}

abstract interface class SessionStore {
  Future<StoredSessionMaterial?> read();
  Future<void> persist({required String ownerId, required String refreshToken});
  Future<void> setBiometricEnabled(bool enabled);
  Future<void> clear();
}

final class SecureSessionStore implements SessionStore {
  const SecureSessionStore(this._storage);

  static const _ownerKey = 'agrocampo.owner_id';
  static const _refreshKey = 'agrocampo.refresh_token';
  static const _biometricKey = 'agrocampo.biometric_enabled';
  final FlutterSecureStorage _storage;

  Future<String?> readOwnerId() => _storage.read(key: _ownerKey);
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  @override
  Future<StoredSessionMaterial?> read() async {
    final ownerId = await readOwnerId();
    final refreshToken = await readRefreshToken();
    if (ownerId == null ||
        ownerId.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      return null;
    }
    return StoredSessionMaterial(
      ownerId: ownerId,
      refreshToken: refreshToken,
      biometricEnabled:
          await _storage.read(key: _biometricKey) == true.toString(),
    );
  }

  @override
  Future<void> persist({
    required String ownerId,
    required String refreshToken,
  }) async {
    await _storage.write(key: _ownerKey, value: ownerId);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(key: _biometricKey, value: enabled.toString());

  @override
  Future<void> clear() async {
    await _storage.delete(key: _ownerKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _biometricKey);
  }
}
