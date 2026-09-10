final class WeatherSnapshot {
  const WeatherSnapshot({
    required this.locality,
    required this.temperatureC,
    required this.humidityPercent,
    required this.rainMillimeters,
    required this.summary,
    required this.fetchedAt,
    this.observedAt,
    this.expiresAt,
    this.provider = 'open-meteo',
    this.attribution = 'Datos meteorológicos por Open-Meteo.com',
    this.attributionUrl,
    this.forecast = const [],
    this.alerts = const [],
  });

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) {
    final locality = json['locality'];
    final temperature = json['temperature_c'];
    final humidity = json['humidity_percent'];
    final rain = json['rain_mm'];
    final summary = json['summary'];
    final fetched = json['fetched_at'];
    if (locality is! String ||
        temperature is! num ||
        humidity is! num ||
        rain is! num ||
        summary is! String ||
        fetched is! String) {
      throw const FormatException('weather_contract_invalid');
    }
    return WeatherSnapshot(
      locality: locality,
      temperatureC: temperature.toDouble(),
      humidityPercent: humidity.toInt(),
      rainMillimeters: rain.toDouble(),
      summary: summary,
      fetchedAt: DateTime.parse(fetched).toUtc(),
      observedAt: _date(json['observed_at']),
      expiresAt: _date(json['expires_at']),
      provider: json['provider'] as String? ?? 'open-meteo',
      attribution:
          json['attribution'] as String? ??
          'Datos meteorológicos por Open-Meteo.com',
      attributionUrl: json['attribution_url'] as String?,
      forecast: (json['forecast'] as List? ?? const [])
          .map(
            (value) => WeatherForecastDay.fromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList(growable: false),
      alerts: (json['alerts'] as List? ?? const [])
          .map(
            (value) =>
                WeatherAlert.fromJson(Map<String, dynamic>.from(value as Map)),
          )
          .toList(growable: false),
    );
  }

  final String locality;
  final double temperatureC;
  final int humidityPercent;
  final double rainMillimeters;
  final String summary;
  final DateTime fetchedAt;
  final DateTime? observedAt;
  final DateTime? expiresAt;
  final String provider;
  final String attribution;
  final String? attributionUrl;
  final List<WeatherForecastDay> forecast;
  final List<WeatherAlert> alerts;

  bool isFreshAt(DateTime now) =>
      (expiresAt ?? fetchedAt.add(const Duration(hours: 1))).isAfter(
        now.toUtc(),
      );

  Map<String, dynamic> toJson() => {
    'locality': locality,
    'temperature_c': temperatureC,
    'humidity_percent': humidityPercent,
    'rain_mm': rainMillimeters,
    'summary': summary,
    'fetched_at': fetchedAt.toUtc().toIso8601String(),
    'observed_at': observedAt?.toUtc().toIso8601String(),
    'expires_at': expiresAt?.toUtc().toIso8601String(),
    'provider': provider,
    'attribution': attribution,
    if (attributionUrl != null) 'attribution_url': attributionUrl,
    'forecast': forecast.map((value) => value.toJson()).toList(),
    'alerts': alerts.map((value) => value.toJson()).toList(),
  };

  static DateTime? _date(Object? value) => value is String && value.isNotEmpty
      ? DateTime.parse(value).toUtc()
      : null;
}

final class WeatherForecastDay {
  const WeatherForecastDay({
    required this.date,
    required this.minimumC,
    required this.maximumC,
    required this.rainChancePercent,
    required this.summary,
  });
  factory WeatherForecastDay.fromJson(Map<String, dynamic> json) =>
      WeatherForecastDay(
        date: DateTime.parse(json['date'] as String),
        minimumC: (json['minimum_c'] as num).toDouble(),
        maximumC: (json['maximum_c'] as num).toDouble(),
        rainChancePercent: (json['rain_chance_percent'] as num).toInt(),
        summary: json['summary'] as String,
      );
  final DateTime date;
  final double minimumC;
  final double maximumC;
  final int rainChancePercent;
  final String summary;
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String().substring(0, 10),
    'minimum_c': minimumC,
    'maximum_c': maximumC,
    'rain_chance_percent': rainChancePercent,
    'summary': summary,
  };
}

final class WeatherAlert {
  const WeatherAlert({
    required this.id,
    required this.title,
    required this.severity,
    required this.startsAt,
    required this.endsAt,
    this.condition,
  });
  factory WeatherAlert.fromJson(Map<String, dynamic> json) => WeatherAlert(
    id: json['id'] as String,
    title: json['title'] as String,
    severity: json['severity'] as String,
    startsAt: DateTime.parse(json['starts_at'] as String).toUtc(),
    endsAt: DateTime.parse(json['ends_at'] as String).toUtc(),
    condition: json['condition'] as String?,
  );
  final String id;
  final String title;
  final String severity;
  final DateTime startsAt;
  final DateTime endsAt;
  final String? condition;

  bool isActiveAt(DateTime instant) {
    final now = instant.toUtc();
    return !now.isBefore(startsAt) && now.isBefore(endsAt);
  }

  bool get isFrost {
    final value = (condition ?? title).toLowerCase();
    return value.contains('helada') || value.contains('frost');
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'severity': severity,
    'starts_at': startsAt.toIso8601String(),
    'ends_at': endsAt.toIso8601String(),
    if (condition != null) 'condition': condition,
  };
}
