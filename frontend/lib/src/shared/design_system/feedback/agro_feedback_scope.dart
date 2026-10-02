import 'package:agrocampo/src/shared/design_system/feedback/agro_sound_effects.dart';
import 'package:flutter/widgets.dart';

/// Carries the sound player and the user's sound preference down the tree so
/// shared components can give feedback without depending on feature modules
/// (the app layer resolves the preference and places this scope).
final class AgroFeedbackScope extends InheritedWidget {
  const AgroFeedbackScope({
    required this.soundEffects,
    required this.soundEnabled,
    required super.child,
    super.key,
  });

  final AgroSoundEffects soundEffects;
  final bool soundEnabled;

  static AgroFeedbackScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AgroFeedbackScope>();

  @override
  bool updateShouldNotify(AgroFeedbackScope oldWidget) =>
      soundEffects != oldWidget.soundEffects ||
      soundEnabled != oldWidget.soundEnabled;
}
