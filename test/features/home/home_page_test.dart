import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/network/connectivity_service.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/home/presentation/home_page.dart';
import 'package:agrocampo/features/weather/data/weather_gateway.dart';
import 'package:agrocampo/features/weather/data/weather_repository.dart';
import 'package:agrocampo/features/weather/domain/weather_snapshot.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

final class _OfflineWeather implements WeatherGateway {
  @override
  Future<WeatherSnapshot> fetch({required String locality, String? parcelId}) =>
      Future.error(StateError('offline'));
}

final class _OnlineConnectivity implements ConnectivityService {
  @override
  Stream<ConnectionSignal> watch() => Stream.value(ConnectionSignal.available);
}

void main() {
  testWidgets('Inicio prioritizes parcel status and four field labors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = createInMemoryDatabase();
    await database
        .into(database.parcels)
        .insert(
          ParcelsCompanion.insert(
            id: 'parcel-1',
            ownerId: 'owner-1',
            name: 'Parcela El Maitén',
            locality: const Value('Curicó'),
            isActive: const Value(true),
            updatedAt: DateTime.now().toUtc(),
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

    expect(find.text('Tu parcela hoy'), findsOneWidget);
    expect(find.text('Curicó'), findsOneWidget);
    expect(find.text('Ver cuadrantes'), findsOneWidget);
    expect(find.text('Labores'), findsOneWidget);
    expect(find.text('Riego'), findsOneWidget);
    expect(find.text('Suelo'), findsOneWidget);
    expect(find.text('Fertilización'), findsOneWidget);
    expect(find.text('Control de enfermedades y plagas'), findsOneWidget);
    expect(find.text('Modo local-first activo'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });
}
