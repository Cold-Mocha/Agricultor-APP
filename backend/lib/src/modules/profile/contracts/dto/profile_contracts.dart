final class ProfileSummary {
  const ProfileSummary({required this.displayName, this.emailDisplay});

  final String displayName;
  final String? emailDisplay;
}

final class ProfileFormInput {
  const ProfileFormInput({required this.displayName});

  final String displayName;
}

enum ProfileSaveResult { saved, nameRequired }

/// Device-local sensory feedback preferences of an owner (specs/004).
/// Both default to enabled and are never synchronized.
final class FeedbackPreferences {
  const FeedbackPreferences({
    this.soundEffectsEnabled = true,
    this.animationsEnabled = true,
  });

  final bool soundEffectsEnabled;
  final bool animationsEnabled;

  @override
  bool operator ==(Object other) =>
      other is FeedbackPreferences &&
      other.soundEffectsEnabled == soundEffectsEnabled &&
      other.animationsEnabled == animationsEnabled;

  @override
  int get hashCode => Object.hash(soundEffectsEnabled, animationsEnabled);
}
