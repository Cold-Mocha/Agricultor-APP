import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/core/geometry/polygon_geometry.dart';
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
    List<GeoPoint>? boundary,
  }) async {
    final parcelId = id ?? EntityId.generate().value;
    final operationId = EntityId.generate().value;
    final now = DateTime.now().toUtc();
    final existing = await (_database.select(
      _database.parcels,
    )..where((row) => row.id.equals(parcelId))).getSingleOrNull();
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
      'polygon': polygonJson == null ? null : jsonDecode(polygonJson),
      'area_square_meters': areaSquareMeters,
      'version': nextVersion,
      'updated_at': now.toIso8601String(),
    };

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
                version: Value(nextVersion),
                updatedAt: now,
              ),
            );
      },
      operation: SyncOutboxCompanion.insert(
        operationId: operationId,
        ownerId: ownerId,
        aggregateType: 'parcel',
        aggregateId: parcelId,
        mutationKind: existing == null ? 'create' : 'update',
        baseVersion: Value(existing?.version),
        payloadJson: jsonEncode(payload),
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
    await save(
      ownerId: ownerId,
      id: id,
      name: row.name,
      locality: row.locality,
      isActive: archived ? false : row.isActive,
    );
    await (_database.update(
      _database.parcels,
    )..where((parcel) => parcel.id.equals(id))).write(
      ParcelsCompanion(
        isArchived: Value(archived),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<bool> deleteIfEmpty({
    required String ownerId,
    required String id,
  }) async {
    final dependencies = await (_database.select(
      _database.sectors,
    )..where((sector) => sector.parcelId.equals(id))).get();
    if (dependencies.isNotEmpty) return false;
    await (_database.delete(_database.parcels)..where(
          (parcel) => parcel.id.equals(id) & parcel.ownerId.equals(ownerId),
        ))
        .go();
    return true;
  }
}
