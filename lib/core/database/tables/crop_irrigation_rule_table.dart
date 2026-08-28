import 'package:drift/drift.dart';

class CropIrrigationRules extends Table {
  TextColumn get id => text()();
  TextColumn get cropId => text()();
  TextColumn get soilTypeCode => text()();
  IntColumn get version => integer()();
  IntColumn get soilMultiplierPermille => integer()();
  IntColumn get efficiencyPermille => integer()();
  IntColumn get minimumDurationMinutes => integer()();
  IntColumn get maximumDurationMinutes => integer()();
  TextColumn get sourceTitle => text()();
  TextColumn get sourceReference => text()();
  DateTimeColumn get approvedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
