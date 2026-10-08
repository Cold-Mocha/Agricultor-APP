part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

class CustomCrops extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get normalizedName => text().withDefault(const Constant(''))();
  TextColumn get description => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  TextColumn get lastSyncErrorCode => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
