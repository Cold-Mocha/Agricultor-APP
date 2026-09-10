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

  Stream<String?> watchActiveLocality(String ownerId) =>
      _facade.watchActiveLocality(ownerId);

  Future<ProfileSaveResult> save(String ownerId, ProfileFormInput input) =>
      _facade.save(ownerId, input);

  Stream<bool> watchWeatherAlertsEnabled(String ownerId) =>
      _facade.watchWeatherAlertsEnabled(ownerId);

  Future<void> setWeatherAlertsEnabled(String ownerId, bool enabled) =>
      _facade.setWeatherAlertsEnabled(ownerId, enabled);
}

final profileControllerProvider = Provider<ProfileController>(
  (ref) => ProfileController(ref.watch(profileFacadeProvider)),
);
