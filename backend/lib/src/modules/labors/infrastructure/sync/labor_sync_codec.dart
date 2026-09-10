import 'dart:convert';

import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/aggregate_sync_codec.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/sync_contract.dart';
import 'package:drift/drift.dart';

final class LaborSyncCodec implements AggregateSyncCodec {
  const LaborSyncCodec();

  @override
  String get aggregateType => 'labor';

  @override
  Future<void> applyRemote(
    AppDatabase database,
    String ownerId,
    RemoteChange change,
  ) async {
    final decoded = jsonDecode(change.payloadJson);
    if (decoded is! Map<String, Object?> ||
        decoded['id'] != change.aggregateId ||
        decoded['sector_id'] is! String ||
        decoded['type'] is! String ||
        decoded['details'] is! Map<String, Object?> ||
        decoded['occurred_at'] is! String ||
        decoded['updated_at'] is! String) {
      throw const FormatException('labor_payload_invalid');
    }
    final type = decoded['type']! as String;
    final isApiary = type == 'apiary';
    final parcelId = decoded['parcel_id'] as String?;
    final sectorId = decoded['sector_id']! as String;
    final seasonId = decoded['agricultural_season_id'] as String?;
    final assignmentId = decoded['crop_assignment_id'] as String?;
    if (!isApiary &&
        (parcelId == null || seasonId == null || assignmentId == null)) {
      throw const FormatException('labor_parent_missing');
    }
    final sectorRow = await database.customSelect(
      'SELECT parcel_id, kind FROM sectors WHERE id = ? AND owner_id = ?',
      variables: [Variable<String>(sectorId), Variable<String>(ownerId)],
    ).getSingleOrNull();
    if (sectorRow == null) {
      throw const FormatException('labor_parent_missing');
    }
    final sectorParcelId = sectorRow.read<String>('parcel_id');
    final sectorKind = sectorRow.read<String>('kind');
    if (isApiary && sectorKind != 'apiary') {
      throw const FormatException('operation_not_valid_for_crop');
    }
    final category = decoded['domain_category'] as String? ?? sectorKind;
    if (category != sectorKind) {
      throw const FormatException('labor_category_mismatch');
    }
    if (!isApiary) {
      final season = await (database.select(database.agriculturalSeasons)..where(
            (row) =>
                row.id.equals(seasonId!) &
                row.ownerId.equals(ownerId) &
                row.parcelId.equals(parcelId!),
          ))
          .getSingleOrNull();
      final assignment = await (database.select(database.cropSeasons)..where(
            (row) =>
                row.id.equals(assignmentId!) &
                row.ownerId.equals(ownerId) &
                row.sectorId.equals(sectorId) &
                row.agriculturalSeasonId.equals(seasonId!),
          ))
          .getSingleOrNull();
      if (season == null || assignment == null) {
        throw const FormatException('labor_parent_missing');
      }
    }
    final details = decoded['details']! as Map<String, Object?>;
    final detailsVersion =
        decoded['details_schema_version'] as int? ??
        details['schemaVersion'] as int? ??
        1;
    final updatedAt = DateTime.parse(decoded['updated_at']! as String).toUtc();
    await database.transaction(() async {
      await database
          .into(database.labors)
          .insertOnConflictUpdate(
            LaborsCompanion.insert(
              id: change.aggregateId,
              ownerId: ownerId,
              parcelId: parcelId ?? sectorParcelId,
              sectorId: sectorId,
              seasonId: Value(seasonId),
              cropAssignmentId: Value(assignmentId),
              type: type,
              customName: Value(decoded['custom_name'] as String?),
              detailsJson: Value(jsonEncode(details)),
              detailsSchemaVersion: Value(detailsVersion),
              status: Value(decoded['status'] as String? ?? 'recorded'),
              supersedesLaborId: Value(
                decoded['supersedes_labor_id'] as String?,
              ),
              notes: Value(decoded['notes'] as String?),
              occurredAt: DateTime.parse(decoded['occurred_at']! as String)
                  .toUtc(),
              version: Value(change.remoteVersion),
              syncState: const Value('synced'),
              serverUpdatedAt: Value(updatedAt),
              deletedAt: Value(_date(decoded['deleted_at'])),
              updatedAt: updatedAt,
            ),
          );
      await database.customUpdate(
        'UPDATE labors SET domain_category = ? WHERE id = ?',
        variables: [Variable<String>(category), Variable<String>(change.aggregateId)],
      );
      final production = decoded['production'];
      if (production != null) {
        if (production is! Map<String, Object?> ||
            production['id'] is! String ||
            production['crop_id'] is! String ||
            production['quantity'] is! num ||
            production['unit'] is! String ||
            production['harvested_at'] is! String) {
          throw const FormatException('labor_production_payload_invalid');
        }
        await database
            .into(database.productionRecords)
            .insertOnConflictUpdate(
              ProductionRecordsCompanion.insert(
                id: production['id']! as String,
                ownerId: ownerId,
              parcelId: parcelId ?? sectorParcelId,
                sectorId: sectorId,
                laborId: Value(change.aggregateId),
                seasonId: Value(seasonId),
                cropId: production['crop_id']! as String,
                quantity: (production['quantity']! as num).toDouble(),
                unit: production['unit']! as String,
                qualityNotes: Value(production['quality_notes'] as String?),
                harvestedAt: DateTime.parse(
                  production['harvested_at']! as String,
                ).toUtc(),
                updatedAt: updatedAt,
              ),
            );
      }
      final irrigation = decoded['irrigation'];
      if (irrigation != null) {
        if (irrigation is! Map<String, Object?> ||
            irrigation['id'] is! String ||
            irrigation['irrigation_type'] is! String ||
            irrigation['soil_type_code'] is! String ||
            irrigation['duration_seconds'] is! int ||
            irrigation['irrigated_at'] is! String) {
          throw const FormatException('labor_irrigation_payload_invalid');
        }
        await database
            .into(database.irrigationRecords)
            .insertOnConflictUpdate(
              IrrigationRecordsCompanion.insert(
                id: irrigation['id']! as String,
                ownerId: ownerId,
                sectorId: sectorId,
                laborId: Value(change.aggregateId),
                irrigationType: irrigation['irrigation_type']! as String,
                soilTypeCode: irrigation['soil_type_code']! as String,
                configId: Value(irrigation['config_id'] as String?),
                configVersion: Value(irrigation['config_version'] as int?),
                durationMinutes: Value(
                  ((irrigation['duration_seconds']! as int) + 59) ~/ 60,
                ),
                durationSeconds: Value(irrigation['duration_seconds']! as int),
                appliedVolumeMl: Value(irrigation['applied_volume_ml'] as int?),
                estimatedLiters: Value(
                  irrigation['applied_volume_ml'] is int
                      ? (irrigation['applied_volume_ml']! as int) / 1000
                      : null,
                ),
                performedDetailsJson: Value(
                  jsonEncode(
                    irrigation['performed_details'] as Map<String, Object?>? ??
                        const {},
                  ),
                ),
                irrigatedAt: DateTime.parse(
                  irrigation['irrigated_at']! as String,
                ).toUtc(),
                updatedAt: updatedAt,
              ),
            );
        final estimate = irrigation['estimate'];
        if (estimate != null) {
          if (estimate is! Map<String, Object?> ||
              estimate['id'] is! String ||
              estimate['rule_id'] is! String ||
              estimate['rule_version'] is! int ||
              estimate['recommended_volume_ml'] is! int ||
              estimate['recommended_duration_seconds'] is! int) {
            throw const FormatException('labor_irrigation_estimate_invalid');
          }
          await database
              .into(database.irrigationEstimates)
              .insertOnConflictUpdate(
                IrrigationEstimatesCompanion.insert(
                  id: estimate['id']! as String,
                  ownerId: ownerId,
                  sectorId: sectorId,
                  irrigationLaborId: Value(change.aggregateId),
                  cropAssignmentId: Value(assignmentId),
                  configId: Value(estimate['config_id'] as String?),
                  configVersion: Value(estimate['config_version'] as int?),
                  algorithmVersion: Value(
                    estimate['algorithm_version'] as int? ?? 2,
                  ),
                  ruleId: estimate['rule_id']! as String,
                  ruleVersion: estimate['rule_version']! as int,
                  soilTypeCode:
                      estimate['soil_type_code'] as String? ?? 'unknown',
                  inputsJson: jsonEncode(estimate['inputs'] ?? const {}),
                  estimatedLitersMilli:
                      estimate['recommended_volume_ml']! as int,
                  recommendedMinutes:
                      ((estimate['recommended_duration_seconds']! as int) +
                          59) ~/
                      60,
                  warningsJson: Value(
                    jsonEncode(estimate['warnings'] ?? const []),
                  ),
                  explanationJson: Value(
                    jsonEncode(estimate['explanation'] ?? const {}),
                  ),
                  calculatedAt: Value(updatedAt),
                  createdAt: updatedAt,
                ),
              );
        }
      }
      final apiary = decoded['apiary'];
      if (apiary != null) {
        if (!isApiary || apiary is! Map<String, Object?> ||
            apiary['id'] is! String || apiary['task_type'] is! String ||
            apiary['beekeeper_name'] is! String || apiary['hive_count'] is! int ||
            apiary['inspected_at'] is! String) {
          throw const FormatException('labor_apiary_payload_invalid');
        }
        await database.into(database.apiaryInspections).insertOnConflictUpdate(
          ApiaryInspectionsCompanion.insert(
            id: apiary['id']! as String,
            ownerId: ownerId,
            sectorId: sectorId,
            taskType: apiary['task_type']! as String,
            beekeeperName: apiary['beekeeper_name']! as String,
            hiveCount: apiary['hive_count']! as int,
            queenStatus: apiary['queen_status'] as String? ?? '',
            broodStatus: apiary['brood_status'] as String? ?? '',
            feedingStatus: apiary['feeding_status'] as String? ?? '',
            healthNotes: apiary['health_notes'] as String? ?? '',
            pestNotes: apiary['pest_notes'] as String? ?? '',
            superInstalled: apiary['super_installed'] as bool? ?? false,
            observations: Value(apiary['observations'] as String?),
            inspectedAt: DateTime.parse(apiary['inspected_at']! as String).toUtc(),
            updatedAt: updatedAt,
          ),
        );
        await database.customUpdate(
          'UPDATE apiary_inspections SET labor_id = ? WHERE id = ?',
          variables: [
            Variable<String>(change.aggregateId),
            Variable<String>(apiary['id']! as String),
          ],
        );
      }
    });
  }

  DateTime? _date(Object? value) =>
      value is String ? DateTime.parse(value).toUtc() : null;

  @override
  Future<void> markAcknowledged(
    AppDatabase database,
    String ownerId,
    String aggregateId,
    int? remoteVersion,
    DateTime acknowledgedAt,
  ) =>
      (database.update(database.labors)..where(
            (row) => row.ownerId.equals(ownerId) & row.id.equals(aggregateId),
          ))
          .write(
            LaborsCompanion(
              version: remoteVersion == null
                  ? const Value.absent()
                  : Value(remoteVersion),
              syncState: const Value('synced'),
              serverUpdatedAt: Value(acknowledgedAt),
              lastSyncErrorCode: const Value(null),
            ),
          );
}
