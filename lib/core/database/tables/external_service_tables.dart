import 'package:drift/drift.dart';

class WeatherCache extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get locality => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AiMessages extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get role => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ExportSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get status => text()();
  TextColumn get manifestJson => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
