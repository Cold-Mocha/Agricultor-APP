import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/auth/contracts/biometric_unlock_result.dart';
import 'package:agrocampo_backend/src/modules/auth/domain/entities/session_state.dart';
import 'package:agrocampo_backend/src/modules/auth/infrastructure/auth_repository.dart';
import 'package:agrocampo_backend/src/modules/auth/infrastructure/biometric_unlock_gateway.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw StateError('AuthRepository no configurado'),
);

final authSessionFacadeProvider = Provider<AuthSessionFacade>((ref) {
  return AuthSessionFacade._(
    () => ref.read(authRepositoryProvider),
    () => ref.read(biometricUnlockGatewayProvider),
    () => ref.read(appDatabaseProvider),
    (ownerId) => ref.read(cropAssignmentReconcilerProvider).reconcile(ownerId),
    (ownerId) => ref.read(reminderReconcilerProvider).reconcile(ownerId),
    (ownerId) => ref.read(syncTriggerCoordinatorProvider).start(ownerId),
    (ownerId) => ref.read(syncTriggerCoordinatorProvider).stop(ownerId),
  );
});

/// Public authentication application boundary. It performs authentication and
/// owner-resume work but owns no widget, router or screen state.
final class AuthSessionFacade {
  AuthSessionFacade._(
    this._auth,
    this._biometrics,
    this._database,
    this._reconcileCrops,
    this._reconcileReminders,
    this._startSync,
    this._stopSync,
  );

  final AuthRepository Function() _auth;
  final BiometricUnlockGateway Function() _biometrics;
  final AppDatabase Function() _database;
  final Future<void> Function(String ownerId) _reconcileCrops;
  final Future<void> Function(String ownerId) _reconcileReminders;
  final Future<void> Function(String ownerId) _startSync;
  final Future<void> Function(String ownerId) _stopSync;

  Future<SessionState> restore() async {
    final session = await _auth().restoreSession();
    if (session == null) return const SessionState.signedOut();
    if (session.biometricEnabled) {
      return SessionState.locked(session.ownerId, offline: session.offline);
    }
    final restored = session.offline
        ? SessionState.offline(session.ownerId)
        : SessionState.signedIn(session.ownerId);
    await resumeOwner(session.ownerId);
    return restored;
  }

  Future<SessionState> signIn({
    required String email,
    required String password,
  }) async {
    final owner = await _auth().signIn(email: email, password: password);
    await _rememberProfile(owner.id, owner.email);
    await resumeOwner(owner.id);
    return SessionState.signedIn(owner.id);
  }

  Future<BiometricUnlockResult> authenticateBiometrics() =>
      _biometrics().authenticate();

  Future<bool> setBiometricEnabled(bool enabled) async {
    if (enabled && !await _biometrics().isAvailable()) return false;
    await _auth().setBiometricEnabled(enabled);
    return true;
  }

  Future<void> signOut(String? ownerId) async {
    if (ownerId != null) await _stopSync(ownerId);
    await _auth().signOut();
  }

  Future<void> resumeOwner(String ownerId) async {
    try {
      await _reconcileCrops(ownerId);
    } on Object {
      // Best effort; the next resume/background synchronization retries it.
    }
    try {
      await _reconcileReminders(ownerId);
    } on Object {
      // Native notification support may be unavailable on a host environment.
    }
    await _startSync(ownerId);
  }

  Future<void> _rememberProfile(String ownerId, String email) async {
    try {
      final database = _database();
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
}
