import 'package:agrocampo/src/modules/profile/profile_ui.dart';
import 'package:agrocampo/src/shared/design_system/feedback/agro_feedback_scope.dart';
import 'package:agrocampo/src/shared/design_system/feedback/agro_sound_effects.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Applies the owner's feedback preferences to the whole app (specs/004).
/// Turning animations off folds into [MediaQueryData.disableAnimations], so
/// every transition that already honours the system reduce-motion setting
/// honours the app preference too, from a single place.
final class AgroFeedbackHost extends ConsumerWidget {
  const AgroFeedbackHost({
    required this.soundEffects,
    required this.child,
    super.key,
  });

  final AgroSoundEffects soundEffects;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences =
        ref.watch(feedbackPreferencesProvider).value ??
        const FeedbackPreferences();
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        disableAnimations:
            media.disableAnimations || !preferences.animationsEnabled,
      ),
      child: AgroFeedbackScope(
        soundEffects: soundEffects,
        soundEnabled: preferences.soundEffectsEnabled,
        child: child,
      ),
    );
  }
}
