import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo/features/weather/data/weather_gateway.dart';
import 'package:agrocampo/features/weather/data/weather_repository.dart';
import 'package:agrocampo/features/weather/domain/weather_snapshot.dart';
import 'package:agrocampo/features/weather/presentation/weather_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

final class _Gateway implements WeatherGateway {
  _Gateway({required this.snapshot, this.fail = false});

  final WeatherSnapshot snapshot;
  final bool fail;

  @override
  Future<WeatherSnapshot> fetch({
    required String locality,
    String? parcelId,
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
              parcelId: 'parcel-1',
              locality: 'Curicó',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('18.5 °C'), findsOneWidget);
    expect(find.text('Nublado'), findsOneWidget);
    expect(find.text('74 %'), findsOneWidget);
    expect(find.text('Alerta vigente'), findsOneWidget);
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
      parcelId: 'parcel-1',
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
              parcelId: 'parcel-1',
              locality: 'Curicó',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('por actualizar'), findsOneWidget);
    expect(find.text('Por actualizar'), findsOneWidget);
    expect(find.text('Alerta vigente'), findsNothing);
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
              parcelId: 'parcel-1',
              locality: 'Curicó',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Clima sin datos'), findsOneWidget);
    expect(find.byTooltip('Actualizar clima'), findsOneWidget);
    expect(find.text('Sin datos'), findsNWidgets(2));
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
  alerts: alerts,
);
