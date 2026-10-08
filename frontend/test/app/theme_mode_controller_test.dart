import 'package:agrocampo/src/app/controllers/theme_mode_controller.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/profile/profile_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../backend/test/helpers/in_memory_database.dart';

void main() {
  test('stays light with no signed-in owner', () {
    final container = ProviderContainer(
      overrides: [unlockedOwnerIdProvider.overrideWithValue(null)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('follows the owner saved preference once unlocked', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        unlockedOwnerIdProvider.overrideWithValue('owner-1'),
      ],
    );
    addTearDown(container.dispose);

    final seen = <ThemeMode>[];
    container.listen(
      themeModeProvider,
      (_, next) => seen.add(next),
      fireImmediately: true,
    );
    expect(seen.single, ThemeMode.light);

    await container
        .read(profileFacadeProvider)
        .setDarkModeEnabled('owner-1', true);
    await pumpEventQueue();

    expect(seen.last, ThemeMode.dark);
  });
}
