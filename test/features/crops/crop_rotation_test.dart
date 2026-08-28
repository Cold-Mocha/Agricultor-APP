import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/crops/data/crop_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test(
    'planned rotations cannot overlap and do not activate automatically',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      await database
          .into(database.parcels)
          .insert(
            ParcelsCompanion.insert(
              id: 'parcel-1',
              ownerId: 'owner-1',
              name: 'Campo',
              updatedAt: DateTime.utc(2026),
            ),
          );
      await database
          .into(database.sectors)
          .insert(
            SectorsCompanion.insert(
              id: 'sector-1',
              ownerId: 'owner-1',
              parcelId: 'parcel-1',
              number: 1,
              name: 'Sector 1',
              polygonJson: '[]',
              areaSquareMeters: 100,
              updatedAt: DateTime.utc(2026),
            ),
          );
      final repository = CropRepository(database);
      await repository.planRotation(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        cropId: 'trigo',
        startsOn: DateTime.utc(2026, 9),
        endsOn: DateTime.utc(2027, 2),
      );

      await expectLater(
        repository.planRotation(
          ownerId: 'owner-1',
          sectorId: 'sector-1',
          cropId: 'maiz',
          startsOn: DateTime.utc(2026, 12),
          endsOn: DateTime.utc(2027, 3),
        ),
        throwsStateError,
      );
      expect(
        (await database.select(database.cropSeasons).getSingle()).status,
        'planned',
      );
    },
  );
}
