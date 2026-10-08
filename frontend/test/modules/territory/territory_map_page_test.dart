import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/territory/presentation/pages/territory_map_page.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/agricultural_context/infrastructure/persistence/daos/app_preferences_dao.dart';
import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';

void main() {
  testWidgets(
    'uses satellite tiles and renders persisted Drift geometry offline',
    (tester) async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      final sectorId = await SectorRepository(database).save(
        ownerId: 'owner-1',
        number: 1,
        name: 'Sector guardado',
        polygon: const [
          GeoPoint(-38.74, -72.60),
          GeoPoint(-38.74, -72.59),
          GeoPoint(-38.73, -72.59),
        ],
      );
      await _selectContext(database, sectorId);
      final before = await database.select(database.sectors).getSingle();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            unlockedOwnerIdProvider.overrideWithValue('owner-1'),
          ],
          child: MaterialApp(
            home: TerritoryMapPage(tileProvider: _TransparentTileProvider()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(
          RegExp('Mapa satelital territorial con tus cuadrantes'),
        ),
        findsOneWidget,
      );
      final tileLayer = tester.widget<TileLayer>(find.byType(TileLayer));
      expect(
        tileLayer.urlTemplate,
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      );
      expect(
        tileLayer.tileProvider.headers['User-Agent'],
        'flutter_map (cl.agrocampo.app)',
      );
      expect(find.text('Esri, Maxar, Earthstar Geographics'), findsOneWidget);
      // The sector selector is the map's textual alternative (master.md).
      expect(
        find.bySemanticsLabel('Lista textual de cuadrantes guardados'),
        findsNothing,
      );
      expect(find.byKey(const Key('active-sector-selector')), findsOneWidget);
      final polygonLayer = tester.widget<PolygonLayer<String>>(
        find.byType(PolygonLayer<String>),
      );
      expect(polygonLayer.polygons, hasLength(1));
      expect(find.text('Nuevo cuadrante'), findsOneWidget);

      await tester.tap(
        find.bySemanticsLabel(
          RegExp('Mapa satelital territorial con tus cuadrantes'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      final after = await database.select(database.sectors).getSingle();
      expect(after.polygonJson, before.polygonJson);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets('cancel preserves geometry and confirm persists vertex edits', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final sectorId = await SectorRepository(database).save(
      ownerId: 'owner-1',
      number: 1,
      name: 'Sector guardado',
      polygon: const [
        GeoPoint(-38.74, -72.60),
        GeoPoint(-38.74, -72.59),
        GeoPoint(-38.73, -72.59),
      ],
    );
    await _selectContext(database, sectorId);
    final original = await database.select(database.sectors).getSingle();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
        ],
        child: MaterialApp(
          home: TerritoryMapPage(tileProvider: _TransparentTileProvider()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Editar'));
    await tester.pump();
    await tester.tap(find.byTooltip('Mover vértice al norte'));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(
      (await database.select(database.sectors).getSingle()).polygonJson,
      original.polygonJson,
    );

    await tester.tap(find.text('Editar'));
    await tester.pump();
    await tester.tap(find.byTooltip('Mover vértice al este'));
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(
      (await database.select(database.sectors).getSingle()).polygonJson,
      isNot(original.polygonJson),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('hides view and edit actions when there is no quadrant', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
        ],
        child: MaterialApp(
          home: TerritoryMapPage(tileProvider: _TransparentTileProvider()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ver cuadrante'), findsNothing);
    expect(find.text('Editar'), findsNothing);
    expect(find.text('Ningún cuadrante seleccionado'), findsNothing);
    expect(
      find.ancestor(
        of: find.text('Nuevo cuadrante'),
        matching: find.byType(Card),
      ),
      findsNothing,
      reason: 'the idle action floats without a white card',
    );
    expect(find.byTooltip('Usar mi ubicación'), findsNothing);
    expect(find.text('Nuevo cuadrante'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('new quadrant uses a pill category switch without arrows', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
        ],
        child: MaterialApp(
          home: TerritoryMapPage(tileProvider: _TransparentTileProvider()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nuevo cuadrante'));
    await tester.pumpAndSettle();
    expect(find.text('Agrega al menos tres puntos.'), findsNothing);
    final origin = tester.getTopLeft(find.byType(FlutterMap));
    for (final offset in const [
      Offset(40, 40),
      Offset(160, 40),
      Offset(100, 120),
    ]) {
      await tester.tapAt(origin + offset);
      // flutter_map reports a tap only after the double-tap window closes.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
    }

    expect(find.byTooltip('Mover vértice al norte'), findsNothing);
    expect(find.text('Categoría obligatoria'), findsNothing);
    expect(find.textContaining('Tamaño cuadrante: '), findsOneWidget);
    expect(find.text('Vegetal'), findsOneWidget);
    expect(find.text('Apícola'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Vegetal')),
      isSemantics(isSelected: true, isButton: true, label: 'Vegetal'),
      reason: 'Vegetal is preselected for a new quadrant',
    );
    expect(tester.takeException(), isNull, reason: 'no layout overflow');

    await tester.tap(find.text('Apícola'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Apícola')),
      isSemantics(isSelected: true, isButton: true, label: 'Apícola'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('confirming a crop quadrant asks for its crop and assigns it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/sectores/mapa',
            routes: [
              GoRoute(
                path: '/sectores',
                builder: (_, _) => const Scaffold(body: Text('Lista destino')),
                routes: [
                  GoRoute(
                    path: 'mapa',
                    builder: (_, _) => TerritoryMapPage(
                      tileProvider: _TransparentTileProvider(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nuevo cuadrante'));
    await tester.pumpAndSettle();
    final origin = tester.getTopLeft(find.byType(FlutterMap));
    for (final offset in const [
      Offset(40, 40),
      Offset(160, 40),
      Offset(100, 120),
    ]) {
      await tester.tapAt(origin + offset);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Confirmar'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();

    expect(find.text('¿Qué cultivas en este cuadrante?'), findsOneWidget);
    final firstCrop = find
        .descendant(of: find.byType(ListTile), matching: find.byType(Text))
        .first;
    final cropLabel = tester.widget<Text>(firstCrop).data!;
    await tester.tap(firstCrop);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();

    final assignment = await tester.runAsync(
      () => database.select(database.cropSeasons).getSingle(),
    );
    expect(assignment!.status, 'active');
    expect(
      find.text('Cuadrante guardado con $cropLabel como cultivo.'),
      findsOneWidget,
    );
    expect(
      find.text('Lista destino'),
      findsOneWidget,
      reason: 'a new quadrant returns to Tus cuadrantes',
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('cancelling the crop choice does not create the quadrant', (
    tester,
  ) async {
    // The catalog asset is cached by an earlier test's fake clock; reload it.
    rootBundle.clear();
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
        ],
        child: MaterialApp(
          home: TerritoryMapPage(tileProvider: _TransparentTileProvider()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nuevo cuadrante'));
    await tester.pumpAndSettle();
    final origin = tester.getTopLeft(find.byType(FlutterMap));
    for (final offset in const [
      Offset(40, 40),
      Offset(160, 40),
      Offset(100, 120),
    ]) {
      await tester.tapAt(origin + offset);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Confirmar'));
    // The catalog loads from the database before the sheet opens.
    for (var attempt = 0; attempt < 60; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
      if (find.text('¿Qué cultivas en este cuadrante?').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pumpAndSettle();
    expect(find.text('¿Qué cultivas en este cuadrante?'), findsOneWidget);

    await tester.tap(find.text('Cancelar').last);
    await tester.pumpAndSettle();

    final sectors = await tester.runAsync(
      () => database.select(database.sectors).get(),
    );
    expect(sectors, isEmpty, reason: 'no crop chosen, no quadrant created');
    expect(find.text('Confirmar'), findsOneWidget, reason: 'still drawing');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

Future<void> _selectContext(AppDatabase database, String sectorId) async {
  final preferences = AppPreferencesDao(database);
  await preferences.write('owner-1', 'active_sector_id', sectorId);
}

final class _TransparentTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(
    TileCoordinates coordinates,
    TileLayer options,
  ) => MemoryImage(TileProvider.transparentImage);
}
