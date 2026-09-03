import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
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
        await ParcelRepository(database).save(
          ownerId: 'owner-1',
          id: 'offline-parcel-$index',
          name: 'Parcela offline $index',
          isActive: index == 0,
        );
        if (index == 33 || index == 66) {
          await database.close();
          database = fixture.open();
        }
      }
      await database.close();
      database = fixture.open();
      addTearDown(database.close);
      final parcels = await database.select(database.parcels).get();
      final outbox = await database.select(database.syncOutbox).get();
      expect(parcels, hasLength(100));
      expect(parcels.map((row) => row.id).toSet(), hasLength(100));
      expect(outbox, hasLength(100));
      expect(outbox.every((row) => row.state == 'pending'), isTrue);
      expect(
        outbox.every((row) => row.requestHash?.isNotEmpty == true),
        isTrue,
      );
    },
  );
}
