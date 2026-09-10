part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

class IrrigationRecords extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get sectorId => text().references(Sectors, #id)();
  TextColumn get laborId => text().nullable()();
  TextColumn get irrigationType => text()();
  TextColumn get soilTypeCode => text()();
  RealColumn get flowLitersPerHour => real().nullable()();
  IntColumn get durationMinutes => integer().nullable()();
  RealColumn get estimatedLiters => real().nullable()();
  TextColumn get configId => text().nullable()();
  IntColumn get configVersion => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  IntColumn get appliedVolumeMl => integer().nullable()();
  TextColumn get performedDetailsJson =>
      text().withDefault(const Constant('{}'))();
  DateTimeColumn get irrigatedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
