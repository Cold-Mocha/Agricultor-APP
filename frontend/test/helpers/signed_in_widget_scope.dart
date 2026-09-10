import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

ProviderContainer signedInWidgetContainer(AppDatabase database) =>
    ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        unlockedOwnerIdProvider.overrideWithValue('owner-1'),
      ],
    );

Future<void> selectFixtureAgriculturalContext(
  ProviderContainer container,
) async {
  container.read(agriculturalContextControllerProvider);
  final controller = container.read(
    agriculturalContextControllerProvider.notifier,
  );
  await controller.restore('owner-1');
  await controller.selectParcel('parcel-1');
  await controller.selectSector('sector-1');
  await controller.selectSeason('season-1');
  await controller.selectAssignment('assignment-1');
}
