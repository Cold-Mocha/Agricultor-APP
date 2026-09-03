import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/irrigation/data/sector_irrigation_config_repository.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_calculator.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_rule_set.dart';
import 'package:agrocampo/features/labors/data/labor_repository.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:drift/drift.dart';

final class IrrigationEstimateRepository {
  IrrigationEstimateRepository(this._database);

  final AppDatabase _database;

  Future<IrrigationPreview> calculateForSector({
    required String ownerId,
    required String parcelId,
    required String sectorId,
    required String soilTypeCode,
    required DateTime occurredAt,
    int? performedDurationSeconds,
    int weatherAdjustmentBp = 0,
  }) async {
    final context = await LaborRepository(_database).resolveContext(
      ownerId: ownerId,
      parcelId: parcelId,
      sectorId: sectorId,
      occurredAt: occurredAt.toUtc(),
    );
    final config = await SectorIrrigationConfigRepository(_database)
        .current(ownerId: ownerId, sectorId: sectorId, at: occurredAt);
    if (config == null) {
      return IrrigationPreview(
        context: context,
        result: const IrrigationUnavailable('drip_config_unavailable'),
      );
    }
    final input = IrrigationCalculationInput(
      plantCount: config.plantCount,
      emitterCount: config.emitterCount,
      flowMlMin: config.flowMlMin,
      performedDurationSeconds: performedDurationSeconds,
      weatherAdjustmentBp: weatherAdjustmentBp,
    );
    final result = await calculate(
      cropId: context.cropId,
      soilTypeCode: soilTypeCode,
      input: input,
    );
    return IrrigationPreview(
      context: context,
      config: config,
      input: input,
      result: result,
    );
  }

  Future<IrrigationCalculationResult> calculate({
    required String cropId,
    required String soilTypeCode,
    required IrrigationCalculationInput input,
  }) async {
    final row =
        await (_database.select(_database.cropIrrigationRules)..where(
              (rule) =>
                  rule.cropId.equals(cropId) &
                  rule.soilTypeCode.equals(soilTypeCode) &
                  rule.isActive.equals(true) &
                  rule.approvedAt.isNotNull(),
            ))
            .getSingleOrNull();
    final rule = row == null
        ? null
        : IrrigationRuleSet(
            id: row.id,
            cropId: row.cropId,
            soilTypeCode: row.soilTypeCode,
            version: row.version,
            soilMultiplierPermille: row.soilMultiplierPermille,
            efficiencyPermille: row.efficiencyPermille,
            minimumDurationMinutes: row.minimumDurationMinutes,
            maximumDurationMinutes: row.maximumDurationMinutes,
            sourceTitle: row.sourceTitle,
            sourceReference: row.sourceReference,
            reviewer: row.reviewer,
            approvedAt: row.approvedAt,
            approvedVectorCount: row.approvedVectorCount,
            baseMlPerPlant: row.baseMlPerPlant,
            minimumAdjustmentBp: row.minimumAdjustmentBp,
            maximumAdjustmentBp: row.maximumAdjustmentBp,
          );
    return IrrigationCalculator.calculate(input, rule: rule);
  }

  Future<String> persist({
    required String ownerId,
    required String sectorId,
    required String soilTypeCode,
    required IrrigationCalculationInput input,
    required IrrigationEstimateResult result,
  }) async {
    final id = EntityId.generate().value;
    await _database
        .into(_database.irrigationEstimates)
        .insert(
          IrrigationEstimatesCompanion.insert(
            id: id,
            ownerId: ownerId,
            sectorId: sectorId,
            ruleId: result.ruleId,
            ruleVersion: result.ruleVersion,
            soilTypeCode: soilTypeCode,
            inputsJson: jsonEncode({...input.toJson()}),
            estimatedLitersMilli: result.estimatedLitersMilli,
            recommendedMinutes: result.recommendedMinutes,
            warningsJson: Value(jsonEncode(result.warnings)),
            explanationJson: Value(jsonEncode(result.explanationFacts)),
            algorithmVersion: Value(result.algorithmVersion),
            calculatedAt: Value(DateTime.now().toUtc()),
            createdAt: DateTime.now().toUtc(),
          ),
        );
    return id;
  }
}

final class IrrigationPreview {
  const IrrigationPreview({
    required this.context,
    required this.result,
    this.config,
    this.input,
  });

  final LaborContext context;
  final SectorIrrigationConfig? config;
  final IrrigationCalculationInput? input;
  final IrrigationCalculationResult result;
}
