import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/crops/data/agricultural_season_repository.dart';
import 'package:agrocampo/features/crops/domain/agricultural_season.dart'
    as domain;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('season validates ranges and irreversible closed transition', () {
    expect(
      () => domain.AgriculturalSeason.validate(
        name: '2026-27',
        startsOn: DateTime.utc(2026, 9),
        endsOn: DateTime.utc(2026, 8),
        status: domain.AgriculturalSeasonStatus.planned,
      ),
      throwsArgumentError,
    );
    expect(
      domain.AgriculturalSeason.canTransition(
        domain.AgriculturalSeasonStatus.closed,
        domain.AgriculturalSeasonStatus.active,
      ),
      isFalse,
    );
  });

  test(
    'only one active season exists per parcel and every save has outbox',
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
      final repository = AgriculturalSeasonRepository(database);
      await repository.save(
        ownerId: 'owner-1',
        parcelId: 'parcel-1',
        name: 'Temporada 2026',
        startsOn: DateTime.utc(2026, 8),
        status: domain.AgriculturalSeasonStatus.active,
      );
      await expectLater(
        repository.save(
          ownerId: 'owner-1',
          parcelId: 'parcel-1',
          name: 'Temporada alternativa',
          startsOn: DateTime.utc(2026, 9),
          status: domain.AgriculturalSeasonStatus.active,
        ),
        throwsStateError,
      );
      expect(
        await database.select(database.agriculturalSeasons).get(),
        hasLength(1),
      );
      expect(
        (await database.select(database.syncOutbox).getSingle()).aggregateType,
        'agriculturalSeason',
      );
    },
  );
}
