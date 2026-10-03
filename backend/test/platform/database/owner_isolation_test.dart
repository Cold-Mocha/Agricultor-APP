import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/file_backed_database.dart';

const _triangle = [
  GeoPoint(-38.74, -72.60),
  GeoPoint(-38.74, -72.59),
  GeoPoint(-38.73, -72.59),
];

void main() {
  test(
    'reopen exposes rows and pending work only to the requested owner',
    () async {
      final fixture = await FileBackedDatabaseFixture.create();
      addTearDown(fixture.dispose);
      var database = fixture.open();
      for (final owner in const ['owner-a', 'owner-b']) {
        await SectorRepository(database).save(
          ownerId: owner,
          number: 1,
          name: owner == 'owner-a' ? 'A' : 'B',
          polygon: _triangle,
        );
      }
      await database.close();

      database = fixture.open();
      addTearDown(database.close);
      final repository = SectorRepository(database);
      expect(
        (await repository.watchAll('owner-a').first).map((row) => row.name),
        ['A'],
      );
      expect(
        (await repository.watchAll('owner-b').first).map((row) => row.name),
        ['B'],
      );
      expect(
        (await database.syncOutboxDao.eligibleBatch('owner-a'))
            .every((row) => row.ownerId == 'owner-a'),
        isTrue,
      );
      expect(
        (await database.syncOutboxDao.eligibleBatch('owner-b'))
            .every((row) => row.ownerId == 'owner-b'),
        isTrue,
      );
    },
  );
}
