import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/weather/domain/weather_snapshot.dart';
import 'package:drift/drift.dart';

final class WeatherAlertService {
  WeatherAlertService(this._database);
  final AppDatabase _database;

  Future<void> setEnabled(String ownerId, bool enabled) => _database
      .into(_database.appPreferences)
      .insertOnConflictUpdate(
        AppPreferencesCompanion.insert(
          ownerId: ownerId,
          key: 'weather_alerts_enabled',
          value: enabled.toString(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );

  Future<List<WeatherAlert>> newAlerts(
    String ownerId,
    WeatherSnapshot snapshot,
  ) async {
    final enabled =
        await (_database.select(_database.appPreferences)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.key.equals('weather_alerts_enabled'),
            ))
            .getSingleOrNull();
    if (enabled?.value != 'true') return const [];
    final delivered =
        await (_database.select(_database.appPreferences)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.key.equals('weather_alert_ids'),
            ))
            .getSingleOrNull();
    final ids = (delivered?.value ?? '')
        .split(',')
        .where((value) => value.isNotEmpty)
        .toSet();
    final fresh = snapshot.alerts
        .where((alert) => !ids.contains(alert.id))
        .toList();
    ids.addAll(fresh.map((alert) => alert.id));
    await _database
        .into(_database.appPreferences)
        .insertOnConflictUpdate(
          AppPreferencesCompanion.insert(
            ownerId: ownerId,
            key: 'weather_alert_ids',
            value: ids.join(','),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    return fresh;
  }
}
