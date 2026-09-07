import 'package:agrocampo_backend/core/config/backend_providers.dart';
import 'package:agrocampo_backend/core/database/app_database.dart';
import 'package:agrocampo_backend/features/profile/dto/profile_ui_state.dart';
import 'package:agrocampo_backend/features/weather/repositories/weather_alert_service.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileControllerProvider = Provider<ProfileController>(
  (ref) => ProfileController._(ref.watch(appDatabaseProvider)),
);

final class ProfileController {
  ProfileController._(this._database);

  final AppDatabase _database;

  Stream<ProfileUiState?> watchProfile(String ownerId) =>
      (_database.select(
        _database.localProfiles,
      )..where((row) => row.id.equals(ownerId))).watchSingleOrNull().map(
        (profile) => profile == null
            ? null
            : ProfileUiState(
                displayName: profile.displayName,
                emailDisplay: profile.emailDisplay,
              ),
      );

  Stream<String?> watchActiveLocality(String ownerId) =>
      (_database.select(_database.parcels)..where(
            (row) =>
                row.ownerId.equals(ownerId) &
                row.isActive.equals(true) &
                row.deletedAt.isNull(),
          ))
          .watchSingleOrNull()
          .map((parcel) => parcel?.locality);

  Future<ProfileSaveResult> save(String ownerId, ProfileFormInput input) async {
    final name = input.displayName.trim();
    if (name.isEmpty) return ProfileSaveResult.nameRequired;
    final current = await (_database.select(
      _database.localProfiles,
    )..where((row) => row.id.equals(ownerId))).getSingleOrNull();
    await _database
        .into(_database.localProfiles)
        .insertOnConflictUpdate(
          LocalProfilesCompanion.insert(
            id: ownerId,
            displayName: name,
            emailDisplay: Value(current?.emailDisplay),
            locale: Value(current?.locale ?? 'es_CL'),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    return ProfileSaveResult.saved;
  }

  Stream<bool> watchWeatherAlertsEnabled(String ownerId) =>
      (_database.select(_database.appPreferences)..where(
            (row) =>
                row.ownerId.equals(ownerId) &
                row.key.equals('weather_alerts_enabled'),
          ))
          .watchSingleOrNull()
          .map((preference) => preference?.value == 'true');

  Future<void> setWeatherAlertsEnabled(String ownerId, bool enabled) =>
      WeatherAlertService(_database).setEnabled(ownerId, enabled);
}
