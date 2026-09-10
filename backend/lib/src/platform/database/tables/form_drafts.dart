part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

class FormDrafts extends Table {
  TextColumn get ownerId => text()();
  TextColumn get draftKey => text()();
  TextColumn get payloadJson => text()();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, draftKey};
}
