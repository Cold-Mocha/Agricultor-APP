part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

class SyncCursors extends Table {
  TextColumn get ownerId => text()();
  TextColumn get stream => text()();
  IntColumn get lastChangeSeq => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, stream};
}
