import 'package:agrocampo/core/database/tables/territory_tables.dart';
import 'package:drift/drift.dart';

class Labors extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get parcelId => text()();
  TextColumn get sectorId => text().references(Sectors, #id)();
  TextColumn get seasonId => text().nullable()();
  TextColumn get cropAssignmentId => text().nullable()();
  TextColumn get type => text()();
  TextColumn get customName => text().nullable()();
  TextColumn get detailsJson => text().withDefault(const Constant('{}'))();
  IntColumn get detailsSchemaVersion =>
      integer().withDefault(const Constant(1))();
  TextColumn get status => text().withDefault(const Constant('recorded'))();
  TextColumn get supersedesLaborId => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  TextColumn get lastSyncErrorCode => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
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
