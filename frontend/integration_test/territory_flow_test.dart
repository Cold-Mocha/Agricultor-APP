import 'package:agrocampo_backend/src/modules/territory/domain/entities/sector_geometry_draft.dart';
import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../backend/test/helpers/file_backed_database.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('multiple territory and confirmed geometry survive real reopen', (
    tester,
  ) async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);
    var database = fixture.open();
    for (var groupIndex = 0; groupIndex < 3; groupIndex++) {
      for (var sectorIndex = 0; sectorIndex < 3; sectorIndex++) {
        final offset = groupIndex * .01 + sectorIndex * .002;
        final number = groupIndex * 3 + sectorIndex + 1;
        await SectorRepository(database).save(
          ownerId: 'owner-1',
          number: number,
          name: 'Sector $number',
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
    )..where((row) => row.ownerId.equals('owner-1'))).get();
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
