final class PushMutation {
  const PushMutation({
    required this.operationId,
    required this.aggregateType,
    required this.aggregateId,
    required this.kind,
    required this.payloadJson,
    this.baseVersion,
  });

  final String operationId;
  final String aggregateType;
  final String aggregateId;
  final String kind;
  final int? baseVersion;
  final String payloadJson;
}

final class PushResult {
  const PushResult({
    required this.acknowledgedOperationIds,
    this.conflicts = const [],
  });

  final Set<String> acknowledgedOperationIds;
  final List<RemoteConflict> conflicts;
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
    required this.payloadJson,
  });

  final int sequence;
  final String aggregateType;
  final String payloadJson;
}

final class RemoteConflict {
  const RemoteConflict({
    required this.id,
    required this.aggregateType,
    required this.aggregateId,
    required this.localJson,
    required this.remoteJson,
  });

  final String id;
  final String aggregateType;
  final String aggregateId;
  final String localJson;
  final String remoteJson;
}
