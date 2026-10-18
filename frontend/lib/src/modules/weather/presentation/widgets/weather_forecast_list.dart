import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Daily forecast, one row per day: condition, rain, wind and min/max.
final class WeatherForecastList extends StatelessWidget {
  const WeatherForecastList({required this.days, super.key});

  final List<WeatherForecastDay> days;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = [
      for (final day in days)
        if (!DateUtils.dateOnly(day.date.toLocal())
            .isBefore(DateUtils.dateOnly(now)))
          day,
    ];
    return Card(
      child: Column(
        children: [
          for (final (index, day) in upcoming.indexed) ...[
            if (index > 0) const Divider(height: 1),
            _ForecastRow(day: day, now: now),
          ],
        ],
      ),
    );
  }
}

final class _ForecastRow extends StatelessWidget {
  const _ForecastRow({required this.day, required this.now});

  final WeatherForecastDay day;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final freezing = day.minimumC <= 0;
    final details = [
      '${day.rainChancePercent} % lluvia',
      if (day.rainMillimeters case final mm? when mm > 0)
        '${mm.toStringAsFixed(1)} mm',
      if (day.windMaxKmh case final wind?) 'viento ${wind.round()} km/h',
      if (freezing) 'helada',
    ].join(' · ');
    final label = _dayLabel(day.date.toLocal(), now);
    return Semantics(
      label:
          '$label. ${day.summary}. Mínima ${day.minimumC.round()} grados, '
          'máxima ${day.maximumC.round()} grados. $details',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AgroSpacing.sm,
          vertical: AgroSpacing.xs,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 76,
              child: Text(label, style: theme.textTheme.titleSmall),
            ),
            Icon(
              weatherIconFor(day.summary),
              size: AgroSizes.iconStandard,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AgroSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day.summary, style: theme.textTheme.bodyMedium),
                  Text(details, style: muted),
                ],
              ),
            ),
            const SizedBox(width: AgroSpacing.xs),
            Text(
              '${day.minimumC.round()}° / ${day.maximumC.round()}°',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: freezing ? theme.colorScheme.error : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _weekdays = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

  static String _dayLabel(DateTime date, DateTime now) {
    if (DateUtils.isSameDay(date, now)) return 'Hoy';
    if (DateUtils.isSameDay(date, now.add(const Duration(days: 1)))) {
      return 'Mañana';
    }
    return '${_weekdays[date.weekday - 1]} '
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}';
  }
}

/// Icon for the Spanish condition text the weather proxy returns.
IconData weatherIconFor(String summary) {
  final text = summary.toLowerCase();
  if (text.contains('tormenta')) return LucideIcons.cloudLightning;
  if (text.contains('nev') || text.contains('nieve')) {
    return LucideIcons.cloudSnow;
  }
  if (text.contains('llovizna')) return LucideIcons.cloudDrizzle;
  if (text.contains('lluvia') || text.contains('chubasco')) {
    return LucideIcons.cloudRain;
  }
  if (text.contains('niebla')) return LucideIcons.cloudFog;
  if (text == 'nublado') return LucideIcons.cloud;
  if (text == 'despejado') return LucideIcons.sun;
  return LucideIcons.cloudSun;
}
