import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/crops/data/crop_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/file_backed_database.dart';

void main() {
  test(
    'official and custom crops coexist and custom archive survives reopen',
    () async {
      final fixture = await FileBackedDatabaseFixture.create();
      addTearDown(fixture.dispose);
      var database = fixture.open();
      await database
          .into(database.officialCrops)
          .insert(
            OfficialCropsCompanion.insert(
              id: 'maiz',
              commonName: 'Maíz',
              category: 'cereal',
              colorToken: 'cropCereal',
              iconAsset: 'assets/icons/crops/custom-crop.svg',
            ),
          );
      final repository = CropRepository(database);
      final customId = await repository.createCustom(
        ownerId: 'owner-1',
        name: 'Maíz dulce',
        notes: 'Semilla local',
      );
      await expectLater(
        repository.createCustom(ownerId: 'owner-1', name: '  MAIZ DULCE  '),
        throwsStateError,
      );
      await repository.archiveCustom(
        ownerId: 'owner-1',
        id: customId,
        archived: true,
      );
      await database.close();
      database = fixture.open();
      addTearDown(database.close);
      final catalog = await CropRepository(database)
          .watchCatalog('owner-1')
          .first;
      expect(
        catalog.map((crop) => crop.label),
        containsAll(['Maíz', 'Maíz dulce']),
      );
      expect(
        catalog.singleWhere((crop) => crop.id == customId).archived,
        isTrue,
      );
      expect(
        await (database.select(
          database.syncOutbox,
        )..where((row) => row.aggregateType.equals('customCrop'))).get(),
        hasLength(2),
      );
    },
  );
}
