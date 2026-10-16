import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/file_backed_database.dart';
import '../../helpers/in_memory_database.dart';

void main() {
  test('sector numbers are unique per owner', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    const polygon = [
      GeoPoint(-38.74, -72.60),
      GeoPoint(-38.74, -72.59),
      GeoPoint(-38.73, -72.59),
    ];
    final repository = SectorRepository(database);
    await repository.save(
      ownerId: 'owner-1',
      number: 1,
      name: 'Sector 1',
      polygon: polygon,
    );

    await expectLater(
      repository.save(
        ownerId: 'owner-1',
        number: 1,
        name: 'Duplicado',
        polygon: polygon,
      ),
      throwsA(anything),
    );
    await repository.save(
      ownerId: 'owner-2',
      number: 1,
      name: 'Otro agricultor',
      polygon: polygon,
    );
  });

  test(
    'a deleted sector frees its number for another sector to reuse',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      const polygon = [
        GeoPoint(-38.74, -72.60),
        GeoPoint(-38.74, -72.59),
        GeoPoint(-38.73, -72.59),
      ];
      final repository = SectorRepository(database);
      final deletedId = await repository.save(
        ownerId: 'owner-1',
        number: 1,
        name: 'Cuadrante 1 original',
        polygon: polygon,
      );
      final renumberedId = await repository.save(
        ownerId: 'owner-1',
        number: 10,
        name: 'Cuadrante 10',
        polygon: polygon,
      );
      await repository.delete(ownerId: 'owner-1', id: deletedId);

      // Renaming cuadrante 10 to 1 must not fail with the deleted sector's
      // old UNIQUE(owner_id, number) row still occupying that number.
      await repository.save(
        ownerId: 'owner-1',
        id: renumberedId,
        number: 1,
        name: 'Cuadrante 10',
        polygon: polygon,
        expectedVersion: 1,
      );

      final active = await repository.loadById(
        ownerId: 'owner-1',
        sectorId: renumberedId,
      );
      expect(active?.number, 1);
      final deleted = await (database.select(
        database.sectors,
      )..where((row) => row.id.equals(deletedId))).getSingle();
      expect(deleted.deletedAt, isNotNull);
      expect(deleted.number, 1, reason: 'the tombstoned row keeps its number');
    },
  );

  test('persists multiple sectors and versions geometry', () async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);
    var database = fixture.open();
    final repository = SectorRepository(database);
    final sectorId = await repository.save(
      ownerId: 'owner-1',
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
              (row) => row.ownerId.equals('owner-1') & row.deletedAt.isNull(),
            ))
            .get();
    expect(sectors, hasLength(2));
    expect(sectors.singleWhere((row) => row.id == sectorId).version, 2);
    final childOperations = await (database.select(
      database.syncOutbox,
    )..where((row) => row.aggregateType.equals('sector'))).get();
    expect(childOperations, hasLength(3));
    expect(childOperations.first.dependencyOperationId, isNull);
  });

  test('rejects invalid geometry and rolls back sector plus outbox', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await expectLater(
      SectorRepository(database).save(
        ownerId: 'owner-2',
        number: 1,
        name: 'Inválido',
        polygon: const [GeoPoint(-38.74, -72.60), GeoPoint(-38.74, -72.59)],
      ),
      throwsArgumentError,
    );
    expect(await database.select(database.sectors).get(), isEmpty);
    expect(
      await (database.select(
        database.syncOutbox,
      )..where((row) => row.aggregateType.equals('sector'))).get(),
      isEmpty,
    );
  });
}
