import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/apiary/domain/apiary_inspection_input.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';
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
    final id = EntityId.generate().value;
    final now = DateTime.now().toUtc();
    final payload = {
      'id': id,
      'sector_id': sectorId,
      'task_type': input.taskType.name,
      'beekeeper_name': input.beekeeperName.trim(),
      'hive_count': input.hiveCount,
      'inspected_at': input.inspectedAt.toUtc().toIso8601String(),
    };
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () => _database
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
          ),
      operation: SyncOutboxCompanion.insert(
        operationId: EntityId.generate().value,
        ownerId: ownerId,
        aggregateType: 'apiary_inspection',
        aggregateId: id,
        mutationKind: 'create',
        payloadJson: jsonEncode(payload),
        createdAt: now,
      ),
    );
    return id;
  }
}
