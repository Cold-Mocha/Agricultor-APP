import 'dart:convert';

import 'package:agrocampo_backend/src/modules/weather/domain/entities/weather_load_result.dart';
import 'package:agrocampo_backend/src/modules/weather/domain/entities/weather_snapshot.dart';
import 'package:agrocampo_backend/src/modules/weather/infrastructure/persistence/weather_gateway.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/drift.dart';

export 'package:agrocampo_backend/src/modules/weather/domain/entities/weather_load_result.dart';

final class WeatherRepository {
  const WeatherRepository(this._database, this._gateway);
  final AppDatabase _database;
  final WeatherGateway _gateway;

  Future<WeatherSnapshot> refresh({
    required String ownerId,
    required String locality,
    String? sectorId,
  }) async {
    WeatherSnapshot snapshot;
    try {
      snapshot = await _gateway.fetch(locality: locality, sectorId: sectorId);
    } on Object {
      await (_database.update(
        _database.weatherCache,
      )..where((row) => row.id.equals('$ownerId:$locality'))).write(
        const WeatherCacheCompanion(errorCode: Value('provider_unavailable')),
      );
      rethrow;
    }
    await _database
        .into(_database.weatherCache)
        .insertOnConflictUpdate(
          WeatherCacheCompanion.insert(
            id: '$ownerId:$locality',
            ownerId: ownerId,
            sectorId: Value(sectorId),
            locality: locality,
            provider: Value(snapshot.provider),
            payloadJson: jsonEncode(snapshot.toJson()),
            observedAt: Value(snapshot.observedAt),
            fetchedAt: snapshot.fetchedAt.toUtc(),
            expiresAt: Value(
              snapshot.expiresAt ??
                  snapshot.fetchedAt.add(const Duration(hours: 1)),
            ),
            attribution: Value(snapshot.attribution),
            errorCode: const Value(null),
          ),
        );
    return snapshot;
  }

  /// Reuses the quadrant's cached weather while it is under an hour old;
  /// [forceRefresh] always asks the provider, as the reload button does.
  Future<WeatherLoadResult> load({
    required String ownerId,
    required String locality,
    String? sectorId,
    DateTime? now,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cachedSnapshot = await cached(
        ownerId,
        sectorId: sectorId,
        locality: locality,
      );
      if (cachedSnapshot != null &&
          cachedSnapshot.isFreshAt(now ?? DateTime.now())) {
        return WeatherFresh(cachedSnapshot, fromCache: true);
      }
    }
    try {
      return WeatherFresh(
        await refresh(ownerId: ownerId, locality: locality, sectorId: sectorId),
      );
    } on Object {
      final snapshot = await cached(
        ownerId,
        sectorId: sectorId,
        locality: locality,
      );
      if (snapshot == null) {
        return const WeatherUnavailable('provider_unavailable');
      }
      return snapshot.isFreshAt(now ?? DateTime.now())
          ? WeatherFresh(snapshot, fromCache: true)
          : WeatherStale(snapshot, 'provider_unavailable');
    }
  }

  Future<WeatherSnapshot?> cached(
    String ownerId, {
    String? sectorId,
    String? locality,
  }) async {
    final row =
        await (_database.select(_database.weatherCache)
              ..where(
                (entry) =>
                    entry.ownerId.equals(ownerId) &
                    (sectorId == null
                        ? const Constant(true)
                        : entry.sectorId.equals(sectorId)) &
                    (locality == null
                        ? const Constant(true)
                        : entry.locality.equals(locality)),
              )
              ..orderBy([(entry) => OrderingTerm.desc(entry.fetchedAt)])
              // A renamed quadrant keeps its old row; the newest one wins.
              ..limit(1))
            .getSingleOrNull();
    return row == null
        ? null
        : WeatherSnapshot.fromJson(
            jsonDecode(row.payloadJson) as Map<String, dynamic>,
          );
  }
}
