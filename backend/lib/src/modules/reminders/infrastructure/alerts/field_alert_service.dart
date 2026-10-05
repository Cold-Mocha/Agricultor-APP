import 'dart:convert';

import 'package:agrocampo_backend/src/modules/reminders/domain/entities/field_alerts.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_gateway.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/drift.dart';

/// Stores the alert thresholds per owner and finds the alerts not yet
/// notified, from active seasons and each quadrant's cached weather.
final class FieldAlertService {
  FieldAlertService(this._database);

  static const _settingsKey = 'field_alerts';
  static const _deliveredKey = 'field_alerts_delivered';

  /// Keys kept to avoid repeating a notice; older ones are long past.
  static const _deliveredLimit = 300;

  final AppDatabase _database;

  Stream<FieldAlertSettings> watchSettings(String ownerId) =>
      _preference(ownerId, _settingsKey).watchSingleOrNull().map(_decode);

  Future<FieldAlertSettings> loadSettings(String ownerId) async =>
      _decode(await _preference(ownerId, _settingsKey).getSingleOrNull());

  Future<void> saveSettings(String ownerId, FieldAlertSettings settings) =>
      _write(ownerId, _settingsKey, jsonEncode(settings.toJson()));

  /// Refreshes the weather of every quadrant through [gateway]; a failing
  /// quadrant keeps its cached forecast.
  Future<void> refreshWeather(String ownerId, WeatherGateway gateway) async {
    final repository = WeatherRepository(_database, gateway);
    for (final sector in await _liveSectors(ownerId)) {
      try {
        await repository.refresh(
          ownerId: ownerId,
          locality: sector.name,
          sectorId: sector.id,
        );
      } on Object {
        continue;
      }
    }
  }

  /// Alerts due now that were not notified before; they are marked as
  /// delivered so each event is notified once.
  Future<List<FieldAlertNotice>> takeNewNotices(
    String ownerId, {
    DateTime? today,
  }) async {
    final settings = await loadSettings(ownerId);
    final sectors = await _liveSectors(ownerId);
    final names = {for (final sector in sectors) sector.id: sector.name};
    final seasons =
        await (_database.select(_database.agriculturalSeasons)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.status.equals('active') &
                  row.endsOn.isNotNull() &
                  row.deletedAt.isNull(),
            ))
            .get();
    final cache = WeatherRepository(
      _database,
      const UnavailableWeatherGateway(),
    );
    final forecasts = <SectorForecast>[];
    for (final sector in sectors) {
      final weather = await cache.cached(ownerId, sectorId: sector.id);
      if (weather != null) {
        forecasts.add((
          sectorId: sector.id,
          sectorName: sector.name,
          weather: weather,
        ));
      }
    }
    final notices = evaluateFieldAlerts(
      settings: settings,
      seasons: [
        for (final season in seasons)
          if (names[season.sectorId] case final name?)
            (seasonId: season.id, sectorName: name, endsOn: season.endsOn!),
      ],
      forecasts: forecasts,
      today: today ?? DateTime.now(),
    );
    final delivered =
        (await _preference(ownerId, _deliveredKey).getSingleOrNull())?.value
            .split(',')
            .where((key) => key.isNotEmpty)
            .toList() ??
        <String>[];
    final seen = delivered.toSet();
    final fresh = [
      for (final notice in notices)
        if (!seen.contains(notice.key)) notice,
    ];
    if (fresh.isNotEmpty) {
      final keys = [...delivered, ...fresh.map((notice) => notice.key)];
      await _write(
        ownerId,
        _deliveredKey,
        keys
            .skip(
              keys.length > _deliveredLimit ? keys.length - _deliveredLimit : 0,
            )
            .join(','),
      );
    }
    return fresh;
  }

  Future<List<Sector>> _liveSectors(String ownerId) =>
      (_database.select(_database.sectors)..where(
            (row) => row.ownerId.equals(ownerId) & row.deletedAt.isNull(),
          ))
          .get();

  SimpleSelectStatement<$AppPreferencesTable, AppPreference> _preference(
    String ownerId,
    String key,
  ) =>
      _database.select(_database.appPreferences)
        ..where((row) => row.ownerId.equals(ownerId) & row.key.equals(key));

  Future<void> _write(String ownerId, String key, String value) => _database
      .into(_database.appPreferences)
      .insertOnConflictUpdate(
        AppPreferencesCompanion.insert(
          ownerId: ownerId,
          key: key,
          value: value,
          updatedAt: DateTime.now().toUtc(),
        ),
      );

  static FieldAlertSettings _decode(AppPreference? row) {
    if (row == null) return FieldAlertSettings.defaults;
    try {
      return FieldAlertSettings.fromJson(
        jsonDecode(row.value) as Map<String, dynamic>,
      );
    } on Object {
      return FieldAlertSettings.defaults;
    }
  }
}
