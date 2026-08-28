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
  }) async {
    final snapshot = await _gateway.fetch(locality);
    await _database
        .into(_database.weatherCache)
        .insertOnConflictUpdate(
          WeatherCacheCompanion.insert(
            id: '$ownerId:$locality',
            ownerId: ownerId,
            locality: locality,
            payloadJson: jsonEncode(snapshot.toJson()),
            fetchedAt: snapshot.fetchedAt.toUtc(),
          ),
        );
    return snapshot;
  }

  Future<WeatherSnapshot?> cached(String ownerId) async {
    final row =
        await (_database.select(_database.weatherCache)
              ..where((entry) => entry.ownerId.equals(ownerId))
              ..orderBy([(entry) => OrderingTerm.desc(entry.fetchedAt)]))
            .getSingleOrNull();
    return row == null
        ? null
        : WeatherSnapshot.fromJson(
            jsonDecode(row.payloadJson) as Map<String, dynamic>,
          );
  }
}
