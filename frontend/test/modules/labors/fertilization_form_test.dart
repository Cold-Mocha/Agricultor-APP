import 'dart:convert';

import 'package:agrocampo/src/modules/labors/presentation/pages/labor_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';
import '../../../../backend/test/helpers/territory_fixture.dart';
import '../../helpers/signed_in_widget_scope.dart';

void main() {
  testWidgets('fertilization selector keeps manual, foliar and fertigation', (
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
        child: const MaterialApp(home: LaborFormPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('product')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(find.byKey(const ValueKey('product')), 'Compost');
    await tester.enterText(find.byKey(const ValueKey('amount')), '5');
    await tester.enterText(find.byKey(const ValueKey('unit')), 'kg');
    await tester.drag(find.byType(ListView), const Offset(0, 220));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('fertilization-method')));
    await tester.pumpAndSettle();
    expect(find.text('Manual'), findsWidgets);
    expect(find.text('Foliar'), findsWidgets);
    expect(find.text('Fertirriego'), findsWidgets);
    await tester.tap(find.text('Foliar').last);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar actividad'));
    await tester.pumpAndSettle();

    final labor = await database.select(database.labors).getSingle();
    expect(
      jsonDecode(labor.detailsJson)['data']['applicationMethod'],
      'foliar',
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
