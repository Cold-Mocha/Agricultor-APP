sealed class AppFailure implements Exception {
  const AppFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => '$runtimeType($code)';
}

final class ConfigurationFailure extends AppFailure {
  const ConfigurationFailure(super.code, super.message);
}

final class LocalPersistenceFailure extends AppFailure {
  const LocalPersistenceFailure(super.code, super.message);
}

final class AuthenticationFailure extends AppFailure {
  const AuthenticationFailure(super.code, super.message);
}

final class ConnectivityFailure extends AppFailure {
  const ConnectivityFailure(super.code, super.message);
}
