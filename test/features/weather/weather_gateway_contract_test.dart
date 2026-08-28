import 'package:agrocampo/features/weather/data/weather_gateway.dart';
import 'package:agrocampo/features/weather/data/weather_repository.dart';
import 'package:agrocampo/features/weather/domain/weather_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

final class _Gateway implements WeatherGateway {
  bool fail = false;
  @override
  Future<WeatherSnapshot> fetch(String locality) async {
    if (fail) throw StateError('offline');
    return WeatherSnapshot(
      locality: locality,
      temperatureC: 19,
      humidityPercent: 60,
      rainMillimeters: 0,
      summary: 'Despejado',
      fetchedAt: DateTime.utc(2026, 8, 28),
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
}
