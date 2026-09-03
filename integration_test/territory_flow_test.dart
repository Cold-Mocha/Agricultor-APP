import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/features/map/domain/sector_geometry_draft.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:agrocampo/features/sectors/data/sector_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/file_backed_database.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('multiple territory and confirmed geometry survive real reopen', (
    tester,
  ) async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);
    var database = fixture.open();
    final parcels = <String>[];
    for (var parcelIndex = 0; parcelIndex < 3; parcelIndex++) {
      final parcelId = await ParcelRepository(database).save(
        ownerId: 'owner-1',
        name: 'Campo ${parcelIndex + 1}',
        isActive: parcelIndex == 0,
      );
      parcels.add(parcelId);
      for (var sectorIndex = 0; sectorIndex < 3; sectorIndex++) {
        final offset = sectorIndex * .002;
        await SectorRepository(database).save(
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
    expect(draft.isDirty, isFalse);
    expect(draft.confirm(), hasLength(3));

    await database.close();
    database = fixture.open();
    addTearDown(database.close);
    expect(await database.select(database.parcels).get(), hasLength(3));
    expect(await database.select(database.sectors).get(), hasLength(9));
    final reopened = await (database.select(
      database.sectors,
    )..where((row) => row.id.equals(original.id))).getSingle();
    expect(reopened.polygonJson, original.polygonJson);
    expect(
      await (database.select(
        database.syncOutbox,
      )..where((row) => row.aggregateType.equals('sector'))).get(),
      hasLength(9),
    );
  });
}
