import 'package:agrocampo/features/labors/domain/harvest_details.dart';
import 'package:agrocampo/features/labors/domain/irrigation_labor_details.dart';
import 'package:agrocampo/features/labors/domain/labor_details.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'versioned envelope round-trips current and unknown schema versions',
    () {
      final current = const IrrigationLaborDetails(
        method: 'drip',
        durationMinutes: 45,
        appliedVolumeLiters: 180,
      ).toEnvelope();
      expect(LaborDetails.decode(current.encode()).data, current.data);

      final future = LaborDetails(
        type: LaborType.harvest,
        schemaVersion: 99,
        data: const {'futureField': 'preserved', 'quantity': 4},
      );
      final decoded = LaborDetails.decode(future.encode());
      expect(decoded.schemaVersion, 99);
      expect(decoded.data['futureField'], 'preserved');
    },
  );

  test('irrigation and harvest reject missing quantities or units', () {
    expect(
      () => const IrrigationLaborDetails(
        method: '',
        durationMinutes: 0,
      ).toEnvelope(),
      throwsArgumentError,
    );
    expect(
      () => const HarvestDetails(quantity: 0, unit: '').toEnvelope(),
      throwsArgumentError,
    );
  });
}
