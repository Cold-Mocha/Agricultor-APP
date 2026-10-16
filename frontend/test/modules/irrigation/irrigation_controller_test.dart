import 'package:agrocampo/src/modules/irrigation/presentation/controllers/irrigation_controller.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';
import '../../../../backend/test/helpers/territory_fixture.dart';
import '../../helpers/signed_in_widget_scope.dart';

void main() {
  test(
    'controller preserves basic drip arithmetic and advanced unavailable state',
    () async {
      final database = createInMemoryDatabase();
      final container = signedInWidgetContainer(database);
      addTearDown(database.close);
      addTearDown(container.dispose);
      await seedAgriculturalContextFixture(database);
      await selectFixtureAgriculturalContext(container);
      final result = await container
          .read(irrigationFormControllerProvider)
          .calculate(
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
    },
  );

  test('sector without a current crop explains what is missing', () async {
    final database = createInMemoryDatabase();
    final container = signedInWidgetContainer(database);
    addTearDown(database.close);
    addTearDown(container.dispose);
    await seedTerritoryFixture(database);
    const input = IrrigationFormInput(
      sectorId: 'sector-1',
      type: IrrigationType.drip,
      soilType: SoilType.loamy,
      duration: '30',
      flow: '120',
      pressure: '',
    );
    final controller = container.read(irrigationFormControllerProvider);

    final calculation = await controller.calculate(input);
    expect(calculation!.isUnavailable, isTrue);
    expect(calculation.needsCrop, isTrue);
    expect(calculation.message, contains('no tiene un cultivo vigente'));
    final failure = await controller.save(input);
    expect(
      failure?.message,
      contains('no tiene un cultivo vigente'),
      reason: 'saving must report the missing crop instead of throwing',
    );
    expect(failure?.needsCrop, isTrue);
  });

  test('save reports missing sector and duration', () async {
    final database = createInMemoryDatabase();
    final container = signedInWidgetContainer(database);
    addTearDown(database.close);
    addTearDown(container.dispose);
    await seedAgriculturalContextFixture(database);
    final controller = container.read(irrigationFormControllerProvider);

    expect(
      await controller.save(
        const IrrigationFormInput(
          sectorId: null,
          type: IrrigationType.furrow,
          soilType: SoilType.loamy,
          duration: '30',
          flow: '',
        ),
      ),
      (message: 'Selecciona un sector antes de continuar.', needsCrop: false),
    );
    expect(
      await controller.save(
        const IrrigationFormInput(
          sectorId: 'sector-1',
          type: IrrigationType.furrow,
          soilType: SoilType.loamy,
          duration: '',
          flow: '',
        ),
      ),
      (message: 'Ingresa la duración del riego en minutos.', needsCrop: false),
    );
  });
}
