import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectionSignal { offline, available }

abstract interface class ConnectivityService {
  Stream<ConnectionSignal> watch();
}

final class PluginConnectivityService implements ConnectivityService {
  PluginConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  @override
  Stream<ConnectionSignal> watch() => _connectivity.onConnectivityChanged.map(
    (results) => results.every((result) => result == ConnectivityResult.none)
        ? ConnectionSignal.offline
        : ConnectionSignal.available,
  );
}
