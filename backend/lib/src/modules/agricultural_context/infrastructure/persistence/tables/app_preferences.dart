part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

class AppPreferences extends Table {
  TextColumn get ownerId => text()();
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, key};
}
