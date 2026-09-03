import 'package:local_auth/local_auth.dart';

enum BiometricUnlockResult {
  success,
  unavailable,
  notEnrolled,
  cancelled,
  failed,
  lockedOut,
}

abstract interface class BiometricUnlockGateway {
  Future<bool> isAvailable();
  Future<BiometricUnlockResult> authenticate();
}

abstract interface class LocalAuthDriver {
  Future<bool> isDeviceSupported();
  Future<List<BiometricType>> getAvailableBiometrics();
  Future<bool> authenticate();
}

final class PluginLocalAuthDriver implements LocalAuthDriver {
  PluginLocalAuthDriver([LocalAuthentication? authentication])
    : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  @override
  Future<bool> isDeviceSupported() => _authentication.isDeviceSupported();

  @override
  Future<List<BiometricType>> getAvailableBiometrics() =>
      _authentication.getAvailableBiometrics();

  @override
  Future<bool> authenticate() => _authentication.authenticate(
    localizedReason: 'Desbloquea AgroCampo para acceder a tus datos',
    biometricOnly: true,
    persistAcrossBackgrounding: true,
  );
}

final class LocalAuthBiometricUnlockGateway implements BiometricUnlockGateway {
  LocalAuthBiometricUnlockGateway([LocalAuthDriver? driver])
    : _driver = driver ?? PluginLocalAuthDriver();

  final LocalAuthDriver _driver;

  @override
  Future<bool> isAvailable() async =>
      await _driver.isDeviceSupported() &&
      (await _driver.getAvailableBiometrics()).isNotEmpty;

  @override
  Future<BiometricUnlockResult> authenticate() async {
    if (!await _driver.isDeviceSupported()) {
      return BiometricUnlockResult.unavailable;
    }
    if ((await _driver.getAvailableBiometrics()).isEmpty) {
      return BiometricUnlockResult.notEnrolled;
    }
    try {
      final authenticated = await _driver.authenticate();
      return authenticated
          ? BiometricUnlockResult.success
          : BiometricUnlockResult.cancelled;
    } on LocalAuthException catch (error) {
      return switch (error.code) {
        LocalAuthExceptionCode.userCanceled ||
        LocalAuthExceptionCode.systemCanceled ||
        LocalAuthExceptionCode.timeout => BiometricUnlockResult.cancelled,
        LocalAuthExceptionCode.noBiometricsEnrolled ||
        LocalAuthExceptionCode.noCredentialsSet =>
          BiometricUnlockResult.notEnrolled,
        LocalAuthExceptionCode.noBiometricHardware ||
        LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable =>
          BiometricUnlockResult.unavailable,
        LocalAuthExceptionCode.temporaryLockout ||
        LocalAuthExceptionCode.biometricLockout =>
          BiometricUnlockResult.lockedOut,
        _ => BiometricUnlockResult.failed,
      };
    }
  }
}
