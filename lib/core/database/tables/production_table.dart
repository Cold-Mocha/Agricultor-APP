import 'package:agrocampo/core/database/tables/territory_tables.dart';
import 'package:drift/drift.dart';

class ProductionRecords extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get parcelId => text()();
  TextColumn get sectorId => text().references(Sectors, #id)();
  TextColumn get laborId => text().nullable()();
  TextColumn get seasonId => text().nullable()();
  TextColumn get cropId => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  TextColumn get qualityNotes => text().nullable()();
  DateTimeColumn get harvestedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {laborId},
  ];

  @override
  Set<Column<Object>> get primaryKey => {id};
}
