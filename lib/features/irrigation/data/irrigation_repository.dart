import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_record.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:drift/drift.dart';

final class IrrigationRepository {
  IrrigationRepository(this._database);

  final AppDatabase _database;

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
}
