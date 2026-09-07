import 'package:agrocampo_backend/core/config/backend_providers.dart';
import 'package:agrocampo_backend/features/weather/repositories/weather_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final weatherControllerProvider = Provider<WeatherController>(
  (ref) => WeatherController._(ref.watch(weatherRepositoryProvider)),
);

final class WeatherController {
  WeatherController._(this._repository);
  final WeatherRepository _repository;
  Future<WeatherLoadResult> load({
    required String ownerId,
    required String locality,
    String? parcelId,
  }) => _repository.load(
    ownerId: ownerId,
    locality: locality,
    parcelId: parcelId,
  );

  static Future<bool> openAttribution(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    return uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
