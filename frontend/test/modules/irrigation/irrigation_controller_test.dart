import 'package:agrocampo/src/modules/irrigation/presentation/controllers/irrigation_controller.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';
import '../../../../backend/test/helpers/territory_fixture.dart';
import '../../helpers/signed_in_widget_scope.dart';

void main() {
  test('controller preserves basic drip arithmetic and advanced unavailable state', () async {
    final database = createInMemoryDatabase();
    final container = signedInWidgetContainer(database);
    addTearDown(database.close);
    addTearDown(container.dispose);
    await seedAgriculturalContextFixture(database);
    await selectFixtureAgriculturalContext(container);
    final result = await container.read(irrigationFormControllerProvider).calculate(
      const IrrigationFormInput(
        sectorId: 'sector-1',
        type: IrrigationType.drip,
        soilType: SoilType.loamy,
        duration: '30',
        flow: '120',
        pressure: '80',
      ),
    );
    expect(result, isNotNull);
    expect(result!.basicVolumeLiters, 60);
    expect(result.basicFormula, 'total_flow_l_per_h*duration_min/60');
  });
}
