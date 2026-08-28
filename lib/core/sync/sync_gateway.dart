import 'package:agrocampo/core/sync/protocol/sync_contract.dart';

abstract interface class SyncGateway {
  Future<PushResult> push({
    required String ownerId,
    required List<PushMutation> operations,
  });

  Future<PullResult> pull({required String ownerId, required int afterCursor});
}
