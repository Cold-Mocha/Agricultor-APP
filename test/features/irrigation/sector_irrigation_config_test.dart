import 'package:agrocampo/features/irrigation/data/sector_irrigation_config_repository.dart';
import 'package:agrocampo/features/irrigation/domain/sector_irrigation_config.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  test(
    'configuration versions close the old range without overwriting it',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      await seedTerritoryFixture(database);
      final repository = SectorIrrigationConfigRepository(database);
      final first = await repository.saveVersion(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        effectiveFrom: DateTime.utc(2026, 1),
        input: const SectorIrrigationConfigInput(
          plantCount: 100,
          emitterCount: 200,
          flowMlMin: 4000,
        ),
      );
      final second = await repository.saveVersion(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        effectiveFrom: DateTime.utc(2026, 2),
        input: const SectorIrrigationConfigInput(
          plantCount: 120,
          emitterCount: 240,
          flowMlMin: 4800,
        ),
      );
      final rows = await database
          .select(database.sectorIrrigationConfigs)
          .get();
      expect(rows, hasLength(2));
      expect(
        rows.singleWhere((row) => row.id == first).effectiveTo,
        DateTime.utc(2026, 2),
      );
      expect(rows.singleWhere((row) => row.id == second).configVersion, 2);
      expect(await database.select(database.syncOutbox).get(), hasLength(2));
    },
  );

  test('invalid hardware values are rejected before persistence', () {
    expect(
      () => const SectorIrrigationConfigInput(
        plantCount: 0,
        emitterCount: 1,
        flowMlMin: 1,
      ).validate(),
      throwsArgumentError,
    );
  });
}
