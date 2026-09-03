import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/weather/data/weather_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Parcel-level weather hero from the canonical visual specification.
///
/// It renders explicit fresh, cached, stale and unavailable states and never
/// derives agronomic risk from temperature thresholds.
final class WeatherSummaryCard extends ConsumerStatefulWidget {
  const WeatherSummaryCard({
    required this.ownerId,
    required this.parcelId,
    required this.locality,
    this.onEditLocality,
    super.key,
  });

  final String ownerId;
  final String parcelId;
  final String locality;
  final VoidCallback? onEditLocality;

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
        oldWidget.parcelId != widget.parcelId ||
        oldWidget.locality != widget.locality) {
      _result = _load();
    }
  }

  Future<WeatherLoadResult> _load() => ref
      .read(weatherRepositoryProvider)
      .load(
        ownerId: widget.ownerId,
        parcelId: widget.parcelId,
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
          humidity: '—',
          frost: 'Por actualizar',
          attribution: null,
          attributionUrl: null,
          busy: true,
        );
      }
      if (snapshot.hasError || snapshot.data is WeatherUnavailable) {
        return _WeatherHero(
          locality: widget.locality,
          status: 'No hay información climática guardada',
          temperature: '—',
          summary: 'Clima sin datos',
          humidity: 'Sin datos',
          frost: 'Sin datos',
          attribution: null,
          attributionUrl: null,
          onRetry: _retry,
          onEditLocality: widget.onEditLocality,
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
        temperature: '${weather.temperatureC.toStringAsFixed(1)} °C',
        summary: weather.summary,
        humidity: '${weather.humidityPercent} %',
        frost: stale
            ? 'Por actualizar'
            : activeFrost
            ? 'Alerta vigente'
            : 'Sin alerta vigente',
        attribution: weather.attribution,
        attributionUrl: weather.attributionUrl,
        warning: activeFrost,
        onRetry: stale || fromCache ? _retry : null,
      );
    },
  );
}

final class _WeatherHero extends StatelessWidget {
  const _WeatherHero({
    required this.locality,
    required this.status,
    required this.temperature,
    required this.summary,
    required this.humidity,
    required this.frost,
    required this.attribution,
    required this.attributionUrl,
    this.warning = false,
    this.busy = false,
    this.onRetry,
    this.onEditLocality,
  });

  final String locality;
  final String status;
  final String temperature;
  final String summary;
  final String humidity;
  final String frost;
  final String? attribution;
  final String? attributionUrl;
  final bool warning;
  final bool busy;
  final VoidCallback? onRetry;
  final VoidCallback? onEditLocality;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Resumen climático de $locality',
      child: Container(
        constraints: const BoxConstraints(minHeight: 188),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(AgroRadii.hero),
          border: Border.all(color: AgroColors.brandDark),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -38,
              top: -50,
              child: ExcludeSemantics(
                child: Transform.rotate(
                  angle: .18,
                  child: Container(
                    width: 142,
                    height: 176,
                    decoration: BoxDecoration(
                      color: colors.secondary.withValues(alpha: .92),
                      borderRadius: BorderRadius.circular(AgroRadii.hero),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AgroSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: colors.onPrimary,
                        size: AgroSizes.iconStandard,
                      ),
                      const SizedBox(width: AgroSpacing.xs),
                      Expanded(
                        child: Text(
                          locality,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: colors.onPrimary),
                        ),
                      ),
                      if (busy)
                        SizedBox.square(
                          dimension: AgroSizes.iconAction,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimary,
                          ),
                        )
                      else if (onRetry != null)
                        IconButton(
                          tooltip: 'Actualizar clima',
                          onPressed: onRetry,
                          color: colors.onPrimary,
                          icon: const Icon(Icons.refresh_outlined),
                        )
                      else if (onEditLocality != null)
                        IconButton(
                          tooltip: 'Editar localidad de la parcela',
                          onPressed: onEditLocality,
                          color: colors.onPrimary,
                          icon: const Icon(Icons.edit_location_alt_outlined),
                        ),
                    ],
                  ),
                  Text(
                    temperature,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    summary,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: colors.onPrimary),
                  ),
                  const SizedBox(height: AgroSpacing.xxs),
                  Text(
                    status,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onPrimary.withValues(alpha: .9),
                    ),
                  ),
                  const SizedBox(height: AgroSpacing.sm),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final oneColumn =
                          constraints.maxWidth < 320 ||
                          MediaQuery.textScalerOf(context).scale(1) > 1.35;
                      final metricWidth = oneColumn
                          ? constraints.maxWidth
                          : (constraints.maxWidth - AgroSpacing.xs) / 2;
                      return Wrap(
                        spacing: AgroSpacing.xs,
                        runSpacing: AgroSpacing.xs,
                        children: [
                          SizedBox(
                            width: metricWidth,
                            child: _HeroMetric(
                              icon: Icons.water_drop_outlined,
                              label: 'Humedad ambiental',
                              value: humidity,
                            ),
                          ),
                          SizedBox(
                            width: metricWidth,
                            child: _HeroMetric(
                              icon: warning
                                  ? Icons.warning_amber_outlined
                                  : Icons.ac_unit_outlined,
                              label: 'Helada',
                              value: frost,
                              warning: warning,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  if (attribution case final value?) ...[
                    const SizedBox(height: AgroSpacing.xs),
                    if (attributionUrl case final url?)
                      Semantics(
                        container: true,
                        link: true,
                        label: 'Abrir fuente meteorológica: $value',
                        child: InkWell(
                          onTap: () => _openExternalUrl(context, url),
                          borderRadius: BorderRadius.circular(AgroRadii.medium),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: AgroSizes.touchTarget,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                value,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colors.onPrimary,
                                      decoration: TextDecoration.underline,
                                      decorationColor: colors.onPrimary,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        value,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onPrimary.withValues(alpha: .82),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _openExternalUrl(BuildContext context, String rawUrl) async {
  final uri = Uri.tryParse(rawUrl);
  final opened =
      uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No fue posible abrir el enlace.')),
    );
  }
}

final class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.warning = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: AgroSizes.touchTarget),
      padding: const EdgeInsets.symmetric(
        horizontal: AgroSpacing.sm,
        vertical: AgroSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: warning
            ? colors.secondaryContainer
            : colors.onPrimary.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(AgroRadii.large),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AgroSizes.iconStandard,
            color: warning ? colors.onSecondaryContainer : colors.onPrimary,
          ),
          const SizedBox(width: AgroSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: warning
                        ? colors.onSecondaryContainer
                        : colors.onPrimary,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: warning
                        ? colors.onSecondaryContainer
                        : colors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _dateTime(BuildContext context, DateTime value) {
  final local = value.toLocal();
  final localizations = MaterialLocalizations.of(context);
  return '${localizations.formatShortDate(local)} · '
      '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
}
