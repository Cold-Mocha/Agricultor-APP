import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/modules/history/presentation/pages/history_page.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';
import '../../helpers/signed_in_widget_scope.dart';

void main() {
  testWidgets('history separates equal-number active and retired identities', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    // master.md / Historial: groups and references distinguish reused numbers.
    final database = createInMemoryDatabase();
    final container = signedInWidgetContainer(database);
    addTearDown(database.close);
    addTearDown(container.dispose);
    // UUIDv7 identities created close together can share their timestamp
    // prefix. Their references must use the random suffix instead.
    const active = '019abcde-0000-7000-8000-000000000001';
    const retiredA = '019abcde-0000-7000-8000-000000000002';
    const retiredB = '019abcde-0000-7000-8000-000000000003';
    for (final id in [active, retiredA, retiredB]) {
      await database
          .into(database.sectors)
          .insert(
            SectorsCompanion.insert(
              id: id,
              ownerId: 'owner-1',
              number: 4,
              name: 'Cuadrante 4',
              polygonJson: '[]',
              areaSquareMeters: 43,
              updatedAt: DateTime.utc(2026),
              deletedAt: id == active
                  ? const Value.absent()
                  : Value(DateTime.utc(2026, 10, 13)),
            ),
          );
      await database
          .into(database.agriculturalSeasons)
          .insert(
            AgriculturalSeasonsCompanion.insert(
              id: 'season-$id',
              ownerId: 'owner-1',
              sectorId: id,
              name: id == active
                  ? 'Temporada activa'
                  : 'Temporada retirada ${id == retiredA ? 'A' : 'B'}',
              startsOn: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          );
      await database
          .into(database.labors)
          .insert(
            LaborsCompanion.insert(
              id: 'labor-$id',
              ownerId: 'owner-1',
              sectorId: id,
              seasonId: Value('season-$id'),
              type: 'other',
              customName: Value(
                id == active
                    ? 'Registro activo'
                    : 'Registro retirado ${id == retiredA ? 'A' : 'B'}',
              ),
              occurredAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          );
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AgroTheme.light, home: const HistoryPage()),
      ),
    );
    await tester.pumpAndSettle();
    final dropdown = tester.widget<DropdownButton<String>>(
      find.descendant(
        of: find.byType(DropdownButtonFormField<String>).first,
        matching: find.byType(DropdownButton<String>),
      ),
    );
    final items = dropdown.items!;
    expect(items.map((item) => item.value), [
      '__all__',
      '__active_group__',
      active,
      '__retired_group__',
      retiredA,
      retiredB,
    ]);
    expect(
      items
          .where((item) => !item.enabled)
          .map((item) => (item.child as Text).data),
      ['Sectores activos', 'Sectores retirados'],
    );
    final retiredLabels = items
        .where((item) => item.value == retiredA || item.value == retiredB)
        .map((item) => (item.child as Text).data!)
        .toList();
    expect(retiredLabels.toSet(), hasLength(2));
    expect(
      retiredLabels.every((label) => label.contains('Retirado · Ref.')),
      isTrue,
    );

    DropdownButton<String> sectorDropdown() =>
        tester.widget<DropdownButton<String>>(
          find.descendant(
            of: find.byType(DropdownButtonFormField<String>).first,
            matching: find.byType(DropdownButton<String>),
          ),
        );
    Future<void> chooseScope(String current, String next) async {
      await tester.tap(find.text(current).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(next).last);
      await tester.pumpAndSettle();
    }

    await chooseScope('Todos', 'Retirados');
    expect(sectorDropdown().items!.map((item) => item.value), [
      '__all__',
      retiredA,
      retiredB,
    ]);
    expect(find.text('Todos los sectores retirados'), findsWidgets);
    expect(find.text('Registro retirado A'), findsOneWidget);
    expect(find.text('Registro retirado B'), findsOneWidget);
    expect(find.text('Registro activo'), findsNothing);

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Ref. 00000002').last);
    await tester.pumpAndSettle();
    expect(find.text('Registro retirado B'), findsNothing);
    expect(find.text('Registro retirado A'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Temporada retirada A').last);
    await tester.pumpAndSettle();

    await chooseScope('Retirados', 'Activos');
    expect(sectorDropdown().value, '__all__');
    expect(sectorDropdown().items!.map((item) => item.value), [
      '__all__',
      active,
    ]);
    expect(find.text('Todas las temporadas'), findsWidgets);
    expect(find.text('Registro activo'), findsOneWidget);
    expect(find.text('Registro retirado A'), findsNothing);
    expect(find.text('Registro retirado B'), findsNothing);

    await chooseScope('Activos', 'Todos');
    expect(sectorDropdown().value, '__all__');
    expect(find.text('Registro activo'), findsOneWidget);
    expect(find.text('Registro retirado A'), findsOneWidget);
    expect(find.text('Registro retirado B'), findsOneWidget);

    // Empty groups retain the control that lets the user recover.
    await (database.update(database.sectors)
          ..where((row) => row.id.equals(active)))
        .write(SectorsCompanion(deletedAt: Value(DateTime.utc(2026))));
    await tester.pumpAndSettle();
    await chooseScope('Todos', 'Activos');
    expect(sectorDropdown().items!.map((item) => item.value), ['__all__']);
    expect(find.text('Sin registros para este filtro'), findsOneWidget);
    await chooseScope('Activos', 'Retirados');
    expect(find.text('Registro activo'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
