import 'dart:convert';

import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/features/weather/domain/weather_snapshot.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class WeatherSummaryCard extends ConsumerWidget {
  const WeatherSummaryCard({required this.ownerId, super.key});
  final String ownerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(appDatabaseProvider);
    return StreamBuilder(
      stream:
          (database.select(database.weatherCache)
                ..where((row) => row.ownerId.equals(ownerId))
                ..orderBy([(row) => OrderingTerm.desc(row.fetchedAt)]))
              .watchSingleOrNull(),
      builder: (context, snapshot) {
        final row = snapshot.data;
        if (row == null) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.cloud_off_outlined),
              title: Text('Clima sin datos todavía'),
              subtitle: Text('El trabajo offline sigue disponible.'),
            ),
          );
        }
        final weather = WeatherSnapshot.fromJson(
          jsonDecode(row.payloadJson) as Map<String, dynamic>,
        );
        return Card(
          child: ListTile(
            leading: const Icon(Icons.wb_cloudy_outlined),
            title: Text(
              '${weather.temperatureC.toStringAsFixed(1)} °C · ${weather.summary}',
            ),
            subtitle: Text(
              '${weather.locality} · Humedad ${weather.humidityPercent}% · Lluvia ${weather.rainMillimeters} mm\nActualizado ${weather.fetchedAt.toLocal()}',
            ),
          ),
        );
      },
    );
  }
}
