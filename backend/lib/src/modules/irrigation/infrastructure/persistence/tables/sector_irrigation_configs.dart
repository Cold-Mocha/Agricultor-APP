part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

class SectorIrrigationConfigs extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get sectorId => text().references(Sectors, #id)();
  TextColumn get method => text().withDefault(const Constant('drip'))();
  IntColumn get plantCount => integer()();
  IntColumn get emitterCount => integer()();
  IntColumn get emittersPerPlantMilli => integer().nullable()();
  IntColumn get flowMlMin => integer()();
  IntColumn get pressureKpa => integer().nullable()();
  TextColumn get distributionNotes => text().nullable()();
  DateTimeColumn get effectiveFrom => dateTime()();
  DateTimeColumn get effectiveTo => dateTime().nullable()();
  IntColumn get configVersion => integer()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  TextColumn get lastSyncErrorCode => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
