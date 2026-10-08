import 'dart:io';

import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../backend/test/helpers/in_memory_database.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android renders the required sector selector at touch size', (
    tester,
  ) async {
    expect(Platform.isAndroid, isTrue);
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await SectorRepository(database).save(
      ownerId: 'owner-1',
      number: 1,
      name: 'Cuadrante 1',
      polygon: const [
        GeoPoint(-38.74, -72.60),
        GeoPoint(-38.74, -72.59),
        GeoPoint(-38.73, -72.59),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
        ],
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AgroSpacing.md),
                child: AgriculturalContextSelector(requireSector: true),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('active-parcel-selector')), findsNothing);
    expect(find.text('Sector requerido'), findsOneWidget);
    final sector = find.byKey(const Key('active-sector-selector'));
    final sectorRect = tester.getRect(sector);
    expect(sectorRect.height, greaterThanOrEqualTo(AgroSizes.touchTarget));
    expect(tester.takeException(), isNull);

    await tester.tap(sector);
    await tester.pumpAndSettle();
    final sectorOption = find.text('Cuadrante 1').last;
    expect(sectorOption, findsOneWidget);
    await tester.tap(sectorOption);
    await tester.pumpAndSettle();
    expect(find.text('Cuadrante 1'), findsOneWidget);
    expect(tester.takeException(), isNull);

    const holdForVisualInspection = bool.fromEnvironment(
      'AGROCAMPO_CAPTURE_UI',
    );
    if (holdForVisualInspection) {
      await Future<void>.delayed(const Duration(seconds: 30));
    }
  });

  testWidgets('Android keeps the sector selector usable with large text', (
    tester,
  ) async {
    expect(Platform.isAndroid, isTrue);
    final database = createInMemoryDatabase();
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
        ],
        child: MaterialApp(
          theme: AgroTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AgroSpacing.md),
                child: AgriculturalContextSelector(requireSector: true),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final sectorRect = tester.getRect(
      find.byKey(const Key('active-sector-selector')),
    );
    expect(sectorRect.height, greaterThanOrEqualTo(AgroSizes.touchTarget));
    expect(tester.takeException(), isNull);
  });
}
