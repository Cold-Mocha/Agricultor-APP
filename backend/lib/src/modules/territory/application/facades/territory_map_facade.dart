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

/// Local geometry and location operations; map rendering follows master.md.
final class TerritoryMapFacade {
  TerritoryMapFacade._(this._database, this._location);
  final AppDatabase _database;
  final LocationGateway _location;

  Stream<List<TerritoryContextSector>> watchContextSectors({
    required String ownerId,
    required String parcelId,
  }) =>
      (_database.select(_database.sectors)
            ..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.parcelId.equals(parcelId) &
                  row.deletedAt.isNull(),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.number)]))
          .watch()
          .map(
            (rows) => rows
                .map(
                  (row) => TerritoryContextSector(
                    id: row.id,
                    parcelId: row.parcelId,
                    name: row.name,
                  ),
                )
                .toList(growable: false),
          );

  Future<TerritoryContextSector?> loadContextSector({
    required String ownerId,
    required String sectorId,
    String? parcelId,
  }) async {
    final query = _database.select(_database.sectors)
      ..where(
        (row) =>
            row.id.equals(sectorId) &
            row.ownerId.equals(ownerId) &
            row.deletedAt.isNull(),
      );
    if (parcelId != null) {
      query.where((row) => row.parcelId.equals(parcelId));
    }
    final row = await query.getSingleOrNull();
    return row == null
        ? null
        : TerritoryContextSector(
            id: row.id,
            parcelId: row.parcelId,
            name: row.name,
          );
  }

  Stream<List<MapSectorGeometry>> watchSectors({
    required String ownerId,
    required String parcelId,
  }) =>
      (_database.select(_database.sectors)..where(
            (row) =>
                row.ownerId.equals(ownerId) &
                row.parcelId.equals(parcelId) &
                row.deletedAt.isNull(),
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
    final sectors =
        await (_database.select(_database.sectors)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.parcelId.equals(input.parcelId) &
                  row.deletedAt.isNull(),
            ))
            .get();
    final matches = sectors.where((row) => row.id == input.sectorId).toList();
    final highest = sectors.fold<int>(
      0,
      (value, row) => row.number > value ? row.number : value,
    );
    final row = matches.isEmpty ? null : matches.first;
    return SectorRepository(_database).save(
      ownerId: ownerId,
      parcelId: input.parcelId,
      id: row?.id,
      number: row?.number ?? highest + 1,
      name: row?.name ?? 'Sector ${highest + 1}',
      kind: row?.kind ?? 'crop',
      polygon: input.polygon,
    );
  }

  Future<GeoPoint> locate() => _location.currentPosition();

  Future<bool> openAttribution() => launchUrl(
    Uri.parse('https://www.openstreetmap.org/copyright'),
    mode: LaunchMode.externalApplication,
  );
}
