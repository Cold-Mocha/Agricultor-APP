import 'dart:io';

import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/territory/presentation/controllers/territory_controllers.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/territory_fixture.dart';

void main() {
  test(
    'deleting survives the detail provider being disposed mid-operation',
    () async {
      // Like the app, queries run on a background isolate, so the deletion
      // yields to the event loop where Riverpod disposes the provider.
      final directory = await Directory.systemTemp.createTemp('sector-del-');
      addTearDown(() => directory.delete(recursive: true));
      final database = AppDatabase.forTesting(
        NativeDatabase.createInBackground(File('${directory.path}/db.sqlite')),
      );
      addTearDown(database.close);
      await seedTerritoryFixture(database);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
        ],
      );
      addTearDown(container.dispose);
      final context = container.read(
        agriculturalContextControllerProvider.notifier,
      );
      await context.restore('owner-1');
      await context.selectSector('sector-1');

      // Like the detail page: read and call at once. Nothing keeps the
      // auto-disposed provider alive, so it is disposed while deleting.
      await container
          .read(sectorDetailControllerProvider('sector-1'))
          .delete('owner-1');

      final row = await database.select(database.sectors).getSingle();
      expect(row.deletedAt, isNotNull);
      expect(
        container.read(agriculturalContextControllerProvider).sectorId,
        isNull,
      );
    },
  );
}
