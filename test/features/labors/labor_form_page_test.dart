import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:agrocampo/features/labors/presentation/labor_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/signed_in_widget_scope.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  testWidgets(
    'seven agricultural labor panels are reachable and preserve input',
    (tester) async {
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
      for (final type in const [
        LaborType.diseaseAndPestControl,
        LaborType.sowing,
        LaborType.pruning,
        LaborType.other,
        LaborType.irrigation,
        LaborType.harvest,
        LaborType.fertilization,
      ]) {
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('labor-type')),
          -250,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.byKey(const ValueKey('labor-type')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(type.label).last);
        await tester.pumpAndSettle();
      }
      expect(find.text('Compost'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('amount')),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(find.byKey(const ValueKey('amount')), '20');
      await tester.enterText(find.byKey(const ValueKey('unit')), 'kg');
      await tester.enterText(find.byKey(const ValueKey('method')), 'Banda');
      await tester.scrollUntilVisible(
        find.text('Guardar actividad'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Guardar actividad'));
      await tester.pumpAndSettle();

      final labor = await database.select(database.labors).getSingle();
      expect(labor.type, LaborType.fertilization.name);
      expect(labor.syncState, 'pending');
      expect(find.textContaining('pendiente de sincronizar'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets('validation failure keeps an offline draft', (tester) async {
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
      find.text('Guardar actividad'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Guardar actividad'));
    await tester.pumpAndSettle();

    expect(await database.select(database.labors).get(), isEmpty);
    expect(await database.select(database.formDrafts).get(), hasLength(1));
    expect(find.textContaining('borrador se conservó'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
