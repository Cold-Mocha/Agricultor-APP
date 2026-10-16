part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

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
