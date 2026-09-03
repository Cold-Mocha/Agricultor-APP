import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';

abstract interface class AggregateSyncCodec {
  String get aggregateType;

  Future<void> applyRemote(
    AppDatabase database,
    String ownerId,
    RemoteChange change,
  );

  Future<void> markAcknowledged(
    AppDatabase database,
    String ownerId,
    String aggregateId,
    int? remoteVersion,
    DateTime acknowledgedAt,
  );
}
