import 'package:agrocampo_backend/src/modules/auth/infrastructure/auth_repository.dart';
import 'package:agrocampo_backend/src/modules/auth/infrastructure/secure_session_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class _MemoryStore implements SessionStore {
  String? ownerId;
  String? refreshToken;

  @override
  Future<StoredSessionMaterial?> read() async =>
      ownerId == null || refreshToken == null
      ? null
      : StoredSessionMaterial(
          ownerId: ownerId!,
          refreshToken: refreshToken!,
          biometricEnabled: false,
        );

  @override
  Future<void> persist({
    required String ownerId,
    required String refreshToken,
  }) async {
    this.ownerId = ownerId;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {}

  @override
  Future<void> clear() async {
    ownerId = null;
    refreshToken = null;
  }
}

void main() {
  test('a rotated refresh token replaces the stored one', () async {
    final store = _MemoryStore()
      ..ownerId = 'owner-1'
      ..refreshToken = 'sign-in-token';

    await persistRotatedToken(
      store,
      event: AuthChangeEvent.tokenRefreshed,
      userId: 'owner-1',
      refreshToken: 'rotated-token',
    );

    expect(store.refreshToken, 'rotated-token');
  });

  test('a late refresh after sign-out does not reopen the session', () async {
    final store = _MemoryStore();

    await persistRotatedToken(
      store,
      event: AuthChangeEvent.tokenRefreshed,
      userId: 'owner-1',
      refreshToken: 'late-token',
    );

    expect(await store.read(), isNull);
  });

  test('another owner or unrelated events never overwrite the token', () async {
    final store = _MemoryStore()
      ..ownerId = 'owner-1'
      ..refreshToken = 'current';

    await persistRotatedToken(
      store,
      event: AuthChangeEvent.tokenRefreshed,
      userId: 'owner-2',
      refreshToken: 'foreign',
    );
    await persistRotatedToken(
      store,
      event: AuthChangeEvent.userUpdated,
      userId: 'owner-1',
      refreshToken: 'unrelated',
    );

    expect(store.refreshToken, 'current');
  });

  test('only network failures keep the session open offline', () {
    expect(isTransientAuthFailure(AuthRetryableFetchException()), isTrue);
    expect(
      isTransientAuthFailure(const AuthException('Invalid Refresh Token')),
      isFalse,
    );
  });

  test('wrong user or PIN reads as a plain sentence, never SDK detail', () {
    final failure = signInFailure(
      const AuthException(
        'Invalid login credentials',
        statusCode: '400',
        code: 'invalid_credentials',
      ),
    );
    expect(failure.message, 'El usuario o el PIN son incorrectos.');
    expect(
      signInFailure(AuthRetryableFetchException()).message,
      'Sin conexión. El primer acceso requiere internet.',
    );
  });
}
