import 'package:agrocampo/core/database/tables/territory_tables.dart';
import 'package:drift/drift.dart';

class Labors extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get parcelId => text()();
  TextColumn get sectorId => text().references(Sectors, #id)();
  TextColumn get seasonId => text().nullable()();
  TextColumn get type => text()();
  TextColumn get customName => text().nullable()();
  TextColumn get detailsJson => text().withDefault(const Constant('{}'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

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

class IrrigationRecords extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get sectorId => text().references(Sectors, #id)();
  TextColumn get irrigationType => text()();
  TextColumn get soilTypeCode => text()();
  RealColumn get flowLitersPerHour => real().nullable()();
  IntColumn get durationMinutes => integer().nullable()();
  RealColumn get estimatedLiters => real().nullable()();
  DateTimeColumn get irrigatedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
