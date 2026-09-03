import 'package:agrocampo/core/sync/protocol/sync_contract.dart';

final class SyncPushResponseParser {
  const SyncPushResponseParser();

  PushResult parse(Object? response, List<PushMutation> requests) {
    if (response is! Map<String, Object?> ||
        response['protocol_version'] != 2) {
      throw const FormatException('sync_response_protocol_invalid');
    }
    final raw = response['results'];
    if (raw is! List<Object?> || raw.length != requests.length) {
      throw const FormatException('sync_response_result_count_invalid');
    }
    final expected = requests.map((item) => item.operationId).toSet();
    final seen = <String>{};
    final results = <PushOperationResult>[];
    for (final value in raw) {
      if (value is! Map<String, Object?>) {
        throw const FormatException('sync_response_result_invalid');
      }
      final id = value['operation_id'];
      final status = value['status'];
      if (id is! String ||
          !expected.contains(id) ||
          !seen.add(id) ||
          status is! String ||
          !const {
            'applied',
            'duplicate',
            'conflict',
            'rejected',
            'retryableError',
          }.contains(status)) {
        throw const FormatException('sync_response_result_invalid');
      }
      results.add(
        PushOperationResult(
          operationId: id,
          status: PushOperationStatus.parse(status),
          remoteVersion: (value['remote_version'] as num?)?.toInt(),
          errorCode: value['error_code'] as String?,
        ),
      );
    }
    return PushResult(operations: results);
  }
}
