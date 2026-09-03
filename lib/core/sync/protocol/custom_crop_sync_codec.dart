import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/protocol/aggregate_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:drift/drift.dart';

final class CustomCropSyncCodec implements AggregateSyncCodec {
  const CustomCropSyncCodec();

  @override
  String get aggregateType => 'customCrop';

  @override
  Future<void> applyRemote(
    AppDatabase database,
    String ownerId,
    RemoteChange change,
  ) async {
    final payload = jsonDecode(change.payloadJson);
    if (payload is! Map<String, Object?> ||
        payload['id'] != change.aggregateId ||
        payload['name'] is! String ||
        payload['normalized_name'] is! String ||
        payload['updated_at'] is! String) {
      throw const FormatException('custom_crop_payload_invalid');
    }
    final updatedAt = DateTime.parse(payload['updated_at']! as String).toUtc();
    await database
        .into(database.customCrops)
        .insertOnConflictUpdate(
          CustomCropsCompanion.insert(
            id: change.aggregateId,
            ownerId: ownerId,
            name: payload['name']! as String,
            normalizedName: Value(payload['normalized_name']! as String),
            description: Value(payload['description'] as String?),
            notes: Value(payload['notes'] as String?),
            archivedAt: Value(
              payload['archived_at'] is String
                  ? DateTime.parse(payload['archived_at']! as String).toUtc()
                  : null,
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
      (database.update(database.customCrops)..where(
            (row) => row.ownerId.equals(ownerId) & row.id.equals(aggregateId),
          ))
          .write(
            CustomCropsCompanion(
              version: remoteVersion == null
                  ? const Value.absent()
                  : Value(remoteVersion),
              syncState: const Value('synced'),
              serverUpdatedAt: Value(acknowledgedAt),
              lastSyncErrorCode: const Value(null),
            ),
          );
}
