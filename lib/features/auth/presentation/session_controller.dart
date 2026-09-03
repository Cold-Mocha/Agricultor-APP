import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/core/auth/auth_repository.dart';
import 'package:agrocampo/core/auth/biometric_unlock_gateway.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/auth/domain/session_state.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw StateError('AuthRepository no configurado'),
);
final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);
final unlockedOwnerIdProvider = Provider<String?>((ref) {
  final session = ref.watch(sessionControllerProvider);
  return switch (session.status) {
    SessionStatus.signedIn || SessionStatus.offline => session.ownerId,
    _ => null,
  };
});

final class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState.restoring();

  Future<void> restore() async {
    final session = await ref.read(authRepositoryProvider).restoreSession();
    if (session == null) {
      state = const SessionState.signedOut();
      return;
    }
    if (session.biometricEnabled) {
      state = SessionState.locked(session.ownerId, offline: session.offline);
      return;
    }
    state = session.offline
        ? SessionState.offline(session.ownerId)
        : SessionState.signedIn(session.ownerId);
    await _resumeOwner(session.ownerId);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const SessionState.restoring();
    try {
      final owner = await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      state = SessionState.signedIn(owner.id);
      await _rememberProfile(owner.id, owner.email);
      await _resumeOwner(owner.id);
    } on Object catch (error) {
      state = SessionState.signedOut(message: error.toString());
    }
  }

  Future<void> unlockWithBiometrics() async {
    final ownerId = state.ownerId;
    if (state.status != SessionStatus.locked || ownerId == null) return;
    final wasOffline = state.offline;
    final result = await ref
        .read(biometricUnlockGatewayProvider)
        .authenticate();
    if (result == BiometricUnlockResult.success) {
      state = wasOffline
          ? SessionState.offline(ownerId, biometricEnabled: true)
          : SessionState(
              status: SessionStatus.signedIn,
              ownerId: ownerId,
              biometricEnabled: true,
            );
      await _resumeOwner(ownerId);
      return;
    }
    state = SessionState.locked(
      ownerId,
      offline: wasOffline,
      message: switch (result) {
        BiometricUnlockResult.cancelled => 'Desbloqueo cancelado.',
        BiometricUnlockResult.notEnrolled =>
          'Configura biometría en el dispositivo o ingresa nuevamente.',
        BiometricUnlockResult.lockedOut =>
          'Biometría bloqueada temporalmente. Ingresa nuevamente.',
        _ => 'No fue posible usar biometría. Ingresa nuevamente.',
      },
    );
  }

  Future<bool> setBiometricEnabled(bool enabled) async {
    if (enabled &&
        !await ref.read(biometricUnlockGatewayProvider).isAvailable()) {
      return false;
    }
    await ref.read(authRepositoryProvider).setBiometricEnabled(enabled);
    final ownerId = state.ownerId;
    if (ownerId != null) {
      state = state.status == SessionStatus.offline
          ? SessionState.offline(ownerId, biometricEnabled: enabled)
          : SessionState(
              status: state.status,
              ownerId: ownerId,
              biometricEnabled: enabled,
              offline: state.offline,
            );
    }
    return true;
  }

  Future<void> signOut() async {
    final ownerId = state.ownerId;
    if (ownerId != null) {
      await ref.read(syncTriggerCoordinatorProvider).stop(ownerId);
    }
    await ref.read(authRepositoryProvider).signOut();
    state = const SessionState.signedOut();
  }

  Future<void> resumeOwner(String ownerId) => _resumeOwner(ownerId);

  Future<void> _rememberProfile(String ownerId, String email) async {
    try {
      final database = ref.read(appDatabaseProvider);
      final current = await (database.select(
        database.localProfiles,
      )..where((row) => row.id.equals(ownerId))).getSingleOrNull();
      await database
          .into(database.localProfiles)
          .insertOnConflictUpdate(
            LocalProfilesCompanion.insert(
              id: ownerId,
              displayName: current?.displayName ?? email,
              emailDisplay: Value(email),
              locale: Value(current?.locale ?? 'es_CL'),
              updatedAt: DateTime.now().toUtc(),
            ),
          );
    } on Object {
      // A local presentation preference must not invalidate authentication.
    }
  }

  Future<void> _resumeOwner(String ownerId) async {
    // Startup reconciliation is best effort: a corrupt reminder, an unavailable
    // native scheduler or a transient database error must never invalidate an
    // otherwise valid local/Supabase session.
    try {
      await ref.read(cropAssignmentReconcilerProvider).reconcile(ownerId);
    } on Object {
      // The next resume/background synchronization retries reconciliation.
    }
    try {
      await ref.read(reminderReconcilerProvider).reconcile(ownerId);
    } on Object {
      // Native notification support is optional and may be unavailable on host.
    }
    await ref.read(syncTriggerCoordinatorProvider).start(ownerId);
  }
}
