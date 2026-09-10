part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

class Sectors extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get parcelId => text().references(Parcels, #id)();
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

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {parcelId, number},
  ];
}
