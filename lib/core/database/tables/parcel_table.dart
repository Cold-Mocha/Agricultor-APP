import 'package:drift/drift.dart';

class Parcels extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get locality => text().nullable()();
  TextColumn get polygonJson => text().nullable()();
  RealColumn get areaSquareMeters => real().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
