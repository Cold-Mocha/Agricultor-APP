import 'package:agrocampo/features/history/presentation/history_page.dart';
import 'package:agrocampo/features/labors/data/labor_repository.dart';
import 'package:agrocampo/features/labors/domain/fertilization_details.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/signed_in_widget_scope.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  testWidgets(
    'timeline exposes historical labels, filters and truthful sync state',
    (tester) async {
      final database = createInMemoryDatabase();
      final container = signedInWidgetContainer(database);
      addTearDown(database.close);
      addTearDown(container.dispose);
      await seedAgriculturalContextFixture(database);
      await LaborRepository(database).save(
        ownerId: 'owner-1',
        parcelId: 'parcel-1',
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
        find.byTooltip('Guardado localmente; pendiente de sincronizar'),
        findsNWidgets(2),
      );
      await tester.tap(find.text('Cultivos'));
      await tester.pumpAndSettle();
      expect(find.text('Cultivo asignado'), findsOneWidget);
      expect(find.text('Fertilización'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
