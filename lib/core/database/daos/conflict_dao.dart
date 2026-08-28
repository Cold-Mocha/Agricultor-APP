import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/database/tables/technical_tables.dart';
import 'package:drift/drift.dart';

part 'conflict_dao.g.dart';

@DriftAccessor(tables: [SyncConflicts])
class ConflictDao extends DatabaseAccessor<AppDatabase>
    with _$ConflictDaoMixin {
  ConflictDao(super.attachedDatabase);

  Stream<List<SyncConflict>> watchUnresolved(String ownerId) =>
      (select(syncConflicts)..where(
            (row) => row.ownerId.equals(ownerId) & row.resolvedAt.isNull(),
          ))
          .watch();

  Future<void> record(SyncConflictsCompanion conflict) =>
      into(syncConflicts).insertOnConflictUpdate(conflict);

  Future<void> markResolved(String conflictId) =>
      (update(
        syncConflicts,
      )..where((row) => row.conflictId.equals(conflictId))).write(
        SyncConflictsCompanion(resolvedAt: Value(DateTime.now().toUtc())),
      );
}
