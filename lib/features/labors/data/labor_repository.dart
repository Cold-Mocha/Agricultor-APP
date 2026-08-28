import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:drift/drift.dart';

final class LaborRepository {
  LaborRepository(this._database);

  final AppDatabase _database;

  Future<String> save({
    required String ownerId,
    required String parcelId,
    required String sectorId,
    required LaborType type,
    required DateTime occurredAt,
    String? customName,
    String? notes,
    Map<String, Object?> details = const {},
  }) async {
    if (type == LaborType.other &&
        (customName == null ||
            customName.trim().isEmpty ||
            notes == null ||
            notes.trim().isEmpty)) {
      throw ArgumentError('other_labor_requires_name_and_notes');
    }
    final id = EntityId.generate().value;
    final now = DateTime.now().toUtc();
    final companion = LaborsCompanion.insert(
      id: id,
      ownerId: ownerId,
      parcelId: parcelId,
      sectorId: sectorId,
      type: type.name,
      customName: Value(customName?.trim()),
      detailsJson: Value(jsonEncode(details)),
      notes: Value(notes?.trim()),
      occurredAt: occurredAt,
      updatedAt: now,
    );
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () => _database.into(_database.labors).insert(companion),
      operation: SyncOutboxCompanion.insert(
        operationId: EntityId.generate().value,
        ownerId: ownerId,
        aggregateType: 'labor',
        aggregateId: id,
        mutationKind: 'create',
        payloadJson: jsonEncode({
          'id': id,
          'type': type.name,
          'sector_id': sectorId,
          'details': details,
        }),
        createdAt: now,
      ),
    );
    await _database.formDraftDao.clear(ownerId, 'labor');
    return id;
  }
}
