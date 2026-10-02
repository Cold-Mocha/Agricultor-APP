import 'package:agrocampo/src/shared/design_system/feedback/agro_feedback_scope.dart';
import 'package:agrocampo/src/shared/design_system/feedback/agro_sound_effects.dart';
import 'package:agrocampo/src/shared/design_system/feedback/agro_success_check.dart';
import 'package:flutter/material.dart';

/// Single entry point for user feedback (specs/004, master.md "Sonido" and
/// "Movimiento y feedback"). Every event keeps its textual snackbar, so sound
/// and motion only reinforce what is already readable and announced.
abstract final class AgroFeedback {
  /// An agricultural record was saved: distinctive sound, animated check and
  /// the confirmation message.
  static void recordSaved(BuildContext context, String message) {
    playSound(context, AgroSound.recordSaved);
    AgroSuccessCheck.show(context);
    _snackBar(context, message);
  }

  /// A setting, profile or export was saved: gentle confirmation sound.
  static void saved(BuildContext context, String message) {
    playSound(context, AgroSound.saved);
    _snackBar(context, message);
  }

  /// A save failed or fields are invalid: error sound and the recovery text.
  static void error(BuildContext context, String message) {
    playSound(context, AgroSound.error);
    _snackBar(context, message);
  }

  /// Neutral guidance that needs no sound.
  static void info(BuildContext context, String message) =>
      _snackBar(context, message);

  /// Wraps a primary button callback so it clicks before running. A null
  /// callback stays null, keeping the button disabled.
  static VoidCallback? tap(BuildContext context, VoidCallback? onPressed) {
    if (onPressed == null) return null;
    return () {
      playSound(context, AgroSound.tap);
      onPressed();
    };
  }

  /// Plays [sound] when the user keeps sound effects enabled. Without a
  /// scope (isolated widget tests, previews) nothing plays.
  static void playSound(BuildContext context, AgroSound sound) {
    final scope = AgroFeedbackScope.maybeOf(context);
    if (scope == null || !scope.soundEnabled) return;
    scope.soundEffects.play(sound);
  }

  static void _snackBar(BuildContext context, String message) =>
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(message)));
}
