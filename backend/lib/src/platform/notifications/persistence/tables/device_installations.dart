part of 'package:agrocampo_backend/src/platform/database/app_database.dart';

class DeviceInstallations extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get fcmToken => text()();
  TextColumn get platform => text().withDefault(const Constant('android'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
