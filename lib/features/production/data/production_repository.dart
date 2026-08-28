import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
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
    required HarvestInput input,
  }) async {
    input.validate();
    final id = EntityId.generate().value;
    final now = DateTime.now().toUtc();
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () => _database
          .into(_database.productionRecords)
          .insert(
            ProductionRecordsCompanion.insert(
              id: id,
              ownerId: ownerId,
              parcelId: parcelId,
              sectorId: sectorId,
              seasonId: Value(seasonId),
              cropId: input.cropId,
              quantity: input.quantity,
              unit: input.unit.trim(),
              qualityNotes: Value(input.qualityNotes?.trim()),
              harvestedAt: input.harvestedAt,
              updatedAt: now,
            ),
          ),
      operation: SyncOutboxCompanion.insert(
        operationId: EntityId.generate().value,
        ownerId: ownerId,
        aggregateType: 'production',
        aggregateId: id,
        mutationKind: 'create',
        payloadJson: jsonEncode({
          'id': id,
          'parcel_id': parcelId,
          'sector_id': sectorId,
          'season_id': seasonId,
          'crop_id': input.cropId,
          'quantity': input.quantity,
          'unit': input.unit,
          'harvested_at': input.harvestedAt.toIso8601String(),
        }),
        createdAt: now,
      ),
    );
    return id;
  }
}
