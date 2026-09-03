import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:agrocampo/features/sectors/data/sector_repository.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/file_backed_database.dart';
import '../../helpers/in_memory_database.dart';

void main() {
  test('sector numbers are unique per parcel', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final parcelId = await ParcelRepository(database)
        .save(ownerId: 'owner-1', name: 'Campo');
    const polygon = [
      GeoPoint(-38.74, -72.60),
      GeoPoint(-38.74, -72.59),
      GeoPoint(-38.73, -72.59),
    ];
    final repository = SectorRepository(database);
    await repository.save(
      ownerId: 'owner-1',
      parcelId: parcelId,
      number: 1,
      name: 'Sector 1',
      polygon: polygon,
    );

    await expectLater(
      repository.save(
        ownerId: 'owner-1',
        parcelId: parcelId,
        number: 1,
        name: 'Duplicado',
        polygon: polygon,
      ),
      throwsA(anything),
    );
  });

  test('persists multiple sectors, versions geometry and creates outbox dependency', () async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);
    var database = fixture.open();
    final parcelId = await ParcelRepository(database).save(
      ownerId: 'owner-1',
      name: 'Campo persistente',
      boundary: const [
        GeoPoint(-38.75, -72.61),
        GeoPoint(-38.75, -72.57),
        GeoPoint(-38.71, -72.57),
        GeoPoint(-38.71, -72.61),
      ],
    );
    final repository = SectorRepository(database);
    final sectorId = await repository.save(
      ownerId: 'owner-1',
      parcelId: parcelId,
      number: 1,
      name: 'Norte',
      polygon: const [
        GeoPoint(-38.74, -72.60),
        GeoPoint(-38.74, -72.59),
        GeoPoint(-38.73, -72.59),
      ],
    );
    await repository.save(
      ownerId: 'owner-1',
      parcelId: parcelId,
      number: 2,
      name: 'Sur',
      polygon: const [
        GeoPoint(-38.73, -72.60),
        GeoPoint(-38.73, -72.59),
        GeoPoint(-38.72, -72.59),
      ],
    );
    await repository.save(
      ownerId: 'owner-1',
      parcelId: parcelId,
      id: sectorId,
      number: 1,
      name: 'Norte editado',
      polygon: const [
        GeoPoint(-38.741, -72.601),
        GeoPoint(-38.741, -72.590),
        GeoPoint(-38.731, -72.590),
      ],
    );
    await database.close();
    database = fixture.open();
    addTearDown(database.close);

    final sectors =
        await (database.select(database.sectors)..where(
              (row) => row.parcelId.equals(parcelId) & row.deletedAt.isNull(),
            ))
            .get();
    expect(sectors, hasLength(2));
    expect(sectors.singleWhere((row) => row.id == sectorId).version, 2);
    final childOperations = await (database.select(
      database.syncOutbox,
    )..where((row) => row.aggregateType.equals('sector'))).get();
    expect(childOperations, hasLength(3));
    expect(childOperations.first.dependencyOperationId, isNotNull);
  });

  test(
    'rejects archived/foreign parent and rolls back sector plus outbox',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      final parcelId = await ParcelRepository(database)
          .save(ownerId: 'owner-1', name: 'Campo');
      await expectLater(
        SectorRepository(database).save(
          ownerId: 'owner-2',
          parcelId: parcelId,
          number: 1,
          name: 'Ajeno',
          polygon: const [
            GeoPoint(-38.74, -72.60),
            GeoPoint(-38.74, -72.59),
            GeoPoint(-38.73, -72.59),
          ],
        ),
        throwsStateError,
      );
      expect(await database.select(database.sectors).get(), isEmpty);
      expect(
        await (database.select(
          database.syncOutbox,
        )..where((row) => row.aggregateType.equals('sector'))).get(),
        isEmpty,
      );
    },
  );
}
