import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/core/geometry/polygon_geometry.dart';
import 'package:agrocampo/core/sync/sync_request_hash.dart';
import 'package:agrocampo/features/parcels/domain/parcel.dart' as domain;
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:drift/drift.dart';

final class ParcelRepository {
  ParcelRepository(this._database);

  final AppDatabase _database;

  Stream<List<domain.Parcel>> watchAll(String ownerId) =>
      (_database.select(_database.parcels)
            ..where(
              (row) => row.ownerId.equals(ownerId) & row.deletedAt.isNull(),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.name)]))
          .watch()
          .map(
            (rows) => rows
                .map(
                  (row) => domain.Parcel(
                    id: row.id,
                    ownerId: row.ownerId,
                    name: row.name,
                    locality: row.locality,
                    isActive: row.isActive,
                    isArchived: row.isArchived,
                    version: row.version,
                    updatedAt: row.updatedAt,
                  ),
                )
                .toList(growable: false),
          );

  Future<String> save({
    required String ownerId,
    required String name,
    String? id,
    String? locality,
    bool isActive = false,
    bool? isArchived,
    DateTime? deletedAt,
    List<GeoPoint>? boundary,
  }) async {
    final parcelId = id ?? EntityId.generate().value;
    final operationId = EntityId.generate().value;
    final now = DateTime.now().toUtc();
    final existing =
        await (_database.select(_database.parcels)..where(
              (row) => row.id.equals(parcelId) & row.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    final nextVersion = (existing?.version ?? 0) + 1;
    final polygonJson = boundary == null
        ? existing?.polygonJson
        : jsonEncode(
            boundary.map((point) => point.toJson()).toList(growable: false),
          );
    final areaSquareMeters = boundary == null
        ? existing?.areaSquareMeters
        : PolygonGeometry.areaSquareMeters(boundary);
    final payload = <String, Object?>{
      'id': parcelId,
      'owner_id': ownerId,
      'name': name.trim(),
      'locality': locality?.trim(),
      'is_active': isActive,
      'is_archived': isArchived ?? existing?.isArchived ?? false,
      'polygon': polygonJson == null ? null : jsonDecode(polygonJson),
      'area_square_meters': areaSquareMeters,
      'version': nextVersion,
      'updated_at': now.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
    final mutationKind = deletedAt != null
        ? 'delete'
        : existing == null
        ? 'create'
        : 'update';

    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () async {
        if (isActive) {
          await (_database.update(_database.parcels)
                ..where((row) => row.ownerId.equals(ownerId)))
              .write(const ParcelsCompanion(isActive: Value(false)));
        }
        await _database
            .into(_database.parcels)
            .insertOnConflictUpdate(
              ParcelsCompanion.insert(
                id: parcelId,
                ownerId: ownerId,
                name: name.trim(),
                locality: Value(locality?.trim()),
                polygonJson: Value(polygonJson),
                areaSquareMeters: Value(areaSquareMeters),
                isActive: Value(isActive),
                isArchived: Value(isArchived ?? existing?.isArchived ?? false),
                version: Value(nextVersion),
                syncState: const Value('pending'),
                updatedAt: now,
                deletedAt: Value(deletedAt),
              ),
            );
      },
      operation: SyncOutboxCompanion.insert(
        operationId: operationId,
        ownerId: ownerId,
        aggregateType: 'parcel',
        aggregateId: parcelId,
        mutationKind: mutationKind,
        baseVersion: Value(existing?.version),
        payloadJson: jsonEncode(payload),
        requestHash: Value(
          syncRequestHash(
            aggregateType: 'parcel',
            aggregateId: parcelId,
            mutationKind: mutationKind,
            baseVersion: existing?.version,
            payload: payload,
          ),
        ),
        createdAt: now,
      ),
    );
    return parcelId;
  }

  Future<void> archive({
    required String ownerId,
    required String id,
    required bool archived,
  }) async {
    final row = await (_database.select(
      _database.parcels,
    )..where((parcel) => parcel.id.equals(id))).getSingle();
    if (row.ownerId != ownerId) throw StateError('parcel_owner_mismatch');
    await save(
      ownerId: ownerId,
      id: id,
      name: row.name,
      locality: row.locality,
      isActive: archived ? false : row.isActive,
      isArchived: archived,
    );
    if (archived && row.isActive) {
      final alternatives =
          await (_database.select(_database.parcels)
                ..where(
                  (parcel) =>
                      parcel.ownerId.equals(ownerId) &
                      parcel.id.equals(id).not() &
                      parcel.isArchived.equals(false) &
                      parcel.deletedAt.isNull(),
                )
                ..orderBy([(parcel) => OrderingTerm.asc(parcel.name)]))
              .get();
      if (alternatives.isNotEmpty) {
        final next = alternatives.first;
        await save(
          ownerId: ownerId,
          id: next.id,
          name: next.name,
          locality: next.locality,
          isActive: true,
          isArchived: false,
        );
      }
    }
  }

  Future<bool> deleteIfEmpty({
    required String ownerId,
    required String id,
  }) async {
    final dependencies = await (_database.select(
      _database.sectors,
    )..where((sector) => sector.parcelId.equals(id))).get();
    if (dependencies.isNotEmpty) return false;
    final row =
        await (_database.select(_database.parcels)..where(
              (parcel) => parcel.id.equals(id) & parcel.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    if (row == null) return false;
    await save(
      ownerId: ownerId,
      id: id,
      name: row.name,
      locality: row.locality,
      isActive: false,
      isArchived: true,
      deletedAt: DateTime.now().toUtc(),
    );
    return true;
  }
}
