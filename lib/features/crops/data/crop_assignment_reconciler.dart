import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/crops/data/sector_crop_assignment_repository.dart';
import 'package:drift/drift.dart';

final class CropAssignmentReconciler {
  CropAssignmentReconciler(this._database);

  final AppDatabase _database;

  Future<int> reconcile(String ownerId, {DateTime? now}) async {
    final instant = (now ?? DateTime.now()).toUtc();
    final due =
        await (_database.select(_database.cropSeasons).join([
                innerJoin(
                  _database.agriculturalSeasons,
                  _database.agriculturalSeasons.id.equalsExp(
                    _database.cropSeasons.agriculturalSeasonId,
                  ),
                ),
              ])
              ..where(
                _database.cropSeasons.ownerId.equals(ownerId) &
                    _database.cropSeasons.status.equals('planned') &
                    _database.cropSeasons.startsOn.isSmallerOrEqualValue(
                      instant,
                    ) &
                    _database.cropSeasons.deletedAt.isNull() &
                    _database.agriculturalSeasons.status.equals('active') &
                    _database.agriculturalSeasons.deletedAt.isNull(),
              )
              ..orderBy([OrderingTerm.asc(_database.cropSeasons.startsOn)]))
            .get();
    final repository = SectorCropAssignmentRepository(_database);
    var activated = 0;
    for (final joined in due) {
      final assignment = joined.readTable(_database.cropSeasons);
      await repository.activate(
        ownerId: ownerId,
        assignmentId: assignment.id,
        effectiveAt: assignment.startsOn,
      );
      activated++;
    }
    return activated;
  }
}
