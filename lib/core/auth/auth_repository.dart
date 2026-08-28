import 'package:agrocampo/core/auth/secure_session_store.dart';
import 'package:agrocampo/core/errors/app_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class AuthenticatedOwner {
  const AuthenticatedOwner({required this.id, required this.email});

  final String id;
  final String email;
}

abstract interface class AuthRepository {
  Future<String?> restoreLocalOwnerId();
  Future<AuthenticatedOwner> signIn({
    required String email,
    required String password,
  });
  Future<void> signOut();
}

final class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository({required this.client, required this.store});

  final SupabaseClient? client;
  final SecureSessionStore store;

  @override
  Future<String?> restoreLocalOwnerId() => store.readOwnerId();

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
  Future<void> signOut() async {
    await client?.auth.signOut();
    await store.clearTokensPreservingOwner();
  }
}
