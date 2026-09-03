import 'dart:convert';

import 'package:agrocampo/core/sync/protocol/sync_contract.dart';

final class SyncPullResponseParser {
  const SyncPullResponseParser();

  PullResult parse(Object? response, int afterCursor) {
    if (response is! List<Object?>) {
      throw const FormatException('sync_pull_response_invalid');
    }
    var cursor = afterCursor;
    final changes = <RemoteChange>[];
    for (final value in response) {
      if (value is! Map<String, Object?>) {
        throw const FormatException('sync_pull_change_invalid');
      }
      final sequence = (value['change_seq'] as num?)?.toInt();
      final aggregateType = value['aggregate_type'];
      final aggregateId = value['aggregate_id'];
      final kind = value['mutation_kind'];
      final remoteVersion = (value['remote_version'] as num?)?.toInt();
      if (sequence == null ||
          sequence <= cursor ||
          aggregateType is! String ||
          aggregateId is! String ||
          kind is! String ||
          remoteVersion == null ||
          value['payload'] is! Map<String, Object?>) {
        throw const FormatException('sync_pull_change_invalid');
      }
      cursor = sequence;
      changes.add(
        RemoteChange(
          sequence: sequence,
          aggregateType: aggregateType,
          aggregateId: aggregateId,
          kind: kind,
          payloadJson: jsonEncode(value['payload']),
          remoteVersion: remoteVersion,
        ),
      );
    }
    return PullResult(nextCursor: cursor, changes: changes);
  }
}
