import 'package:drift/drift.dart';

class IrrigationEstimates extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get sectorId => text()();
  TextColumn get ruleId => text()();
  IntColumn get ruleVersion => integer()();
  TextColumn get soilTypeCode => text()();
  TextColumn get inputsJson => text()();
  IntColumn get estimatedLitersMilli => integer()();
  IntColumn get recommendedMinutes => integer()();
  TextColumn get warningsJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
