import 'package:agrocampo_backend/agrocampo_backend.dart';

final class SyncStatusUiState {
  const SyncStatusUiState({
    this.pending = 0,
    this.retryable = 0,
    this.blocked = 0,
  });

  factory SyncStatusUiState.fromSummary(SyncQueueSummary summary) =>
      SyncStatusUiState(
        pending: summary.pending,
        retryable: summary.retryable,
        blocked: summary.blocked,
      );

  final int pending;
  final int retryable;
  final int blocked;
}

final class ConflictComparisonUiState {
  const ConflictComparisonUiState({
    required this.localDescription,
    required this.remoteDescription,
  });

  factory ConflictComparisonUiState.fromContract(
    ConflictComparison comparison,
  ) => ConflictComparisonUiState(
    localDescription: comparison.localDescription,
    remoteDescription: comparison.remoteDescription,
  );

  final String localDescription;
  final String remoteDescription;
}
