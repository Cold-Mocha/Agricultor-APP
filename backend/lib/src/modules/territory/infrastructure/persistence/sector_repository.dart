import 'dart:convert';

import 'package:agrocampo_backend/src/modules/territory/domain/entities/sector.dart'
    as domain;
import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/polygon_geometry.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_request_hash.dart';
import 'package:agrocampo_backend/src/shared/kernel/entity_id.dart';
import 'package:drift/drift.dart';

final class SectorRepository {
  SectorRepository(this._database);

  final AppDatabase _database;

  Stream<List<domain.Sector>> watchAll(String ownerId) =>
      (_database.select(_database.sectors)
            ..where(
              (row) => row.ownerId.equals(ownerId) & row.deletedAt.isNull(),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.number)]))
          .watch()
          .map((rows) => rows.map(_toDomain).toList(growable: false));

  /// Watches one sector without exposing Drift rows to the presentation layer.
  Stream<domain.Sector?> watchById({
    required String ownerId,
    required String sectorId,
  }) =>
      (_database.select(_database.sectors)..where(
            (row) =>
                row.ownerId.equals(ownerId) &
                row.id.equals(sectorId) &
                row.deletedAt.isNull(),
          ))
          .watch()
          .map((rows) => rows.isEmpty ? null : _toDomain(rows.first));

  Future<domain.Sector?> loadById({
    required String ownerId,
    required String sectorId,
  }) async {
    final row =
        await (_database.select(_database.sectors)..where(
              (item) =>
                  item.ownerId.equals(ownerId) &
                  item.id.equals(sectorId) &
                  item.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  domain.Sector _toDomain(Sector row) => domain.Sector(
    id: row.id,
    ownerId: row.ownerId,
    number: row.number,
    name: row.name,
    kind: row.kind,
    polygon: _decodePolygon(row.polygonJson),
    areaSquareMeters: row.areaSquareMeters,
    version: row.version,
    syncState: row.syncState,
    deletedAt: row.deletedAt,
  );

  Future<String> save({
    required String ownerId,
    required int number,
    required String name,
    required List<GeoPoint> polygon,
    String kind = 'crop',
    String? id,
    int? expectedVersion,
  }) => _database.transaction(() async {
    if (number < 1) throw ArgumentError.value(number, 'number');
    if (kind != 'crop' && kind != 'apiary' && kind != 'legacyUnknown') {
      throw ArgumentError.value(kind, 'kind', 'sector_kind_invalid');
    }
    final normalizedPolygon = PolygonGeometry.normalize(polygon);
    final geometryError = PolygonGeometry.validationError(normalizedPolygon);
    if (geometryError != null) {
      throw ArgumentError.value(polygon, 'polygon', geometryError);
    }
    final sectorId = id ?? EntityId.generate().value;
    final now = DateTime.now().toUtc();
    final existing = id == null
        ? null
        : await (_database.select(_database.sectors)..where(
                (row) => row.id.equals(id) & row.ownerId.equals(ownerId),
              ))
              .getSingleOrNull();
    if (id != null && existing == null) throw StateError('sector_not_found');
    if (existing?.deletedAt != null) throw StateError('sector_retired');
    if (existing != null && existing.number != number) {
      throw StateError('sector_number_immutable');
    }
    // Older v13 data may already share a number with a tombstone. Preserve
    // edits to that existing identity, while prohibiting any new reuse.
    if (existing == null) {
      final reserved =
          await (_database.select(_database.sectors)..where(
                (row) =>
                    row.ownerId.equals(ownerId) & row.number.equals(number),
              ))
              .get();
      if (reserved.isNotEmpty) throw StateError('sector_number_reserved');
    }
    if (existing != null && existing.kind != kind) {
      throw StateError('sector_kind_immutable');
    }
    if (existing != null &&
        expectedVersion != null &&
        existing.version != expectedVersion) {
      throw StateError('sector_stale_version');
    }
    final nextVersion = (existing?.version ?? 0) + 1;
    final polygonJson = jsonEncode(
      normalizedPolygon.map((point) => point.toJson()).toList(growable: false),
    );
    final area = PolygonGeometry.areaSquareMeters(normalizedPolygon);
    final payload = jsonEncode({
      'id': sectorId,
      'owner_id': ownerId,
      'number': number,
      'name': name.trim(),
      'kind': kind,
      'polygon': jsonDecode(polygonJson),
      'area_square_meters': area,
      'version': nextVersion,
      'updated_at': now.toIso8601String(),
      'deleted_at': null,
    });
    final operationId = EntityId.generate().value;
    final mutationKind = existing == null ? 'create' : 'update';
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () => _database
          .into(_database.sectors)
          .insertOnConflictUpdate(
            SectorsCompanion.insert(
              id: sectorId,
              ownerId: ownerId,
              number: number,
              name: name.trim(),
              kind: Value(kind),
              polygonJson: polygonJson,
              areaSquareMeters: area,
              version: Value(nextVersion),
              syncState: const Value('pending'),
              updatedAt: now,
            ),
          ),
      operation: SyncOutboxCompanion.insert(
        operationId: operationId,
        ownerId: ownerId,
        aggregateType: 'sector',
        aggregateId: sectorId,
        mutationKind: mutationKind,
        baseVersion: Value(existing?.version),
        payloadJson: payload,
        requestHash: Value(
          syncRequestHash(
            aggregateType: 'sector',
            aggregateId: sectorId,
            mutationKind: mutationKind,
            baseVersion: existing?.version,
            payload: jsonDecode(payload) as Map<String, Object?>,
          ),
        ),
        createdAt: now,
      ),
    );
    return sectorId;
  });

  /// Explicit command. Callers must supply the immutable category and the
  /// version they edited; `save` remains for existing fixtures.
  Future<String> saveConfirmed({
    required String ownerId,
    required int number,
    required String name,
    required String kind,
    required List<GeoPoint> polygon,
    String? id,
    int? expectedVersion,
  }) => save(
    ownerId: ownerId,
    number: number,
    name: name,
    kind: kind,
    polygon: polygon,
    id: id,
    expectedVersion: expectedVersion,
  );

  Future<void> archive({required String ownerId, required String id}) async {
    final row =
        await (_database.select(_database.sectors)..where(
              (sector) => sector.id.equals(id) & sector.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    if (row == null) throw StateError('sector_not_found');
    await _tombstone(row, mutationKind: 'archive');
  }

  Future<void> delete({required String ownerId, required String id}) async {
    final row =
        await (_database.select(_database.sectors)..where(
              (sector) => sector.id.equals(id) & sector.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    if (row == null) return;
    await _tombstone(row, mutationKind: 'delete');
  }

  Future<void> _tombstone(Sector row, {required String mutationKind}) async {
    final now = DateTime.now().toUtc();
    final nextVersion = row.version + 1;
    final payload = <String, Object?>{
      'id': row.id,
      'owner_id': row.ownerId,
      'number': row.number,
      'name': row.name,
      'kind': row.kind,
      'polygon': jsonDecode(row.polygonJson),
      'area_square_meters': row.areaSquareMeters,
      'version': nextVersion,
      'updated_at': now.toIso8601String(),
      'deleted_at': now.toIso8601String(),
    };
    final operationId = EntityId.generate().value;
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () =>
          (_database.update(
            _database.sectors,
          )..where((sector) => sector.id.equals(row.id))).write(
            SectorsCompanion(
              version: Value(nextVersion),
              syncState: const Value('pending'),
              updatedAt: Value(now),
              deletedAt: Value(now),
            ),
          ),
      operation: SyncOutboxCompanion.insert(
        operationId: operationId,
        ownerId: row.ownerId,
        aggregateType: 'sector',
        aggregateId: row.id,
        mutationKind: mutationKind,
        baseVersion: Value(row.version),
        payloadJson: jsonEncode(payload),
        requestHash: Value(
          syncRequestHash(
            aggregateType: 'sector',
            aggregateId: row.id,
            mutationKind: mutationKind,
            baseVersion: row.version,
            payload: payload,
          ),
        ),
        createdAt: now,
      ),
    );
  }

  List<GeoPoint> _decodePolygon(String source) =>
      (jsonDecode(source) as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(
            (point) => GeoPoint(
              (point['lat'] as num).toDouble(),
              (point['lng'] as num).toDouble(),
            ),
          )
          .toList(growable: false);
}
