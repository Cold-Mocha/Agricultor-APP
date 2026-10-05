import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/weather/domain/entities/weather_snapshot.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_alert_service.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_gateway.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
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

  /// For composition roots without a Riverpod container (e.g. the
  /// background WorkManager isolate in sync_scheduler.dart), where [gateway]
  /// is built manually from a signed-in client.
  factory WeatherFacade.withGateway(
    AppDatabase database,
    WeatherGateway gateway,
  ) => WeatherFacade._(
        WeatherRepository(database, gateway),
        (ownerId, enabled) =>
            WeatherAlertService(database).setEnabled(ownerId, enabled),
      );

  /// Read-only access to each quadrant's cached forecast, without a provider
  /// able to fetch a fresh one. Used where only the local cache matters
  /// (e.g. reminders' field alerts reading whatever is already stored).
  factory WeatherFacade.cacheOnly(AppDatabase database) =>
      WeatherFacade.withGateway(database, const UnavailableWeatherGateway());

  final WeatherRepository _repository;
  final Future<void> Function(String ownerId, bool enabled) _setAlertsEnabled;

  Future<WeatherSnapshot?> cached(String ownerId, {String? sectorId}) =>
      _repository.cached(ownerId, sectorId: sectorId);

  Future<WeatherSnapshot> refresh({
    required String ownerId,
    required String locality,
    String? sectorId,
  }) => _repository.refresh(
    ownerId: ownerId,
    locality: locality,
    sectorId: sectorId,
  );

  Future<WeatherLoadResult> load({
    required String ownerId,
    required String locality,
    String? sectorId,
    bool forceRefresh = false,
  }) => _repository.load(
    ownerId: ownerId,
    locality: locality,
    sectorId: sectorId,
    forceRefresh: forceRefresh,
  );

  Future<void> setAlertsEnabled(String ownerId, bool enabled) =>
      _setAlertsEnabled(ownerId, enabled);

  static Future<bool> openAttribution(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    return uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
