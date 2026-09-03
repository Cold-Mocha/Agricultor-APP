import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/protocol/aggregate_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:drift/drift.dart';

final class AgriculturalSeasonSyncCodec implements AggregateSyncCodec {
  const AgriculturalSeasonSyncCodec();

  @override
  String get aggregateType => 'agriculturalSeason';

  @override
  Future<void> applyRemote(
    AppDatabase database,
    String ownerId,
    RemoteChange change,
  ) async {
    final payload = jsonDecode(change.payloadJson);
    if (payload is! Map<String, Object?> ||
        payload['id'] != change.aggregateId ||
        payload['parcel_id'] is! String ||
        payload['name'] is! String ||
        payload['starts_on'] is! String ||
        payload['status'] is! String ||
        payload['updated_at'] is! String) {
      throw const FormatException('agricultural_season_payload_invalid');
    }
    final parcelId = payload['parcel_id']! as String;
    final parent =
        await (database.select(database.parcels)..where(
              (row) => row.id.equals(parcelId) & row.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    if (parent == null) throw const FormatException('season_parent_missing');
    final updatedAt = DateTime.parse(payload['updated_at']! as String).toUtc();
    await database
        .into(database.agriculturalSeasons)
        .insertOnConflictUpdate(
          AgriculturalSeasonsCompanion.insert(
            id: change.aggregateId,
            ownerId: ownerId,
            parcelId: parcelId,
            name: payload['name']! as String,
            startsOn: DateTime.parse(payload['starts_on']! as String).toUtc(),
            endsOn: Value(
              payload['ends_on'] is String
                  ? DateTime.parse(payload['ends_on']! as String).toUtc()
                  : null,
            ),
            status: Value(payload['status']! as String),
            notes: Value(payload['notes'] as String?),
            isMigrationBackfill: Value(
              payload['is_migration_backfill'] as bool? ?? false,
            ),
            version: Value(change.remoteVersion),
            syncState: const Value('synced'),
            updatedAt: updatedAt,
            serverUpdatedAt: Value(updatedAt),
            deletedAt: Value(
              payload['deleted_at'] is String
                  ? DateTime.parse(payload['deleted_at']! as String).toUtc()
                  : null,
            ),
          ),
        );
  }

  @override
  Future<void> markAcknowledged(
    AppDatabase database,
    String ownerId,
    String aggregateId,
    int? remoteVersion,
    DateTime acknowledgedAt,
  ) =>
      (database.update(database.agriculturalSeasons)..where(
            (row) => row.ownerId.equals(ownerId) & row.id.equals(aggregateId),
          ))
          .write(
            AgriculturalSeasonsCompanion(
              version: remoteVersion == null
                  ? const Value.absent()
                  : Value(remoteVersion),
              syncState: const Value('synced'),
              serverUpdatedAt: Value(acknowledgedAt),
              lastSyncErrorCode: const Value(null),
            ),
          );
}
