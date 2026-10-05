import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ProfileUiState {
  const ProfileUiState({required this.displayName, this.emailDisplay});

  factory ProfileUiState.fromSummary(ProfileSummary summary) => ProfileUiState(
    displayName: summary.displayName,
    emailDisplay: summary.emailDisplay,
  );

  final String displayName;
  final String? emailDisplay;

  /// The login user: accounts are `<user>@agrocampo.app`, so the part before
  /// the `@` is what the farmer typed to sign in.
  String get username {
    final user = emailDisplay?.split('@').first.trim() ?? '';
    if (user.isEmpty) return displayName;
    return user[0].toUpperCase() + user.substring(1);
  }
}

final class ProfileController {
  const ProfileController(this._facade);

  final ProfileFacade _facade;

  Stream<ProfileUiState?> watchProfile(String ownerId) => _facade
      .watchProfile(ownerId)
      .map(
        (summary) =>
            summary == null ? null : ProfileUiState.fromSummary(summary),
      );

  Stream<bool> watchWeatherAlertsEnabled(String ownerId) =>
      _facade.watchWeatherAlertsEnabled(ownerId);

  Future<void> setWeatherAlertsEnabled(String ownerId, bool enabled) =>
      _facade.setWeatherAlertsEnabled(ownerId, enabled);

  Stream<bool> watchDarkModeEnabled(String ownerId) =>
      _facade.watchDarkModeEnabled(ownerId);

  Future<void> setDarkModeEnabled(String ownerId, bool enabled) =>
      _facade.setDarkModeEnabled(ownerId, enabled);
}

final profileControllerProvider = Provider<ProfileController>(
  (ref) => ProfileController(ref.watch(profileFacadeProvider)),
);
