import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/sync_request_hash.dart';
import 'package:agrocampo/features/irrigation/data/irrigation_estimate_repository.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_calculator.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_record.dart';
import 'package:agrocampo/features/labors/data/labor_repository.dart';
import 'package:agrocampo/features/labors/domain/irrigation_labor_details.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:drift/drift.dart';

final class IrrigationRepository {
  IrrigationRepository(this._database);

  final AppDatabase _database;

  Future<String> savePerformed({
    required String ownerId,
    required String parcelId,
    required String sectorId,
    required BasicIrrigationInput input,
    required DateTime occurredAt,
    IrrigationPreview? preview,
    String? laborId,
  }) async {
    input.validate();
    final instant = occurredAt.toUtc();
    final context =
        preview?.context ??
        await LaborRepository(_database).resolveContext(
          ownerId: ownerId,
          parcelId: parcelId,
          sectorId: sectorId,
          occurredAt: instant,
        );
    final rootId = laborId ?? EntityId.generate().value;
    final existing =
        await (_database.select(_database.labors)..where(
              (row) => row.id.equals(rootId) & row.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    if (existing != null) return rootId;
    final recordId = EntityId.generate().value;
    final estimateId = preview?.result is IrrigationEstimateResult
        ? EntityId.generate().value
        : null;
    final valid = preview?.result is IrrigationEstimateResult
        ? preview!.result as IrrigationEstimateResult
        : null;
    final config = preview?.config;
    final durationSeconds = input.durationMinutes * 60;
    final appliedVolumeMl =
        valid?.appliedVolumeMl ??
        (input.flowLitersPerHour == null
            ? null
            : (input.flowLitersPerHour! * 1000 * input.durationMinutes / 60)
                  .round());
    final details = IrrigationLaborDetails(
      method: input.type.name,
      durationMinutes: input.durationMinutes,
      appliedVolumeLiters: appliedVolumeMl == null
          ? null
          : appliedVolumeMl / 1000,
    ).toEnvelope();
    final now = DateTime.now().toUtc();
    final irrigationPayload = <String, Object?>{
      'id': recordId,
      'labor_id': rootId,
      'sector_id': sectorId,
      'irrigation_type': input.type.name,
      'soil_type_code': input.soilType.name,
      'config_id': config?.id,
      'config_version': config?.configVersion,
      'duration_seconds': durationSeconds,
      'applied_volume_ml': appliedVolumeMl,
      'performed_details': {
        'duration_seconds': durationSeconds,
        'applied_volume_ml': appliedVolumeMl,
        'config_snapshot': config == null
            ? null
            : {
                'id': config.id,
                'version': config.configVersion,
                'plant_count': config.plantCount,
                'emitter_count': config.emitterCount,
                'flow_ml_min': config.flowMlMin,
                'pressure_kpa': config.pressureKpa,
              },
      },
      'irrigated_at': instant.toIso8601String(),
      'updated_at': now.toIso8601String(),
      if (valid != null)
        'estimate': {
          'id': estimateId,
          'crop_assignment_id': context.assignmentId,
          'config_id': config!.id,
          'config_version': config.configVersion,
          'algorithm_version': valid.algorithmVersion,
          'rule_id': valid.ruleId,
          'rule_version': valid.ruleVersion,
          'soil_type_code': input.soilType.name,
          'inputs': preview!.input!.toJson(),
          'recommended_volume_ml': valid.recommendedVolumeMl,
          'recommended_duration_seconds': valid.recommendedDurationSeconds,
          'warnings': valid.warnings,
          'explanation': valid.explanationFacts,
        },
    };
    final payload = <String, Object?>{
      'id': rootId,
      'owner_id': ownerId,
      'parcel_id': parcelId,
      'sector_id': sectorId,
      'agricultural_season_id': context.seasonId,
      'crop_assignment_id': context.assignmentId,
      'type': 'irrigation',
      'details': details.toJson(),
      'details_schema_version': details.schemaVersion,
      'status': 'recorded',
      'occurred_at': instant.toIso8601String(),
      'version': 1,
      'updated_at': now.toIso8601String(),
      'deleted_at': null,
      'irrigation': irrigationPayload,
    };
    final dependency = await _pendingAssignment(ownerId, context.assignmentId);
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () async {
        await _database
            .into(_database.labors)
            .insert(
              LaborsCompanion.insert(
                id: rootId,
                ownerId: ownerId,
                parcelId: parcelId,
                sectorId: sectorId,
                seasonId: Value(context.seasonId),
                cropAssignmentId: Value(context.assignmentId),
                type: 'irrigation',
                detailsJson: Value(details.encode()),
                detailsSchemaVersion: Value(details.schemaVersion),
                occurredAt: instant,
                updatedAt: now,
              ),
            );
        await _database
            .into(_database.irrigationRecords)
            .insert(
              IrrigationRecordsCompanion.insert(
                id: recordId,
                ownerId: ownerId,
                sectorId: sectorId,
                laborId: Value(rootId),
                irrigationType: input.type.name,
                soilTypeCode: input.soilType.name,
                flowLitersPerHour: Value(input.flowLitersPerHour),
                durationMinutes: Value(input.durationMinutes),
                estimatedLiters: Value(
                  appliedVolumeMl == null ? null : appliedVolumeMl / 1000,
                ),
                configId: Value(config?.id),
                configVersion: Value(config?.configVersion),
                durationSeconds: Value(durationSeconds),
                appliedVolumeMl: Value(appliedVolumeMl),
                performedDetailsJson: Value(
                  jsonEncode(irrigationPayload['performed_details']),
                ),
                irrigatedAt: instant,
                updatedAt: now,
              ),
            );
        if (valid != null) {
          await _database
              .into(_database.irrigationEstimates)
              .insert(
                IrrigationEstimatesCompanion.insert(
                  id: estimateId!,
                  ownerId: ownerId,
                  sectorId: sectorId,
                  irrigationLaborId: Value(rootId),
                  cropAssignmentId: Value(context.assignmentId),
                  configId: Value(config!.id),
                  configVersion: Value(config.configVersion),
                  algorithmVersion: Value(valid.algorithmVersion),
                  ruleId: valid.ruleId,
                  ruleVersion: valid.ruleVersion,
                  soilTypeCode: input.soilType.name,
                  inputsJson: jsonEncode(preview!.input!.toJson()),
                  estimatedLitersMilli: valid.recommendedVolumeMl,
                  recommendedMinutes: valid.recommendedMinutes,
                  warningsJson: Value(jsonEncode(valid.warnings)),
                  explanationJson: Value(jsonEncode(valid.explanationFacts)),
                  calculatedAt: Value(now),
                  createdAt: now,
                ),
              );
        }
      },
      operation: SyncOutboxCompanion.insert(
        operationId: EntityId.generate().value,
        ownerId: ownerId,
        aggregateType: 'labor',
        aggregateId: rootId,
        mutationKind: 'create',
        payloadJson: jsonEncode(payload),
        requestHash: Value(
          syncRequestHash(
            aggregateType: 'labor',
            aggregateId: rootId,
            mutationKind: 'create',
            baseVersion: null,
            payload: payload,
          ),
        ),
        dependencyOperationId: Value(dependency),
        createdAt: now,
      ),
    );
    return rootId;
  }

  Future<String> saveBasic({
    required String ownerId,
    required String sectorId,
    required BasicIrrigationInput input,
  }) async {
    input.validate();
    final id = EntityId.generate().value;
    final now = DateTime.now().toUtc();
    final liters = input.flowLitersPerHour == null
        ? null
        : input.flowLitersPerHour! * input.durationMinutes / 60;
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () => _database
          .into(_database.irrigationRecords)
          .insert(
            IrrigationRecordsCompanion.insert(
              id: id,
              ownerId: ownerId,
              sectorId: sectorId,
              irrigationType: input.type.name,
              soilTypeCode: input.soilType.name,
              flowLitersPerHour: Value(input.flowLitersPerHour),
              durationMinutes: Value(input.durationMinutes),
              estimatedLiters: Value(liters),
              irrigatedAt: now,
              updatedAt: now,
            ),
          ),
      operation: SyncOutboxCompanion.insert(
        operationId: EntityId.generate().value,
        ownerId: ownerId,
        aggregateType: 'irrigation_record',
        aggregateId: id,
        mutationKind: 'create',
        payloadJson: jsonEncode({
          'id': id,
          'sector_id': sectorId,
          'irrigation_type': input.type.name,
          'soil_type_code': input.soilType.name,
          'duration_minutes': input.durationMinutes,
          'flow_liters_per_hour': input.flowLitersPerHour,
          'estimated_liters': liters,
        }),
        createdAt: now,
      ),
    );
    return id;
  }

  Future<String?> _pendingAssignment(
    String ownerId,
    String assignmentId,
  ) async {
    final rows =
        await (_database.select(_database.syncOutbox)
              ..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.aggregateType.equals('sectorCropAssignment') &
                    row.aggregateId.equals(assignmentId) &
                    row.state.isNotIn(const ['done']),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
            .get();
    return rows.isEmpty ? null : rows.first.operationId;
  }
}
