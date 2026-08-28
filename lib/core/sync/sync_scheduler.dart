import 'dart:ui';

import 'package:agrocampo/core/auth/secure_session_store.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/network/runtime_config.dart';
import 'package:agrocampo/core/sync/protocol/supabase_sync_gateway.dart';
import 'package:agrocampo/core/sync/sync_coordinator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

abstract interface class SyncScheduler {
  Future<void> initialize();
  Future<void> schedule({required String ownerId});
}

@pragma('vm:entry-point')
void syncWorkerDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != WorkManagerSyncScheduler.taskName ||
        inputData?['ownerId'] is! String) {
      return false;
    }
    DartPluginRegistrant.ensureInitialized();
    final config = RuntimeConfig.fromCompileTime();
    if (!config.hasSupabase) {
      return true;
    }
    final store = SecureSessionStore(const FlutterSecureStorage());
    final refreshToken = await store.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }
    final database = AppDatabase();
    try {
      final client = SupabaseClient(
        config.supabaseUrl,
        config.supabasePublishableKey,
      );
      await client.auth.setSession(refreshToken);
      await SyncCoordinator(
        database,
        SupabaseSyncGateway(client),
      ).synchronize(inputData!['ownerId']! as String);
      return true;
    } on Object {
      return false;
    } finally {
      await database.close();
    }
  });
}

final class WorkManagerSyncScheduler implements SyncScheduler {
  WorkManagerSyncScheduler([Workmanager? workmanager])
    : _workmanager = workmanager ?? Workmanager();

  static const taskName = 'agrocampo.sync.owner.v1';
  final Workmanager _workmanager;

  @override
  Future<void> initialize() => _workmanager.initialize(syncWorkerDispatcher);

  @override
  Future<void> schedule({required String ownerId}) =>
      _workmanager.registerOneOffTask(
        '$taskName.$ownerId',
        taskName,
        inputData: {'ownerId': ownerId},
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingWorkPolicy.keep,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(seconds: 30),
      );
}
