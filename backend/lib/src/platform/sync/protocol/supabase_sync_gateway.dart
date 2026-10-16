import 'dart:convert';

import 'package:agrocampo_backend/src/platform/sync/protocol/sync_contract.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/sync_pull_response_parser.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/sync_push_response_parser.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_gateway.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SupabaseSyncGateway implements SyncGateway, SectorExistenceGateway {
  const SupabaseSyncGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<PushResult> push({
    required String ownerId,
    required List<PushMutation> operations,
  }) async {
    _requireOwner(ownerId);
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
    _requireOwner(ownerId);
    final response = await _client.rpc<List<Object?>>(
      'sync_pull',
      params: {'after_cursor': afterCursor, 'page_size': 200},
    );
    return const SyncPullResponseParser().parse(response, afterCursor);
  }

  void _requireOwner(String ownerId) {
    final currentOwner = _client.auth.currentUser?.id;
    if (currentOwner != null && currentOwner != ownerId) {
      throw StateError('sync_owner_mismatch');
    }
  }

  @override
  Future<Set<String>> existingSectorIds({
    required String ownerId,
    required List<String> candidateIds,
  }) async {
    void requireSession() {
      if (_client.auth.currentUser?.id != ownerId) {
        throw StateError('sync_owner_mismatch');
      }
    }

    requireSession();
    final existing = <String>{};
    // A unique-ID query cannot silently truncate at the project's row limit.
    // Failure of any request aborts the comparison without hiding local data.
    for (var offset = 0; offset < candidateIds.length; offset += 8) {
      final batch = candidateIds.skip(offset).take(8);
      final found = await Future.wait(
        batch.map((id) async {
          requireSession();
          final row = await _client
              .from('sectors')
              .select('id,owner_id')
              .eq('owner_id', ownerId)
              .eq('id', id)
              .maybeSingle()
              .timeout(const Duration(seconds: 20));
          requireSession();
          if (row == null) return null;
          if (row['id'] != id || row['owner_id'] != ownerId) {
            throw const FormatException('sector_inventory_invalid');
          }
          return id;
        }),
      );
      existing.addAll(found.whereType<String>());
    }
    requireSession();
    return existing;
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
