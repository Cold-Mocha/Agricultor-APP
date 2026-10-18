import 'dart:async';

import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/weather/presentation/controllers/weather_controller.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Sector-level weather hero from the canonical visual specification.
///
/// It renders explicit fresh, cached, stale and unavailable states and never
/// derives agronomic risk from temperature thresholds.
final class WeatherSummaryCard extends ConsumerStatefulWidget {
  const WeatherSummaryCard({
    required this.ownerId,
    required this.sectorId,
    required this.locality,
    super.key,
  });

  final String ownerId;
  final String sectorId;
  final String locality;

  @override
  ConsumerState<WeatherSummaryCard> createState() => _WeatherSummaryCardState();
}

final class _WeatherSummaryCardState extends ConsumerState<WeatherSummaryCard> {
  late Future<WeatherLoadResult> _result;

  @override
  void initState() {
    super.initState();
    _result = _load();
  }

  @override
  void didUpdateWidget(covariant WeatherSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerId != widget.ownerId ||
        oldWidget.sectorId != widget.sectorId ||
        oldWidget.locality != widget.locality) {
      _result = _load();
    }
  }

  Future<WeatherLoadResult> _load() => ref
      .read(weatherControllerProvider)
      .load(
        ownerId: widget.ownerId,
        sectorId: widget.sectorId,
        locality: widget.locality,
      );

  void _retry() => setState(() => _result = _load());

  @override
  Widget build(BuildContext context) => FutureBuilder<WeatherLoadResult>(
    future: _result,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return _WeatherHero(
          locality: widget.locality,
          status: 'Actualizando clima…',
          temperature: '—',
          summary: 'Consultando condiciones',
          attribution: null,
          attributionUrl: null,
          busy: true,
        );
      }
      if (snapshot.hasError || snapshot.data is WeatherUnavailable) {
        final localMode = ref.watch(isLocalModeProvider);
        return _WeatherHero(
          locality: widget.locality,
          status: localMode
              ? 'Disponible al activar el respaldo en la nube.'
              : 'No hay información climática guardada',
          temperature: '—',
          summary: 'Clima sin datos',
          attribution: null,
          attributionUrl: null,
          onRetry: localMode ? null : _retry,
        );
      }
      final result = snapshot.data!;
      final weather = switch (result) {
        WeatherFresh(:final snapshot) => snapshot,
        WeatherStale(:final snapshot) => snapshot,
        WeatherUnavailable() => throw StateError('handled_above'),
      };
      final stale = result is WeatherStale;
      final fromCache = result is WeatherFresh && result.fromCache;
      final now = DateTime.now();
      final today = weather.forecast
          .where((day) => DateUtils.isSameDay(day.date.toLocal(), now))
          .firstOrNull;
      final activeFrost =
          !stale &&
          weather.alerts.any((alert) => alert.isFrost && alert.isActiveAt(now));
      return _WeatherHero(
        locality: weather.locality,
        status: stale
            ? 'Datos guardados del ${_dateTime(context, weather.fetchedAt)} · por actualizar'
            : fromCache
            ? 'Datos guardados · ${_dateTime(context, weather.fetchedAt)}'
            : 'Actualizado ${_dateTime(context, weather.fetchedAt)}',
        temperature: '${weather.temperatureC.round()}°',
        summary: weather.summary,
        range: today == null
            ? null
            : '${today.maximumC.round()}°/${today.minimumC.round()}°',
        forecast: [
          for (final day in weather.forecast)
            if (_isAfter(day.date, now)) day,
        ].take(4).toList(growable: false),
        frostAlert: activeFrost,
        attribution: weather.attribution,
        attributionUrl: weather.attributionUrl,
        onRetry: stale || fromCache ? _retry : null,
      );
    },
  );
}

/// Weather hero styled after the approved card reference: warm sky with a
/// concentric sun, condition and temperature on the left, clock, date and
/// quadrant on the right, and a forecast strip along the bottom.
final class _WeatherHero extends StatefulWidget {
  const _WeatherHero({
    required this.locality,
    required this.status,
    required this.temperature,
    required this.summary,
    required this.attribution,
    required this.attributionUrl,
    this.range,
    this.forecast = const [],
    this.frostAlert = false,
    this.busy = false,
    this.onRetry,
  });

  final String locality;
  final String status;
  final String temperature;
  final String summary;
  final String? range;
  final List<WeatherForecastDay> forecast;
  final bool frostAlert;
  final String? attribution;
  final String? attributionUrl;
  final bool busy;
  final VoidCallback? onRetry;

  @override
  State<_WeatherHero> createState() => _WeatherHeroState();
}

final class _WeatherHeroState extends State<_WeatherHero> {
  static const _white = Colors.white;

  late DateTime _now = DateTime.now();
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _scheduleTick();
  }

  void _scheduleTick() {
    final now = DateTime.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    _clock = Timer(nextMinute.difference(now), () {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
      _scheduleTick();
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final time =
        '${_now.hour.toString().padLeft(2, '0')}:'
        '${_now.minute.toString().padLeft(2, '0')}';
    final date =
        '${_weekday(_now)} ${_now.day.toString().padLeft(2, '0')}-'
        '${_now.month.toString().padLeft(2, '0')}';
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Resumen climático de ${widget.locality}',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AgroRadii.hero),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AgroColors.weatherSkyStart, AgroColors.weatherSkyEnd],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                const Positioned(
                  right: -70,
                  top: -90,
                  child: ExcludeSemantics(child: _ConcentricSun()),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AgroSpacing.md,
                    AgroSpacing.md,
                    AgroSpacing.md,
                    AgroSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _conditionIcon(widget.summary),
                                      color: _white,
                                      size: AgroSizes.iconStandard,
                                    ),
                                    const SizedBox(width: AgroSpacing.xs),
                                    Flexible(
                                      child: Text(
                                        widget.summary,
                                        style: text.titleSmall?.copyWith(
                                          color: _white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  widget.temperature,
                                  style: text.displayLarge?.copyWith(
                                    color: _white,
                                    fontSize: 56,
                                    height: 1.1,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (widget.range case final value?)
                                  Text(
                                    value,
                                    style: text.titleMedium?.copyWith(
                                      color: _white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                time,
                                style: text.headlineMedium?.copyWith(
                                  color: _white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                date,
                                style: text.titleSmall?.copyWith(color: _white),
                              ),
                              const SizedBox(height: AgroSpacing.lg),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 150,
                                ),
                                child: Text(
                                  widget.locality,
                                  textAlign: TextAlign.end,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.titleMedium?.copyWith(
                                    color: _white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AgroSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.status,
                              style: text.bodySmall?.copyWith(color: _white),
                            ),
                          ),
                          if (widget.busy)
                            const SizedBox.square(
                              dimension: AgroSizes.iconAction,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _white,
                              ),
                            )
                          else if (widget.onRetry != null)
                            IconButton(
                              tooltip: 'Actualizar clima',
                              onPressed: widget.onRetry,
                              color: _white,
                              icon: const Icon(LucideIcons.refreshCw),
                            ),
                        ],
                      ),
                      if (widget.frostAlert) ...[
                        const SizedBox(height: AgroSpacing.xs),
                        _FrostAlert(),
                      ],
                      if (widget.attribution case final value?)
                        _Attribution(label: value, url: widget.attributionUrl),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.forecast.isNotEmpty)
              ColoredBox(
                color: AgroColors.weatherStrip,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      for (final (index, day) in widget.forecast.indexed) ...[
                        if (index > 0)
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: _white.withValues(alpha: .18),
                          ),
                        Expanded(child: _ForecastCell(day: day)),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

final class _ConcentricSun extends StatelessWidget {
  const _ConcentricSun();

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 260,
    child: Stack(
      alignment: Alignment.center,
      children: [
        for (final (size, alpha) in const [
          (260.0, .16),
          (190.0, .22),
          (120.0, .55),
        ])
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AgroColors.accent.withValues(alpha: alpha),
            ),
          ),
      ],
    ),
  );
}

final class _ForecastCell extends StatelessWidget {
  const _ForecastCell({required this.day});

  final WeatherForecastDay day;

  @override
  Widget build(BuildContext context) {
    final label = _weekday(day.date.toLocal());
    return Semantics(
      label:
          '$label: ${day.summary}, '
          'máxima ${day.maximumC.round()}°, mínima ${day.minimumC.round()}°',
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AgroSizes.touchTarget),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(width: AgroSpacing.xxs),
            Icon(
              _conditionIcon(day.summary),
              color: Colors.white,
              size: AgroSizes.iconStandard,
            ),
          ],
        ),
      ),
    );
  }
}

final class _FrostAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AgroSpacing.sm,
        vertical: AgroSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(AgroRadii.large),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.triangleAlert,
            size: AgroSizes.iconStandard,
            color: colors.onSecondaryContainer,
          ),
          const SizedBox(width: AgroSpacing.xs),
          Text(
            'Alerta de helada vigente',
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: colors.onSecondaryContainer),
          ),
        ],
      ),
    );
  }
}

final class _Attribution extends StatelessWidget {
  const _Attribution({required this.label, required this.url});

  final String label;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Colors.white,
      decoration: url == null ? null : TextDecoration.underline,
      decorationColor: Colors.white,
    );
    if (url case final target?) {
      return Semantics(
        container: true,
        link: true,
        label: 'Abrir fuente meteorológica: $label',
        child: InkWell(
          onTap: () => _openExternalUrl(context, target),
          borderRadius: BorderRadius.circular(AgroRadii.medium),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AgroSizes.touchTarget),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(label, style: style),
            ),
          ),
        ),
      );
    }
    return Text(label, style: style);
  }
}

IconData _conditionIcon(String summary) {
  final value = summary.toLowerCase();
  if (value.contains('tormenta')) return LucideIcons.cloudLightning;
  if (value.contains('niev') || value.contains('nieve')) {
    return LucideIcons.snowflake;
  }
  if (value.contains('lluvia') ||
      value.contains('llovizna') ||
      value.contains('chubasco')) {
    return LucideIcons.cloudRain;
  }
  if (value.contains('niebla')) return LucideIcons.cloudFog;
  if (value.contains('parcialmente')) return LucideIcons.cloudSun;
  if (value.contains('nublado')) return LucideIcons.cloud;
  if (value.contains('despejado')) return LucideIcons.sun;
  return LucideIcons.cloudSun;
}

String _weekday(DateTime value) =>
    const ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'][value.weekday - 1];

bool _isAfter(DateTime day, DateTime now) {
  final local = day.toLocal();
  return DateTime(
    local.year,
    local.month,
    local.day,
  ).isAfter(DateTime(now.year, now.month, now.day));
}

Future<void> _openExternalUrl(BuildContext context, String rawUrl) async {
  final opened = await WeatherController.openAttribution(rawUrl);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No fue posible abrir el enlace.')),
    );
  }
}

String _dateTime(BuildContext context, DateTime value) {
  final local = value.toLocal();
  final localizations = MaterialLocalizations.of(context);
  return '${localizations.formatShortDate(local)} · '
      '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
}
