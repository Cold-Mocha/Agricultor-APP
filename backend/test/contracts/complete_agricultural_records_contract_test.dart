import 'package:agrocampo_backend/src/modules/labors/labors_api.dart';
import 'package:agrocampo_backend/src/modules/production/production_api.dart';
import 'package:agrocampo_backend/src/modules/soil/soil_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public record inputs retain discriminators, units and optional omissions', () {
    final labor = LaborFormInput(
      sectorId: 'sector-1',
      type: LaborType.diseaseAndPestControl,
      occurredAt: DateTime(2026),
      primary: 'Producto',
      secondary: 'Pulgón',
      amount: '2',
      unit: 'ml/L',
      extra: '7',
      customName: '',
      notes: 'observación',
    );
    const harvest = ProductionFormInput(
      sectorId: 'sector-1',
      quantity: '12.5',
      unit: 'kg',
      qualityNotes: 'Primera',
    );
    const soil = SoilMeasurementInput(moisturePercent: 0);
    expect(labor.type, LaborType.diseaseAndPestControl);
    expect(harvest.destination, isNull);
    expect(soil.moisturePercent, 0);
  });

  test('typed details expose complete phytosanitary and harvest fields', () {
    final phytosanitary = const PhytosanitaryDetails(
      product: 'Jabón',
      target: 'Pulgón',
      dose: 2,
      unit: 'ml/L',
      safetyIntervalDays: 7,
      observations: 'Aplicar al atardecer',
    ).toEnvelope();
    final harvest = const HarvestDetails(
      quantity: 10,
      unit: 'kg',
      qualityNotes: 'Primera',
      destination: 'Bodega',
      workShift: 'Mañana',
      observations: 'Sin daño',
    ).toEnvelope();
    expect(phytosanitary.data['safetyIntervalDays'], 7);
    expect(phytosanitary.data['observations'], 'Aplicar al atardecer');
    expect(harvest.data['destination'], 'Bodega');
    expect(harvest.data['workShift'], 'Mañana');
  });
}
