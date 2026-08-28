import 'package:agrocampo/features/soil/data/soil_repository.dart';
import 'package:agrocampo/features/soil/domain/soil_measurement.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  test(
    'partial measurement preserves zero separately from missing values',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      await seedTerritoryFixture(database);
      await SoilRepository(database).save(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        input: const SoilMeasurementInput(moisturePercent: 0),
      );
      final row = await database.select(database.soilMeasurements).getSingle();
      expect(row.moisturePercent, 0);
      expect(row.ph, isNull);
    },
  );

  test('rejects invalid agronomic ranges', () {
    expect(
      () => const SoilMeasurementInput(ph: 15).validate(),
      throwsArgumentError,
    );
    expect(
      () => const SoilMeasurementInput(moisturePercent: -1).validate(),
      throwsArgumentError,
    );
  });
}
