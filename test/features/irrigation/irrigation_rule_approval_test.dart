import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/irrigation/data/irrigation_estimate_repository.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_calculator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test(
    'repository only releases a fully reviewed rule with 20 vectors',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      await database
          .into(database.officialCrops)
          .insert(
            OfficialCropsCompanion.insert(
              id: 'crop-1',
              commonName: 'Cultivo validado',
              category: 'test',
              colorToken: 'test',
              iconAsset: 'test',
            ),
          );
      await database
          .into(database.cropIrrigationRules)
          .insert(
            CropIrrigationRulesCompanion.insert(
              id: 'rule-1',
              cropId: 'crop-1',
              soilTypeCode: 'loamy',
              version: 1,
              soilMultiplierPermille: 1100,
              efficiencyPermille: 900,
              minimumDurationMinutes: 1,
              maximumDurationMinutes: 180,
              sourceTitle: 'Validación agronómica',
              sourceReference: 'fixture-reviewed-v1',
              reviewer: const Value('Revisor de prueba'),
              approvedAt: Value(DateTime.utc(2026)),
              approvedVectorCount: const Value(20),
              baseMlPerPlant: const Value(1000),
              minimumAdjustmentBp: const Value(5000),
              maximumAdjustmentBp: const Value(15000),
              isActive: const Value(true),
            ),
          );

      final repository = IrrigationEstimateRepository(database);
      const expected = <(int, int, int)>[
        (10000, 11000, 660),
        (10117, 12375, 736),
        (10234, 13200, 777),
        (10352, 14625, 852),
        (10469, 15400, 889),
        (10588, 16875, 965),
        (10706, 17600, 997),
        (10825, 19125, 1073),
        (10944, 19800, 1100),
        (11064, 21375, 1177),
        (11183, 22000, 1200),
        (11304, 23625, 1278),
        (11424, 24200, 1297),
        (11545, 25875, 1374),
        (11666, 26400, 1390),
        (11788, 28125, 1468),
        (11909, 28600, 1480),
        (12032, 30375, 1558),
        (12154, 30800, 1567),
        (12277, 32625, 1645),
      ];
      for (var index = 0; index < 20; index++) {
        final result = await repository.calculate(
          cropId: 'crop-1',
          soilTypeCode: 'loamy',
          input: IrrigationCalculationInput(
            plantCount: 10 + index,
            emitterCount: 20 + index,
            flowMlMin: 1000 + index * 10,
            performedDurationSeconds: 600 + index,
            weatherAdjustmentBp: index.isEven ? 0 : 250,
          ),
        );
        expect(result, isA<IrrigationEstimateResult>());
        final estimate = result as IrrigationEstimateResult;
        expect(estimate.ruleId, 'rule-1');
        expect((
          estimate.appliedVolumeMl,
          estimate.recommendedVolumeMl,
          estimate.recommendedDurationSeconds,
        ), expected[index]);
      }
    },
  );

  test('missing reviewer keeps a database rule unavailable', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await database
        .into(database.officialCrops)
        .insert(
          OfficialCropsCompanion.insert(
            id: 'crop-2',
            commonName: 'Sin revisión',
            category: 'test',
            colorToken: 'test',
            iconAsset: 'test',
          ),
        );
    await database
        .into(database.cropIrrigationRules)
        .insert(
          CropIrrigationRulesCompanion.insert(
            id: 'rule-2',
            cropId: 'crop-2',
            soilTypeCode: 'loamy',
            version: 1,
            soilMultiplierPermille: 1000,
            efficiencyPermille: 900,
            minimumDurationMinutes: 1,
            maximumDurationMinutes: 180,
            sourceTitle: 'Fuente',
            sourceReference: 'Referencia',
            approvedAt: Value(DateTime.utc(2026)),
            approvedVectorCount: const Value(20),
            isActive: const Value(true),
          ),
        );

    final result = await IrrigationEstimateRepository(database).calculate(
      cropId: 'crop-2',
      soilTypeCode: 'loamy',
      input: const IrrigationCalculationInput(
        plantCount: 10,
        emitterCount: 20,
        flowMlMin: 1000,
        performedDurationSeconds: 600,
      ),
    );
    expect(result, isA<IrrigationUnavailable>());
  });
}
