import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/soil/domain/soil_measurement.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:drift/drift.dart';

final class SoilRepository {
  SoilRepository(this._database);

  final AppDatabase _database;

  Future<String> save({
    required String ownerId,
    required String sectorId,
    required SoilMeasurementInput input,
  }) async {
    input.validate();
    final id = EntityId.generate().value;
    await _database
        .into(_database.soilMeasurements)
        .insert(
          SoilMeasurementsCompanion.insert(
            id: id,
            ownerId: ownerId,
            sectorId: sectorId,
            moisturePercent: Value(input.moisturePercent),
            ph: Value(input.ph),
            temperatureCelsius: Value(input.temperatureCelsius),
            conductivity: Value(input.conductivity),
            nitrogen: Value(input.nitrogen),
            phosphorus: Value(input.phosphorus),
            potassium: Value(input.potassium),
            measuredAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    return id;
  }
}
