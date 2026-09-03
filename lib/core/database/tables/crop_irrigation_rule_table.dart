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
  TextColumn get reviewer => text().nullable()();
  DateTimeColumn get approvedAt => dateTime().nullable()();
  IntColumn get approvedVectorCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get baseMlPerPlant => integer().withDefault(const Constant(1000))();
  IntColumn get minimumAdjustmentBp =>
      integer().withDefault(const Constant(5000))();
  IntColumn get maximumAdjustmentBp =>
      integer().withDefault(const Constant(15000))();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
