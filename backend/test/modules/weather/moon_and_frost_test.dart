import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoonPhase', () {
    test('is full on a known full moon', () {
      final moon = MoonPhase.at(DateTime.utc(2024, 1, 25, 17, 54));
      expect(moon.name, MoonPhaseName.fullMoon);
      expect(moon.illumination, greaterThan(0.97));
    });

    test('is new on a known new moon', () {
      final moon = MoonPhase.at(DateTime.utc(2024, 1, 11, 11, 57));
      expect(moon.name, MoonPhaseName.newMoon);
      expect(moon.illumination, lessThan(0.03));
    });

    test('is a first quarter on a known first quarter', () {
      final moon = MoonPhase.at(DateTime.utc(2024, 1, 18, 3, 53));
      expect(moon.name, MoonPhaseName.firstQuarter);
      expect(moon.illumination, closeTo(0.5, 0.08));
    });

    test('predicts the next full moon within a day', () {
      final moon = MoonPhase.at(DateTime.utc(2024, 1, 12));
      expect(
        moon.nextFullMoon.difference(DateTime.utc(2024, 1, 25, 17, 54)).abs(),
        lessThan(const Duration(days: 1)),
      );
      expect(moon.nextMilestone.full, isTrue);
    });
  });

  group('freezingForecastFrom', () {
    WeatherSnapshot snapshot(List<double> minimums) => WeatherSnapshot(
      locality: 'Cuadrante 1',
      temperatureC: 8,
      humidityPercent: 70,
      rainMillimeters: 0,
      summary: 'Despejado',
      fetchedAt: DateTime.utc(2026, 7, 1),
      forecast: [
        for (final (index, minimum) in minimums.indexed)
          WeatherForecastDay(
            date: DateTime(2026, 7, 1 + index),
            minimumC: minimum,
            maximumC: minimum + 12,
            rainChancePercent: 0,
            summary: 'Despejado',
          ),
      ],
    );

    test('returns the first day at or below 0 °C', () {
      final day = snapshot([3, 0, -2])
          .freezingForecastFrom(DateTime(2026, 7, 1));
      expect(day?.date, DateTime(2026, 7, 2));
    });

    test('ignores days before today', () {
      final day = snapshot([-1, 4, 5])
          .freezingForecastFrom(DateTime(2026, 7, 2));
      expect(day, isNull);
    });
  });

  group('WeatherForecastDay', () {
    test('reads rain and wind when the proxy sends them', () {
      final day = WeatherForecastDay.fromJson({
        'date': '2026-07-02',
        'minimum_c': 2,
        'maximum_c': 14,
        'rain_chance_percent': 80,
        'summary': 'Lluvia ligera',
        'rain_mm': 6.4,
        'wind_max_kmh': 30.5,
      });
      expect(day.rainMillimeters, 6.4);
      expect(day.windMaxKmh, 30.5);
      expect(WeatherForecastDay.fromJson(day.toJson()).windMaxKmh, 30.5);
    });

    test('keeps reading forecasts cached before rain and wind existed', () {
      final day = WeatherForecastDay.fromJson({
        'date': '2026-07-02',
        'minimum_c': 2,
        'maximum_c': 14,
        'rain_chance_percent': 80,
        'summary': 'Lluvia ligera',
      });
      expect(day.rainMillimeters, isNull);
      expect(day.windMaxKmh, isNull);
    });
  });
}
