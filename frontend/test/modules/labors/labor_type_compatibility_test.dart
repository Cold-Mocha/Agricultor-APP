import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/modules/apiary/presentation/pages/apiary_inspection_page.dart';
import 'package:agrocampo/src/modules/labors/presentation/pages/labor_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';
import '../../../../backend/test/helpers/territory_fixture.dart';
import '../../helpers/signed_in_widget_scope.dart';

Future<ProviderContainer> _cropSectorContainer(WidgetTester tester) async {
  final database = createInMemoryDatabase();
  final container = signedInWidgetContainer(database);
  addTearDown(database.close);
  addTearDown(container.dispose);
  await seedAgriculturalContextFixture(database);
  await selectFixtureAgriculturalContext(container);
  return container;
}

void main() {
  testWidgets('a crop sector does not offer apiary labor', (tester) async {
    final container = await _cropSectorContainer(tester);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AgroTheme.light, home: const LaborFormPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('labor-type')));
    await tester.pumpAndSettle();

    expect(find.text('Fertilización'), findsWidgets);
    expect(find.text('Apicultura'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('apiary inspection explains an incompatible crop sector', (
    tester,
  ) async {
    final container = await _cropSectorContainer(tester);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const ApiaryInspectionPage(sectorId: 'sector-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sector incompatible'), findsOneWidget);
    expect(find.text('Guardar revisión'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
