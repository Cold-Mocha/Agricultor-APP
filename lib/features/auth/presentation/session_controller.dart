import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/core/auth/auth_repository.dart';
import 'package:agrocampo/features/auth/domain/session_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw StateError('AuthRepository no configurado'),
);
final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

final class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState.checking();

  Future<void> restore() async {
    final ownerId = await ref
        .read(authRepositoryProvider)
        .restoreLocalOwnerId();
    state = ownerId == null
        ? const SessionState.signedOut()
        : SessionState.signedIn(ownerId);
    if (ownerId != null) {
      await ref.read(syncSchedulerProvider).schedule(ownerId: ownerId);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const SessionState.checking();
    try {
      final owner = await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      state = SessionState.signedIn(owner.id);
      await ref.read(syncSchedulerProvider).schedule(ownerId: owner.id);
    } on Object catch (error) {
      state = SessionState.signedOut(message: error.toString());
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const SessionState.signedOut();
  }
}
