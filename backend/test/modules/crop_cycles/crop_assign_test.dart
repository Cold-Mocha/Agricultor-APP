import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart'
    as db;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('assign makes the crop current now and ends the previous one', () async {
    final database = createInMemoryDatabase();
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(database.close);
    addTearDown(container.dispose);
    await seedAgriculturalContextFixture(database);
    await database
        .into(database.officialCrops)
        .insert(
          db.OfficialCropsCompanion.insert(
            id: 'maiz',
            commonName: 'Maíz',
            category: 'cereal',
            colorToken: 'cropCorn',
            iconAsset: 'corn',
          ),
        );
    final crops = container.read(cropCyclesFacadeProvider);
    final options = await crops.planOptions(
      ownerId: 'owner-1',
      sectorId: 'sector-1',
    );
    final maize = options!.crops.singleWhere((crop) => crop.id == 'maiz');

    final assignmentId = await crops.assign(
      ownerId: 'owner-1',
      sectorId: 'sector-1',
      agriculturalSeasonId: options.season.id,
      crop: maize,
      effectiveFrom: DateTime.now(),
    );

    final assignments = await crops
        .watchAssignments(ownerId: 'owner-1', sectorId: 'sector-1')
        .first;
    expect(
      assignments.singleWhere((item) => item.id == assignmentId).status,
      SectorCropAssignmentStatus.active,
      reason: 'the assigned crop is current without a separate activation',
    );
    expect(
      assignments.singleWhere((item) => item.id == 'assignment-1').status,
      SectorCropAssignmentStatus.ended,
      reason: 'the previous crop keeps its history and ends',
    );
  });

  test('assign without an active season leaves no partial rows', () async {
    final database = createInMemoryDatabase();
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(database.close);
    addTearDown(container.dispose);
    await seedAgriculturalContextFixture(database, status: 'closed');
    final crops = container.read(cropCyclesFacadeProvider);
    final trigo = (await crops.watchCatalog('owner-1').first).singleWhere(
      (crop) => crop.id == 'trigo',
    );

    await expectLater(
      crops.assign(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        agriculturalSeasonId: 'season-1',
        crop: trigo,
        effectiveFrom: DateTime.now(),
      ),
      throwsStateError,
    );
    expect(
      (await database.select(database.cropSeasons).get()).map((row) => row.id),
      ['assignment-1'],
    );
  });

  test('end removes the current crop but keeps it in history', () async {
    final database = createInMemoryDatabase();
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(database.close);
    addTearDown(container.dispose);
    await seedAgriculturalContextFixture(database);
    final crops = container.read(cropCyclesFacadeProvider);

    await crops.end(
      ownerId: 'owner-1',
      assignmentId: 'assignment-1',
      effectiveAt: DateTime.now(),
    );

    final assignment =
        (await crops
                .watchAssignments(ownerId: 'owner-1', sectorId: 'sector-1')
                .first)
            .single;
    expect(assignment.status, SectorCropAssignmentStatus.ended);
    expect(assignment.effectiveTo, isNotNull);
    await expectLater(
      crops.end(
        ownerId: 'owner-1',
        assignmentId: 'assignment-1',
        effectiveAt: DateTime.now(),
      ),
      throwsStateError,
      reason: 'an ended crop cannot be removed twice',
    );
  });

  test('a crop chosen for a future season starts with that season', () async {
    final database = createInMemoryDatabase();
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(database.close);
    addTearDown(container.dispose);
    await seedAgriculturalContextFixture(database);
    final crops = container.read(cropCyclesFacadeProvider);
    final trigo = (await crops.watchCatalog('owner-1').first).singleWhere(
      (crop) => crop.id == 'trigo',
    );
    final today = DateTime.now();
    final startsOn = DateTime(today.year + 1, 3);
    final seasonId = await crops.saveSeasonByDates(
      ownerId: 'owner-1',
      sectorId: 'sector-1',
      startsOn: startsOn,
      endsOn: DateTime(today.year + 2, 2),
    );

    final assignmentId = await crops.assignCropForSeason(
      ownerId: 'owner-1',
      sectorId: 'sector-1',
      agriculturalSeasonId: seasonId,
      crop: trigo,
    );

    final assignments = await crops
        .watchAssignments(ownerId: 'owner-1', sectorId: 'sector-1')
        .first;
    final created = assignments.singleWhere((item) => item.id == assignmentId);
    expect(
      created.status,
      SectorCropAssignmentStatus.planned,
      reason: 'the crop waits for its season instead of replacing today',
    );
    final season = await crops.loadSeason(ownerId: 'owner-1', id: seasonId);
    expect(
      created.effectiveFrom,
      season!.startsOn,
      reason: 'the crop starts on the season start date',
    );
    expect(
      assignments.singleWhere((item) => item.id == 'assignment-1').status,
      SectorCropAssignmentStatus.active,
      reason: 'the current crop stays until the new season starts',
    );
  });
}
