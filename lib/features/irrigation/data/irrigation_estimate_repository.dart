import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_calculator.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_rule_set.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:drift/drift.dart';

final class IrrigationEstimateRepository {
  IrrigationEstimateRepository(this._database);

  final AppDatabase _database;

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
            inputsJson: jsonEncode({
              'plant_count': input.plantCount,
              'flow_milliliters_per_hour_per_plant':
                  input.flowMilliLitersPerHourPerPlant,
              'requested_minutes': input.requestedMinutes,
            }),
            estimatedLitersMilli: result.estimatedLitersMilli,
            recommendedMinutes: result.recommendedMinutes,
            warningsJson: Value(jsonEncode(result.warnings)),
            createdAt: DateTime.now().toUtc(),
          ),
        );
    return id;
  }
}
