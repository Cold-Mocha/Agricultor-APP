import 'package:agrocampo/src/modules/apiary/presentation/pages/apiary_inspection_page.dart';
import 'package:agrocampo/src/modules/agricultural_context/presentation/controllers/agricultural_context_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';
import '../../../../backend/test/helpers/territory_fixture.dart';
import '../../helpers/signed_in_widget_scope.dart';

void main() {
  testWidgets('apiary page exposes task-specific fields and persists offline', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    final container = signedInWidgetContainer(database);
    addTearDown(database.close);
    addTearDown(container.dispose);
    await seedTerritoryFixture(database);
    await database.customUpdate(
      'UPDATE sectors SET kind = ? WHERE id = ?',
      variables: const [
        Variable<String>('apiary'),
        Variable<String>('sector-1'),
      ],
    );
    final contextController = container.read(
      agriculturalContextControllerProvider.notifier,
    );
    await contextController.restore('owner-1');
    await contextController.selectParcel('parcel-1');
    await contextController.selectSector('sector-1');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: ApiaryInspectionPage(sectorId: 'sector-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('apiary-Apicultor responsable')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byKey(const ValueKey('apiary-Apicultor responsable')),
      'Responsable local',
    );
    await tester.enterText(
      find.byKey(const ValueKey('apiary-Cantidad de colmenas')),
      '8',
    );
    await tester.enterText(
      find.byKey(const ValueKey('apiary-Estado de la reina')),
      'Presente',
    );
    await tester.enterText(
      find.byKey(const ValueKey('apiary-Postura')),
      'Normal',
    );
    final saveButton = find.ancestor(
      of: find.text('Guardar revisión'),
      matching: find.byType(FilledButton),
    );
    await tester.scrollUntilVisible(
      saveButton,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -100));
    await tester.pump();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(
      await database.select(database.apiaryInspections).get(),
      hasLength(1),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
