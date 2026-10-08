import 'package:agrocampo_backend/src/modules/auth/infrastructure/auth_repository.dart';
import 'package:agrocampo_backend/src/shared/kernel/app_failure.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Device-local owner used by local-only builds. The identifier is created
/// once and survives restarts so every local record keeps a stable owner.
final class LocalOwnerStore {
  const LocalOwnerStore(this._storage);

  static const _ownerKey = 'agrocampo.local_owner_id';
  static const _biometricKey = 'agrocampo.biometric_enabled';
  final FlutterSecureStorage _storage;

  Future<String?> readOwnerId() async {
    final ownerId = await _storage.read(key: _ownerKey);
    return ownerId == null || ownerId.isEmpty ? null : ownerId;
  }

  Future<String> ensureOwnerId() async {
    final existing = await readOwnerId();
    if (existing != null) return existing;
    final created = const Uuid().v4();
    await _storage.write(key: _ownerKey, value: created);
    return created;
  }

  Future<bool> readBiometricEnabled() async =>
      await _storage.read(key: _biometricKey) == true.toString();

  Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(key: _biometricKey, value: enabled.toString());

  Future<void> clearOwnerId() => _storage.delete(key: _ownerKey);
}

final class LocalAuthRepository implements AuthRepository {
  const LocalAuthRepository(this._store);

  final LocalOwnerStore _store;

  @override
  Future<RestoredAuthSession?> restoreSession() async => RestoredAuthSession(
    ownerId: await _store.ensureOwnerId(),
    biometricEnabled: await _store.readBiometricEnabled(),
    offline: true,
  );

  @override
  Future<AuthenticatedOwner> signIn({
    required String email,
    required String password,
  }) async {
    throw const AuthenticationFailure(
      'local_mode',
      'Esta versión funciona sólo en el dispositivo.',
    );
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) =>
      _store.setBiometricEnabled(enabled);

  /// The local owner is the only account on the device; signing out must not
  /// orphan its records, so the identity is kept.
  @override
  Future<void> signOut() async {}
}
