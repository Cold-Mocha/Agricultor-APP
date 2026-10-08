part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

class SyncOutbox extends Table {
  TextColumn get operationId => text()();
  TextColumn get ownerId => text()();
  TextColumn get aggregateType => text()();
  TextColumn get aggregateId => text()();
  TextColumn get mutationKind => text()();
  TextColumn get deviceId => text().nullable()();
  IntColumn get protocolVersion => integer().withDefault(const Constant(2))();
  IntColumn get baseVersion => integer().nullable()();
  TextColumn get payloadJson => text()();
  IntColumn get payloadSchemaVersion =>
      integer().withDefault(const Constant(1))();
  TextColumn get requestHash => text().nullable()();
  TextColumn get dependencyOperationId => text().nullable()();
  TextColumn get state => text().withDefault(const Constant('pending'))();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get lastErrorCode => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttemptedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {operationId};
}
