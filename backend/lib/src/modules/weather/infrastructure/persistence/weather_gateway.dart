import 'package:agrocampo_backend/src/modules/weather/domain/entities/weather_snapshot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class WeatherGateway {
  Future<WeatherSnapshot> fetch({required String locality, String? sectorId});
}

final class UnavailableWeatherGateway implements WeatherGateway {
  const UnavailableWeatherGateway();

  @override
  Future<WeatherSnapshot> fetch({required String locality, String? sectorId}) =>
      Future.error(StateError('weather_unavailable'));
}

final class SupabaseWeatherGateway implements WeatherGateway {
  const SupabaseWeatherGateway(this._client);
  final SupabaseClient _client;

  @override
  Future<WeatherSnapshot> fetch({
    required String locality,
    String? sectorId,
  }) async {
    final response = await _client.functions.invoke(
      'weather-proxy',
      body: {
        'locality': locality,
        if (sectorId != null && sectorId.isNotEmpty) 'sectorId': sectorId,
      },
    );
    if (response.status != 200 || response.data is! Map) {
      throw StateError('weather_unavailable');
    }
    return WeatherSnapshot.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
