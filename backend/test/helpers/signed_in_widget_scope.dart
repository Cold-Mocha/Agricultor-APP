import 'package:agrocampo_backend/core/config/backend_providers.dart';
import 'package:agrocampo_backend/core/database/app_database.dart';
import 'package:agrocampo_backend/features/auth/controllers/session_controller.dart';
import 'package:agrocampo_backend/features/context/controllers/agricultural_context_controller.dart';
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
