import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/home/presentation/pages/home_page.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:agrocampo_backend/src/modules/weather/domain/entities/weather_snapshot.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_gateway.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_repository.dart';
import 'package:agrocampo_backend/src/platform/network/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';

final class _OfflineWeather implements WeatherGateway {
  @override
  Future<WeatherSnapshot> fetch({required String locality, String? sectorId}) =>
      Future.error(StateError('offline'));
}

final class _OnlineConnectivity implements ConnectivityService {
  @override
  Stream<ConnectionSignal> watch() => Stream.value(ConnectionSignal.available);
}

void main() {
  testWidgets('Inicio shows the active sector without field actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = createInMemoryDatabase();
    await tester.runAsync(
      () => SectorRepository(database).save(
        ownerId: 'owner-1',
        number: 1,
        name: 'Curicó',
        polygon: const [
          GeoPoint(-34.98, -71.24),
          GeoPoint(-34.98, -71.23),
          GeoPoint(-34.97, -71.23),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
          connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
          weatherRepositoryProvider.overrideWithValue(
            WeatherRepository(database, _OfflineWeather()),
          ),
        ],
        child: MaterialApp(theme: AgroTheme.light, home: const HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tu campo hoy'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Resumen del historial'), 200);
    expect(find.text('Resumen del historial'), findsOneWidget);
    expect(find.text('Curicó'), findsOneWidget);
    expect(find.text('Ver cuadrantes'), findsOneWidget);
    // Field actions live in each quadrant's detail, not on Inicio.
    expect(find.text('Labores'), findsNothing);
    expect(find.text('Riego'), findsNothing);
    expect(find.text('Fertilización'), findsNothing);
    expect(find.text('Modo local-first activo'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });

  testWidgets('Inicio invites to draw the first sector', (tester) async {
    final database = createInMemoryDatabase();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
        ],
        child: MaterialApp(theme: AgroTheme.light, home: const HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dibuja tu primer cuadrante'), findsOneWidget);
    expect(find.text('Abrir mapa'), findsOneWidget);
    expect(find.textContaining('parcela'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });
}
