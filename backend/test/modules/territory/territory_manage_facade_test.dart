import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sector can be renamed and deleted from its detail facade', () async {
    final database = createInMemoryDatabase();
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(database.close);
    addTearDown(container.dispose);
    final sectorId = await SectorRepository(database).save(
      ownerId: 'owner-1',
      number: 1,
      name: 'Sector 1',
      polygon: const [
        GeoPoint(-38.74, -72.60),
        GeoPoint(-38.74, -72.59),
        GeoPoint(-38.73, -72.59),
      ],
    );
    final facade = container.read(sectorDetailFacadeProvider(sectorId));

    await facade.rename(ownerId: 'owner-1', name: '  Frutillas norte ');
    expect((await facade.loadSector('owner-1'))?.name, 'Frutillas norte');
    await expectLater(
      facade.rename(ownerId: 'owner-1', name: ' '),
      throwsStateError,
    );

    await facade.delete('owner-1');
    expect(
      await facade.loadSector('owner-1'),
      isNull,
      reason: 'a deleted sector disappears from the detail view',
    );
  });

  test('a new sector never reuses the number of a deleted one', () async {
    final database = createInMemoryDatabase();
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(database.close);
    addTearDown(container.dispose);
    final map = container.read(territoryMapFacadeProvider);
    const polygon = [
      GeoPoint(-38.74, -72.60),
      GeoPoint(-38.74, -72.59),
      GeoPoint(-38.73, -72.59),
    ];
    final input = MapGeometryFormInput(polygon: polygon, kind: 'crop');
    await map.saveGeometry(ownerId: 'owner-1', input: input);
    final last = await map.saveGeometry(ownerId: 'owner-1', input: input);
    await container.read(sectorDetailFacadeProvider(last)).delete('owner-1');

    final next = await map.saveGeometry(ownerId: 'owner-1', input: input);

    final created = await (database.select(
      database.sectors,
    )..where((row) => row.id.equals(next))).getSingle();
    expect(
      created.number,
      3,
      reason: 'deleted sector numbers stay reserved by the unique key',
    );
  });
}
