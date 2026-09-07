import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/shared/presentation/components/agricultural_context_selector.dart';
import 'package:agrocampo_backend/core/config/backend_providers.dart';
import 'package:agrocampo_backend/features/auth/controllers/session_controller.dart';
import 'package:agrocampo_backend/features/parcels/repositories/parcel_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../backend/test/helpers/in_memory_database.dart';

void main() {
  testWidgets('shows agricultural labels and never exposes raw ids', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final parcelId = await ParcelRepository(database)
        .save(ownerId: 'owner-1', name: 'Parcela El Molino', isActive: true);

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

    expect(find.text('Parcela El Molino'), findsOneWidget);
    expect(find.text(parcelId), findsNothing);
    expect(find.bySemanticsLabel('Contexto agrícola activo'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('places parcel and sector side by side on a standard phone', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await ParcelRepository(database)
        .save(ownerId: 'owner-1', name: 'Parcela El Molino', isActive: true);
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

    expect(find.byKey(const Key('agricultural-context-row')), findsOneWidget);
    final parcel = find.byKey(const Key('active-parcel-selector'));
    final sector = find.byKey(const Key('active-sector-selector'));
    expect(tester.getTopLeft(parcel).dy, tester.getTopLeft(sector).dy);
    expect(
      tester.getTopLeft(parcel).dx,
      lessThan(tester.getTopLeft(sector).dx),
    );
    expect(tester.getSize(parcel).height, greaterThanOrEqualTo(48));
    expect(tester.getTopLeft(parcel).dy, AgroSpacing.xs);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('stacks the selectors when the available width is too narrow', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await ParcelRepository(database)
        .save(ownerId: 'owner-1', name: 'Parcela El Molino', isActive: true);
    await tester.binding.setSurfaceSize(const Size(300, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

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
      find.byKey(const Key('agricultural-context-column')),
      findsOneWidget,
    );
    final parcelTop = tester.getTopLeft(
      find.byKey(const Key('active-parcel-selector')),
    );
    final sectorTop = tester.getTopLeft(
      find.byKey(const Key('active-sector-selector')),
    );
    expect(sectorTop.dy, greaterThan(parcelTop.dy));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('stacks the selectors when system text is enlarged', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await ParcelRepository(database)
        .save(ownerId: 'owner-1', name: 'Parcela El Molino', isActive: true);
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

    expect(
      find.byKey(const Key('agricultural-context-column')),
      findsOneWidget,
    );
    expect(find.text('Sector requerido'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
