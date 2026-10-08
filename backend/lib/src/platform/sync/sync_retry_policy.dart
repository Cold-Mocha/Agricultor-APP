final class SyncRetryPolicy {
  const SyncRetryPolicy({this.baseSeconds = 5, this.maximumSeconds = 3600});

  final int baseSeconds;
  final int maximumSeconds;

  Duration delayForAttempt(
    int attempt, {
    String operationId = '',
    Duration? serverDelay,
  }) {
    final exponent = attempt.clamp(0, 20);
    final rawSeconds = baseSeconds * (1 << exponent);
    if (rawSeconds >= maximumSeconds) {
      final capped = Duration(seconds: maximumSeconds);
      if (serverDelay != null && serverDelay > capped) return serverDelay;
      return capped;
    }
    final jitterRange = (rawSeconds * 0.2).round();
    final stableHash = operationId.codeUnits.fold<int>(0, (a, b) => a + b);
    final jitter = jitterRange == 0
        ? 0
        : (stableHash % (jitterRange * 2 + 1)) - jitterRange;
    final seconds = (rawSeconds + jitter).clamp(baseSeconds, maximumSeconds);
    final localDelay = Duration(seconds: seconds);
    if (serverDelay != null && serverDelay > localDelay) return serverDelay;
    return localDelay;
  }
}
