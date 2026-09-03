import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/core/geometry/polygon_geometry.dart';
import 'package:agrocampo/core/sync/protocol/aggregate_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:drift/drift.dart';

final class SectorSyncCodec implements AggregateSyncCodec {
  const SectorSyncCodec();

  @override
  String get aggregateType => 'sector';

  @override
  Future<void> applyRemote(
    AppDatabase database,
    String ownerId,
    RemoteChange change,
  ) async {
    final decoded = jsonDecode(change.payloadJson);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('sector_payload_not_object');
    }
    final id = decoded['id'];
    final parcelId = decoded['parcel_id'];
    final name = decoded['name'];
    final number = decoded['number'];
    final polygonValue = decoded['polygon'];
    final updatedAt = decoded['updated_at'];
    if (id is! String ||
        id != change.aggregateId ||
        parcelId is! String ||
        name is! String ||
        number is! int ||
        polygonValue is! List<Object?> ||
        updatedAt is! String) {
      throw const FormatException('sector_payload_invalid');
    }
    final parcel =
        await (database.select(database.parcels)..where(
              (row) => row.id.equals(parcelId) & row.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    if (parcel == null) throw const FormatException('sector_parent_missing');
    final polygon = polygonValue
        .map((value) {
          if (value is! Map<String, Object?> ||
              value['lat'] is! num ||
              value['lng'] is! num) {
            throw const FormatException('sector_polygon_invalid');
          }
          return GeoPoint(
            (value['lat'] as num).toDouble(),
            (value['lng'] as num).toDouble(),
          );
        })
        .toList(growable: false);
    final geometryError = PolygonGeometry.validationError(polygon);
    if (geometryError != null) throw FormatException(geometryError);
    final deletedAt = decoded['deleted_at'];
    await database
        .into(database.sectors)
        .insertOnConflictUpdate(
          SectorsCompanion.insert(
            id: id,
            ownerId: ownerId,
            parcelId: parcelId,
            number: number,
            name: name,
            kind: Value(decoded['kind'] as String? ?? 'crop'),
            polygonJson: jsonEncode(
              PolygonGeometry.normalize(polygon)
                  .map((point) => point.toJson())
                  .toList(growable: false),
            ),
            areaSquareMeters: PolygonGeometry.areaSquareMeters(polygon),
            version: Value(change.remoteVersion),
            syncState: const Value('synced'),
            serverUpdatedAt: Value(DateTime.parse(updatedAt).toUtc()),
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
      (database.update(database.sectors)..where(
            (row) => row.ownerId.equals(ownerId) & row.id.equals(aggregateId),
          ))
          .write(
            SectorsCompanion(
              version: remoteVersion == null
                  ? const Value.absent()
                  : Value(remoteVersion),
              syncState: const Value('synced'),
              serverUpdatedAt: Value(acknowledgedAt),
              lastSyncErrorCode: const Value(null),
            ),
          );
}
