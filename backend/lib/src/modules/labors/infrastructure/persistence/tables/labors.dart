part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

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
