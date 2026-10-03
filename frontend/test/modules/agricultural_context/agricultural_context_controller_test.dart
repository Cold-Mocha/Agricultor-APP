import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';

void main() {
  test(
    'restores a valid owner sector and falls back when it is deleted',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      final repository = SectorRepository(database);
      Future<String> save(int number) => repository.save(
        ownerId: 'owner-1',
        number: number,
        name: 'Cuadrante $number',
        polygon: [
          GeoPoint(-38.74 + number * .002, -72.60),
          GeoPoint(-38.74 + number * .002, -72.59),
          GeoPoint(-38.739 + number * .002, -72.59),
        ],
      );
      final first = await save(1);
      final second = await save(2);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(
        agriculturalContextControllerProvider.notifier,
      );
      await controller.restore('owner-1');
      expect(
        container.read(agriculturalContextControllerProvider).sectorId,
        first,
        reason: 'without a remembered sector the first one becomes active',
      );

      await controller.selectSector(second);
      await controller.restore('owner-1');
      expect(
        container.read(agriculturalContextControllerProvider).sectorId,
        second,
      );

      await repository.delete(ownerId: 'owner-1', id: second);
      await controller.restore('owner-1');
      final restored = container.read(agriculturalContextControllerProvider);
      expect(restored.sectorId, first);
      expect(restored.seasonId, isNull);
    },
  );
}
