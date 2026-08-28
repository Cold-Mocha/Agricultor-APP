import 'package:agrocampo/features/irrigation/domain/irrigation_calculator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('unapproved crop always returns crop_rule_unavailable offline', (
    tester,
  ) async {
    const input = IrrigationCalculationInput(
      plantCount: 200,
      flowMilliLitersPerHourPerPlant: 1500,
      requestedMinutes: 45,
    );
    for (var run = 0; run < 2; run++) {
      final result =
          IrrigationCalculator.calculate(input) as IrrigationUnavailable;
      expect(result.code, 'crop_rule_unavailable');
    }
  });
}
