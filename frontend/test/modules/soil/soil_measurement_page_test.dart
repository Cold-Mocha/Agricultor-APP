import 'package:agrocampo/src/modules/soil/presentation/pages/soil_measurement_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';
import '../../../../backend/test/helpers/territory_fixture.dart';
import '../../helpers/signed_in_widget_scope.dart';

void main() {
  testWidgets('soil preserves measured values, units and omitted fields', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    final container = signedInWidgetContainer(database);
    addTearDown(database.close);
    addTearDown(container.dispose);
    await seedAgriculturalContextFixture(database);
    await selectFixtureAgriculturalContext(container);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SoilMeasurementPage()),
      ),
    );
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '40');
    await tester.enterText(fields.at(1), '6.8');
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    final saveButton = find.ancestor(
      of: find.text('Guardar medición'),
      matching: find.byType(FilledButton),
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final row = await database.select(database.soilMeasurements).getSingle();
    expect(row.moisturePercent, 40);
    expect(row.ph, 6.8);
    expect(row.temperatureCelsius, isNull);
    expect(await database.select(database.syncOutbox).get(), isNotEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
