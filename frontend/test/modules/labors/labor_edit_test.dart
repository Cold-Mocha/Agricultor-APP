import 'package:agrocampo/src/modules/labors/presentation/pages/labor_form_page.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';
import '../../../../backend/test/helpers/territory_fixture.dart';
import '../../helpers/signed_in_widget_scope.dart';

void main() {
  testWidgets('reopens a recorded labor prefilled and saves a correction', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    final container = signedInWidgetContainer(database);
    addTearDown(database.close);
    addTearDown(container.dispose);
    await seedAgriculturalContextFixture(database);
    await selectFixtureAgriculturalContext(container);
    await container
        .read(laborsFacadeProvider)
        .saveOutcome(
          ownerId: 'owner-1',
          input: LaborFormInput(
            sectorId: 'sector-1',
            type: LaborType.fertilization,
            occurredAt: DateTime.utc(2026, 3, 1),
            primary: 'Compost',
            secondary: 'manual',
            amount: '5',
            unit: 'kg',
            extra: '',
            customName: '',
            notes: 'Primera pasada',
          ),
        );
    final laborId = (await database.select(database.labors).getSingle()).id;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: LaborFormPage(editLaborId: laborId)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Corregir labor'), findsOneWidget);
    expect(find.text('Compost'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);
    // The known method code populated the dropdown, not the free-text field.
    expect(find.text('Manual'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('labor-notes')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Primera pasada'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('amount')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(find.byKey(const ValueKey('amount')), '8');
    await tester.scrollUntilVisible(
      find.text('Guardar corrección'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Guardar corrección'));
    await tester.pumpAndSettle();

    expect(find.text('Corrección guardada.'), findsOneWidget);
    final rows = await database.select(database.labors).get();
    expect(rows, hasLength(2));
    final original = rows.singleWhere((row) => row.id == laborId);
    expect(original.status, 'corrected');
    final replacement = rows.singleWhere((row) => row.id != laborId);
    expect(replacement.supersedesLaborId, laborId);
    expect(replacement.detailsJson, contains('"amount":8.0'));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('a labor type without a generic form shows the empty state', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    final container = signedInWidgetContainer(database);
    addTearDown(database.close);
    addTearDown(container.dispose);
    await seedAgriculturalContextFixture(database);
    await database
        .into(database.labors)
        .insert(
          LaborsCompanion.insert(
            id: 'labor-soil',
            ownerId: 'owner-1',
            sectorId: 'sector-1',
            type: 'soil',
            occurredAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: LaborFormPage(editLaborId: 'labor-soil'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No disponible para corrección'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
