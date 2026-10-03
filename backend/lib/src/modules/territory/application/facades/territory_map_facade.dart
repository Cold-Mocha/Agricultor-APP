import 'dart:convert';

import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/territory/contracts/dto/map_contracts.dart';
import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/location_gateway.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final territoryMapFacadeProvider = Provider<TerritoryMapFacade>(
  (ref) => TerritoryMapFacade._(
    ref.watch(appDatabaseProvider),
    GeolocatorLocationGateway(),
  ),
);

/// Local geometry and location operations.
final class TerritoryMapFacade {
  TerritoryMapFacade._(this._database, this._location);
  final AppDatabase _database;
  final LocationGateway _location;

  Stream<List<TerritoryContextSector>> watchContextSectors(String ownerId) =>
      (_database.select(_database.sectors)
            ..where(
              (row) => row.ownerId.equals(ownerId) & row.deletedAt.isNull(),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.number)]))
          .watch()
          .map(
            (rows) => rows
                .map(
                  (row) => TerritoryContextSector(
                    id: row.id,
                    name: row.name,
                    kind: row.kind,
                  ),
                )
                .toList(growable: false),
          );

  Future<TerritoryContextSector?> loadContextSector({
    required String ownerId,
    required String sectorId,
  }) async {
    final row =
        await (_database.select(_database.sectors)..where(
              (row) =>
                  row.id.equals(sectorId) &
                  row.ownerId.equals(ownerId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    return row == null
        ? null
        : TerritoryContextSector(id: row.id, name: row.name, kind: row.kind);
  }

  /// First active sector, used when no sector was remembered yet.
  Future<TerritoryContextSector?> loadFirstContextSector(String ownerId) async {
    final row =
        await (_database.select(_database.sectors)
              ..where(
                (row) => row.ownerId.equals(ownerId) & row.deletedAt.isNull(),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.number)])
              ..limit(1))
            .getSingleOrNull();
    return row == null
        ? null
        : TerritoryContextSector(id: row.id, name: row.name, kind: row.kind);
  }

  Stream<List<MapSectorGeometry>> watchSectors(String ownerId) =>
      (_database.select(_database.sectors)..where(
            (row) => row.ownerId.equals(ownerId) & row.deletedAt.isNull(),
          ))
          .watch()
          .map(
            (rows) => rows
                .map(
                  (row) => MapSectorGeometry(
                    id: row.id,
                    number: row.number,
                    name: row.name,
                    kind: row.kind,
                    polygon: (jsonDecode(row.polygonJson) as List<Object?>)
                        .cast<Map<String, Object?>>()
                        .map(
                          (point) => GeoPoint(
                            (point['lat'] as num).toDouble(),
                            (point['lng'] as num).toDouble(),
                          ),
                        )
                        .toList(growable: false),
                  ),
                )
                .toList(growable: false),
          );

  Future<String> saveGeometry({
    required String ownerId,
    required MapGeometryFormInput input,
  }) async {
    // Deleted sectors are tombstones that keep their number under the
    // (owner_id, number) unique key, so numbering must count them too.
    final sectors = await (_database.select(
      _database.sectors,
    )..where((row) => row.ownerId.equals(ownerId))).get();
    final matches = sectors
        .where((row) => row.id == input.sectorId && row.deletedAt == null)
        .toList();
    final highest = sectors.fold<int>(
      0,
      (value, row) => row.number > value ? row.number : value,
    );
    final row = matches.isEmpty ? null : matches.first;
    final kind = row?.kind ?? input.kind;
    if (kind == null) throw StateError('sector_kind_required');
    return SectorRepository(_database).saveConfirmed(
      ownerId: ownerId,
      id: row?.id,
      number: row?.number ?? highest + 1,
      name: row?.name ?? 'Sector ${highest + 1}',
      kind: kind,
      polygon: input.polygon,
      expectedVersion: input.expectedVersion ?? row?.version,
    );
  }

  Future<GeoPoint> locate() => _location.currentPosition();

  Future<bool> openAttribution() => launchUrl(
    Uri.parse('https://www.openstreetmap.org/copyright'),
    mode: LaunchMode.externalApplication,
  );
}
