/// Automatic alerts the farmer can switch on, each with its own threshold.
enum FieldAlertKind {
  /// Threshold: days before a season ends.
  seasonEnd,

  /// Threshold: forecast minimum (°C) at or below which frost is announced.
  frost,

  /// Threshold: forecast minimum (°C) at or below which it is too cold.
  cold,

  /// Threshold: forecast maximum (°C) at or above which it is too hot.
  heat,
}

final class FieldAlertRule {
  const FieldAlertRule({required this.enabled, required this.threshold});

  final bool enabled;
  final double threshold;

  FieldAlertRule copyWith({bool? enabled, double? threshold}) => FieldAlertRule(
    enabled: enabled ?? this.enabled,
    threshold: threshold ?? this.threshold,
  );
}

final class FieldAlertSettings {
  const FieldAlertSettings(this._rules);

  factory FieldAlertSettings.fromJson(Map<String, dynamic> json) =>
      FieldAlertSettings({
        for (final kind in FieldAlertKind.values)
          kind: switch (json[kind.name]) {
            {'enabled': final bool enabled, 'threshold': final num threshold} =>
              FieldAlertRule(enabled: enabled, threshold: threshold.toDouble()),
            _ => defaults.rule(kind),
          },
      });

  static const defaults = FieldAlertSettings({
    FieldAlertKind.seasonEnd: FieldAlertRule(enabled: true, threshold: 7),
    FieldAlertKind.frost: FieldAlertRule(enabled: true, threshold: 0),
    FieldAlertKind.cold: FieldAlertRule(enabled: false, threshold: 5),
    FieldAlertKind.heat: FieldAlertRule(enabled: false, threshold: 30),
  });

  final Map<FieldAlertKind, FieldAlertRule> _rules;

  FieldAlertRule rule(FieldAlertKind kind) =>
      _rules[kind] ?? defaults._rules[kind]!;

  FieldAlertSettings withRule(FieldAlertKind kind, FieldAlertRule rule) =>
      FieldAlertSettings({
        for (final value in FieldAlertKind.values)
          value: value == kind ? rule : this.rule(value),
      });

  Map<String, dynamic> toJson() => {
    for (final kind in FieldAlertKind.values)
      kind.name: {
        'enabled': rule(kind).enabled,
        'threshold': rule(kind).threshold,
      },
  };
}

/// A season that may end soon, already labeled with its quadrant.
typedef SeasonEnding = ({String seasonId, String sectorName, DateTime endsOn});

/// One forecast day's extremes; a minimal projection so this domain never
/// depends on the weather module's own entity.
typedef FieldAlertForecastDay = ({
  DateTime date,
  double minimumC,
  double maximumC,
});

/// Cached weather of one quadrant, reduced to what the rules below need.
typedef SectorForecast = ({
  String sectorId,
  String sectorName,
  List<FieldAlertForecastDay> forecast,
});

final class FieldAlertNotice {
  const FieldAlertNotice({
    required this.key,
    required this.kind,
    required this.title,
    required this.body,
  });

  /// Identifies the event so it is notified only once.
  final String key;
  final FieldAlertKind kind;
  final String title;
  final String body;
}

/// Pure rules behind the automatic alerts; weather values only repeat the
/// provider forecast and are never official warnings.
List<FieldAlertNotice> evaluateFieldAlerts({
  required FieldAlertSettings settings,
  required List<SeasonEnding> seasons,
  required List<SectorForecast> forecasts,
  required DateTime today,
}) {
  final start = DateTime(today.year, today.month, today.day);
  final notices = <FieldAlertNotice>[];
  final seasonRule = settings.rule(FieldAlertKind.seasonEnd);
  if (seasonRule.enabled) {
    for (final season in seasons) {
      final local = season.endsOn.toLocal();
      final ends = DateTime(local.year, local.month, local.day);
      final daysLeft = ends.difference(start).inDays;
      if (daysLeft < 0 || daysLeft > seasonRule.threshold) continue;
      notices.add(
        FieldAlertNotice(
          key: 'seasonEnd:${season.seasonId}:${_isoDate(ends)}',
          kind: FieldAlertKind.seasonEnd,
          title: 'La temporada de ${season.sectorName} termina pronto',
          body: daysLeft == 0
              ? 'Termina hoy.'
              : 'Termina el ${_date(ends)} (en $daysLeft '
                    '${daysLeft == 1 ? 'día' : 'días'}).',
        ),
      );
    }
  }
  final frost = settings.rule(FieldAlertKind.frost);
  final cold = settings.rule(FieldAlertKind.cold);
  final heat = settings.rule(FieldAlertKind.heat);
  for (final sector in forecasts) {
    for (final day in sector.forecast) {
      final local = day.date.toLocal();
      final date = DateTime(local.year, local.month, local.day);
      if (date.isBefore(start)) continue;
      final when = _dayLabel(date, start);
      final freezing = frost.enabled && day.minimumC <= frost.threshold;
      if (freezing) {
        notices.add(
          FieldAlertNotice(
            key: 'frost:${sector.sectorId}:${_isoDate(date)}',
            kind: FieldAlertKind.frost,
            title: 'Helada pronosticada en ${sector.sectorName}',
            body:
                '$when, mínima de ${day.minimumC.round()} °C. Según '
                'pronóstico, no es alerta oficial.',
          ),
        );
      } else if (cold.enabled && day.minimumC <= cold.threshold) {
        notices.add(
          FieldAlertNotice(
            key: 'cold:${sector.sectorId}:${_isoDate(date)}',
            kind: FieldAlertKind.cold,
            title:
                'Frío bajo ${_degrees(cold.threshold)} en '
                '${sector.sectorName}',
            body:
                '$when, mínima de ${day.minimumC.round()} °C. Según '
                'pronóstico.',
          ),
        );
      }
      if (heat.enabled && day.maximumC >= heat.threshold) {
        notices.add(
          FieldAlertNotice(
            key: 'heat:${sector.sectorId}:${_isoDate(date)}',
            kind: FieldAlertKind.heat,
            title:
                'Calor sobre ${_degrees(heat.threshold)} en '
                '${sector.sectorName}',
            body:
                '$when, máxima de ${day.maximumC.round()} °C. Según '
                'pronóstico.',
          ),
        );
      }
    }
  }
  return notices;
}

String _degrees(double value) => '${value.round()} °C';

String _isoDate(DateTime value) =>
    '${value.year}-${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}';

String _dayLabel(DateTime date, DateTime today) {
  final days = date.difference(today).inDays;
  if (days == 0) return 'Hoy';
  if (days == 1) return 'Mañana';
  return 'El ${_date(date)}';
}
