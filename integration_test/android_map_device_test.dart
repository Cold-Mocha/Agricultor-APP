import 'dart:io';

import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/database/daos/app_preferences_dao.dart';
import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/map/data/location_gateway.dart';
import 'package:agrocampo/features/map/presentation/territory_map_page.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:agrocampo/features/sectors/data/sector_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/in_memory_database.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android uses live OSM, foreground GPS and persisted polygon editing',
    (tester) async {
      final location = await GeolocatorLocationGateway().currentPosition();
      expect(location.latitude, inInclusiveRange(-90, 90));
      expect(location.longitude, inInclusiveRange(-180, 180));

      final tileClient = HttpClient()
        ..userAgent = 'flutter_map (cl.agrocampo.app)';
      addTearDown(() => tileClient.close(force: true));
      final tileRequest = await tileClient
          .getUrl(Uri.parse('https://tile.openstreetmap.org/0/0/0.png'))
          .timeout(const Duration(seconds: 10));
      tileRequest.headers.set(
        HttpHeaders.userAgentHeader,
        'flutter_map (cl.agrocampo.app)',
      );
      final tileResponse = await tileRequest.close().timeout(
        const Duration(seconds: 10),
      );
      final tileBytes = await tileResponse.fold<int>(
        0,
        (total, chunk) => total + chunk.length,
      );
      expect(tileResponse.statusCode, HttpStatus.ok);
      expect(tileResponse.headers.contentType?.mimeType, 'image/png');
      expect(tileBytes, greaterThan(100));

      final database = createInMemoryDatabase();
      addTearDown(database.close);
      final parcelId = await ParcelRepository(database).save(
        ownerId: 'owner-device-test',
        name: 'Campo prueba Android',
        isActive: true,
      );
      final sectorId = await SectorRepository(database).save(
        ownerId: 'owner-device-test',
        parcelId: parcelId,
        number: 1,
        name: 'Sector prueba Android',
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
            unlockedOwnerIdProvider.overrideWithValue('owner-device-test'),
          ],
          child: const MaterialApp(home: TerritoryMapPage()),
        ),
      );
      await tester.pump();
      for (var second = 0; second < 8; second++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(
        find.bySemanticsLabel(
          RegExp('Mapa territorial de OpenStreetMap con geometrías locales'),
        ),
        findsOneWidget,
      );
      expect(find.byType(TileLayer), findsOneWidget);
      expect(find.byType(PolygonLayer<String>), findsOneWidget);
      expect(find.text('© OpenStreetMap contributors'), findsOneWidget);
      expect(
        find.textContaining('Los tiles no están disponibles'),
        findsNothing,
      );

      await tester.tap(find.byTooltip('Usar mi ubicación'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(find.textContaining('Ubicación no disponible'), findsNothing);
      expect(
        find.textContaining('Permiso de ubicación denegado'),
        findsNothing,
      );

      await tester.tap(find.text('Editar'));
      await tester.pump();
      await tester.tap(find.byTooltip('Mover vértice al norte'));
      await tester.tap(find.text('Cancelar'));
      await tester.pump();
      expect(
        (await database.select(database.sectors).getSingle()).polygonJson,
        original.polygonJson,
      );

      await tester.tap(find.text('Editar'));
      await tester.pump();
      await tester.tap(find.byTooltip('Mover vértice al este'));
      await tester.tap(find.text('Confirmar'));
      await tester.pump();
      expect(
        (await database.select(database.sectors).getSingle()).polygonJson,
        isNot(original.polygonJson),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}

Future<void> _selectContext(
  AppDatabase database,
  String parcelId,
  String sectorId,
) async {
  final preferences = AppPreferencesDao(database);
  await preferences.write('owner-device-test', 'active_parcel_id', parcelId);
  await preferences.write('owner-device-test', 'active_sector_id', sectorId);
}
