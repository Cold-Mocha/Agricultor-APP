import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/parcel_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';

void main() {
  test(
    'restores only valid owner context and clears archived parent children',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      final repository = ParcelRepository(database);
      final first = await repository.save(
        ownerId: 'owner-1',
        name: 'Los Robles',
        isActive: true,
      );
      final second = await repository.save(
        ownerId: 'owner-1',
        name: 'Los Robles',
      );
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
        container.read(agriculturalContextControllerProvider).parcelId,
        first,
      );

      await controller.selectParcel(second);
      await repository.archive(ownerId: 'owner-1', id: second, archived: true);
      await controller.restore('owner-1');
      final restored = container.read(agriculturalContextControllerProvider);
      expect(restored.parcelId, first);
      expect(restored.sectorId, isNull);
    },
  );
}
