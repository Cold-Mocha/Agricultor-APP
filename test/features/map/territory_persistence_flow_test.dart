import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/features/map/domain/sector_geometry_draft.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:agrocampo/features/sectors/data/sector_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/file_backed_database.dart';

void main() {
  test(
    '30 confirmed geometries survive five file reopen cycles unchanged',
    () async {
      final fixture = await FileBackedDatabaseFixture.create();
      addTearDown(fixture.dispose);
      var database = fixture.open();
      addTearDown(() => database.close());
      final parcels = <String>[];
      final expectedGeometryBySector = <String, String>{};

      for (var parcelIndex = 0; parcelIndex < 3; parcelIndex++) {
        final parcelId = await ParcelRepository(database).save(
          ownerId: 'owner-1',
          name: 'Campo ${parcelIndex + 1}',
          isActive: parcelIndex == 0,
        );
        parcels.add(parcelId);
        for (var sectorIndex = 0; sectorIndex < 10; sectorIndex++) {
          final offset = parcelIndex * .03 + sectorIndex * .002;
          final sectorId = await SectorRepository(database).save(
            ownerId: 'owner-1',
            parcelId: parcelId,
            number: sectorIndex + 1,
            name: 'Sector ${sectorIndex + 1}',
            polygon: [
              GeoPoint(-38.74 + offset, -72.60),
              GeoPoint(-38.74 + offset, -72.59),
              GeoPoint(-38.739 + offset, -72.59),
            ],
          );
          expectedGeometryBySector[sectorId] = (await (database.select(
            database.sectors,
          )..where((row) => row.id.equals(sectorId))).getSingle()).polygonJson;
        }
      }

      final originalRows = await (database.select(
        database.sectors,
      )..where((row) => row.parcelId.equals(parcels.first))).get();
      final original = originalRows.first;
      final draft = SectorGeometryDraft(const [
        GeoPoint(-38.74, -72.60),
        GeoPoint(-38.74, -72.59),
        GeoPoint(-38.73, -72.59),
      ]);
      draft.add(const GeoPoint(-38.73, -72.60));
      draft.cancel();
      expect(draft.confirm(), hasLength(3));

      for (var reopen = 1; reopen <= 5; reopen++) {
        await database.close();
        database = fixture.open();
        expect(await database.select(database.parcels).get(), hasLength(3));
        final reopenedSectors = await database.select(database.sectors).get();
        expect(reopenedSectors, hasLength(30));
        for (final sector in reopenedSectors) {
          expect(
            sector.polygonJson,
            expectedGeometryBySector[sector.id],
            reason: 'La geometría ${sector.id} cambió en reapertura $reopen',
          );
        }
      }
      final reopened = await (database.select(
        database.sectors,
      )..where((row) => row.id.equals(original.id))).getSingle();
      expect(reopened.polygonJson, original.polygonJson);
      expect(
        await (database.select(
          database.syncOutbox,
        )..where((row) => row.aggregateType.equals('sector'))).get(),
        hasLength(30),
      );
    },
  );
}
