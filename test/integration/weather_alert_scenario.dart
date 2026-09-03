import 'package:agrocampo/features/weather/data/weather_alert_service.dart';
import 'package:agrocampo/features/weather/data/weather_gateway.dart';
import 'package:agrocampo/features/weather/data/weather_repository.dart';
import 'package:agrocampo/features/weather/domain/weather_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/file_backed_database.dart';

final class _WeatherGateway implements WeatherGateway {
  _WeatherGateway({this.fail = false});
  bool fail;
  @override
  Future<WeatherSnapshot> fetch({
    required String locality,
    String? parcelId,
  }) async {
    if (fail) throw StateError('offline');
    return WeatherSnapshot(
      locality: locality,
      temperatureC: 12,
      humidityPercent: 82,
      rainMillimeters: 1,
      summary: 'Nublado',
      fetchedAt: DateTime.utc(2026, 8, 30),
      expiresAt: DateTime.utc(2026, 8, 30, 1),
      provider: 'open-meteo',
      attribution: 'Datos meteorológicos por Open-Meteo.com',
      attributionUrl: 'https://open-meteo.com/',
      forecast: [
        WeatherForecastDay(
          date: DateTime.utc(2026, 8, 31),
          minimumC: 3,
          maximumC: 15,
          rainChancePercent: 30,
          summary: 'Nublado',
        ),
      ],
      alerts: [
        WeatherAlert(
          id: 'frost-2026-08-31',
          title: 'Riesgo de helada',
          severity: 'moderate',
          startsAt: DateTime.utc(2026, 8, 31),
          endsAt: DateTime.utc(2026, 8, 31, 8),
        ),
      ],
    );
  }
}

void main() {
  test(
    'weather cache becomes stale offline and alert dedupe survives restart',
    () async {
      final fixture = await FileBackedDatabaseFixture.create();
      addTearDown(fixture.dispose);
      var database = fixture.open();
      final repository = WeatherRepository(database, _WeatherGateway());
      final snapshot = await repository.refresh(
        ownerId: 'owner-1',
        locality: 'Curicó',
      );
      final alerts = WeatherAlertService(database);
      await alerts.setEnabled('owner-1', true);
      expect(await alerts.newAlerts('owner-1', snapshot), hasLength(1));
      await database.close();
      database = fixture.open();
      addTearDown(database.close);
      final offline = WeatherRepository(database, _WeatherGateway(fail: true));
      final result = await offline.load(
        ownerId: 'owner-1',
        locality: 'Curicó',
        now: DateTime.utc(2026, 9),
      );
      expect(result, isA<WeatherStale>());
      final cached = await offline.cached('owner-1');
      expect(cached?.attribution, 'Datos meteorológicos por Open-Meteo.com');
      expect(cached?.forecast, hasLength(1));
      expect(
        await WeatherAlertService(database).newAlerts('owner-1', cached!),
        isEmpty,
      );
    },
  );
}
