import 'dart:convert';

import 'package:agrocampo_backend/src/modules/agricultural_context/agricultural_context_api.dart';
import 'package:agrocampo_backend/src/modules/apiary/domain/entities/apiary_inspection_input.dart';
import 'package:agrocampo_backend/src/modules/apiary/domain/entities/apiary_operation_details.dart';
import 'package:agrocampo_backend/src/modules/labors/labors_api.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_request_hash.dart';
import 'package:agrocampo_backend/src/shared/kernel/entity_id.dart';
import 'package:drift/drift.dart';

final class ApiaryRepository {
  const ApiaryRepository(this._database);
  final AppDatabase _database;

  Future<String> save({
    required String ownerId,
    required String sectorId,
    required ApiaryInspectionInput input,
  }) async {
    input.validate();
    final typedDetails = ApiaryOperationDetails.fromInput(input);
    final detailsJson = typedDetails.toJson();
    final sector =
        await (_database.select(_database.sectors)..where(
              (row) => row.id.equals(sectorId) & row.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    if (sector == null) throw StateError('owner_mismatch');
    final category = ProductiveCategory.fromCode(sector.kind);
    final compatibility = const DomainCompatibilityPolicy().evaluate(
      category: category,
      operation: switch (input.taskType) {
        ApiaryTaskType.inspection => ProductiveOperation.apiaryInspection,
        ApiaryTaskType.feeding => ProductiveOperation.apiaryFeeding,
        ApiaryTaskType.health => ProductiveOperation.apiaryHealth,
        ApiaryTaskType.harvest => ProductiveOperation.apiaryHarvest,
        ApiaryTaskType.superPlacement =>
          ProductiveOperation.apiarySuperPlacement,
        ApiaryTaskType.other => ProductiveOperation.otherApiaryOperation,
      },
      context: sectorId,
    );
    if (!compatibility.isAllowed) {
      throw StateError((compatibility as CompatibilityRejected).code);
    }
    final id = EntityId.generate().value;
    final laborId = EntityId.generate().value;
    final now = DateTime.now().toUtc();
    final payload = <String, Object?>{
      'id': laborId,
      'parcel_id': sector.parcelId,
      'agricultural_season_id': null,
      'crop_assignment_id': null,
      'type': LaborType.apiary.name,
      'sector_id': sectorId,
      'task_type': input.taskType.name,
      'beekeeper_name': input.beekeeperName.trim(),
      'hive_count': input.hiveCount,
      'inspected_at': input.inspectedAt.toUtc().toIso8601String(),
      'domain_category': category.code,
      'details': LaborDetails.current(LaborType.apiary, detailsJson).toJson(),
      'details_schema_version': LaborDetails.currentSchemaVersion,
      'occurred_at': input.inspectedAt.toUtc().toIso8601String(),
      'updated_at': now.toIso8601String(),
      'apiary': {
        'id': id,
        'task_type': input.taskType.name,
        'beekeeper_name': input.beekeeperName.trim(),
        'hive_count': input.hiveCount,
        'queen_status': input.queenStatus.trim(),
        'brood_status': input.broodStatus.trim(),
        'feeding_status': input.feedingStatus.trim(),
        'health_notes': input.healthNotes.trim(),
        'pest_notes': input.pestNotes.trim(),
        'super_installed': input.superInstalled,
        'observations': input.observations?.trim(),
        'inspected_at': input.inspectedAt.toUtc().toIso8601String(),
      },
    };
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () async {
        final details = LaborDetails.current(LaborType.apiary, detailsJson);
        await _database
            .into(_database.labors)
            .insert(
              LaborsCompanion.insert(
                id: laborId,
                ownerId: ownerId,
                parcelId: sector.parcelId,
                sectorId: sectorId,
                type: LaborType.apiary.name,
                detailsJson: Value(details.encode()),
                detailsSchemaVersion: Value(details.schemaVersion),
                occurredAt: input.inspectedAt.toUtc(),
                updatedAt: now,
              ),
            );
        await _database.customUpdate(
          'UPDATE labors SET domain_category = ? WHERE id = ?',
          variables: [Variable(category.code), Variable(laborId)],
        );
        await _database
            .into(_database.apiaryInspections)
            .insert(
              ApiaryInspectionsCompanion.insert(
                id: id,
                ownerId: ownerId,
                sectorId: sectorId,
                taskType: input.taskType.name,
                beekeeperName: input.beekeeperName.trim(),
                hiveCount: input.hiveCount,
                queenStatus: input.queenStatus.trim(),
                broodStatus: input.broodStatus.trim(),
                feedingStatus: input.feedingStatus.trim(),
                healthNotes: input.healthNotes.trim(),
                pestNotes: input.pestNotes.trim(),
                superInstalled: input.superInstalled,
                observations: Value(input.observations?.trim()),
                inspectedAt: input.inspectedAt.toUtc(),
                updatedAt: now,
              ),
            );
        await _database.customUpdate(
          'UPDATE apiary_inspections SET labor_id = ? WHERE id = ?',
          variables: [Variable(laborId), Variable(id)],
        );
      },
      operation: SyncOutboxCompanion.insert(
        operationId: EntityId.generate().value,
        ownerId: ownerId,
        aggregateType: 'labor',
        aggregateId: laborId,
        mutationKind: 'create',
        payloadJson: jsonEncode(payload),
        requestHash: Value(
          syncRequestHash(
            aggregateType: 'labor',
            aggregateId: laborId,
            mutationKind: 'create',
            baseVersion: null,
            payload: payload,
          ),
        ),
        createdAt: now,
      ),
    );
    return id;
  }
}
