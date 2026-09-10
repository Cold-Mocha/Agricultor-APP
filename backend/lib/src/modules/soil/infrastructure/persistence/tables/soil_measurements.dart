part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

class SoilMeasurements extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get sectorId => text().references(Sectors, #id)();
  RealColumn get moisturePercent => real().nullable()();
  RealColumn get ph => real().nullable()();
  RealColumn get temperatureCelsius => real().nullable()();
  RealColumn get conductivity => real().nullable()();
  RealColumn get nitrogen => real().nullable()();
  RealColumn get phosphorus => real().nullable()();
  RealColumn get potassium => real().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get measuredAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
