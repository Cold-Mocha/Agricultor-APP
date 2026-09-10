part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

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
