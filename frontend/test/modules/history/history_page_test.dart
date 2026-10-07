import 'package:agrocampo/src/modules/history/presentation/pages/history_page.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/fertilization_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';
import 'package:agrocampo_backend/src/modules/labors/infrastructure/persistence/labor_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';
import '../../../../backend/test/helpers/territory_fixture.dart';
import '../../helpers/signed_in_widget_scope.dart';

void main() {
  testWidgets(
    'timeline exposes historical labels and filters without sync state',
    (tester) async {
      final database = createInMemoryDatabase();
      final container = signedInWidgetContainer(database);
      addTearDown(database.close);
      addTearDown(container.dispose);
      await seedAgriculturalContextFixture(database);
      await LaborRepository(database).save(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        type: LaborType.fertilization,
        occurredAt: DateTime.utc(2026, 2),
        details: const FertilizationDetails(
          product: 'Compost',
          amount: 20,
          unit: 'kg',
          applicationMethod: 'Banda',
        ).toEnvelope(),
        notes: 'Aplicación norte',
      );
      await selectFixtureAgriculturalContext(container);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: HistoryPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Temporada 2025/26'), findsOneWidget);
      expect(find.text('Fertilización'), findsOneWidget);
      expect(find.textContaining('Trigo'), findsNWidgets(2));
      expect(
        find.textContaining('sincroniz'),
        findsNothing,
        reason: 'sync runs in the background and is not shown',
      );
      await tester.tap(find.text('Cultivos'));
      await tester.pumpAndSettle();
      expect(find.text('Cultivo asignado'), findsOneWidget);
      expect(find.text('Fertilización'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets(
    'only recorded labors with a generic edit form offer correction',
    (tester) async {
      final database = createInMemoryDatabase();
      final container = signedInWidgetContainer(database);
      addTearDown(database.close);
      addTearDown(container.dispose);
      await seedAgriculturalContextFixture(database);
      await LaborRepository(database).save(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        type: LaborType.fertilization,
        occurredAt: DateTime.utc(2026, 2),
        details: const FertilizationDetails(
          product: 'Compost',
          amount: 20,
          unit: 'kg',
          applicationMethod: 'Banda',
        ).toEnvelope(),
        notes: 'Aplicación norte',
      );
      await LaborRepository(database).save(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        type: LaborType.soil,
        occurredAt: DateTime.utc(2026, 2, 2),
      );
      await selectFixtureAgriculturalContext(container);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: HistoryPage()),
        ),
      );
      await tester.pumpAndSettle();

      final fertilizationTile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text('Fertilización'),
          matching: find.byType(ListTile),
        ),
      );
      expect(fertilizationTile.onTap, isNotNull);
      expect(fertilizationTile.trailing, isA<Icon>());

      final soilTile = tester.widget<ListTile>(
        find.ancestor(of: find.text('Suelo'), matching: find.byType(ListTile)),
      );
      expect(soilTile.onTap, isNull);
      expect(soilTile.trailing, isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
