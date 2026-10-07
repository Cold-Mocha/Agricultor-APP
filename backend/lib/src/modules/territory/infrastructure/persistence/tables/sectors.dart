part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

class Sectors extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  IntColumn get number =>
      integer().customConstraint('NOT NULL CHECK (number > 0)')();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get kind => text().withDefault(const Constant('crop'))();
  TextColumn get polygonJson => text()();
  RealColumn get areaSquareMeters =>
      real().customConstraint('NOT NULL CHECK (area_square_meters > 0)')();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  TextColumn get lastSyncErrorCode => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  // A sector number is only unique among sectors the owner hasn't deleted;
  // reusing a deleted sector's number must be allowed. SQLite can't express
  // that as a table-level UNIQUE constraint, so it lives in a partial
  // unique index (see idx_sectors_number_active) applied in migrations.
}
