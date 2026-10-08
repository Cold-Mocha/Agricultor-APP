part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

class LocalProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text().withLength(min: 1, max: 120)();
  TextColumn get emailDisplay => text().nullable()();
  TextColumn get locale => text().withDefault(const Constant('es_CL'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
