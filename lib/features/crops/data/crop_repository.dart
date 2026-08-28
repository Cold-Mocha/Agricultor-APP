import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/crops/domain/crop_rotation.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:drift/drift.dart';

final class CropRepository {
  CropRepository(this._database);

  final AppDatabase _database;

  Future<String> createCustom({
    required String ownerId,
    required String name,
    String? notes,
  }) async {
    final id = EntityId.generate().value;
    await _database
        .into(_database.customCrops)
        .insert(
          CustomCropsCompanion.insert(
            id: id,
            ownerId: ownerId,
            name: name.trim(),
            notes: Value(notes?.trim()),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    return id;
  }

  Future<String> planRotation({
    required String ownerId,
    required String sectorId,
    required String cropId,
    required DateTime startsOn,
    DateTime? endsOn,
    bool isCustomCrop = false,
  }) async {
    if (endsOn != null && !endsOn.isAfter(startsOn)) {
      throw ArgumentError('rotation_invalid_range');
    }
    final existing =
        await (_database.select(_database.cropSeasons)..where(
              (row) =>
                  row.sectorId.equals(sectorId) &
                  row.status.isIn(const ['planned', 'active']),
            ))
            .get();
    for (final season in existing) {
      final seasonEnd = season.endsOn ?? DateTime.utc(9999);
      final proposedEnd = endsOn ?? DateTime.utc(9999);
      if (startsOn.isBefore(seasonEnd) &&
          season.startsOn.isBefore(proposedEnd)) {
        throw StateError('rotation_overlap');
      }
    }
    final id = EntityId.generate().value;
    await _database
        .into(_database.cropSeasons)
        .insert(
          CropSeasonsCompanion.insert(
            id: id,
            ownerId: ownerId,
            sectorId: sectorId,
            cropId: cropId,
            isCustomCrop: Value(isCustomCrop),
            status: Value(CropSeasonStatus.planned.name),
            startsOn: startsOn,
            endsOn: Value(endsOn),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    return id;
  }

  Future<void> activate(String seasonId) async {
    final season = await (_database.select(
      _database.cropSeasons,
    )..where((row) => row.id.equals(seasonId))).getSingle();
    await _database.transaction(() async {
      await (_database.update(_database.cropSeasons)..where(
            (row) =>
                row.sectorId.equals(season.sectorId) &
                row.status.equals('active'),
          ))
          .write(
            CropSeasonsCompanion(
              status: const Value('ended'),
              endsOn: Value(DateTime.now().toUtc()),
            ),
          );
      await (_database.update(
        _database.cropSeasons,
      )..where((row) => row.id.equals(seasonId))).write(
        CropSeasonsCompanion(
          status: const Value('active'),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    });
  }
}
