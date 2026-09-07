final class ProfileUiState {
  const ProfileUiState({required this.displayName, this.emailDisplay});

  final String displayName;
  final String? emailDisplay;
}

final class ProfileFormInput {
  const ProfileFormInput({required this.displayName});

  final String displayName;
}

enum ProfileSaveResult { saved, nameRequired }
