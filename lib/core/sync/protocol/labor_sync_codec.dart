import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/protocol/aggregate_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
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
        decoded['parcel_id'] is! String ||
        decoded['sector_id'] is! String ||
        decoded['agricultural_season_id'] is! String ||
        decoded['crop_assignment_id'] is! String ||
        decoded['type'] is! String ||
        decoded['details'] is! Map<String, Object?> ||
        decoded['occurred_at'] is! String ||
        decoded['updated_at'] is! String) {
      throw const FormatException('labor_payload_invalid');
    }
    final parcelId = decoded['parcel_id']! as String;
    final sectorId = decoded['sector_id']! as String;
    final seasonId = decoded['agricultural_season_id']! as String;
    final assignmentId = decoded['crop_assignment_id']! as String;
    final parents = await Future.wait([
      (database.select(database.sectors)..where(
            (row) =>
                row.id.equals(sectorId) &
                row.ownerId.equals(ownerId) &
                row.parcelId.equals(parcelId),
          ))
          .getSingleOrNull(),
      (database.select(database.agriculturalSeasons)..where(
            (row) =>
                row.id.equals(seasonId) &
                row.ownerId.equals(ownerId) &
                row.parcelId.equals(parcelId),
          ))
          .getSingleOrNull(),
      (database.select(database.cropSeasons)..where(
            (row) =>
                row.id.equals(assignmentId) &
                row.ownerId.equals(ownerId) &
                row.sectorId.equals(sectorId) &
                row.agriculturalSeasonId.equals(seasonId),
          ))
          .getSingleOrNull(),
    ]);
    if (parents.any((parent) => parent == null)) {
      throw const FormatException('labor_parent_missing');
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
              parcelId: parcelId,
              sectorId: sectorId,
              seasonId: Value(seasonId),
              cropAssignmentId: Value(assignmentId),
              type: decoded['type']! as String,
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
                parcelId: parcelId,
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
