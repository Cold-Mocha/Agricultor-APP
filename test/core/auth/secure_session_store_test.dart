import 'package:agrocampo/core/auth/secure_session_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('round-trips owner, refresh token and biometric preference', () async {
    const store = SecureSessionStore(FlutterSecureStorage());
    await store.persist(ownerId: 'owner-1', refreshToken: 'refresh-1');
    await store.setBiometricEnabled(true);

    final restored = await store.read();
    expect(restored?.ownerId, 'owner-1');
    expect(restored?.refreshToken, 'refresh-1');
    expect(restored?.biometricEnabled, isTrue);
  });

  test('clear removes all local access material', () async {
    const store = SecureSessionStore(FlutterSecureStorage());
    await store.persist(ownerId: 'owner-1', refreshToken: 'refresh-1');
    await store.setBiometricEnabled(true);

    await store.clear();

    expect(await store.read(), isNull);
    expect(await store.readOwnerId(), isNull);
    expect(await store.readRefreshToken(), isNull);
  });

  test('owner without refresh token is not recoverable', () async {
    FlutterSecureStorage.setMockInitialValues({
      'agrocampo.owner_id': 'owner-1',
    });
    const store = SecureSessionStore(FlutterSecureStorage());

    expect(await store.read(), isNull);
  });
}
