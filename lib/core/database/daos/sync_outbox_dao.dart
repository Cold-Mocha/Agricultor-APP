import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/database/tables/technical_tables.dart';
import 'package:drift/drift.dart';

part 'sync_outbox_dao.g.dart';

@DriftAccessor(tables: [SyncOutbox])
class SyncOutboxDao extends DatabaseAccessor<AppDatabase>
    with _$SyncOutboxDaoMixin {
  SyncOutboxDao(super.attachedDatabase);

  Future<void> enqueue(SyncOutboxCompanion operation) =>
      into(syncOutbox).insert(operation);

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
