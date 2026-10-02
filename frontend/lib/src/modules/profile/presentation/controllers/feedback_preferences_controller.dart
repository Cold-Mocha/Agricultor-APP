import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sensory feedback preferences of the unlocked owner (specs/004). Without
/// a session (login) the enabled defaults apply.
final feedbackPreferencesProvider = StreamProvider<FeedbackPreferences>((ref) {
  final ownerId = ref.watch(unlockedOwnerIdProvider);
  if (ownerId == null) return Stream.value(const FeedbackPreferences());
  return ref.watch(profileFacadeProvider).watchFeedbackPreferences(ownerId);
});

final feedbackPreferencesControllerProvider =
    Provider<FeedbackPreferencesController>(
      (ref) => FeedbackPreferencesController(
        ref.watch(profileFacadeProvider),
        ref.watch(unlockedOwnerIdProvider),
      ),
    );

final class FeedbackPreferencesController {
  const FeedbackPreferencesController(this._facade, this._ownerId);

  final ProfileFacade _facade;
  final String? _ownerId;

  Future<void> setSoundEffectsEnabled(bool enabled) async {
    final ownerId = _ownerId;
    if (ownerId == null) return;
    await _facade.setSoundEffectsEnabled(ownerId, enabled);
  }

  Future<void> setAnimationsEnabled(bool enabled) async {
    final ownerId = _ownerId;
    if (ownerId == null) return;
    await _facade.setAnimationsEnabled(ownerId, enabled);
  }
}
