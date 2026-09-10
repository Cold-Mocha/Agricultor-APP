part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get parcelId => text().nullable()();
  TextColumn get sectorId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get sourceTimeZone => text().withDefault(const Constant('UTC'))();
  TextColumn get status => text().withDefault(const Constant('scheduled'))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get cancelledAt => dateTime().nullable()();
  IntColumn get androidNotificationId => integer().nullable()();
  TextColumn get notificationState =>
      text().withDefault(const Constant('none'))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  TextColumn get lastSyncErrorCode => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
