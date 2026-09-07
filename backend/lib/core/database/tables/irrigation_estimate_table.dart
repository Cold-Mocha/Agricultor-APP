import 'package:drift/drift.dart';

class IrrigationEstimates extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get sectorId => text()();
  TextColumn get irrigationLaborId => text().nullable()();
  TextColumn get cropAssignmentId => text().nullable()();
  TextColumn get configId => text().nullable()();
  IntColumn get configVersion => integer().nullable()();
  IntColumn get algorithmVersion => integer().withDefault(const Constant(1))();
  TextColumn get ruleId => text()();
  IntColumn get ruleVersion => integer()();
  TextColumn get soilTypeCode => text()();
  TextColumn get inputsJson => text()();
  IntColumn get estimatedLitersMilli => integer()();
  IntColumn get recommendedMinutes => integer()();
  TextColumn get warningsJson => text().withDefault(const Constant('[]'))();
  TextColumn get explanationJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get calculatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
