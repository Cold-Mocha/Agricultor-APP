part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

class PhotoAttachments extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get aggregateType => text()();
  TextColumn get aggregateId => text()();
  TextColumn get localPath => text()();
  TextColumn get contentHash => text()();
  TextColumn get mimeType => text()();
  TextColumn get remotePath => text().nullable()();
  TextColumn get uploadState => text().withDefault(const Constant('pending'))();
  DateTimeColumn get capturedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {ownerId, contentHash},
  ];
}
