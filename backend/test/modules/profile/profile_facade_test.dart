import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
  });

  test('dark mode defaults to disabled until the owner opts in', () async {
    final facade = container.read(profileFacadeProvider);

    expect(await facade.watchDarkModeEnabled('owner-1').first, isFalse);

    await facade.setDarkModeEnabled('owner-1', true);
    expect(await facade.watchDarkModeEnabled('owner-1').first, isTrue);

    await facade.setDarkModeEnabled('owner-1', false);
    expect(await facade.watchDarkModeEnabled('owner-1').first, isFalse);
  });

  test('dark mode preference is scoped per owner', () async {
    final facade = container.read(profileFacadeProvider);

    await facade.setDarkModeEnabled('owner-1', true);

    expect(await facade.watchDarkModeEnabled('owner-1').first, isTrue);
    expect(await facade.watchDarkModeEnabled('owner-2').first, isFalse);
  });
}
