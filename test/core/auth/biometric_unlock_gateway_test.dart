import 'package:agrocampo/core/auth/biometric_unlock_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  test('reports unavailable and not enrolled before prompting', () async {
    final unsupported = _Driver(supported: false);
    expect(
      await LocalAuthBiometricUnlockGateway(unsupported).authenticate(),
      BiometricUnlockResult.unavailable,
    );
    final empty = _Driver();
    expect(
      await LocalAuthBiometricUnlockGateway(empty).authenticate(),
      BiometricUnlockResult.notEnrolled,
    );
  });

  test(
    'maps success, cancellation and lockout without creating a session',
    () async {
      final driver = _Driver(biometrics: const [BiometricType.fingerprint]);
      expect(
        await LocalAuthBiometricUnlockGateway(driver).authenticate(),
        BiometricUnlockResult.success,
      );
      driver.error = const LocalAuthException(
        code: LocalAuthExceptionCode.userCanceled,
      );
      expect(
        await LocalAuthBiometricUnlockGateway(driver).authenticate(),
        BiometricUnlockResult.cancelled,
      );
      driver.error = const LocalAuthException(
        code: LocalAuthExceptionCode.biometricLockout,
      );
      expect(
        await LocalAuthBiometricUnlockGateway(driver).authenticate(),
        BiometricUnlockResult.lockedOut,
      );
    },
  );
}

final class _Driver implements LocalAuthDriver {
  _Driver({this.supported = true, this.biometrics = const []});

  final bool supported;
  final List<BiometricType> biometrics;
  LocalAuthException? error;

  @override
  Future<bool> authenticate() async {
    if (error != null) throw error!;
    return true;
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => biometrics;

  @override
  Future<bool> isDeviceSupported() async => supported;
}
