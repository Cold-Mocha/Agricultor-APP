import 'package:agrocampo_backend/src/modules/auth/infrastructure/auth_repository.dart';

/// Opens the device without credential UI; remote identity remains owner scoped.
final class DeviceAuthRepository implements AuthRepository {
  const DeviceAuthRepository(this._remote, this._local, this._anonymous);
  final AuthRepository _remote;
  final AuthRepository _local;
  final Future<RestoredAuthSession> Function() _anonymous;

  @override
  Future<RestoredAuthSession?> restoreSession() async {
    try {
      final existing = await _remote.restoreSession();
      if (existing != null) return existing;
      return await _anonymous();
    } on Object {
      // First use without internet must still preserve a stable local owner.
      return _local.restoreSession();
    }
  }

  @override
  Future<AuthenticatedOwner> signIn({
    required String email,
    required String password,
  }) => _remote.signIn(email: email, password: password);

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _remote.setBiometricEnabled(enabled);
    await _local.setBiometricEnabled(enabled);
  }

  @override
  Future<void> signOut() async {}
}
