import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/in_memory_database.dart';
import '../helpers/territory_fixture.dart';

void main() {
  test('context options expose labels and preserve owner filters', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedTerritoryFixture(database);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    final controller = container.read(contextOptionsQueriesProvider);
    final options = await controller.watchSectors('owner-1').first;
    expect(options.single, isA<ContextOption>());
    expect(options.single.name, 'Sector 1');
    expect(await controller.watchSectors('owner-2').first, isEmpty);
  });
}
