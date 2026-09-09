import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/file_backed_database.dart';
import '../helpers/in_memory_database.dart';
import '../helpers/territory_fixture.dart';

void main() {
  test('public parcel save survives restart with its pending outbox', () async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);
    final database = fixture.open();
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    final id = await container
        .read(parcelFacadeProvider)
        .save(
          const ParcelFormInput(
            ownerId: 'owner-1',
            name: 'Parcela offline',
            locality: 'Chillán',
            isActive: false,
          ),
        );
    container.dispose();
    await database.close();

    final reopened = fixture.open();
    final restored = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(reopened)],
    );
    final view = await restored.read(parcelFacadeProvider).load(id);
    expect(view, isA<ParcelSummary>());
    expect(view!.name, 'Parcela offline');
    expect(view.locality, 'Chillán');
    final pending = await (reopened.select(
      reopened.syncOutbox,
    )..where((row) => row.aggregateId.equals(id))).get();
    expect(pending, hasLength(1));
    expect(pending.single.state, 'pending');
    restored.dispose();
    await reopened.close();
  });

  test(
    'context options expose labels and preserve owner/parcel filters',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      await seedTerritoryFixture(database);
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );
      addTearDown(container.dispose);
      final controller = container.read(contextOptionsQueriesProvider);
      final options = await controller
          .watchSectors('owner-1', 'parcel-1')
          .first;
      expect(options.single, isA<ContextOption>());
      expect(options.single.name, 'Sector 1');
      expect(
        await controller.watchSectors('owner-2', 'parcel-1').first,
        isEmpty,
      );
      expect(
        await controller.watchSectors('owner-1', 'another-parcel').first,
        isEmpty,
      );
    },
  );
}
