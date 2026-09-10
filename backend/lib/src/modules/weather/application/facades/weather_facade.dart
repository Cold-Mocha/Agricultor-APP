import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_alert_service.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final weatherFacadeProvider = Provider<WeatherFacade>((ref) {
  return WeatherFacade._(
    ref.watch(weatherRepositoryProvider),
    (ownerId, enabled) =>
        WeatherAlertService(ref.read(appDatabaseProvider))
            .setEnabled(ownerId, enabled),
  );
});

final class WeatherFacade {
  WeatherFacade._(this._repository, this._setAlertsEnabled);
  final WeatherRepository _repository;
  final Future<void> Function(String ownerId, bool enabled) _setAlertsEnabled;
  Future<WeatherLoadResult> load({
    required String ownerId,
    required String locality,
    String? parcelId,
  }) => _repository.load(
    ownerId: ownerId,
    locality: locality,
    parcelId: parcelId,
  );

  Future<void> setAlertsEnabled(String ownerId, bool enabled) =>
      _setAlertsEnabled(ownerId, enabled);

  static Future<bool> openAttribution(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    return uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
