import 'package:agrocampo/features/weather/domain/weather_snapshot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class WeatherGateway {
  Future<WeatherSnapshot> fetch(String locality);
}

final class SupabaseWeatherGateway implements WeatherGateway {
  const SupabaseWeatherGateway(this._client);
  final SupabaseClient _client;

  @override
  Future<WeatherSnapshot> fetch(String locality) async {
    final response = await _client.functions.invoke(
      'weather-proxy',
      body: {'locality': locality},
    );
    if (response.status != 200 || response.data is! Map) {
      throw StateError('weather_unavailable');
    }
    return WeatherSnapshot.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
