import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/sync_request_hash.dart';
import 'package:agrocampo/features/irrigation/domain/sector_irrigation_config.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:drift/drift.dart';

final class SectorIrrigationConfigRepository {
  SectorIrrigationConfigRepository(this._database);
  final AppDatabase _database;

  Future<SectorIrrigationConfig?> current({
    required String ownerId,
    required String sectorId,
    DateTime? at,
  }) async {
    final instant = (at ?? DateTime.now()).toUtc();
    final rows =
        await (_database.select(_database.sectorIrrigationConfigs)
              ..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.sectorId.equals(sectorId) &
                    row.method.equals('drip') &
                    row.effectiveFrom.isSmallerOrEqualValue(instant) &
                    (row.effectiveTo.isNull() |
                        row.effectiveTo.isBiggerThanValue(instant)) &
                    row.deletedAt.isNull(),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.configVersion)]))
            .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<String> saveVersion({
    required String ownerId,
    required String sectorId,
    required SectorIrrigationConfigInput input,
    DateTime? effectiveFrom,
  }) async {
    input.validate();
    final sector =
        await (_database.select(_database.sectors)..where(
              (row) =>
                  row.id.equals(sectorId) &
                  row.ownerId.equals(ownerId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (sector == null) throw StateError('irrigation_config_sector_missing');
    final now = DateTime.now().toUtc();
    final effective = (effectiveFrom ?? now).toUtc();
    final previous = await current(
      ownerId: ownerId,
      sectorId: sectorId,
      at: effective,
    );
    final id = EntityId.generate().value;
    final configVersion = (previous?.configVersion ?? 0) + 1;
    final payload = <String, Object?>{
      'id': id,
      'sector_id': sectorId,
      'method': 'drip',
      'plant_count': input.plantCount,
      'emitter_count': input.emitterCount,
      'emitters_per_plant_milli': input.emittersPerPlantMilli,
      'flow_ml_min': input.flowMlMin,
      'pressure_kpa': input.pressureKpa,
      'distribution_notes': input.distributionNotes?.trim(),
      'effective_from': effective.toIso8601String(),
      'effective_to': null,
      'config_version': configVersion,
      'supersedes_config_id': previous?.id,
      'version': 1,
      'updated_at': now.toIso8601String(),
      'deleted_at': null,
    };
    final sectorDependency = await _pending(ownerId, 'sector', sectorId);
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () async {
        if (previous != null) {
          await (_database.update(
            _database.sectorIrrigationConfigs,
          )..where((row) => row.id.equals(previous.id))).write(
            SectorIrrigationConfigsCompanion(effectiveTo: Value(effective)),
          );
        }
        await _database
            .into(_database.sectorIrrigationConfigs)
            .insert(
              SectorIrrigationConfigsCompanion.insert(
                id: id,
                ownerId: ownerId,
                sectorId: sectorId,
                plantCount: input.plantCount,
                emitterCount: input.emitterCount,
                emittersPerPlantMilli: Value(input.emittersPerPlantMilli),
                flowMlMin: input.flowMlMin,
                pressureKpa: Value(input.pressureKpa),
                distributionNotes: Value(input.distributionNotes?.trim()),
                effectiveFrom: effective,
                configVersion: configVersion,
                updatedAt: now,
              ),
            );
      },
      operation: SyncOutboxCompanion.insert(
        operationId: EntityId.generate().value,
        ownerId: ownerId,
        aggregateType: 'irrigationConfig',
        aggregateId: id,
        mutationKind: 'create',
        payloadJson: jsonEncode(payload),
        requestHash: Value(
          syncRequestHash(
            aggregateType: 'irrigationConfig',
            aggregateId: id,
            mutationKind: 'create',
            baseVersion: null,
            payload: payload,
          ),
        ),
        dependencyOperationId: Value(sectorDependency),
        createdAt: now,
      ),
    );
    return id;
  }

  Future<String?> _pending(String ownerId, String type, String id) async {
    final rows =
        await (_database.select(_database.syncOutbox)
              ..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.aggregateType.equals(type) &
                    row.aggregateId.equals(id) &
                    row.state.isNotIn(const ['done']),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
            .get();
    return rows.isEmpty ? null : rows.first.operationId;
  }
}
