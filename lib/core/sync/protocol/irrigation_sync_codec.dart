import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/protocol/aggregate_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:drift/drift.dart';

final class IrrigationConfigSyncCodec implements AggregateSyncCodec {
  const IrrigationConfigSyncCodec();

  @override
  String get aggregateType => 'irrigationConfig';

  @override
  Future<void> applyRemote(
    AppDatabase database,
    String ownerId,
    RemoteChange change,
  ) async {
    final payload = jsonDecode(change.payloadJson);
    if (payload is! Map<String, Object?> ||
        payload['id'] != change.aggregateId ||
        payload['sector_id'] is! String ||
        payload['method'] != 'drip' ||
        payload['plant_count'] is! int ||
        payload['emitter_count'] is! int ||
        payload['flow_ml_min'] is! int ||
        payload['effective_from'] is! String ||
        payload['config_version'] is! int ||
        payload['updated_at'] is! String) {
      throw const FormatException('irrigation_config_payload_invalid');
    }
    final sectorId = payload['sector_id']! as String;
    final parent =
        await (database.select(database.sectors)..where(
              (row) => row.id.equals(sectorId) & row.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    if (parent == null) {
      throw const FormatException('irrigation_config_parent_missing');
    }
    final updatedAt = DateTime.parse(payload['updated_at']! as String).toUtc();
    await database.transaction(() async {
      final supersedes = payload['supersedes_config_id'];
      if (supersedes is String) {
        await (database.update(database.sectorIrrigationConfigs)..where(
              (row) => row.id.equals(supersedes) & row.ownerId.equals(ownerId),
            ))
            .write(
              SectorIrrigationConfigsCompanion(
                effectiveTo: Value(
                  DateTime.parse(payload['effective_from']! as String).toUtc(),
                ),
              ),
            );
      }
      await database
          .into(database.sectorIrrigationConfigs)
          .insertOnConflictUpdate(
            SectorIrrigationConfigsCompanion.insert(
              id: change.aggregateId,
              ownerId: ownerId,
              sectorId: sectorId,
              plantCount: payload['plant_count']! as int,
              emitterCount: payload['emitter_count']! as int,
              emittersPerPlantMilli: Value(
                payload['emitters_per_plant_milli'] as int?,
              ),
              flowMlMin: payload['flow_ml_min']! as int,
              pressureKpa: Value(payload['pressure_kpa'] as int?),
              distributionNotes: Value(
                payload['distribution_notes'] as String?,
              ),
              effectiveFrom: DateTime.parse(
                payload['effective_from']! as String,
              ).toUtc(),
              effectiveTo: Value(_date(payload['effective_to'])),
              configVersion: payload['config_version']! as int,
              version: Value(change.remoteVersion),
              syncState: const Value('synced'),
              serverUpdatedAt: Value(updatedAt),
              deletedAt: Value(_date(payload['deleted_at'])),
              updatedAt: updatedAt,
            ),
          );
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
      (database.update(database.sectorIrrigationConfigs)..where(
            (row) => row.id.equals(aggregateId) & row.ownerId.equals(ownerId),
          ))
          .write(
            SectorIrrigationConfigsCompanion(
              version: remoteVersion == null
                  ? const Value.absent()
                  : Value(remoteVersion),
              syncState: const Value('synced'),
              serverUpdatedAt: Value(acknowledgedAt),
              lastSyncErrorCode: const Value(null),
            ),
          );
}
