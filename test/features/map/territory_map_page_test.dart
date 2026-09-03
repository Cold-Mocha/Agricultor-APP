import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/database/daos/app_preferences_dao.dart';
import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/map/presentation/territory_map_page.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:agrocampo/features/sectors/data/sector_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  testWidgets(
    'uses OpenStreetMap tiles and renders persisted Drift geometry offline',
    (tester) async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      final parcelId = await ParcelRepository(database)
          .save(ownerId: 'owner-1', name: 'Campo mapa', isActive: true);
      final sectorId = await SectorRepository(database).save(
        ownerId: 'owner-1',
        parcelId: parcelId,
        number: 1,
        name: 'Sector guardado',
        polygon: const [
          GeoPoint(-38.74, -72.60),
          GeoPoint(-38.74, -72.59),
          GeoPoint(-38.73, -72.59),
        ],
      );
      await _selectContext(database, parcelId, sectorId);
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
          RegExp('Mapa territorial de OpenStreetMap con geometrías locales'),
        ),
        findsOneWidget,
      );
      final tileLayer = tester.widget<TileLayer>(find.byType(TileLayer));
      expect(
        tileLayer.urlTemplate,
        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      );
      expect(
        tileLayer.tileProvider.headers['User-Agent'],
        'flutter_map (cl.agrocampo.app)',
      );
      expect(find.text('OpenStreetMap contributors'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Lista textual de cuadrantes guardados'),
        findsOneWidget,
      );
      final polygonLayer = tester.widget<PolygonLayer<String>>(
        find.byType(PolygonLayer<String>),
      );
      expect(polygonLayer.polygons, hasLength(1));
      expect(find.text('Nuevo cuadrante'), findsOneWidget);

      await tester.tap(
        find.bySemanticsLabel(
          RegExp('Mapa territorial de OpenStreetMap con geometrías locales'),
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
    final parcelId = await ParcelRepository(database)
        .save(ownerId: 'owner-1', name: 'Campo mapa', isActive: true);
    final sectorId = await SectorRepository(database).save(
      ownerId: 'owner-1',
      parcelId: parcelId,
      number: 1,
      name: 'Sector guardado',
      polygon: const [
        GeoPoint(-38.74, -72.60),
        GeoPoint(-38.74, -72.59),
        GeoPoint(-38.73, -72.59),
      ],
    );
    await _selectContext(database, parcelId, sectorId);
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
}

Future<void> _selectContext(
  AppDatabase database,
  String parcelId,
  String sectorId,
) async {
  final preferences = AppPreferencesDao(database);
  await preferences.write('owner-1', 'active_parcel_id', parcelId);
  await preferences.write('owner-1', 'active_sector_id', sectorId);
}

final class _TransparentTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(
    TileCoordinates coordinates,
    TileLayer options,
  ) => MemoryImage(TileProvider.transparentImage);
}
