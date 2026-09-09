import 'package:agrocampo_backend/src/composition/sync_codec_composition.dart';
import 'package:agrocampo_backend/src/composition/sync_scheduler.dart';
import 'package:agrocampo_backend/src/modules/auth/infrastructure/biometric_unlock_gateway.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/infrastructure/persistence/crop_assignment_reconciler.dart';
import 'package:agrocampo_backend/src/modules/labors/infrastructure/persistence/labor_repository.dart';
import 'package:agrocampo_backend/src/modules/labors/labors_api.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_gateway.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/network/connectivity_service.dart';
import 'package:agrocampo_backend/src/platform/network/runtime_config.dart';
import 'package:agrocampo_backend/src/platform/notifications/local_notification_scheduler.dart';
import 'package:agrocampo_backend/src/platform/notifications/reminder_notification_payload.dart';
import 'package:agrocampo_backend/src/platform/notifications/reminder_reconciler.dart';
import 'package:agrocampo_backend/src/platform/observability/safe_logger.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/supabase_sync_gateway.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_coordinator.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_trigger_coordinator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final runtimeConfigProvider = Provider<RuntimeConfig>(
  (ref) => throw StateError('RuntimeConfig no configurado'),
);
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw StateError('AppDatabase no configurada'),
);
final laborContextReaderProvider = Provider<LaborContextReader>(
  (ref) => LaborRepository(ref.watch(appDatabaseProvider)),
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
final reminderNotificationPayloadBuilderProvider =
    Provider<ReminderNotificationPayloadBuilder>(
      (ref) =>
          throw StateError('ReminderNotificationPayloadBuilder no configurado'),
    );
final reminderReconcilerProvider = Provider<ReminderReconciler>(
  (ref) => ReminderReconciler(
    ref.watch(appDatabaseProvider),
    ref.watch(localNotificationSchedulerProvider),
    ref.watch(reminderNotificationPayloadBuilderProvider),
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
            registry: createAgroCampoSyncRegistry(),
          ),
    ref.watch(syncSchedulerProvider),
    ref.watch(connectivityServiceProvider),
  );
});
