import 'package:agrocampo/core/auth/secure_session_store.dart';
import 'package:agrocampo/core/errors/app_failure.dart';
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
    } on AuthException {
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
      throw AuthenticationFailure('auth_rejected', error.message);
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
