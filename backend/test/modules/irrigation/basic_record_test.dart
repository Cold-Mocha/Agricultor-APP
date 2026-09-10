import 'package:agrocampo_backend/src/modules/irrigation/domain/entities/irrigation_calculator.dart';
import 'package:agrocampo_backend/src/modules/irrigation/domain/entities/irrigation_record.dart';
import 'package:agrocampo_backend/src/modules/irrigation/domain/entities/sector_irrigation_config.dart';
import 'package:agrocampo_backend/src/modules/irrigation/infrastructure/persistence/irrigation_estimate_repository.dart';
import 'package:agrocampo_backend/src/modules/irrigation/infrastructure/persistence/irrigation_repository.dart';
import 'package:agrocampo_backend/src/modules/irrigation/infrastructure/persistence/sector_irrigation_config_repository.dart';
import 'package:agrocampo_backend/src/modules/labors/infrastructure/persistence/labor_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  test(
    'basic irrigation keeps type, soil classification and computed volume',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      await seedTerritoryFixture(database);
      await IrrigationRepository(database).saveBasic(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        input: const BasicIrrigationInput(
          type: IrrigationType.drip,
          soilType: SoilType.loamy,
          durationMinutes: 30,
          flowLitersPerHour: 120,
          pressureKpa: 80,
        ),
      );
      final row = await database.select(database.irrigationRecords).getSingle();
      expect(row.soilTypeCode, 'loamy');
      expect(row.estimatedLiters, 60);
    },
  );

  test('basic drip math and pressure survive in the confirmed input snapshot', () {
    const input = BasicIrrigationInput(
      type: IrrigationType.drip,
      soilType: SoilType.loamy,
      durationMinutes: 45,
      flowLitersPerHour: 120,
      pressureKpa: 80,
    );
    expect(input.estimatedVolumeLiters, 90);
    expect(input.toJson()['pressure_kpa'], 80);
    expect(input.toJson()['estimated_liters'], 90);
  });

  test('drip confirmation writes one labor aggregate and immutable config snapshot', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedAgriculturalContextFixture(database);
    await SectorIrrigationConfigRepository(database).saveVersion(
      ownerId: 'owner-1',
      sectorId: 'sector-1',
      effectiveFrom: DateTime.utc(2026, 1),
      input: const SectorIrrigationConfigInput(
        plantCount: 100,
        emitterCount: 200,
        flowMlMin: 4000,
      ),
    );
    final preview =
        await IrrigationEstimateRepository(
          database,
          LaborRepository(database),
        ).calculateForSector(
          ownerId: 'owner-1',
          parcelId: 'parcel-1',
          sectorId: 'sector-1',
          soilTypeCode: 'loamy',
          occurredAt: DateTime.utc(2026, 2),
          performedDurationSeconds: 1800,
        );
    expect(preview.result, isA<IrrigationUnavailable>());
    await IrrigationRepository(
      database,
      LaborRepository(database),
    ).savePerformed(
      ownerId: 'owner-1',
      parcelId: 'parcel-1',
      sectorId: 'sector-1',
      occurredAt: DateTime.utc(2026, 2),
      preview: preview,
      input: const BasicIrrigationInput(
        type: IrrigationType.drip,
        soilType: SoilType.loamy,
        durationMinutes: 30,
        flowLitersPerHour: 120,
        pressureKpa: 80,
      ),
    );
    expect(await database.select(database.labors).get(), hasLength(1));
    final record = await database
        .select(database.irrigationRecords)
        .getSingle();
    expect(record.configVersion, 1);
    expect(record.performedDetailsJson, contains('config_snapshot'));
    expect(record.performedDetailsJson, contains('pressure_kpa'));
    expect(record.performedDetailsJson, contains('total_flow_l_per_h*duration_min/60'));
    expect(record.performedDetailsJson, contains('roundHalfUp'));
    expect(await database.select(database.irrigationEstimates).get(), isEmpty);
    expect(
      (await database.select(database.syncOutbox).get()).where(
        (row) => row.aggregateType == 'labor',
      ),
      hasLength(1),
    );
  });

  test('repeating a confirmed labor id is idempotent and apiary is rejected directly', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedAgriculturalContextFixture(database);
    final repository = IrrigationRepository(database, LaborRepository(database));
    const input = BasicIrrigationInput(
      type: IrrigationType.drip,
      soilType: SoilType.loamy,
      durationMinutes: 30,
      flowLitersPerHour: 120,
    );
    final laborId = await repository.savePerformed(
      ownerId: 'owner-1',
      parcelId: 'parcel-1',
      sectorId: 'sector-1',
      occurredAt: DateTime.utc(2026, 2),
      input: input,
    );
    await repository.savePerformed(
      ownerId: 'owner-1',
      parcelId: 'parcel-1',
      sectorId: 'sector-1',
      occurredAt: DateTime.utc(2026, 2),
      laborId: laborId,
      input: input,
    );
    expect(await database.select(database.labors).get(), hasLength(1));
    expect(await database.select(database.irrigationRecords).get(), hasLength(1));
    await database.customUpdate(
      'UPDATE sectors SET kind = ? WHERE id = ?',
      variables: [Variable<String>('apiary'), Variable<String>('sector-1')],
    );
    await expectLater(
      repository.savePerformed(
        ownerId: 'owner-1',
        parcelId: 'parcel-1',
        sectorId: 'sector-1',
        occurredAt: DateTime.utc(2026, 2),
        input: input,
      ),
      throwsStateError,
    );
  });
}
