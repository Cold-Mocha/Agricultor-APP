import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:agrocampo/core/sync/sync_gateway.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SupabaseSyncGateway implements SyncGateway {
  const SupabaseSyncGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<PushResult> push({
    required String ownerId,
    required List<PushMutation> operations,
  }) async {
    final response = await _client.rpc<Object?>(
      'sync_push',
      params: {
        'operations': operations
            .map(
              (operation) => {
                'operation_id': operation.operationId,
                'owner_id': ownerId,
                'aggregate_type': operation.aggregateType,
                'aggregate_id': operation.aggregateId,
                'mutation_kind': operation.kind,
                'base_version': operation.baseVersion,
                'payload': operation.payloadJson,
              },
            )
            .toList(growable: false),
      },
    );
    final json = response! as Map<String, Object?>;
    return PushResult(
      acknowledgedOperationIds:
          ((json['acknowledged_operation_ids'] as List<Object?>?) ?? const [])
              .whereType<String>()
              .toSet(),
      conflicts: _parseConflicts(json['conflicts']),
    );
  }

  @override
  Future<PullResult> pull({
    required String ownerId,
    required int afterCursor,
  }) async {
    final response = await _client.rpc<List<Object?>>(
      'sync_pull',
      params: {'after_cursor': afterCursor, 'page_size': 200},
    );
    final rows = response.whereType<Map<String, Object?>>().toList(
      growable: false,
    );
    return PullResult(
      nextCursor: rows.fold(
        afterCursor,
        (cursor, row) => (row['change_seq'] as num).toInt() > cursor
            ? (row['change_seq'] as num).toInt()
            : cursor,
      ),
      changes: rows
          .map(
            (row) => RemoteChange(
              sequence: (row['change_seq'] as num).toInt(),
              aggregateType: row['aggregate_type']! as String,
              payloadJson: row['payload'].toString(),
            ),
          )
          .toList(growable: false),
    );
  }

  List<RemoteConflict> _parseConflicts(Object? value) =>
      (value as List<Object?>? ?? const [])
          .whereType<Map<String, Object?>>()
          .map(
            (row) => RemoteConflict(
              id: row['id']! as String,
              aggregateType: row['aggregate_type']! as String,
              aggregateId: row['aggregate_id']! as String,
              localJson: row['local'].toString(),
              remoteJson: row['remote'].toString(),
            ),
          )
          .toList(growable: false);
}
