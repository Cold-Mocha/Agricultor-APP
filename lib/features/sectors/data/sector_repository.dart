import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/core/geometry/polygon_geometry.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:drift/drift.dart';

final class SectorRepository {
  SectorRepository(this._database);

  final AppDatabase _database;

  Future<String> save({
    required String ownerId,
    required String parcelId,
    required int number,
    required String name,
    required List<GeoPoint> polygon,
    String kind = 'crop',
    String? id,
  }) async {
    if (polygon.length < 3) {
      throw ArgumentError.value(
        polygon,
        'polygon',
        'polygon_requires_three_points',
      );
    }
    final parcel = await (_database.select(
      _database.parcels,
    )..where((row) => row.id.equals(parcelId))).getSingle();
    if (parcel.ownerId != ownerId) {
      throw StateError('owner_mismatch');
    }
    if (parcel.polygonJson case final parentJson?) {
      final parent = _decodePolygon(parentJson);
      if (!PolygonGeometry.isContained(polygon, parent)) {
        throw StateError('sector_outside_parcel');
      }
    }
    final sectorId = id ?? EntityId.generate().value;
    final now = DateTime.now().toUtc();
    final polygonJson = jsonEncode(
      polygon.map((point) => point.toJson()).toList(growable: false),
    );
    final area = PolygonGeometry.areaSquareMeters(polygon);
    final payload = jsonEncode({
      'id': sectorId,
      'owner_id': ownerId,
      'parcel_id': parcelId,
      'number': number,
      'name': name.trim(),
      'kind': kind,
      'polygon': jsonDecode(polygonJson),
      'area_square_meters': area,
      'updated_at': now.toIso8601String(),
    });
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () => _database
          .into(_database.sectors)
          .insertOnConflictUpdate(
            SectorsCompanion.insert(
              id: sectorId,
              ownerId: ownerId,
              parcelId: parcelId,
              number: number,
              name: name.trim(),
              kind: Value(kind),
              polygonJson: polygonJson,
              areaSquareMeters: area,
              updatedAt: now,
            ),
          ),
      operation: SyncOutboxCompanion.insert(
        operationId: EntityId.generate().value,
        ownerId: ownerId,
        aggregateType: 'sector',
        aggregateId: sectorId,
        mutationKind: id == null ? 'create' : 'update',
        payloadJson: payload,
        createdAt: now,
      ),
    );
    return sectorId;
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
