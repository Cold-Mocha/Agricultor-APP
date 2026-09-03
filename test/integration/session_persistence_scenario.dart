import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/core/auth/auth_repository.dart';
import 'package:agrocampo/core/auth/biometric_unlock_gateway.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/network/connectivity_service.dart';
import 'package:agrocampo/core/sync/sync_scheduler.dart';
import 'package:agrocampo/features/auth/domain/session_state.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/file_backed_database.dart';

void main() {
  test(
    'offline reopen logout and owner changes preserve data without exposing it',
    () async {
      final fixture = await FileBackedDatabaseFixture.create();
      addTearDown(fixture.dispose);
      var database = fixture.open();
      addTearDown(() => database.close());
      await ParcelRepository(database).save(
        ownerId: 'owner-a',
        id: 'parcel-a',
        name: 'Campo A pendiente',
        isActive: true,
      );

      final auth = _DurableAuthRepository(
        ownerId: 'owner-a',
        recoverable: true,
        offline: true,
        biometricEnabled: true,
      );
      final biometrics = _BiometricGateway(BiometricUnlockResult.cancelled);
      final scheduler = _Scheduler();
      var container = _container(
        database: database,
        auth: auth,
        biometrics: biometrics,
        scheduler: scheduler,
      );

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

      biometrics.result = BiometricUnlockResult.success;
      await container
          .read(sessionControllerProvider.notifier)
          .unlockWithBiometrics();
      expect(
        container.read(sessionControllerProvider).status,
        SessionStatus.offline,
      );
      expect(container.read(unlockedOwnerIdProvider), 'owner-a');
      expect(
        (await ParcelRepository(
          database,
        ).watchAll('owner-a').first).map((row) => row.id),
        ['parcel-a'],
      );

      container.dispose();
      await database.close();
      database = fixture.open();
      container = _container(
        database: database,
        auth: auth,
        biometrics: biometrics,
        scheduler: scheduler,
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
        SessionStatus.offline,
      );

      await container.read(sessionControllerProvider.notifier).signOut();
      expect(
        container.read(sessionControllerProvider).status,
        SessionStatus.signedOut,
      );
      expect(container.read(unlockedOwnerIdProvider), isNull);
      expect(scheduler.cancelledOwners, contains('owner-a'));
      expect(
        (await database.select(database.parcels).get()).map((row) => row.id),
        contains('parcel-a'),
        reason: 'Cerrar sesión debe bloquear, no borrar datos pendientes.',
      );
      await container
          .read(sessionControllerProvider.notifier)
          .unlockWithBiometrics();
      expect(
        container.read(sessionControllerProvider).status,
        SessionStatus.signedOut,
      );

      auth.nextOwnerId = 'owner-a';
      await container
          .read(sessionControllerProvider.notifier)
          .signIn(
            email: 'owner-a@agrocampo.local',
            password: 'valid-test-password',
          );
      expect(container.read(unlockedOwnerIdProvider), 'owner-a');
      expect(
        (await ParcelRepository(
          database,
        ).watchAll('owner-a').first).map((row) => row.id),
        ['parcel-a'],
      );

      await container.read(sessionControllerProvider.notifier).signOut();
      auth.nextOwnerId = 'owner-b';
      await container
          .read(sessionControllerProvider.notifier)
          .signIn(
            email: 'owner-b@agrocampo.local',
            password: 'valid-test-password',
          );
      await ParcelRepository(database).save(
        ownerId: 'owner-b',
        id: 'parcel-b',
        name: 'Campo B',
        isActive: true,
      );
      expect(container.read(unlockedOwnerIdProvider), 'owner-b');
      expect(
        (await ParcelRepository(
          database,
        ).watchAll('owner-b').first).map((row) => row.id),
        ['parcel-b'],
      );
      expect(
        (await database.syncOutboxDao.eligibleBatch('owner-b'))
            .every((row) => row.ownerId == 'owner-b'),
        isTrue,
      );
      expect(
        (await database.syncOutboxDao.eligibleBatch('owner-a'))
            .every((row) => row.ownerId == 'owner-a'),
        isTrue,
      );
    },
  );
}

ProviderContainer _container({
  required AppDatabase database,
  required _DurableAuthRepository auth,
  required _BiometricGateway biometrics,
  required _Scheduler scheduler,
}) => ProviderContainer(
  overrides: [
    appDatabaseProvider.overrideWithValue(database),
    authRepositoryProvider.overrideWithValue(auth),
    biometricUnlockGatewayProvider.overrideWithValue(biometrics),
    syncSchedulerProvider.overrideWithValue(scheduler),
    connectivityServiceProvider.overrideWithValue(_OfflineConnectivity()),
  ],
);

final class _DurableAuthRepository implements AuthRepository {
  _DurableAuthRepository({
    required this.ownerId,
    required this.recoverable,
    required this.offline,
    required this.biometricEnabled,
  });

  String? ownerId;
  String? nextOwnerId;
  bool recoverable;
  bool offline;
  bool biometricEnabled;

  @override
  Future<RestoredAuthSession?> restoreSession() async {
    final value = ownerId;
    if (!recoverable || value == null) return null;
    return RestoredAuthSession(
      ownerId: value,
      biometricEnabled: biometricEnabled,
      offline: offline,
    );
  }

  @override
  Future<AuthenticatedOwner> signIn({
    required String email,
    required String password,
  }) async {
    ownerId = nextOwnerId ?? ownerId ?? 'owner-a';
    recoverable = true;
    offline = false;
    biometricEnabled = false;
    return AuthenticatedOwner(id: ownerId!, email: email);
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    biometricEnabled = enabled;
  }

  @override
  Future<void> signOut() async {
    recoverable = false;
    biometricEnabled = false;
  }
}

final class _BiometricGateway implements BiometricUnlockGateway {
  _BiometricGateway(this.result);
  BiometricUnlockResult result;

  @override
  Future<BiometricUnlockResult> authenticate() async => result;

  @override
  Future<bool> isAvailable() async =>
      result != BiometricUnlockResult.unavailable &&
      result != BiometricUnlockResult.notEnrolled;
}

final class _Scheduler implements SyncScheduler {
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

final class _OfflineConnectivity implements ConnectivityService {
  @override
  Stream<ConnectionSignal> watch() => Stream.value(ConnectionSignal.offline);
}
