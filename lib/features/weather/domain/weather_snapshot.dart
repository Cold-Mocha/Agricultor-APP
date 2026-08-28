final class WeatherSnapshot {
  const WeatherSnapshot({
    required this.locality,
    required this.temperatureC,
    required this.humidityPercent,
    required this.rainMillimeters,
    required this.summary,
    required this.fetchedAt,
  });

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) =>
      WeatherSnapshot(
        locality: json['locality'] as String,
        temperatureC: (json['temperature_c'] as num).toDouble(),
        humidityPercent: (json['humidity_percent'] as num).toInt(),
        rainMillimeters: (json['rain_mm'] as num).toDouble(),
        summary: json['summary'] as String,
        fetchedAt: DateTime.parse(json['fetched_at'] as String),
      );

  final String locality;
  final double temperatureC;
  final int humidityPercent;
  final double rainMillimeters;
  final String summary;
  final DateTime fetchedAt;

  Map<String, dynamic> toJson() => {
    'locality': locality,
    'temperature_c': temperatureC,
    'humidity_percent': humidityPercent,
    'rain_mm': rainMillimeters,
    'summary': summary,
    'fetched_at': fetchedAt.toUtc().toIso8601String(),
  };
}
