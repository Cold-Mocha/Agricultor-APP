import 'dart:developer' as developer;

abstract interface class SafeLogger {
  void info(String event, {Map<String, Object?> metadata = const {}});
  void error(String event, Object error, {StackTrace? stackTrace});
}

final class DeveloperSafeLogger implements SafeLogger {
  const DeveloperSafeLogger();

  static const _blocked = {
    'token',
    'key',
    'secret',
    'password',
    'prompt',
    'latitude',
    'longitude',
  };

  static Map<String, Object?> sanitize(Map<String, Object?> metadata) =>
      Map<String, Object?>.fromEntries(
        metadata.entries.where(
          (entry) => !_blocked.any(entry.key.toLowerCase().contains),
        ),
      );

  @override
  void info(String event, {Map<String, Object?> metadata = const {}}) {
    final safe = sanitize(metadata);
    developer.log('$event $safe', name: 'agrocampo');
  }

  @override
  void error(String event, Object error, {StackTrace? stackTrace}) {
    developer.log(
      event,
      name: 'agrocampo',
      error: error.runtimeType,
      stackTrace: stackTrace,
    );
  }
}
