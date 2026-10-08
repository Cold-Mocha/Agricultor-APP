import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('status follows today against the season dates', () {
    final start = DateTime(2026, 9, 1);
    final end = DateTime(2027, 3, 31);
    expect(
      AgriculturalSeason.statusFor(
        startsOn: start,
        endsOn: end,
        today: DateTime(2026, 10, 4),
      ),
      AgriculturalSeasonStatus.active,
    );
    expect(
      AgriculturalSeason.statusFor(
        startsOn: start,
        endsOn: end,
        today: DateTime(2026, 8, 31),
      ),
      AgriculturalSeasonStatus.planned,
    );
    expect(
      AgriculturalSeason.statusFor(
        startsOn: start,
        endsOn: end,
        today: DateTime(2027, 4, 1),
      ),
      AgriculturalSeasonStatus.closed,
    );
    expect(
      AgriculturalSeason.statusFor(startsOn: start, endsOn: end, today: end),
      AgriculturalSeasonStatus.active,
      reason: 'the end day still belongs to the season',
    );
  });

  test(
    'saving by dates derives status and a dated name, then moves on',
    () async {
      final database = createInMemoryDatabase();
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );
      addTearDown(database.close);
      addTearDown(container.dispose);
      await seedTerritoryFixture(database);
      final crops = container.read(cropCyclesFacadeProvider);

      final id = await crops.saveSeasonByDates(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        startsOn: DateTime(2026, 11, 1),
        endsOn: DateTime(2027, 2, 28),
        notes: 'Frutillas',
        today: DateTime(2026, 10, 4),
      );
      var season = await crops.loadSeason(ownerId: 'owner-1', id: id);
      expect(season!.status, AgriculturalSeasonStatus.planned);
      expect(season.name, 'Temporada 01/11/2026 – 28/02/2027');
      expect(season.notes, 'Frutillas');

      await crops.reconcileSeasonStatuses(
        'owner-1',
        today: DateTime(2026, 12, 1),
      );
      season = await crops.loadSeason(ownerId: 'owner-1', id: id);
      expect(season!.status, AgriculturalSeasonStatus.active);

      await crops.reconcileSeasonStatuses(
        'owner-1',
        today: DateTime(2027, 3, 1),
      );
      season = await crops.loadSeason(ownerId: 'owner-1', id: id);
      expect(season!.status, AgriculturalSeasonStatus.closed);
    },
  );
}
