import 'package:agrocampo_backend/src/composition/sync_codec_composition.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_coordinator.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_gateway.dart';

SyncCoordinator createTestSyncCoordinator(
  AppDatabase database,
  SyncGateway gateway,
) =>
    SyncCoordinator(database, gateway, registry: createAgroCampoSyncRegistry());
