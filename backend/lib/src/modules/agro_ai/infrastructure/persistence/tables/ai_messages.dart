part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

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
