import 'package:agrocampo/features/weather/data/weather_alert_service.dart';
import 'package:agrocampo/features/weather/data/weather_gateway.dart';
import 'package:agrocampo/features/weather/data/weather_repository.dart';
import 'package:agrocampo/features/weather/domain/weather_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

final class _Gateway implements WeatherGateway {
  bool fail = false;
  @override
  Future<WeatherSnapshot> fetch({
    required String locality,
    String? parcelId,
  }) async {
    if (fail) throw StateError('offline');
    return WeatherSnapshot(
      locality: locality,
      temperatureC: 19,
      humidityPercent: 60,
      rainMillimeters: 0,
      summary: 'Despejado',
      fetchedAt: DateTime.utc(2026, 8, 28),
      expiresAt: DateTime.utc(2026, 8, 28, 1),
      forecast: [
        WeatherForecastDay(
          date: DateTime(2026, 8, 29),
          minimumC: 8,
          maximumC: 19,
          rainChancePercent: 20,
          summary: 'Nublado',
        ),
      ],
      alerts: [
        WeatherAlert(
          id: 'frost-1',
          title: 'Helada',
          severity: 'moderate',
          startsAt: DateTime.utc(2026, 8, 29),
          endsAt: DateTime.utc(2026, 8, 29, 8),
        ),
      ],
    );
  }
}

void main() {
  test('keeps last cache when provider is unavailable', () async {
    final database = createInMemoryDatabase();
    final gateway = _Gateway();
    final repository = WeatherRepository(database, gateway);
    addTearDown(database.close);
    await repository.refresh(ownerId: 'owner-1', locality: 'Curicó');
    gateway.fail = true;
    await expectLater(
      repository.refresh(ownerId: 'owner-1', locality: 'Curicó'),
      throwsStateError,
    );
    expect((await repository.cached('owner-1'))?.temperatureC, 19);
  });

  test('reports stale cache and deduplicates opted-in alerts', () async {
    final database = createInMemoryDatabase();
    final gateway = _Gateway();
    final repository = WeatherRepository(database, gateway);
    addTearDown(database.close);
    await repository.refresh(ownerId: 'owner-1', locality: 'Curicó');
    gateway.fail = true;
    final result = await repository.load(
      ownerId: 'owner-1',
      locality: 'Curicó',
      now: DateTime.utc(2026, 8, 30),
    );
    expect(result, isA<WeatherStale>());
    final service = WeatherAlertService(database);
    await service.setEnabled('owner-1', true);
    final snapshot = await repository.cached('owner-1');
    expect(await service.newAlerts('owner-1', snapshot!), hasLength(1));
    expect(await service.newAlerts('owner-1', snapshot), isEmpty);
  });

  test('normalized parser rejects malformed payload', () {
    expect(
      () => WeatherSnapshot.fromJson(<String, dynamic>{'locality': 'Curicó'}),
      throwsFormatException,
    );
  });
}
