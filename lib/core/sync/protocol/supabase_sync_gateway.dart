import 'dart:convert';

import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:agrocampo/core/sync/protocol/sync_pull_response_parser.dart';
import 'package:agrocampo/core/sync/protocol/sync_push_response_parser.dart';
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
                'protocol_version': operation.protocolVersion,
                'payload_schema_version': operation.payloadSchemaVersion,
                'base_version': operation.baseVersion,
                'payload': jsonDecode(operation.payloadJson),
                'request_hash': operation.requestHash,
                'depends_on_operation_id': operation.dependsOnOperationId,
              },
            )
            .toList(growable: false),
      },
    );
    final json = response! as Map<String, Object?>;
    final conflicts = {
      for (final conflict in _parseConflicts(json['conflicts']))
        conflict.sourceOperationId: conflict,
    };
    final parsed = const SyncPushResponseParser().parse(json, operations);
    return PushResult(
      operations: parsed.operations
          .map(
            (result) => PushOperationResult(
              operationId: result.operationId,
              status: result.status,
              remoteVersion: result.remoteVersion,
              errorCode: result.errorCode,
              conflict: conflicts[result.operationId],
            ),
          )
          .toList(growable: false),
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
    return const SyncPullResponseParser().parse(response, afterCursor);
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
              baseJson: row['base'] == null ? null : jsonEncode(row['base']),
              remoteJson: jsonEncode(row['remote']),
              remoteVersion: (row['remote_version'] as num?)?.toInt(),
              sourceOperationId: row['source_operation_id'] as String?,
            ),
          )
          .toList(growable: false);
}
