import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    state = await ref.read(authSessionFacadeProvider).restore();
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const SessionState.restoring();
    try {
      state = await ref
          .read(authSessionFacadeProvider)
          .signIn(email: email, password: password);
    } on Object catch (error) {
      state = SessionState.signedOut(message: error.toString());
    }
  }

  Future<void> unlockWithBiometrics() async {
    final ownerId = state.ownerId;
    if (state.status != SessionStatus.locked || ownerId == null) return;
    final wasOffline = state.offline;
    final result = await ref
        .read(authSessionFacadeProvider)
        .authenticateBiometrics();
    if (result == BiometricUnlockResult.success) {
      state = wasOffline
          ? SessionState.offline(ownerId, biometricEnabled: true)
          : SessionState(
              status: SessionStatus.signedIn,
              ownerId: ownerId,
              biometricEnabled: true,
            );
      await ref.read(authSessionFacadeProvider).resumeOwner(ownerId);
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
    final accepted = await ref
        .read(authSessionFacadeProvider)
        .setBiometricEnabled(enabled);
    if (!accepted) return false;
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
    await ref.read(authSessionFacadeProvider).signOut(state.ownerId);
    state = const SessionState.signedOut();
  }

  Future<void> resumeOwner(String ownerId) =>
      ref.read(authSessionFacadeProvider).resumeOwner(ownerId);
}
