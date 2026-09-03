import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/crops/data/sector_crop_assignment_repository.dart';

final class CropExchangeResult {
  const CropExchangeResult({
    required this.firstAssignmentId,
    required this.secondAssignmentId,
  });

  final String firstAssignmentId;
  final String secondAssignmentId;
}

final class CropExchangeRepository {
  CropExchangeRepository(this._database);

  final AppDatabase _database;

  Future<CropExchangeResult> exchange({
    required String ownerId,
    required String firstSectorId,
    required String secondSectorId,
    required DateTime effectiveAt,
  }) async {
    if (firstSectorId == secondSectorId) {
      throw ArgumentError.value(
        secondSectorId,
        'secondSectorId',
        'same_sector',
      );
    }
    final repository = SectorCropAssignmentRepository(_database);
    final instant = effectiveAt.toUtc();
    final first = await repository.activeAt(
      ownerId: ownerId,
      sectorId: firstSectorId,
      instant: instant,
    );
    final second = await repository.activeAt(
      ownerId: ownerId,
      sectorId: secondSectorId,
      instant: instant,
    );
    if (first == null || second == null) {
      throw StateError('exchange_requires_two_active_assignments');
    }

    return _database.transaction(() async {
      final firstNew = await repository.plan(
        ownerId: ownerId,
        sectorId: firstSectorId,
        agriculturalSeasonId: first.agriculturalSeasonId,
        crop: second.crop,
        effectiveFrom: instant,
        notes: 'Intercambio con $secondSectorId',
      );
      final secondNew = await repository.plan(
        ownerId: ownerId,
        sectorId: secondSectorId,
        agriculturalSeasonId: second.agriculturalSeasonId,
        crop: first.crop,
        effectiveFrom: instant,
        notes: 'Intercambio con $firstSectorId',
      );
      await repository.activate(
        ownerId: ownerId,
        assignmentId: firstNew,
        effectiveAt: instant,
      );
      await repository.activate(
        ownerId: ownerId,
        assignmentId: secondNew,
        effectiveAt: instant,
      );
      return CropExchangeResult(
        firstAssignmentId: firstNew,
        secondAssignmentId: secondNew,
      );
    });
  }
}
