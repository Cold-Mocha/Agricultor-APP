import 'package:agrocampo/app/agro_campo_app.dart';
import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/core/auth/auth_repository.dart';
import 'package:agrocampo/core/auth/secure_session_store.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/network/runtime_config.dart';
import 'package:agrocampo/core/sync/sync_scheduler.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> bootstrapAgroCampo() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = RuntimeConfig.fromCompileTime();
  final database = AppDatabase();
  final client = config.hasSupabase
      ? SupabaseClient(config.supabaseUrl, config.supabasePublishableKey)
      : null;
  const secureStorage = FlutterSecureStorage();
  final authRepository = SupabaseAuthRepository(
    client: client,
    store: const SecureSessionStore(secureStorage),
  );
  final syncScheduler = WorkManagerSyncScheduler();
  await syncScheduler.initialize();
  runApp(
    ProviderScope(
      overrides: [
        runtimeConfigProvider.overrideWithValue(config),
        appDatabaseProvider.overrideWithValue(database),
        authRepositoryProvider.overrideWithValue(authRepository),
        syncSchedulerProvider.overrideWithValue(syncScheduler),
      ],
      child: const AgroCampoApp(),
    ),
  );
}
