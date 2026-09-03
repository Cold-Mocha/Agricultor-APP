import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/irrigation/data/irrigation_estimate_repository.dart';
import 'package:agrocampo/features/irrigation/data/irrigation_repository.dart';
import 'package:agrocampo/features/irrigation/data/sector_irrigation_config_repository.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_calculator.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_record.dart';
import 'package:agrocampo/features/irrigation/domain/sector_irrigation_config.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/file_backed_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  test(
    'drip result and config snapshot survive reopen and later versions',
    () async {
      final fixture = await FileBackedDatabaseFixture.create();
      addTearDown(fixture.dispose);
      var database = fixture.open();
      await seedAgriculturalContextFixture(database);
      await database
          .into(database.cropIrrigationRules)
          .insert(
            CropIrrigationRulesCompanion.insert(
              id: 'rule-trigo-loamy',
              cropId: 'trigo',
              soilTypeCode: 'loamy',
              version: 1,
              soilMultiplierPermille: 1100,
              efficiencyPermille: 900,
              minimumDurationMinutes: 1,
              maximumDurationMinutes: 180,
              sourceTitle: 'Regla revisada de prueba',
              sourceReference: 'vector-set-v1',
              reviewer: const Value('Revisor agronómico'),
              approvedAt: Value(DateTime.utc(2026)),
              approvedVectorCount: const Value(20),
              isActive: const Value(true),
            ),
          );
      final configs = SectorIrrigationConfigRepository(database);
      final configV1 = await configs.saveVersion(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        effectiveFrom: DateTime.utc(2026),
        input: const SectorIrrigationConfigInput(
          plantCount: 100,
          emitterCount: 200,
          flowMlMin: 4000,
        ),
      );
      final preview = await IrrigationEstimateRepository(database)
          .calculateForSector(
            ownerId: 'owner-1',
            parcelId: 'parcel-1',
            sectorId: 'sector-1',
            soilTypeCode: 'loamy',
            occurredAt: DateTime.utc(2026, 3),
            performedDurationSeconds: 1800,
          );
      expect(preview.result, isA<IrrigationEstimateResult>());
      final laborId = await IrrigationRepository(database).savePerformed(
        ownerId: 'owner-1',
        parcelId: 'parcel-1',
        sectorId: 'sector-1',
        occurredAt: DateTime.utc(2026, 3),
        preview: preview,
        input: const BasicIrrigationInput(
          type: IrrigationType.drip,
          soilType: SoilType.loamy,
          durationMinutes: 30,
        ),
      );
      final originalEstimate = await database
          .select(database.irrigationEstimates)
          .getSingle();
      final originalPerformed =
          (await database.select(database.irrigationRecords).getSingle())
              .performedDetailsJson;
      await database.close();

      database = fixture.open();
      addTearDown(database.close);
      await SectorIrrigationConfigRepository(database).saveVersion(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        effectiveFrom: DateTime.utc(2026, 4),
        input: const SectorIrrigationConfigInput(
          plantCount: 120,
          emitterCount: 240,
          flowMlMin: 5000,
        ),
      );

      final reopenedRecord = await database
          .select(database.irrigationRecords)
          .getSingle();
      final reopenedEstimate = await database
          .select(database.irrigationEstimates)
          .getSingle();
      expect(reopenedRecord.laborId, laborId);
      expect(reopenedRecord.configId, configV1);
      expect(reopenedRecord.configVersion, 1);
      expect(reopenedRecord.performedDetailsJson, originalPerformed);
      expect(reopenedEstimate.inputsJson, originalEstimate.inputsJson);
      expect(
        reopenedEstimate.explanationJson,
        originalEstimate.explanationJson,
      );
      expect(reopenedEstimate.configVersion, 1);
      expect(
        await database.select(database.sectorIrrigationConfigs).get(),
        hasLength(2),
      );
    },
  );
}
