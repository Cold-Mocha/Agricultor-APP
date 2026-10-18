part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

class SyncConflicts extends Table {
  TextColumn get conflictId => text()();
  TextColumn get ownerId => text()();
  TextColumn get aggregateType => text()();
  TextColumn get aggregateId => text()();
  TextColumn get localJson => text()();
  TextColumn get baseJson => text().nullable()();
  TextColumn get remoteJson => text()();
  IntColumn get remoteVersion => integer().nullable()();
  TextColumn get sourceOperationId => text().nullable()();
  TextColumn get state => text().withDefault(const Constant('open'))();
  TextColumn get resolutionChoice => text().nullable()();
  TextColumn get resolutionOperationId => text().nullable()();
  TextColumn get errorCode => text().nullable()();
  DateTimeColumn get detectedAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {conflictId};
}
