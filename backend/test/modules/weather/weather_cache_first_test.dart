import 'package:agrocampo_backend/src/modules/weather/domain/entities/weather_snapshot.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_gateway.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

final class _CountingGateway implements WeatherGateway {
  int calls = 0;

  @override
  Future<WeatherSnapshot> fetch({
    required String locality,
    String? sectorId,
  }) async {
    calls++;
    final now = DateTime.now().toUtc();
    return WeatherSnapshot(
      locality: locality,
      temperatureC: 15,
      humidityPercent: 70,
      rainMillimeters: 0,
      summary: 'Nublado',
      fetchedAt: now,
      expiresAt: now.add(const Duration(hours: 1)),
    );
  }
}

void main() {
  test('weather under an hour old is reused; reload always asks', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final gateway = _CountingGateway();
    final repository = WeatherRepository(database, gateway);

    Future<WeatherLoadResult> load({bool force = false}) => repository.load(
      ownerId: 'owner-1',
      locality: 'Cuadrante 1',
      sectorId: 'sector-1',
      forceRefresh: force,
    );

    expect(await load(), isA<WeatherFresh>());
    expect(gateway.calls, 1, reason: 'nothing cached yet');

    final second = await load();
    expect(gateway.calls, 1, reason: 'the hour-old cache is still fresh');
    expect((second as WeatherFresh).fromCache, isTrue);

    await load(force: true);
    expect(gateway.calls, 2, reason: 'the reload button bypasses the cache');
  });
}
