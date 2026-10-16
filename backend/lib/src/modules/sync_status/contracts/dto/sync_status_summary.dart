final class SyncQueueSummary {
  const SyncQueueSummary({
    required this.pending,
    required this.retryable,
    required this.blocked,
  });

  final int pending;
  final int retryable;
  final int blocked;
}

final class ConflictComparison {
  const ConflictComparison({
    required this.localDescription,
    required this.remoteDescription,
  });

  final String localDescription;
  final String remoteDescription;
}
