import 'package:drift/drift.dart';

class ApiaryInspections extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get sectorId => text()();
  TextColumn get taskType => text()();
  TextColumn get beekeeperName => text()();
  IntColumn get hiveCount => integer()();
  TextColumn get queenStatus => text()();
  TextColumn get broodStatus => text()();
  TextColumn get feedingStatus => text()();
  TextColumn get healthNotes => text()();
  TextColumn get pestNotes => text()();
  BoolColumn get superInstalled => boolean()();
  TextColumn get observations => text().nullable()();
  DateTimeColumn get inspectedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
