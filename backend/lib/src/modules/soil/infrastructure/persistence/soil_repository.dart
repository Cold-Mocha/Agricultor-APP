import 'dart:convert';

import 'package:agrocampo_backend/src/modules/agricultural_context/agricultural_context_api.dart';
import 'package:agrocampo_backend/src/modules/labors/labors_api.dart';
import 'package:agrocampo_backend/src/modules/soil/domain/entities/soil_measurement.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_request_hash.dart';
import 'package:agrocampo_backend/src/shared/kernel/entity_id.dart';
import 'package:drift/drift.dart';

final class SoilRepository {
  SoilRepository(this._database);

  final AppDatabase _database;

  Future<String> save({
    required String ownerId,
    required String sectorId,
    required SoilMeasurementInput input,
  }) async {
    input.validate();
    final sector =
        await (_database.select(_database.sectors)..where(
              (row) => row.id.equals(sectorId) & row.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    if (sector == null) throw StateError('owner_mismatch');
    if (sector.kind != 'crop') {
      throw StateError('operation_not_valid_for_apiary');
    }
    final id = EntityId.generate().value;
    final laborId = EntityId.generate().value;
    final now = DateTime.now().toUtc();
    final indicatorData = <String, Object?>{
      if (input.moisturePercent != null)
        'moisturePercent': input.moisturePercent,
      if (input.ph != null) 'ph': input.ph,
      if (input.temperatureCelsius != null)
        'temperatureCelsius': input.temperatureCelsius,
      if (input.conductivity != null) 'conductivity': input.conductivity,
      if (input.nitrogen != null) 'nitrogen': input.nitrogen,
      if (input.phosphorus != null) 'phosphorus': input.phosphorus,
      if (input.potassium != null) 'potassium': input.potassium,
      if (input.units.isNotEmpty)
        'units': Map<String, String>.unmodifiable(input.units),
    };
    final details = LaborDetails.current(LaborType.soil, indicatorData);
    final payload = <String, Object?>{
      'id': laborId,
      'owner_id': ownerId,
      'parcel_id': sector.parcelId,
      'sector_id': sectorId,
      'type': LaborType.soil.name,
      'domain_category': ProductiveCategory.crop.code,
      'details': details.toJson(),
      'soil': {'id': id, 'labor_id': laborId, ...indicatorData},
      'occurred_at': now.toIso8601String(),
      'version': 1,
      'updated_at': now.toIso8601String(),
    };
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () async {
        await _database
            .into(_database.labors)
            .insert(
              LaborsCompanion.insert(
                id: laborId,
                ownerId: ownerId,
                parcelId: sector.parcelId,
                sectorId: sectorId,
                type: LaborType.soil.name,
                detailsJson: Value(details.encode()),
                detailsSchemaVersion: Value(details.schemaVersion),
                occurredAt: now,
                updatedAt: now,
              ),
            );
        await _database.customUpdate(
          'UPDATE labors SET domain_category = ? WHERE id = ?',
          variables: [
            Variable(ProductiveCategory.crop.code),
            Variable(laborId),
          ],
        );
        await _database
            .into(_database.soilMeasurements)
            .insert(
              SoilMeasurementsCompanion.insert(
                id: id,
                ownerId: ownerId,
                sectorId: sectorId,
                moisturePercent: Value(input.moisturePercent),
                ph: Value(input.ph),
                temperatureCelsius: Value(input.temperatureCelsius),
                conductivity: Value(input.conductivity),
                nitrogen: Value(input.nitrogen),
                phosphorus: Value(input.phosphorus),
                potassium: Value(input.potassium),
                measuredAt: now,
                updatedAt: now,
              ),
            );
        await _database.customUpdate(
          'UPDATE soil_measurements SET labor_id = ? WHERE id = ?',
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
