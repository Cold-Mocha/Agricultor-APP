import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/sync_request_hash.dart';
import 'package:agrocampo/features/labors/data/labor_repository.dart';
import 'package:agrocampo/features/labors/domain/harvest_details.dart';
import 'package:agrocampo/features/production/domain/harvest_input.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:drift/drift.dart';

final class ProductionRepository {
  ProductionRepository(this._database);

  final AppDatabase _database;

  Future<String> save({
    required String ownerId,
    required String parcelId,
    required String sectorId,
    String? seasonId,
    String? cropAssignmentId,
    String? laborId,
    required HarvestInput input,
  }) async {
    input.validate();
    final context = await LaborRepository(_database).resolveContext(
      ownerId: ownerId,
      parcelId: parcelId,
      sectorId: sectorId,
      occurredAt: input.harvestedAt.toUtc(),
      seasonId: seasonId,
      cropAssignmentId: cropAssignmentId,
    );
    if (input.cropId != context.cropId) {
      throw StateError('harvest_crop_context_mismatch');
    }
    final rootId = laborId ?? EntityId.generate().value;
    final existing =
        await (_database.select(_database.labors)..where(
              (row) => row.id.equals(rootId) & row.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    if (existing != null) {
      final production = await (_database.select(
        _database.productionRecords,
      )..where((row) => row.laborId.equals(rootId))).getSingle();
      return production.id;
    }
    final productionId = EntityId.generate().value;
    final now = DateTime.now().toUtc();
    final details = HarvestDetails.fromInput(input).toEnvelope();
    final payload = <String, Object?>{
      'id': rootId,
      'owner_id': ownerId,
      'parcel_id': parcelId,
      'sector_id': sectorId,
      'agricultural_season_id': context.seasonId,
      'crop_assignment_id': context.assignmentId,
      'type': 'harvest',
      'details': details.toJson(),
      'details_schema_version': details.schemaVersion,
      'status': 'recorded',
      'occurred_at': input.harvestedAt.toUtc().toIso8601String(),
      'version': 1,
      'updated_at': now.toIso8601String(),
      'deleted_at': null,
      'production': {
        'id': productionId,
        'labor_id': rootId,
        'parcel_id': parcelId,
        'sector_id': sectorId,
        'season_id': context.seasonId,
        'crop_id': context.cropId,
        'quantity': input.quantity,
        'unit': input.unit.trim(),
        'quality_notes': input.qualityNotes?.trim(),
        'harvested_at': input.harvestedAt.toUtc().toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
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
                type: 'harvest',
                detailsJson: Value(details.encode()),
                detailsSchemaVersion: Value(details.schemaVersion),
                status: const Value('recorded'),
                occurredAt: input.harvestedAt.toUtc(),
                version: const Value(1),
                syncState: const Value('pending'),
                updatedAt: now,
              ),
            );
        await _database
            .into(_database.productionRecords)
            .insert(
              ProductionRecordsCompanion.insert(
                id: productionId,
                ownerId: ownerId,
                parcelId: parcelId,
                sectorId: sectorId,
                laborId: Value(rootId),
                seasonId: Value(context.seasonId),
                cropId: context.cropId,
                quantity: input.quantity,
                unit: input.unit.trim(),
                qualityNotes: Value(input.qualityNotes?.trim()),
                harvestedAt: input.harvestedAt.toUtc(),
                updatedAt: now,
              ),
            );
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
    return productionId;
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
