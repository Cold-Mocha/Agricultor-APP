import 'package:agrocampo_backend/src/modules/soil/domain/entities/soil_measurement.dart';
import 'package:agrocampo_backend/src/modules/soil/infrastructure/persistence/soil_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/drift.dart' show Value, Variable;
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
      final laborId = await database
          .customSelect(
            'SELECT labor_id FROM soil_measurements WHERE id = ?',
            variables: [Variable(row.id)],
          )
          .map((result) => result.read<String>('labor_id'))
          .getSingle();
      expect(laborId, isNotEmpty);
      expect(await database.select(database.labors).get(), hasLength(1));
    },
  );

  test('soil details retain explicit indicator units without turning omissions into zero', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedTerritoryFixture(database);
    await SoilRepository(database).save(
      ownerId: 'owner-1',
      sectorId: 'sector-1',
      input: const SoilMeasurementInput(
        moisturePercent: 40,
        units: {'moisturePercent': '%'},
      ),
    );
    final labor = await database.select(database.labors).getSingle();
    expect(labor.detailsJson, contains('moisturePercent'));
    expect(labor.detailsJson, contains('%'));
    expect(labor.detailsJson, isNot(contains('ph')));
  });

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

  test('soil measurement rejects an apiary sector without writes', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedTerritoryFixture(database);
    await (database.update(database.sectors)
          ..where((row) => row.id.equals('sector-1')))
        .write(const SectorsCompanion(kind: Value('apiary')));
    final outboxBefore = await database.select(database.syncOutbox).get();
    await expectLater(
      SoilRepository(database).save(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        input: const SoilMeasurementInput(moisturePercent: 10),
      ),
      throwsA(isA<StateError>()),
    );
    expect(await database.select(database.soilMeasurements).get(), isEmpty);
    expect(await database.select(database.labors).get(), isEmpty);
    expect(await database.select(database.syncOutbox).get(), outboxBefore);
  });
}
