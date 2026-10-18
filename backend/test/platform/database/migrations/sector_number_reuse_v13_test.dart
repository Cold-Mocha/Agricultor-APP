import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/database/sector_number_reuse_v12.dart';
import '../../../helpers/file_backed_database.dart';

void main() {
  test(
    'upgrading from v12 preserves sectors and frees deleted numbers for reuse',
    () async {
      final fixture = await FileBackedDatabaseFixture.create();
      addTearDown(fixture.dispose);
      await createV12WithDeletedSectorNumber(fixture.databaseFile);

      final database = fixture.open();
      addTearDown(database.close);

      final version = await database
          .customSelect('PRAGMA user_version')
          .map((row) => row.read<int>('user_version'))
          .getSingle();
      expect(version, 13);

      final rows = await database.select(database.sectors).get();
      expect(rows, hasLength(2), reason: 'the upgrade must not drop data');
      final deleted = rows.singleWhere((row) => row.id == 'sector-deleted');
      expect(deleted.deletedAt, isNotNull);
      expect(deleted.number, 1);

      // This is the reported bug: renaming the active sector to the number
      // a deleted sector still holds used to throw a UNIQUE violation.
      await SectorRepository(database).save(
        ownerId: 'owner-1',
        id: 'sector-active',
        number: 1,
        name: 'Cuadrante 10',
        polygon: const [
          GeoPoint(-38.74, -72.60),
          GeoPoint(-38.74, -72.59),
          GeoPoint(-38.73, -72.59),
        ],
        expectedVersion: 1,
      );

      final renamed = await (database.select(
        database.sectors,
      )..where((row) => row.id.equals('sector-active'))).getSingle();
      expect(renamed.number, 1);
    },
  );

  test(
    'two active sectors still cannot share a number after the upgrade',
    () async {
      final fixture = await FileBackedDatabaseFixture.create();
      addTearDown(fixture.dispose);
      await createV12WithDeletedSectorNumber(fixture.databaseFile);

      final database = fixture.open();
      addTearDown(database.close);
      final repository = SectorRepository(database);

      // sector-active currently holds number 10; recreate the deleted sector's
      // identity as a live one at number 1 so both numbers are truly active.
      await repository.save(
        ownerId: 'owner-1',
        number: 1,
        name: 'Otro cuadrante 1',
        polygon: const [
          GeoPoint(-38.74, -72.60),
          GeoPoint(-38.74, -72.59),
          GeoPoint(-38.73, -72.59),
        ],
      );

      await expectLater(
        repository.save(
          ownerId: 'owner-1',
          id: 'sector-active',
          number: 1,
          name: 'Cuadrante 10',
          polygon: const [
            GeoPoint(-38.74, -72.60),
            GeoPoint(-38.74, -72.59),
            GeoPoint(-38.73, -72.59),
          ],
          expectedVersion: 1,
        ),
        throwsA(anything),
      );
    },
  );
}
