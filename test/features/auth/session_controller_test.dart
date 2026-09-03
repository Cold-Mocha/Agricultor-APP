import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/core/auth/auth_repository.dart';
import 'package:agrocampo/core/auth/biometric_unlock_gateway.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/network/connectivity_service.dart';
import 'package:agrocampo/core/sync/sync_scheduler.dart';
import 'package:agrocampo/features/auth/domain/session_state.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('rejects an owner id without recoverable session material', () async {
    final scheduler = _FakeSyncScheduler();
    final container = _container(
      repository: _FakeAuthRepository(
        ownerId: 'owner-1',
        recoverableSession: false,
      ),
      scheduler: scheduler,
    );
    addTearDown(container.dispose);

    await container.read(sessionControllerProvider.notifier).restore();

    expect(
      container.read(sessionControllerProvider).status,
      SessionStatus.signedOut,
    );
    expect(scheduler.scheduledOwners, isEmpty);
  });

  test(
    'restores the same owner when session material is recoverable',
    () async {
      final scheduler = _FakeSyncScheduler();
      final container = _container(
        repository: _FakeAuthRepository(
          ownerId: 'owner-1',
          recoverableSession: true,
        ),
        scheduler: scheduler,
      );
      addTearDown(container.dispose);

      await container.read(sessionControllerProvider.notifier).restore();

      expect(
        container.read(sessionControllerProvider).status,
        SessionStatus.signedIn,
      );
      expect(container.read(sessionControllerProvider).ownerId, 'owner-1');
      expect(scheduler.scheduledOwners, ['owner-1']);
    },
  );

  test('sign in preserves the real email for the local profile', () async {
    final database = createInMemoryDatabase();
    final scheduler = _FakeSyncScheduler();
    final container = _container(
      repository: _FakeAuthRepository(
        ownerId: 'owner-1',
        recoverableSession: false,
      ),
      scheduler: scheduler,
      database: database,
    );
    addTearDown(container.dispose);
    addTearDown(database.close);

    await container
        .read(sessionControllerProvider.notifier)
        .signIn(email: 'maria@example.com', password: 'secret');

    final profile = await database.select(database.localProfiles).getSingle();
    expect(profile.emailDisplay, 'maria@example.com');
    expect(profile.displayName, 'maria@example.com');
  });

  test('logout durably closes local access and cancels owner work', () async {
    final scheduler = _FakeSyncScheduler();
    final repository = _FakeAuthRepository(
      ownerId: 'owner-1',
      recoverableSession: true,
    );
    final container = _container(repository: repository, scheduler: scheduler);
    addTearDown(container.dispose);

    await container.read(sessionControllerProvider.notifier).restore();
    await container.read(sessionControllerProvider.notifier).signOut();

    expect(repository.didSignOut, isTrue);
    expect(scheduler.cancelledOwners, ['owner-1']);
    expect(
      container.read(sessionControllerProvider).status,
      SessionStatus.signedOut,
    );
    expect(container.read(sessionControllerProvider).ownerId, isNull);
  });

  test(
    'biometric cancel stays locked and success unlocks local access',
    () async {
      final scheduler = _FakeSyncScheduler();
      final gateway = _FakeBiometricGateway(BiometricUnlockResult.cancelled);
      final container = _container(
        repository: _FakeAuthRepository(
          ownerId: 'owner-1',
          recoverableSession: true,
          biometricEnabled: true,
        ),
        scheduler: scheduler,
        gateway: gateway,
      );
      addTearDown(container.dispose);

      await container.read(sessionControllerProvider.notifier).restore();
      expect(
        container.read(sessionControllerProvider).status,
        SessionStatus.locked,
      );
      await container
          .read(sessionControllerProvider.notifier)
          .unlockWithBiometrics();
      expect(
        container.read(sessionControllerProvider).status,
        SessionStatus.locked,
      );

      gateway.result = BiometricUnlockResult.success;
      await container
          .read(sessionControllerProvider.notifier)
          .unlockWithBiometrics();
      expect(
        container.read(sessionControllerProvider).status,
        SessionStatus.signedIn,
      );
      expect(scheduler.scheduledOwners, ['owner-1']);
    },
  );
}

ProviderContainer _container({
  required _FakeAuthRepository repository,
  required _FakeSyncScheduler scheduler,
  BiometricUnlockGateway? gateway,
  AppDatabase? database,
}) => ProviderContainer(
  overrides: [
    authRepositoryProvider.overrideWithValue(repository),
    syncSchedulerProvider.overrideWithValue(scheduler),
    connectivityServiceProvider.overrideWithValue(_FakeConnectivityService()),
    biometricUnlockGatewayProvider.overrideWithValue(
      gateway ?? _FakeBiometricGateway(),
    ),
    if (database != null) appDatabaseProvider.overrideWithValue(database),
  ],
);

final class _FakeConnectivityService implements ConnectivityService {
  @override
  Stream<ConnectionSignal> watch() => const Stream.empty();
}

final class _FakeSyncScheduler implements SyncScheduler {
  final scheduledOwners = <String>[];
  final cancelledOwners = <String>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> schedule({required String ownerId}) async {
    scheduledOwners.add(ownerId);
  }

  @override
  Future<void> cancel({required String ownerId}) async {
    cancelledOwners.add(ownerId);
  }
}

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    required this.ownerId,
    required this.recoverableSession,
    this.biometricEnabled = false,
  });

  final String? ownerId;
  final bool recoverableSession;
  final bool biometricEnabled;
  bool didSignOut = false;

  @override
  Future<RestoredAuthSession?> restoreSession() async =>
      recoverableSession && ownerId != null
      ? RestoredAuthSession(
          ownerId: ownerId!,
          biometricEnabled: biometricEnabled,
          offline: false,
        )
      : null;

  @override
  Future<AuthenticatedOwner> signIn({
    required String email,
    required String password,
  }) async => AuthenticatedOwner(id: ownerId ?? 'owner-1', email: email);

  @override
  Future<void> setBiometricEnabled(bool enabled) async {}

  @override
  Future<void> signOut() async {
    didSignOut = true;
  }
}

final class _FakeBiometricGateway implements BiometricUnlockGateway {
  _FakeBiometricGateway([this.result = BiometricUnlockResult.success]);

  BiometricUnlockResult result;

  @override
  Future<BiometricUnlockResult> authenticate() async => result;

  @override
  Future<bool> isAvailable() async => true;
}
