import 'dart:async';

import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/weather/weather_ui.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_action_tile.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_metric_card.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_section_header.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Today's weather of the active quadrant plus the moon, which is computed on
/// the device and needs no connection.
final class TodayWeatherSection extends ConsumerStatefulWidget {
  const TodayWeatherSection({
    required this.ownerId,
    required this.sectorId,
    required this.label,
    super.key,
  });

  final String ownerId;
  final String sectorId;
  final String label;

  @override
  ConsumerState<TodayWeatherSection> createState() =>
      _TodayWeatherSectionState();
}

final class _TodayWeatherSectionState
    extends ConsumerState<TodayWeatherSection> {
  static const _autoRefresh = Duration(hours: 1);

  late Future<WeatherLoadResult> _weather = _load();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_autoRefresh, (_) => _reload());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<WeatherLoadResult> _load({bool forceRefresh = false}) => ref
      .read(weatherControllerProvider)
      .load(
        ownerId: widget.ownerId,
        locality: widget.label,
        sectorId: widget.sectorId,
        forceRefresh: forceRefresh,
      );

  void _reload() => setState(() => _weather = _load(forceRefresh: true));

  @override
  void didUpdateWidget(covariant TodayWeatherSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sectorId != widget.sectorId) _weather = _load();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<WeatherLoadResult>(
    future: _weather,
    builder: (context, snapshot) {
      final weather = switch (snapshot.data) {
        WeatherFresh(:final snapshot) => snapshot,
        WeatherStale(:final snapshot) => snapshot,
        _ => null,
      };
      final loading = snapshot.connectionState != ConnectionState.done;
      final missing = loading ? 'Cargando…' : 'Sin datos';
      final now = DateTime.now();
      final today = weather == null ? null : _forecastFor(weather, now);
      final frost = weather?.freezingForecastFrom(now);
      final moon = MoonPhase.at(now);
      final milestone = moon.nextMilestone;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AgroSectionHeader(
                  title: 'Clima de hoy',
                  subtitle: '${widget.label} · se actualiza cada hora.',
                ),
              ),
              IconButton(
                tooltip: 'Actualizar clima',
                onPressed: loading ? null : _reload,
                icon: loading
                    ? const SizedBox.square(
                        dimension: AgroSizes.iconStandard,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.refreshCw),
              ),
            ],
          ),
          const SizedBox(height: AgroSpacing.sm),
          AgroAdaptiveGrid(
            columns: 2,
            uniformHeight: true,
            children: [
              AgroMetricCard(
                label: 'Temperatura',
                value: weather == null
                    ? missing
                    : '${weather.temperatureC.round()} °C',
                supportingText: weather?.summary,
                icon: weather == null
                    ? LucideIcons.cloudSun
                    : weatherIconFor(weather.summary),
              ),
              AgroMetricCard(
                label: 'Mín / Máx',
                value: today == null
                    ? missing
                    : '${today.minimumC.round()}° / ${today.maximumC.round()}°',
                supportingText: today == null ? null : 'Pronóstico de hoy',
                icon: LucideIcons.thermometer,
              ),
              AgroMetricCard(
                label: 'Helada',
                value: weather == null
                    ? missing
                    : frost == null
                    ? 'No pronosticada'
                    : 'Pronosticada',
                supportingText: weather == null
                    ? null
                    : frost == null
                    ? 'Según pronóstico, no es alerta oficial.'
                    : '${_dayLabel(frost.date, now)}, mín. ${frost.minimumC.round()} °C. Según pronóstico, no es alerta oficial.',
                icon: LucideIcons.snowflake,
              ),
              AgroMetricCard(
                label: 'Luna',
                value: _moonLabel(moon.name),
                supportingText:
                    '${(moon.illumination * 100).round()} % iluminada · '
                    '${milestone.full ? 'Llena' : 'Nueva'} el ${_date(milestone.at)}',
                icon: LucideIcons.moon,
              ),
            ],
          ),
          if (weather != null && weather.forecast.isNotEmpty) ...[
            const SizedBox(height: AgroSpacing.md),
            AgroSectionHeader(
              title: 'Próximos días',
              subtitle:
                  'Pronóstico de ${weather.forecast.length} días. ${weather.attribution}',
            ),
            const SizedBox(height: AgroSpacing.sm),
            WeatherForecastList(days: weather.forecast),
          ],
        ],
      );
    },
  );

  static WeatherForecastDay? _forecastFor(
    WeatherSnapshot weather,
    DateTime now,
  ) => weather.forecast
      .where((day) => DateUtils.isSameDay(day.date.toLocal(), now))
      .firstOrNull;

  static String _dayLabel(DateTime date, DateTime now) {
    final local = date.toLocal();
    if (DateUtils.isSameDay(local, now)) return 'Hoy';
    if (DateUtils.isSameDay(local, now.add(const Duration(days: 1)))) {
      return 'Mañana';
    }
    return 'El ${_date(local)}';
  }

  static String _date(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}';
  }

  static String _moonLabel(MoonPhaseName name) => switch (name) {
    MoonPhaseName.newMoon => 'Luna nueva',
    MoonPhaseName.waxingCrescent => 'Creciente',
    MoonPhaseName.firstQuarter => 'Cuarto creciente',
    MoonPhaseName.waxingGibbous => 'Gibosa creciente',
    MoonPhaseName.fullMoon => 'Luna llena',
    MoonPhaseName.waningGibbous => 'Gibosa menguante',
    MoonPhaseName.lastQuarter => 'Cuarto menguante',
    MoonPhaseName.waningCrescent => 'Menguante',
  };
}
