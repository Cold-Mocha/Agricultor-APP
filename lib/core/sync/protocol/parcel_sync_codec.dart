import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/protocol/aggregate_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:drift/drift.dart';

final class ParcelSyncCodec implements AggregateSyncCodec {
  const ParcelSyncCodec();

  @override
  String get aggregateType => 'parcel';

  @override
  Future<void> applyRemote(
    AppDatabase database,
    String ownerId,
    RemoteChange change,
  ) async {
    final decoded = jsonDecode(change.payloadJson);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('parcel_payload_not_object');
    }
    final id = decoded['id'];
    final name = decoded['name'];
    final updatedAt = decoded['updated_at'];
    if (id is! String ||
        id != change.aggregateId ||
        name is! String ||
        updatedAt is! String) {
      throw const FormatException('parcel_payload_invalid');
    }
    final deletedAt = decoded['deleted_at'];
    await database
        .into(database.parcels)
        .insertOnConflictUpdate(
          ParcelsCompanion.insert(
            id: id,
            ownerId: ownerId,
            name: name,
            locality: Value(decoded['locality'] as String?),
            polygonJson: Value(
              decoded['polygon'] == null
                  ? null
                  : jsonEncode(decoded['polygon']),
            ),
            areaSquareMeters: Value(
              (decoded['area_square_meters'] as num?)?.toDouble(),
            ),
            isActive: Value(decoded['is_active'] as bool? ?? false),
            isArchived: Value(decoded['is_archived'] as bool? ?? false),
            version: Value(change.remoteVersion),
            syncState: const Value('synced'),
            updatedAt: DateTime.parse(updatedAt).toUtc(),
            deletedAt: Value(
              deletedAt is String ? DateTime.parse(deletedAt).toUtc() : null,
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
      (database.update(database.parcels)..where(
            (row) => row.ownerId.equals(ownerId) & row.id.equals(aggregateId),
          ))
          .write(
            ParcelsCompanion(
              version: remoteVersion == null
                  ? const Value.absent()
                  : Value(remoteVersion),
              syncState: const Value('synced'),
              serverUpdatedAt: Value(acknowledgedAt),
              lastSyncErrorCode: const Value(null),
            ),
          );
}
