import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/core/auth/auth_repository.dart';
import 'package:agrocampo/core/sync/sync_scheduler.dart';
import 'package:agrocampo/features/auth/domain/session_state.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'restores the last local owner without requiring connectivity',
    () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            _FakeAuthRepository('owner-1'),
          ),
          syncSchedulerProvider.overrideWithValue(_FakeSyncScheduler()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sessionControllerProvider.notifier).restore();

      expect(
        container.read(sessionControllerProvider).status,
        SessionStatus.signedIn,
      );
      expect(container.read(sessionControllerProvider).ownerId, 'owner-1');
    },
  );
}

final class _FakeSyncScheduler implements SyncScheduler {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> schedule({required String ownerId}) async {}
}

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.ownerId);

  final String? ownerId;

  @override
  Future<String?> restoreLocalOwnerId() async => ownerId;

  @override
  Future<AuthenticatedOwner> signIn({
    required String email,
    required String password,
  }) async => AuthenticatedOwner(id: ownerId ?? 'owner-1', email: email);

  @override
  Future<void> signOut() async {}
}
