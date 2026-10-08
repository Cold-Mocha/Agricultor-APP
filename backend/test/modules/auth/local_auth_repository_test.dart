import 'package:agrocampo_backend/src/modules/auth/infrastructure/local_auth_repository.dart';
import 'package:agrocampo_backend/src/shared/kernel/app_failure.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('restores a stable offline owner across instances', () async {
    const first = LocalAuthRepository(LocalOwnerStore(FlutterSecureStorage()));
    const second = LocalAuthRepository(LocalOwnerStore(FlutterSecureStorage()));

    final restored = await first.restoreSession();
    final again = await second.restoreSession();

    expect(restored?.offline, isTrue);
    expect(restored?.ownerId, isNotEmpty);
    expect(again?.ownerId, restored?.ownerId);
  });

  test('sign out keeps the local owner so records are not orphaned', () async {
    const repository = LocalAuthRepository(
      LocalOwnerStore(FlutterSecureStorage()),
    );
    final before = await repository.restoreSession();

    await repository.signOut();

    expect((await repository.restoreSession())?.ownerId, before?.ownerId);
  });

  test('persists the biometric preference', () async {
    const repository = LocalAuthRepository(
      LocalOwnerStore(FlutterSecureStorage()),
    );

    await repository.setBiometricEnabled(true);

    expect((await repository.restoreSession())?.biometricEnabled, isTrue);
  });

  test('rejects credential sign-in in local mode', () async {
    const repository = LocalAuthRepository(
      LocalOwnerStore(FlutterSecureStorage()),
    );

    await expectLater(
      repository.signIn(email: 'a@b.cl', password: 'secret'),
      throwsA(isA<AuthenticationFailure>()),
    );
  });
}
