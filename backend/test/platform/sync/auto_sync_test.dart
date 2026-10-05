import 'dart:async';

import 'package:agrocampo_backend/src/composition/sync_scheduler.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/network/connectivity_service.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/sync_contract.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_coordinator.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_gateway.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_trigger_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/sync_test_coordinator.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  late AppDatabase database;
  setUp(() => database = createInMemoryDatabase());
  tearDown(() => database.close());

  Future<void> enqueue(String id) => database.syncOutboxDao.enqueue(
    SyncOutboxCompanion.insert(
      operationId: id,
      ownerId: 'owner-1',
      aggregateType: 'sectorCropAssignment',
      aggregateId: 'assignment-$id',
      mutationKind: 'create',
      payloadJson: '{"id":"assignment-$id"}',
      createdAt: DateTime.utc(2026),
    ),
  );

  Future<SyncOutboxData> row(String id) => (database.select(
    database.syncOutbox,
  )..where((row) => row.operationId.equals(id))).getSingle();

  test(
    'a missing parent or crop is retried instead of failing for good',
    () async {
      await enqueue('op-1');
      final gateway = _Gateway()..reply = PushOperationStatus.rejected;

      await createTestSyncCoordinator(database, gateway).synchronize('owner-1');

      final stored = await row('op-1');
      expect(stored.state, 'retry_wait');
      expect(stored.lastErrorCode, 'assignment_crop_missing');
      expect(isRecoverableRejection('payload_invalid'), isFalse);
    },
  );

  test(
    'operations already failed for a missing parent are pushed again',
    () async {
      await enqueue('op-1');
      await database.syncOutboxDao.markTerminal(
        'op-1',
        'failed',
        'assignment_crop_missing',
      );
      final gateway = _Gateway()..reply = PushOperationStatus.applied;

      final result = await createTestSyncCoordinator(
        database,
        gateway,
      ).synchronize('owner-1');

      expect(result.pushed, 1);
      expect((await row('op-1')).state, 'done');
    },
  );

  test('work under a deleted quadrant is cancelled, not retried', () async {
    await seedAgriculturalContextFixture(database);
    await database.syncOutboxDao.enqueue(
      SyncOutboxCompanion.insert(
        operationId: 'orphan',
        ownerId: 'owner-1',
        aggregateType: 'sectorCropAssignment',
        aggregateId: 'assignment-1',
        mutationKind: 'create',
        payloadJson: '{"id":"assignment-1"}',
        createdAt: DateTime.utc(2026),
      ),
    );
    await database.customStatement(
      "UPDATE sectors SET deleted_at = '2026-10-04T21:14:11Z' WHERE id = 'sector-1'",
    );
    final gateway = _Gateway()..reply = PushOperationStatus.rejected;

    await createTestSyncCoordinator(database, gateway).synchronize('owner-1');

    expect(gateway.pushed, isNot(contains('orphan')));
    expect((await row('orphan')).state, 'cancelled');
    expect(
      await database.syncOutboxDao.watchPending('owner-1').first,
      isEmpty,
      reason: 'cancelled work no longer counts as pending',
    );
  });

  test('saving new work synchronizes without pressing a button', () async {
    final gateway = _Gateway()..reply = PushOperationStatus.applied;
    final trigger = SyncTriggerCoordinator(
      createTestSyncCoordinator(database, gateway),
      _Scheduler(),
      _Connectivity(),
      pendingWork: (ownerId) => database.syncOutboxDao
          .watchPending(ownerId)
          .map(
            (rows) => rows
                .where(
                  (row) => row.state == 'pending' || row.state == 'retry_wait',
                )
                .length,
          ),
      saveDebounce: const Duration(milliseconds: 20),
    );
    await trigger.start('owner-1');
    final pushesAfterStart = gateway.pushed.length;

    await enqueue('op-new');
    await Future<void>.delayed(const Duration(milliseconds: 300));

    expect(gateway.pushed.skip(pushesAfterStart), contains('op-new'));
    expect((await row('op-new')).state, 'done');
    await trigger.stop('owner-1');
  });
}

final class _Gateway implements SyncGateway {
  PushOperationStatus reply = PushOperationStatus.applied;
  final pushed = <String>[];

  @override
  Future<PullResult> pull({
    required String ownerId,
    required int afterCursor,
  }) async => PullResult(nextCursor: afterCursor);

  @override
  Future<PushResult> push({
    required String ownerId,
    required List<PushMutation> operations,
  }) async {
    pushed.addAll(operations.map((operation) => operation.operationId));
    return PushResult(
      operations: [
        for (final operation in operations)
          PushOperationResult(
            operationId: operation.operationId,
            status: reply,
            errorCode: reply == PushOperationStatus.rejected
                ? 'assignment_crop_missing'
                : null,
          ),
      ],
    );
  }
}

final class _Scheduler implements SyncScheduler {
  @override
  Future<void> initialize() async {}
  @override
  Future<void> schedule({required String ownerId}) async {}
  @override
  Future<void> cancel({required String ownerId}) async {}
}

final class _Connectivity implements ConnectivityService {
  @override
  Stream<ConnectionSignal> watch() => const Stream.empty();
}
