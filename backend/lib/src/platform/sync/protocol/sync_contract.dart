enum PushOperationStatus {
  applied,
  duplicate,
  conflict,
  rejected,
  retryableError;

  static PushOperationStatus parse(String value) => switch (value) {
    'applied' => applied,
    'duplicate' => duplicate,
    'conflict' => conflict,
    'rejected' => rejected,
    _ => retryableError,
  };
}

final class PushMutation {
  const PushMutation({
    required this.operationId,
    required this.aggregateType,
    required this.aggregateId,
    required this.kind,
    required this.payloadJson,
    this.protocolVersion = 2,
    this.payloadSchemaVersion = 1,
    this.baseVersion,
    this.requestHash,
    this.dependsOnOperationId,
  });

  final String operationId;
  final String aggregateType;
  final String aggregateId;
  final String kind;
  final int protocolVersion;
  final int payloadSchemaVersion;
  final int? baseVersion;
  final String payloadJson;
  final String? requestHash;
  final String? dependsOnOperationId;
}

final class PushOperationResult {
  const PushOperationResult({
    required this.operationId,
    required this.status,
    this.remoteVersion,
    this.errorCode,
    this.conflict,
  });

  final String operationId;
  final PushOperationStatus status;
  final int? remoteVersion;
  final String? errorCode;
  final RemoteConflict? conflict;

  bool get isAcknowledged =>
      status == PushOperationStatus.applied ||
      status == PushOperationStatus.duplicate;
}

final class PushResult {
  const PushResult({required this.operations});
  final List<PushOperationResult> operations;
}

final class PullResult {
  const PullResult({
    required this.nextCursor,
    this.changes = const [],
    this.conflicts = const [],
  });

  final int nextCursor;
  final List<RemoteChange> changes;
  final List<RemoteConflict> conflicts;
}

final class RemoteChange {
  const RemoteChange({
    required this.sequence,
    required this.aggregateType,
    required this.aggregateId,
    required this.kind,
    required this.payloadJson,
    required this.remoteVersion,
  });

  final int sequence;
  final String aggregateType;
  final String aggregateId;
  final String kind;
  final String payloadJson;
  final int remoteVersion;
}

final class RemoteConflict {
  const RemoteConflict({
    required this.id,
    required this.aggregateType,
    required this.aggregateId,
    required this.localJson,
    required this.remoteJson,
    this.baseJson,
    this.remoteVersion,
    this.sourceOperationId,
  });

  final String id;
  final String aggregateType;
  final String aggregateId;
  final String localJson;
  final String? baseJson;
  final String remoteJson;
  final int? remoteVersion;
  final String? sourceOperationId;
}
