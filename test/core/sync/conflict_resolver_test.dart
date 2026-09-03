import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/conflicts/conflict_resolver.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:agrocampo/core/sync/sync_coordinator.dart';
import 'package:agrocampo/core/sync/sync_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase database;
  setUp(() => database = createInMemoryDatabase());
  tearDown(() => database.close());

  Future<void> insertConflict(String id) => database.conflictDao.record(
    SyncConflictsCompanion.insert(
      conflictId: id,
      ownerId: 'owner-1',
      aggregateType: 'parcel',
      aggregateId: '11111111-1111-4111-8111-111111111111',
      localJson: '{"id":"11111111-1111-4111-8111-111111111111","name":"Local","updated_at":"2026-01-01T00:00:00Z"}',
      remoteJson: '{"id":"11111111-1111-4111-8111-111111111111","name":"Remota","version":2,"updated_at":"2026-01-02T00:00:00Z"}',
      detectedAt: DateTime.utc(2026),
    ),
  );

  test('keep local remains resolving until remote ACK', () async {
    await insertConflict('conflict-local');
    await ConflictResolver(database)
        .resolve('conflict-local', ConflictChoice.keepLocal);
    var conflict = await database.select(database.syncConflicts).getSingle();
    expect(conflict.state, 'resolving');
    expect(conflict.resolvedAt, isNull);

    await SyncCoordinator(database, const _AckGateway()).synchronize('owner-1');
    conflict = await database.select(database.syncConflicts).getSingle();
    expect(conflict.state, 'resolved');
    expect(conflict.resolvedAt, isNotNull);
  });

  test('keep remote applies snapshot but retains audit until ACK', () async {
    await insertConflict('conflict-remote');
    await ConflictResolver(database)
        .resolve('conflict-remote', ConflictChoice.keepRemote);
    expect(
      (await database.select(database.parcels).getSingle()).name,
      'Remota',
    );
    expect(
      (await database.select(database.syncConflicts).getSingle()).state,
      'resolving',
    );
    expect(await database.select(database.syncOutbox).get(), hasLength(1));
  });
}

final class _AckGateway implements SyncGateway {
  const _AckGateway();
  @override
  Future<PullResult> pull({
    required String ownerId,
    required int afterCursor,
  }) async => PullResult(nextCursor: afterCursor);
  @override
  Future<PushResult> push({
    required String ownerId,
    required List<PushMutation> operations,
  }) async => PushResult(
    operations: operations
        .map(
          (operation) => PushOperationResult(
            operationId: operation.operationId,
            status: PushOperationStatus.applied,
            remoteVersion: 3,
          ),
        )
        .toList(growable: false),
  );
}
