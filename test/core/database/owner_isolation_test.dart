import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/file_backed_database.dart';

void main() {
  test(
    'reopen exposes rows and pending work only to the requested owner',
    () async {
      final fixture = await FileBackedDatabaseFixture.create();
      addTearDown(fixture.dispose);
      var database = fixture.open();
      await ParcelRepository(database).save(ownerId: 'owner-a', name: 'A');
      await ParcelRepository(database).save(ownerId: 'owner-b', name: 'B');
      await database.close();

      database = fixture.open();
      addTearDown(database.close);
      final repository = ParcelRepository(database);
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
