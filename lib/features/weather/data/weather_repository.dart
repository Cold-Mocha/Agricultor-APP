import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/weather/data/weather_gateway.dart';
import 'package:agrocampo/features/weather/domain/weather_snapshot.dart';
import 'package:drift/drift.dart';

final class WeatherRepository {
  const WeatherRepository(this._database, this._gateway);
  final AppDatabase _database;
  final WeatherGateway _gateway;

  Future<WeatherSnapshot> refresh({
    required String ownerId,
    required String locality,
    String? parcelId,
  }) async {
    WeatherSnapshot snapshot;
    try {
      snapshot = await _gateway.fetch(locality: locality, parcelId: parcelId);
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
            parcelId: Value(parcelId),
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

  Future<WeatherLoadResult> load({
    required String ownerId,
    required String locality,
    String? parcelId,
    DateTime? now,
  }) async {
    try {
      return WeatherFresh(
        await refresh(ownerId: ownerId, locality: locality, parcelId: parcelId),
      );
    } on Object {
      final snapshot = await cached(
        ownerId,
        parcelId: parcelId,
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
    String? parcelId,
    String? locality,
  }) async {
    final row =
        await (_database.select(_database.weatherCache)
              ..where(
                (entry) =>
                    entry.ownerId.equals(ownerId) &
                    (parcelId == null
                        ? const Constant(true)
                        : entry.parcelId.equals(parcelId)) &
                    (locality == null
                        ? const Constant(true)
                        : entry.locality.equals(locality)),
              )
              ..orderBy([(entry) => OrderingTerm.desc(entry.fetchedAt)]))
            .getSingleOrNull();
    return row == null
        ? null
        : WeatherSnapshot.fromJson(
            jsonDecode(row.payloadJson) as Map<String, dynamic>,
          );
  }
}

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
