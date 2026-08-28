import 'package:agrocampo/features/irrigation/data/irrigation_estimate_repository.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('repository does not invent or activate crop rules', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final result = await IrrigationEstimateRepository(database).calculate(
      cropId: 'physalis',
      soilTypeCode: 'loamy',
      input: const IrrigationCalculationInput(
        plantCount: 100,
        flowMilliLitersPerHourPerPlant: 2000,
        requestedMinutes: 30,
      ),
    );
    expect(result, isA<IrrigationUnavailable>());
    expect((result as IrrigationUnavailable).code, 'crop_rule_unavailable');
  });
}
