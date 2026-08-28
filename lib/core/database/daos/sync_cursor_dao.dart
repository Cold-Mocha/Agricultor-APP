import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/database/tables/technical_tables.dart';
import 'package:drift/drift.dart';

part 'sync_cursor_dao.g.dart';

@DriftAccessor(tables: [SyncCursors])
class SyncCursorDao extends DatabaseAccessor<AppDatabase>
    with _$SyncCursorDaoMixin {
  SyncCursorDao(super.attachedDatabase);

  Future<int> read(String ownerId, String stream) async =>
      (await (select(syncCursors)..where(
                (row) =>
                    row.ownerId.equals(ownerId) & row.stream.equals(stream),
              ))
              .getSingleOrNull())
          ?.lastChangeSeq ??
      0;

  Future<void> write(String ownerId, String stream, int cursor) =>
      into(syncCursors).insertOnConflictUpdate(
        SyncCursorsCompanion.insert(
          ownerId: ownerId,
          stream: stream,
          lastChangeSeq: Value(cursor),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
}
