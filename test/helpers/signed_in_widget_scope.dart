import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/context/presentation/agricultural_context_controller.dart';
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
