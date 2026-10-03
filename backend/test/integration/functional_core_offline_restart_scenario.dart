import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/file_backed_database.dart';

void main() {
  test(
    '100 offline mutations survive multiple close and reopen cycles',
    () async {
      final fixture = await FileBackedDatabaseFixture.create();
      addTearDown(fixture.dispose);
      var database = fixture.open();
      for (var index = 0; index < 100; index++) {
        final offset = index * .002;
        await SectorRepository(database).save(
          ownerId: 'owner-1',
          number: index + 1,
          name: 'Sector offline $index',
          polygon: [
            GeoPoint(-38.74 + offset, -72.60),
            GeoPoint(-38.74 + offset, -72.59),
            GeoPoint(-38.739 + offset, -72.59),
          ],
        );
        if (index == 33 || index == 66) {
          await database.close();
          database = fixture.open();
        }
      }
      await database.close();
      database = fixture.open();
      addTearDown(database.close);
      final sectors = await database.select(database.sectors).get();
      final outbox = await database.select(database.syncOutbox).get();
      expect(sectors, hasLength(100));
      expect(sectors.map((row) => row.id).toSet(), hasLength(100));
      expect(outbox, hasLength(100));
      expect(outbox.every((row) => row.state == 'pending'), isTrue);
      expect(
        outbox.every((row) => row.requestHash?.isNotEmpty == true),
        isTrue,
      );
    },
  );
}
