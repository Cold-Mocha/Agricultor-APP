import 'dart:ui';

import 'package:agrocampo_backend/src/composition/sync_codec_composition.dart';
import 'package:agrocampo_backend/src/modules/auth/infrastructure/secure_session_store.dart';
import 'package:agrocampo_backend/src/modules/reminders/infrastructure/alerts/field_alert_service.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_gateway.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/network/runtime_config.dart';
import 'package:agrocampo_backend/src/platform/notifications/local_notification_scheduler.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/supabase_sync_gateway.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_coordinator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

abstract interface class SyncScheduler {
  Future<void> initialize();
  Future<void> schedule({required String ownerId});
  Future<void> cancel({required String ownerId});
}

@pragma('vm:entry-point')
void syncWorkerDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    final ownerId = inputData?['ownerId'];
    if (ownerId is! String) return false;
    DartPluginRegistrant.ensureInitialized();
    return switch (taskName) {
      WorkManagerSyncScheduler.taskName => _runSync(ownerId),
      WorkManagerFieldAlertScheduler.taskName => _runFieldAlerts(ownerId),
      _ => false,
    };
  });
}

Future<bool> _runSync(String ownerId) async {
  final config = RuntimeConfig.fromCompileTime();
  if (!config.hasSupabase) {
    return true;
  }
  final database = AppDatabase();
  try {
    final client = await _ownerClient(config, ownerId);
    if (client == null) return false;
    await SyncCoordinator(
      database,
      SupabaseSyncGateway(client),
      registry: createAgroCampoSyncRegistry(),
    ).synchronize(ownerId);
    return true;
  } on Object {
    return false;
  } finally {
    await database.close();
  }
}

/// Refreshes each quadrant's forecast when online and notifies the alerts
/// due; season alerts also work without Supabase.
Future<bool> _runFieldAlerts(String ownerId) async {
  final config = RuntimeConfig.fromCompileTime();
  final database = AppDatabase();
  try {
    final service = FieldAlertService(database);
    if (config.hasSupabase) {
      try {
        final client = await _ownerClient(config, ownerId);
        if (client == null) return false;
        await service.refreshWeather(ownerId, SupabaseWeatherGateway(client));
      } on Object {
        // Offline: the cached forecast and season dates still apply.
      }
    }
    final notices = await service.takeNewNotices(ownerId);
    if (notices.isNotEmpty) {
      await PluginLocalNotificationScheduler().initialize();
      final notifier = PluginFieldAlertNotifier();
      for (final notice in notices) {
        await notifier.show(
          id: stableNotificationId(notice.key),
          title: notice.title,
          body: notice.body,
        );
      }
    }
    return true;
  } on Object {
    return false;
  } finally {
    await database.close();
  }
}

/// Signs the stored owner in from the background, or returns null.
Future<SupabaseClient?> _ownerClient(
  RuntimeConfig config,
  String ownerId,
) async {
  final store = SecureSessionStore(const FlutterSecureStorage());
  final storedSession = await store.read();
  if (storedSession == null || storedSession.ownerId != ownerId) return null;
  final client = SupabaseClient(
    config.supabaseUrl,
    config.supabasePublishableKey,
  );
  final session = await client.auth.setSession(storedSession.refreshToken);
  if (session.user?.id != storedSession.ownerId) return null;
  // setSession rotates the refresh token; keep the new one or the app
  // would find a used token on its next start and sign the owner out.
  final rotated = session.session?.refreshToken;
  if (rotated != null && rotated.isNotEmpty) {
    await store.persist(ownerId: storedSession.ownerId, refreshToken: rotated);
  }
  return client;
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

  @override
  Future<void> cancel({required String ownerId}) =>
      _workmanager.cancelByUniqueName('$taskName.$ownerId');
}

/// Checks the field alerts every few hours, even with the app closed.
abstract interface class FieldAlertScheduler {
  Future<void> schedule({required String ownerId});
  Future<void> cancel({required String ownerId});
}

/// Used where no background work exists, such as tests.
final class NoFieldAlertScheduler implements FieldAlertScheduler {
  const NoFieldAlertScheduler();

  @override
  Future<void> schedule({required String ownerId}) async {}

  @override
  Future<void> cancel({required String ownerId}) async {}
}

final class WorkManagerFieldAlertScheduler implements FieldAlertScheduler {
  WorkManagerFieldAlertScheduler([Workmanager? workmanager])
    : _workmanager = workmanager ?? Workmanager();

  static const taskName = 'agrocampo.alerts.owner.v1';
  static const frequency = Duration(hours: 3);
  final Workmanager _workmanager;

  @override
  Future<void> schedule({required String ownerId}) =>
      _workmanager.registerPeriodicTask(
        '$taskName.$ownerId',
        taskName,
        frequency: frequency,
        inputData: {'ownerId': ownerId},
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 5),
      );

  @override
  Future<void> cancel({required String ownerId}) =>
      _workmanager.cancelByUniqueName('$taskName.$ownerId');
}
