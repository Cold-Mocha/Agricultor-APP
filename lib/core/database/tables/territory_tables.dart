import 'package:agrocampo/core/database/tables/parcel_table.dart';
import 'package:drift/drift.dart';

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
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {parcelId, number},
  ];
}

class OfficialCrops extends Table {
  TextColumn get id => text()();
  TextColumn get commonName => text()();
  TextColumn get scientificName => text().nullable()();
  TextColumn get category => text()();
  TextColumn get colorToken => text()();
  TextColumn get iconAsset => text()();
  IntColumn get catalogVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CustomCrops extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CropSeasons extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get sectorId => text().references(Sectors, #id)();
  TextColumn get cropId => text()();
  BoolColumn get isCustomCrop => boolean().withDefault(const Constant(false))();
  TextColumn get status => text().withDefault(const Constant('planned'))();
  DateTimeColumn get startsOn => dateTime()();
  DateTimeColumn get endsOn => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
