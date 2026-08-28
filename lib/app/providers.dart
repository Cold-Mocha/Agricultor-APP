import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/network/connectivity_service.dart';
import 'package:agrocampo/core/network/runtime_config.dart';
import 'package:agrocampo/core/observability/safe_logger.dart';
import 'package:agrocampo/core/sync/sync_scheduler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final runtimeConfigProvider = Provider<RuntimeConfig>(
  (ref) => throw StateError('RuntimeConfig no configurado'),
);
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw StateError('AppDatabase no configurada'),
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
