import 'package:agrocampo_backend/core/auth/biometric_unlock_gateway.dart';
import 'package:agrocampo_backend/core/database/app_database.dart';
import 'package:agrocampo_backend/core/network/connectivity_service.dart';
import 'package:agrocampo_backend/core/network/runtime_config.dart';
import 'package:agrocampo_backend/core/notifications/local_notification_scheduler.dart';
import 'package:agrocampo_backend/core/notifications/reminder_reconciler.dart';
import 'package:agrocampo_backend/core/observability/safe_logger.dart';
import 'package:agrocampo_backend/core/sync/protocol/supabase_sync_gateway.dart';
import 'package:agrocampo_backend/core/sync/sync_coordinator.dart';
import 'package:agrocampo_backend/core/sync/sync_scheduler.dart';
import 'package:agrocampo_backend/core/sync/sync_trigger_coordinator.dart';
import 'package:agrocampo_backend/features/crops/repositories/crop_assignment_reconciler.dart';
import 'package:agrocampo_backend/features/weather/repositories/weather_gateway.dart';
import 'package:agrocampo_backend/features/weather/repositories/weather_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final runtimeConfigProvider = Provider<RuntimeConfig>(
  (ref) => throw StateError('RuntimeConfig no configurado'),
);
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw StateError('AppDatabase no configurada'),
);
final supabaseClientProvider = Provider<SupabaseClient?>((ref) => null);
final biometricUnlockGatewayProvider = Provider<BiometricUnlockGateway>(
  (ref) => LocalAuthBiometricUnlockGateway(),
);
final safeLoggerProvider = Provider<SafeLogger>(
  (ref) => const DeveloperSafeLogger(),
);
final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => PluginConnectivityService(Connectivity()),
);
final syncSchedulerProvider = Provider<SyncScheduler>(
  (ref) => WorkManagerSyncScheduler(),
);
final localNotificationSchedulerProvider = Provider<LocalNotificationScheduler>(
  (ref) => PluginLocalNotificationScheduler(),
);
final reminderReconcilerProvider = Provider<ReminderReconciler>(
  (ref) => ReminderReconciler(
    ref.watch(appDatabaseProvider),
    ref.watch(localNotificationSchedulerProvider),
  ),
);
final cropAssignmentReconcilerProvider = Provider<CropAssignmentReconciler>(
  (ref) => CropAssignmentReconciler(ref.watch(appDatabaseProvider)),
);
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return WeatherRepository(
    ref.watch(appDatabaseProvider),
    client == null
        ? const UnavailableWeatherGateway()
        : SupabaseWeatherGateway(client),
  );
});
final syncTriggerCoordinatorProvider = Provider<SyncTriggerCoordinator>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SyncTriggerCoordinator(
    client == null
        ? null
        : SyncCoordinator(
            ref.watch(appDatabaseProvider),
            SupabaseSyncGateway(client),
          ),
    ref.watch(syncSchedulerProvider),
    ref.watch(connectivityServiceProvider),
  );
});
