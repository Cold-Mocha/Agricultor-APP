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
