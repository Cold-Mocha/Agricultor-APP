import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/database/tables/technical_tables.dart';
import 'package:drift/drift.dart';

part 'sync_outbox_dao.g.dart';

@DriftAccessor(tables: [SyncOutbox])
class SyncOutboxDao extends DatabaseAccessor<AppDatabase>
    with _$SyncOutboxDaoMixin {
  SyncOutboxDao(super.attachedDatabase);

  Future<void> enqueue(SyncOutboxCompanion operation) async {
    final aggregateType = operation.aggregateType.value;
    final aggregateId = operation.aggregateId.value;
    if (operation.mutationKind.value == 'delete') {
      final unsyncedCreate =
          await (select(syncOutbox)..where(
                (row) =>
                    row.ownerId.equals(operation.ownerId.value) &
                    row.aggregateType.equals(aggregateType) &
                    row.aggregateId.equals(aggregateId) &
                    row.mutationKind.equals('create') &
                    row.state.isNotIn(const ['done']),
              ))
              .getSingleOrNull();
      if (unsyncedCreate != null) {
        await (delete(syncOutbox)..where(
              (row) =>
                  row.operationId.equals(unsyncedCreate.operationId) |
                  row.dependencyOperationId.equals(unsyncedCreate.operationId),
            ))
            .go();
        return;
      }
    }
    await into(syncOutbox).insert(operation);
  }

  Future<List<SyncOutboxData>> eligibleBatch(
    String ownerId, {
    DateTime? now,
    int limit = 100,
  }) async {
    final instant = now ?? DateTime.now().toUtc();
    await (update(syncOutbox)..where(
          (row) =>
              row.ownerId.equals(ownerId) &
              row.state.equals('retry_wait') &
              row.nextAttemptAt.isSmallerOrEqualValue(instant),
        ))
        .write(const SyncOutboxCompanion(state: Value('pending')));
    await (update(syncOutbox)..where(
          (row) =>
              row.ownerId.equals(ownerId) &
              row.state.equals('sending') &
              (row.lastAttemptedAt.isNull() |
                  row.lastAttemptedAt.isSmallerThanValue(
                    instant.subtract(const Duration(minutes: 5)),
                  )),
        ))
        .write(const SyncOutboxCompanion(state: Value('pending')));
    final candidates =
        await (select(syncOutbox)
              ..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.state.equals('pending') &
                    (row.nextAttemptAt.isNull() |
                        row.nextAttemptAt.isSmallerOrEqualValue(instant)),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
            .get();
    final doneIds =
        (await (select(syncOutbox)..where(
                  (row) =>
                      row.ownerId.equals(ownerId) & row.state.equals('done'),
                ))
                .get())
            .map((row) => row.operationId)
            .toSet();
    final result = <SyncOutboxData>[];
    for (final row in candidates) {
      if (row.dependencyOperationId == null ||
          doneIds.contains(row.dependencyOperationId)) {
        result.add(row);
        if (result.length == limit) break;
      }
    }
    if (result.isNotEmpty) {
      final ids = result.map((row) => row.operationId).toList();
      await (update(
        syncOutbox,
      )..where((row) => row.operationId.isIn(ids))).write(
        SyncOutboxCompanion(
          state: const Value('sending'),
          lastAttemptedAt: Value(instant),
        ),
      );
    }
    return result;
  }

  Future<void> markDone(String operationId, DateTime now) =>
      (update(
        syncOutbox,
      )..where((row) => row.operationId.equals(operationId))).write(
        SyncOutboxCompanion(
          state: const Value('done'),
          completedAt: Value(now),
          lastErrorCode: const Value(null),
        ),
      );

  Future<void> markPendingRetry(
    SyncOutboxData operation,
    DateTime nextAttemptAt,
    String errorCode,
  ) =>
      (update(
        syncOutbox,
      )..where((row) => row.operationId.equals(operation.operationId))).write(
        SyncOutboxCompanion(
          state: const Value('retry_wait'),
          attemptCount: Value(operation.attemptCount + 1),
          nextAttemptAt: Value(nextAttemptAt),
          lastErrorCode: Value(errorCode),
        ),
      );

  Future<void> retryManually(String ownerId, String operationId) =>
      (update(syncOutbox)..where(
            (row) =>
                row.ownerId.equals(ownerId) &
                row.operationId.equals(operationId) &
                row.state.isIn(const ['retry_wait']),
          ))
          .write(
            const SyncOutboxCompanion(
              state: Value('pending'),
              nextAttemptAt: Value(null),
            ),
          );

  Future<void> restorePending(String operationId, String errorCode) =>
      (update(
        syncOutbox,
      )..where((row) => row.operationId.equals(operationId))).write(
        SyncOutboxCompanion(
          state: const Value('pending'),
          lastErrorCode: Value(errorCode),
        ),
      );

  Future<void> markTerminal(String operationId, String state, String? error) =>
      (update(
        syncOutbox,
      )..where((row) => row.operationId.equals(operationId))).write(
        SyncOutboxCompanion(state: Value(state), lastErrorCode: Value(error)),
      );

  Stream<List<SyncOutboxData>> watchPending(String ownerId) =>
      (select(syncOutbox)..where(
            (row) =>
                row.ownerId.equals(ownerId) & row.state.isNotIn(const ['done']),
          ))
          .watch();

  Future<T> transactionWithOutbox<T>({
    required Future<T> Function() writeAggregate,
    required SyncOutboxCompanion operation,
  }) => transaction(() async {
    final result = await writeAggregate();
    await enqueue(operation);
    return result;
  });
}
