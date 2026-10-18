import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/modules/weather/presentation/widgets/weather_summary_card.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart'
    show isLocalModeProvider;
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/weather/domain/entities/weather_snapshot.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_gateway.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';

final class _Gateway implements WeatherGateway {
  _Gateway({required this.snapshot, this.fail = false});

  final WeatherSnapshot snapshot;
  final bool fail;

  @override
  Future<WeatherSnapshot> fetch({
    required String locality,
    String? sectorId,
  }) async {
    if (fail) throw StateError('offline');
    return snapshot;
  }
}

void main() {
  testWidgets('shows fresh weather and only an active frost alert', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final now = DateTime.now().toUtc();
    final repository = WeatherRepository(
      database,
      _Gateway(
        snapshot: _snapshot(
          now: now,
          expiresAt: now.add(const Duration(hours: 1)),
          alerts: [
            WeatherAlert(
              id: 'frost',
              title: 'Helada',
              severity: 'moderate',
              startsAt: now.subtract(const Duration(minutes: 10)),
              endsAt: now.add(const Duration(hours: 2)),
              condition: 'frost',
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [weatherRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          home: Scaffold(
            body: WeatherSummaryCard(
              ownerId: 'owner-1',
              sectorId: 'sector-1',
              locality: 'Curicó',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('19°'), findsOneWidget);
    expect(find.text('Nublado'), findsOneWidget);
    expect(find.text('24°/9°'), findsOneWidget, reason: 'today max/min');
    expect(find.text('Curicó'), findsOneWidget);
    expect(find.text('Alerta de helada vigente'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^[A-ZÁÉ]{3}: Lluvia ligera')),
      findsNWidgets(2),
      reason: 'the strip lists only the days after today',
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.link == true &&
            widget.properties.label == 'Abrir fuente meteorológica: Datos meteorológicos por Open-Meteo.com',
      ),
      findsOneWidget,
    );
  });

  testWidgets('stale cache never presents an expired frost state as current', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final old = DateTime.now().toUtc().subtract(const Duration(days: 2));
    final cachedRepository = WeatherRepository(
      database,
      _Gateway(
        snapshot: _snapshot(
          now: old,
          expiresAt: old.add(const Duration(hours: 1)),
          alerts: [
            WeatherAlert(
              id: 'old-frost',
              title: 'Helada',
              severity: 'moderate',
              startsAt: old,
              endsAt: old.add(const Duration(hours: 1)),
            ),
          ],
        ),
      ),
    );
    await cachedRepository.refresh(
      ownerId: 'owner-1',
      sectorId: 'sector-1',
      locality: 'Curicó',
    );
    final offlineRepository = WeatherRepository(
      database,
      _Gateway(
        snapshot: _snapshot(now: old, expiresAt: old),
        fail: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weatherRepositoryProvider.overrideWithValue(offlineRepository),
        ],
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const Scaffold(
            body: WeatherSummaryCard(
              ownerId: 'owner-1',
              sectorId: 'sector-1',
              locality: 'Curicó',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('por actualizar'), findsOneWidget);
    expect(find.text('Alerta de helada vigente'), findsNothing);
  });

  testWidgets('keeps local work understandable when no weather exists', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final now = DateTime.now().toUtc();
    final repository = WeatherRepository(
      database,
      _Gateway(
        snapshot: _snapshot(now: now, expiresAt: now),
        fail: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [weatherRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const Scaffold(
            body: WeatherSummaryCard(
              ownerId: 'owner-1',
              sectorId: 'sector-1',
              locality: 'Curicó',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Clima sin datos'), findsOneWidget);
    expect(find.byTooltip('Actualizar clima'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('local mode explains weather needs the cloud and hides refresh', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final now = DateTime.now().toUtc();
    final repository = WeatherRepository(
      database,
      _Gateway(
        snapshot: _snapshot(now: now, expiresAt: now),
        fail: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isLocalModeProvider.overrideWithValue(true),
          weatherRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const Scaffold(
            body: WeatherSummaryCard(
              ownerId: 'owner-1',
              sectorId: 'sector-1',
              locality: 'Curicó',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Disponible al activar el respaldo en la nube.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Actualizar clima'), findsNothing);
  });
}

WeatherSnapshot _snapshot({
  required DateTime now,
  required DateTime expiresAt,
  List<WeatherAlert> alerts = const [],
}) => WeatherSnapshot(
  locality: 'Curicó',
  temperatureC: 18.5,
  humidityPercent: 74,
  rainMillimeters: 0,
  summary: 'Nublado',
  fetchedAt: now,
  expiresAt: expiresAt,
  provider: 'open-meteo',
  attribution: 'Datos meteorológicos por Open-Meteo.com',
  attributionUrl: 'https://open-meteo.com/',
  forecast: [
    for (var offset = 0; offset < 3; offset++)
      WeatherForecastDay(
        date: DateTime.now().add(Duration(days: offset)),
        minimumC: 9,
        maximumC: 24,
        rainChancePercent: 40,
        summary: offset == 0 ? 'Nublado' : 'Lluvia ligera',
      ),
  ],
  alerts: alerts,
);
