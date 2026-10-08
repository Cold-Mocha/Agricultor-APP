import 'dart:async';

import 'package:agrocampo_backend/src/modules/auth/infrastructure/secure_session_store.dart';
import 'package:agrocampo_backend/src/shared/kernel/app_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class AuthenticatedOwner {
  const AuthenticatedOwner({required this.id, required this.email});

  final String id;
  final String email;
}

final class RestoredAuthSession {
  const RestoredAuthSession({
    required this.ownerId,
    required this.biometricEnabled,
    required this.offline,
  });

  final String ownerId;
  final bool biometricEnabled;
  final bool offline;
}

abstract interface class AuthRepository {
  Future<RestoredAuthSession?> restoreSession();
  Future<AuthenticatedOwner> signIn({
    required String email,
    required String password,
  });
  Future<void> setBiometricEnabled(bool enabled);
  Future<void> signOut();
}

final class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository({required this.client, required this.store});

  final SupabaseClient? client;
  final SessionStore store;

  /// Keeps the stored refresh token current. Supabase rotates it on every
  /// refresh, so persisting only the sign-in token would end the session at
  /// the next app start. Lives as long as the app.
  StreamSubscription<AuthState>? keepSessionFresh() =>
      client?.auth.onAuthStateChange.listen(
        (state) => persistRotatedToken(
          store,
          event: state.event,
          userId: state.session?.user.id,
          refreshToken: state.session?.refreshToken,
        ),
      );

  @override
  Future<RestoredAuthSession?> restoreSession() async {
    final local = await store.read();
    if (local == null) return null;
    final authClient = client;
    if (authClient == null) {
      return RestoredAuthSession(
        ownerId: local.ownerId,
        biometricEnabled: local.biometricEnabled,
        offline: true,
      );
    }
    // supabase_flutter recovers its own persisted session on initialize; it
    // is newer than ours whenever the token rotated while the app was open.
    final recovered = authClient.auth.currentSession;
    if (recovered != null && recovered.user.id == local.ownerId) {
      final refreshToken = recovered.refreshToken;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await store.persist(ownerId: local.ownerId, refreshToken: refreshToken);
      }
      return RestoredAuthSession(
        ownerId: local.ownerId,
        biometricEnabled: local.biometricEnabled,
        offline: false,
      );
    }
    try {
      final response = await authClient.auth.setSession(local.refreshToken);
      final session = response.session;
      final user = response.user;
      if (session == null || user == null || user.id != local.ownerId) {
        await store.clear();
        return null;
      }
      final refreshToken = session.refreshToken;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await store.persist(ownerId: user.id, refreshToken: refreshToken);
      }
      return RestoredAuthSession(
        ownerId: user.id,
        biometricEnabled: local.biometricEnabled,
        offline: false,
      );
    } on AuthException catch (error) {
      // Without signal the session stays open offline; only a rejection by
      // Supabase ends it.
      if (isTransientAuthFailure(error)) {
        return RestoredAuthSession(
          ownerId: local.ownerId,
          biometricEnabled: local.biometricEnabled,
          offline: true,
        );
      }
      await store.clear();
      return null;
    } on Object {
      return RestoredAuthSession(
        ownerId: local.ownerId,
        biometricEnabled: local.biometricEnabled,
        offline: true,
      );
    }
  }

  @override
  Future<AuthenticatedOwner> signIn({
    required String email,
    required String password,
  }) async {
    final authClient = client;
    if (authClient == null) {
      throw const AuthenticationFailure(
        'auth_not_configured',
        'Configura Supabase para el primer acceso.',
      );
    }
    try {
      final response = await authClient.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final session = response.session;
      final user = response.user;
      if (session == null || user == null) {
        throw const AuthenticationFailure(
          'invalid_session',
          'No fue posible iniciar sesión.',
        );
      }
      await store.persist(
        ownerId: user.id,
        refreshToken: session.refreshToken ?? '',
      );
      return AuthenticatedOwner(id: user.id, email: user.email ?? email.trim());
    } on AuthException catch (error) {
      throw signInFailure(error);
    }
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) =>
      store.setBiometricEnabled(enabled);

  @override
  Future<void> signOut() async {
    try {
      await client?.auth.signOut();
    } finally {
      await store.clear();
    }
  }
}

/// Network failures while refreshing must not sign the owner out.
bool isTransientAuthFailure(Object error) =>
    error is AuthRetryableFetchException;

/// Persists a rotated refresh token for the signed-in owner. Ignores events
/// after sign-out so a late refresh cannot resurrect a closed session.
Future<void> persistRotatedToken(
  SessionStore store, {
  required AuthChangeEvent event,
  required String? userId,
  required String? refreshToken,
}) async {
  if (event != AuthChangeEvent.tokenRefreshed &&
      event != AuthChangeEvent.signedIn) {
    return;
  }
  if (userId == null || refreshToken == null || refreshToken.isEmpty) return;
  final stored = await store.read();
  if (stored == null || stored.ownerId != userId) return;
  await store.persist(ownerId: userId, refreshToken: refreshToken);
}

/// Farmer-facing reason for a rejected sign-in; never exposes SDK details.
AppFailure signInFailure(AuthException error) {
  if (isTransientAuthFailure(error)) {
    return const ConnectivityFailure(
      'auth_offline',
      'Sin conexión. El primer acceso requiere internet.',
    );
  }
  if (error.code == 'invalid_credentials' || error.statusCode == '400') {
    return const AuthenticationFailure(
      'invalid_credentials',
      'El usuario o el PIN son incorrectos.',
    );
  }
  return const AuthenticationFailure(
    'auth_rejected',
    'No fue posible iniciar sesión. Intenta nuevamente.',
  );
}
