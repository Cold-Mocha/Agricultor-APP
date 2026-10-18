import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'first crop of a new quadrant opens its season and becomes current',
    () async {
      final database = createInMemoryDatabase();
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );
      addTearDown(database.close);
      addTearDown(container.dispose);
      await seedTerritoryFixture(database);
      final crops = container.read(cropCyclesFacadeProvider);

      final catalog = await crops.availableCrops('owner-1');
      expect(catalog, isNotEmpty, reason: 'the official catalog is seeded');

      final now = DateTime.now();
      await crops.assignInitialCrop(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        crop: catalog.first,
        effectiveFrom: now,
      );

      final seasons = await database.select(database.agriculturalSeasons).get();
      expect(seasons, hasLength(1));
      expect(seasons.single.sectorId, 'sector-1');
      expect(seasons.single.status, 'active');
      expect(seasons.single.name, 'Temporada ${now.year}');
      final assignment = await (database.select(
        database.cropSeasons,
      )..where((row) => row.sectorId.equals('sector-1'))).getSingle();
      expect(assignment.cropId, catalog.first.id);
      expect(assignment.status, 'active');
      expect(assignment.agriculturalSeasonId, seasons.single.id);
    },
  );

  test('an existing active season is reused instead of duplicated', () async {
    final database = createInMemoryDatabase();
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(database.close);
    addTearDown(container.dispose);
    await seedAgriculturalContextFixture(database);
    final crops = container.read(cropCyclesFacadeProvider);
    final catalog = await crops.availableCrops('owner-1');

    await crops.assignInitialCrop(
      ownerId: 'owner-1',
      sectorId: 'sector-1',
      crop: catalog.firstWhere((crop) => crop.id != 'trigo'),
    );

    final seasons = await database.select(database.agriculturalSeasons).get();
    expect(seasons.map((row) => row.id), ['season-1']);
  });
}
