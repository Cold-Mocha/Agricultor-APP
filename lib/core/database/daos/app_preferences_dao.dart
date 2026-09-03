import 'package:agrocampo/core/database/app_database.dart';
import 'package:drift/drift.dart';

final class AppPreferencesDao {
  AppPreferencesDao(this._database);

  final AppDatabase _database;

  Future<String?> read(String ownerId, String key) async =>
      (await (_database.select(_database.appPreferences)..where(
                (row) => row.ownerId.equals(ownerId) & row.key.equals(key),
              ))
              .getSingleOrNull())
          ?.value;

  Future<Map<String, String>> readAll(String ownerId) async {
    final rows = await (_database.select(
      _database.appPreferences,
    )..where((row) => row.ownerId.equals(ownerId))).get();
    return {for (final row in rows) row.key: row.value};
  }

  Future<void> write(String ownerId, String key, String? value) async {
    if (value == null) {
      await (_database.delete(_database.appPreferences)
            ..where((row) => row.ownerId.equals(ownerId) & row.key.equals(key)))
          .go();
      return;
    }
    await _database
        .into(_database.appPreferences)
        .insertOnConflictUpdate(
          AppPreferencesCompanion.insert(
            ownerId: ownerId,
            key: key,
            value: value,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> clearAgriculturalContext(String ownerId) async {
    const keys = {
      'active_parcel_id',
      'active_sector_id',
      'active_season_id',
      'active_assignment_id',
      'agricultural_context_revision',
    };
    await (_database.delete(
      _database.appPreferences,
    )..where((row) => row.ownerId.equals(ownerId) & row.key.isIn(keys))).go();
  }
}
