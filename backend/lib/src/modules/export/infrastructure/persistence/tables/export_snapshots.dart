part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

class ExportSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get status => text()();
  TextColumn get manifestJson => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
