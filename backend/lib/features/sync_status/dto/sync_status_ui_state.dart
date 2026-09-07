final class SyncStatusUiState {
  const SyncStatusUiState({
    this.pending = 0,
    this.retryable = 0,
    this.blocked = 0,
  });

  final int pending;
  final int retryable;
  final int blocked;
}

/// Display-only comparison prepared by the backend, never a sync command.
final class ConflictComparisonUiState {
  const ConflictComparisonUiState({
    required this.localDescription,
    required this.remoteDescription,
  });

  final String localDescription;
  final String remoteDescription;
}
