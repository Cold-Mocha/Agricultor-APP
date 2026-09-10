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
