import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../backend/test/helpers/in_memory_database.dart';

void main() {
  testWidgets('shows sector labels and never exposes raw ids', (tester) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final sectorId = await tester.runAsync(
      () => SectorRepository(database).save(
        ownerId: 'owner-1',
        number: 1,
        name: 'Cuadrante El Molino',
        polygon: const [
          GeoPoint(-38.74, -72.60),
          GeoPoint(-38.74, -72.59),
          GeoPoint(-38.73, -72.59),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AgriculturalContextSelector()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(RegExp('^Contexto agrícola activo')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('active-sector-selector')));
    await tester.pumpAndSettle();

    expect(find.text('Cuadrante El Molino'), findsWidgets);
    expect(find.text(sectorId!), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('offers only the sector selector on a standard phone', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: AgroSpacing.md),
              child: AgriculturalContextSelector(requireSector: true),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final sector = find.byKey(const Key('active-sector-selector'));
    expect(sector, findsOneWidget);
    expect(find.byKey(const Key('active-parcel-selector')), findsNothing);
    expect(tester.getSize(sector).height, greaterThanOrEqualTo(48));
    expect(tester.getTopLeft(sector).dy, AgroSpacing.xs);
    expect(find.text('Sector requerido'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('keeps the selector usable when system text is enlarged', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await tester.binding.setSurfaceSize(const Size(412, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: Scaffold(
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: AgroSpacing.md),
                child: AgriculturalContextSelector(requireSector: true),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('active-sector-selector')), findsOneWidget);
    expect(find.text('Sector requerido'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
