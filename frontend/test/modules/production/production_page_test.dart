import 'package:agrocampo/src/modules/production/presentation/pages/production_page.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';
import '../../../../backend/test/helpers/territory_fixture.dart';
import '../../helpers/signed_in_widget_scope.dart';

void main() {
  testWidgets('production captures quantity and optional traceability', (
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
        child: const MaterialApp(home: ProductionPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('production-quantity')),
      '12.5',
    );
    await tester.enterText(
      find.byKey(const ValueKey('production-destination')),
      'Mercado local',
    );
    final saveButton = find.ancestor(
      of: find.text('Guardar cosecha'),
      matching: find.byType(FilledButton),
    );
    await tester.scrollUntilVisible(
      saveButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final row = await database.select(database.productionRecords).getSingle();
    expect(row.quantity, 12.5);
    final labor = await database.select(database.labors).getSingle();
    expect(
      jsonDecode(labor.detailsJson)['data']['destination'],
      'Mercado local',
    );
    expect(labor.syncState, 'pending');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
