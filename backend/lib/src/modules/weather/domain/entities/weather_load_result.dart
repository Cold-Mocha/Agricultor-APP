import 'weather_snapshot.dart';

sealed class WeatherLoadResult {
  const WeatherLoadResult();
}

final class WeatherFresh extends WeatherLoadResult {
  const WeatherFresh(this.snapshot, {this.fromCache = false});
  final WeatherSnapshot snapshot;
  final bool fromCache;
}

final class WeatherStale extends WeatherLoadResult {
  const WeatherStale(this.snapshot, this.reason);
  final WeatherSnapshot snapshot;
  final String reason;
}

final class WeatherUnavailable extends WeatherLoadResult {
  const WeatherUnavailable(this.reason);
  final String reason;
}
