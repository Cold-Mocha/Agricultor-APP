import 'package:drift/drift.dart';

class LocalProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text().withLength(min: 1, max: 120)();
  TextColumn get emailDisplay => text().nullable()();
  TextColumn get locale => text().withDefault(const Constant('es_CL'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppPreferences extends Table {
  TextColumn get ownerId => text()();
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, key};
}

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

class SyncCursors extends Table {
  TextColumn get ownerId => text()();
  TextColumn get stream => text()();
  IntColumn get lastChangeSeq => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, stream};
}

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

class FormDrafts extends Table {
  TextColumn get ownerId => text()();
  TextColumn get draftKey => text()();
  TextColumn get payloadJson => text()();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, draftKey};
}
