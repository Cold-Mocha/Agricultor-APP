import 'package:agrocampo_backend/core/auth/auth_repository.dart';
import 'package:agrocampo_backend/core/auth/secure_session_store.dart';
import 'package:agrocampo_backend/core/config/backend_providers.dart';
import 'package:agrocampo_backend/core/database/app_database.dart';
import 'package:agrocampo_backend/core/network/runtime_config.dart';
import 'package:agrocampo_backend/core/notifications/local_notification_scheduler.dart';
import 'package:agrocampo_backend/core/sync/sync_scheduler.dart';
import 'package:agrocampo_backend/features/auth/controllers/session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Owns the local runtime without exposing its database or remote client.
final class AgroCampoBackend {
  AgroCampoBackend._(this.container);

  final ProviderContainer container;

  static Future<AgroCampoBackend> initialize() async {
    final config = RuntimeConfig.fromCompileTime();
    final database = AppDatabase();
    SupabaseClient? client;
    if (config.hasSupabase) {
      await Supabase.initialize(
        url: config.supabaseUrl,
        publishableKey: config.supabasePublishableKey,
      );
      client = Supabase.instance.client;
    }
    const secureStorage = FlutterSecureStorage();
    final authRepository = SupabaseAuthRepository(
      client: client,
      store: const SecureSessionStore(secureStorage),
    );
    final syncScheduler = WorkManagerSyncScheduler();
    await syncScheduler.initialize();
    final notificationScheduler = PluginLocalNotificationScheduler();
    await notificationScheduler.initialize();
    return AgroCampoBackend._(
      ProviderContainer(
        overrides: [
          runtimeConfigProvider.overrideWithValue(config),
          appDatabaseProvider.overrideWithValue(database),
          supabaseClientProvider.overrideWithValue(client),
          authRepositoryProvider.overrideWithValue(authRepository),
          syncSchedulerProvider.overrideWithValue(syncScheduler),
          localNotificationSchedulerProvider.overrideWithValue(
            notificationScheduler,
          ),
        ],
      ),
    );
  }
}
