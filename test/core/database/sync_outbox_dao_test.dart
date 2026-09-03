import 'package:agrocampo/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = createInMemoryDatabase());
  tearDown(() => database.close());

  SyncOutboxCompanion operation({
    required String id,
    String kind = 'update',
    String state = 'pending',
    String? dependency,
    DateTime? nextAttempt,
  }) => SyncOutboxCompanion.insert(
    operationId: id,
    ownerId: 'owner-1',
    aggregateType: 'parcel',
    aggregateId: 'parcel-1',
    mutationKind: kind,
    payloadJson: '{}',
    state: Value(state),
    dependencyOperationId: Value(dependency),
    nextAttemptAt: Value(nextAttempt),
    createdAt: DateTime.utc(2026),
  );

  test(
    'only selects due operations whose dependency is acknowledged',
    () async {
      final now = DateTime.utc(2026, 2);
      await database.syncOutboxDao.enqueue(operation(id: 'parent'));
      await database.syncOutboxDao.enqueue(
        operation(id: 'child', dependency: 'parent'),
      );
      await database.syncOutboxDao.enqueue(
        operation(
          id: 'future',
          state: 'retry_wait',
          nextAttempt: now.add(const Duration(hours: 1)),
        ),
      );

      expect(
        (await database.syncOutboxDao.eligibleBatch(
          'owner-1',
          now: now,
        )).map((row) => row.operationId),
        ['parent'],
      );
      await database.syncOutboxDao.markDone('parent', now);
      expect(
        (await database.syncOutboxDao.eligibleBatch(
          'owner-1',
          now: now,
        )).map((row) => row.operationId),
        ['child'],
      );
    },
  );

  test('manual retry reactivates only retryable operations', () async {
    await database.syncOutboxDao.enqueue(
      operation(id: 'retry', state: 'retry_wait'),
    );
    await database.syncOutboxDao.enqueue(
      operation(id: 'blocked', state: 'blocked'),
    );
    await database.syncOutboxDao.retryManually('owner-1', 'retry');
    await database.syncOutboxDao.retryManually('owner-1', 'blocked');
    final rows = await database.select(database.syncOutbox).get();
    expect(
      rows.singleWhere((row) => row.operationId == 'retry').state,
      'pending',
    );
    expect(
      rows.singleWhere((row) => row.operationId == 'blocked').state,
      'blocked',
    );
  });

  test('create then delete before ACK cancels root and descendants', () async {
    await database.syncOutboxDao.enqueue(
      operation(id: 'create', kind: 'create'),
    );
    await database.syncOutboxDao.enqueue(
      operation(id: 'child', dependency: 'create'),
    );
    await database.syncOutboxDao.enqueue(
      operation(id: 'delete', kind: 'delete'),
    );

    expect(await database.select(database.syncOutbox).get(), isEmpty);
  });
}
