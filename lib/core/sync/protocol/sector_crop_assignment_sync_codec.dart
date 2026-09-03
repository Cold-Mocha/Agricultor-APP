import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/protocol/aggregate_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:drift/drift.dart';

final class SectorCropAssignmentSyncCodec implements AggregateSyncCodec {
  const SectorCropAssignmentSyncCodec();

  @override
  String get aggregateType => 'sectorCropAssignment';

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
        payload['agricultural_season_id'] is! String ||
        payload['crop_id'] is! String ||
        payload['is_custom_crop'] is! bool ||
        payload['status'] is! String ||
        payload['starts_on'] is! String ||
        payload['updated_at'] is! String) {
      throw const FormatException('crop_assignment_payload_invalid');
    }
    final sectorId = payload['sector_id']! as String;
    final seasonId = payload['agricultural_season_id']! as String;
    final sector =
        await (database.select(database.sectors)..where(
              (row) => row.id.equals(sectorId) & row.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    final season =
        await (database.select(database.agriculturalSeasons)..where(
              (row) => row.id.equals(seasonId) & row.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    if (sector == null ||
        season == null ||
        sector.parcelId != season.parcelId) {
      throw const FormatException('crop_assignment_parent_missing');
    }
    final isCustom = payload['is_custom_crop']! as bool;
    final cropId = payload['crop_id']! as String;
    final cropExists = isCustom
        ? await (database.select(database.customCrops)..where(
                    (row) =>
                        row.id.equals(cropId) & row.ownerId.equals(ownerId),
                  ))
                  .getSingleOrNull() !=
              null
        : await (database.select(
                database.officialCrops,
              )..where((row) => row.id.equals(cropId))).getSingleOrNull() !=
              null;
    if (!cropExists) {
      throw const FormatException('crop_assignment_crop_missing');
    }
    final updatedAt = DateTime.parse(payload['updated_at']! as String).toUtc();
    await database
        .into(database.cropSeasons)
        .insertOnConflictUpdate(
          CropSeasonsCompanion.insert(
            id: change.aggregateId,
            ownerId: ownerId,
            sectorId: sectorId,
            agriculturalSeasonId: Value(seasonId),
            cropId: cropId,
            isCustomCrop: Value(isCustom),
            status: Value(payload['status']! as String),
            startsOn: DateTime.parse(payload['starts_on']! as String).toUtc(),
            endsOn: Value(
              payload['ends_on'] is String
                  ? DateTime.parse(payload['ends_on']! as String).toUtc()
                  : null,
            ),
            notes: Value(payload['notes'] as String?),
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
      (database.update(database.cropSeasons)..where(
            (row) => row.ownerId.equals(ownerId) & row.id.equals(aggregateId),
          ))
          .write(
            CropSeasonsCompanion(
              version: remoteVersion == null
                  ? const Value.absent()
                  : Value(remoteVersion),
              syncState: const Value('synced'),
              serverUpdatedAt: Value(acknowledgedAt),
              lastSyncErrorCode: const Value(null),
            ),
          );
}
