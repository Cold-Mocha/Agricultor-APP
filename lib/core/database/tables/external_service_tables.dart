import 'package:drift/drift.dart';

class WeatherCache extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get parcelId => text().nullable()();
  TextColumn get locality => text()();
  TextColumn get provider => text().withDefault(const Constant('weatherapi'))();
  TextColumn get payloadJson => text()();
  DateTimeColumn get observedAt => dateTime().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  TextColumn get attribution => text().nullable()();
  TextColumn get errorCode => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AiMessages extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get clientMessageId => text().withDefault(const Constant(''))();
  TextColumn get role => text()();
  TextColumn get content => text()();
  TextColumn get state => text().withDefault(const Constant('sent'))();
  TextColumn get replyToClientMessageId => text().nullable()();
  TextColumn get remoteResponseId => text().nullable()();
  TextColumn get policyVersion => text().nullable()();
  TextColumn get errorCode => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ExportSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get status => text()();
  TextColumn get manifestJson => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
