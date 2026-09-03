import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/database/daos/app_preferences_dao.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/context/domain/agricultural_context.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final agriculturalContextControllerProvider =
    NotifierProvider<AgriculturalContextController, AgriculturalContext>(
      AgriculturalContextController.new,
    );

final class AgriculturalContextController
    extends Notifier<AgriculturalContext> {
  @override
  AgriculturalContext build() {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    if (ownerId == null) return const AgriculturalContext();
    Future.microtask(() => restore(ownerId));
    return AgriculturalContext.restoring(ownerId);
  }

  Future<void> restore(String ownerId) async {
    if (state.ownerId != ownerId) return;
    final database = ref.read(appDatabaseProvider);
    final values = await AppPreferencesDao(database).readAll(ownerId);
    var parcelId = values['active_parcel_id'];
    var sectorId = values['active_sector_id'];
    var seasonId = values['active_season_id'];
    var assignmentId = values['active_assignment_id'];

    final validParcels =
        await (database.select(database.parcels)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.deletedAt.isNull() &
                  row.isArchived.equals(false),
            ))
            .get();
    if (!validParcels.any((row) => row.id == parcelId)) {
      final activeRows = validParcels.where((row) => row.isActive).toList();
      parcelId = activeRows.isNotEmpty
          ? activeRows.first.id
          : validParcels.isEmpty
          ? null
          : validParcels.first.id;
    }
    if (parcelId == null) {
      sectorId = null;
      seasonId = null;
      assignmentId = null;
    } else {
      final sector = sectorId == null
          ? null
          : await (database.select(database.sectors)..where(
                  (row) =>
                      row.id.equals(sectorId!) &
                      row.ownerId.equals(ownerId) &
                      row.parcelId.equals(parcelId!) &
                      row.deletedAt.isNull(),
                ))
                .getSingleOrNull();
      if (sector == null) {
        sectorId = null;
        assignmentId = null;
      }
      final season = seasonId == null
          ? null
          : await (database.select(database.agriculturalSeasons)..where(
                  (row) =>
                      row.id.equals(seasonId!) &
                      row.ownerId.equals(ownerId) &
                      row.parcelId.equals(parcelId!) &
                      row.deletedAt.isNull(),
                ))
                .getSingleOrNull();
      if (season == null) {
        seasonId = null;
        assignmentId = null;
      }
      final assignment = assignmentId == null || sectorId == null
          ? null
          : await (database.select(database.cropSeasons)..where(
                  (row) =>
                      row.id.equals(assignmentId!) &
                      row.ownerId.equals(ownerId) &
                      row.sectorId.equals(sectorId!) &
                      row.deletedAt.isNull(),
                ))
                .getSingleOrNull();
      if (assignment == null ||
          (seasonId != null && assignment.agriculturalSeasonId != seasonId)) {
        assignmentId = null;
      }
    }
    final revision =
        int.tryParse(values['agricultural_context_revision'] ?? '') ?? 0;
    state = AgriculturalContext(
      ownerId: ownerId,
      parcelId: parcelId,
      sectorId: sectorId,
      seasonId: seasonId,
      assignmentId: assignmentId,
      revision: revision,
    );
    await _persist();
  }

  Future<void> selectParcel(String parcelId) async {
    final ownerId = state.ownerId;
    if (ownerId == null) return;
    final database = ref.read(appDatabaseProvider);
    final parcel =
        await (database.select(database.parcels)..where(
              (row) =>
                  row.id.equals(parcelId) &
                  row.ownerId.equals(ownerId) &
                  row.deletedAt.isNull() &
                  row.isArchived.equals(false),
            ))
            .getSingleOrNull();
    if (parcel == null) throw StateError('invalid_parcel_context');
    await database.transaction(() async {
      await (database.update(database.parcels)
            ..where((row) => row.ownerId.equals(ownerId)))
          .write(const ParcelsCompanion(isActive: Value(false)));
      await (database.update(database.parcels)
            ..where((row) => row.id.equals(parcelId)))
          .write(const ParcelsCompanion(isActive: Value(true)));
    });
    state = state.copyWith(
      parcelId: parcelId,
      clearSector: true,
      clearSeason: true,
      clearAssignment: true,
      revision: state.revision + 1,
    );
    await _persist();
  }

  Future<void> selectSector(String? sectorId) async {
    if (sectorId != null && state.parcelId == null) {
      throw StateError('parcel_context_required');
    }
    if (sectorId != null) {
      final database = ref.read(appDatabaseProvider);
      final valid =
          await (database.select(database.sectors)..where(
                (row) =>
                    row.id.equals(sectorId) &
                    row.ownerId.equals(state.ownerId!) &
                    row.parcelId.equals(state.parcelId!) &
                    row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (valid == null) throw StateError('invalid_sector_context');
    }
    state = state.copyWith(
      sectorId: sectorId,
      clearSector: sectorId == null,
      clearAssignment: true,
      revision: state.revision + 1,
    );
    await _persist();
  }

  Future<void> selectSeason(String? seasonId) async {
    if (seasonId != null) {
      if (state.ownerId == null || state.parcelId == null) {
        throw StateError('parcel_context_required');
      }
      final database = ref.read(appDatabaseProvider);
      final valid =
          await (database.select(database.agriculturalSeasons)..where(
                (row) =>
                    row.id.equals(seasonId) &
                    row.ownerId.equals(state.ownerId!) &
                    row.parcelId.equals(state.parcelId!) &
                    row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (valid == null) throw StateError('invalid_season_context');
    }
    state = state.copyWith(
      seasonId: seasonId,
      clearSeason: seasonId == null,
      clearAssignment: true,
      revision: state.revision + 1,
    );
    await _persist();
  }

  Future<void> selectAssignment(String? assignmentId) async {
    if (assignmentId != null) {
      if (state.ownerId == null || state.sectorId == null) {
        throw StateError('sector_context_required');
      }
      final database = ref.read(appDatabaseProvider);
      final valid =
          await (database.select(database.cropSeasons)..where(
                (row) =>
                    row.id.equals(assignmentId) &
                    row.ownerId.equals(state.ownerId!) &
                    row.sectorId.equals(state.sectorId!) &
                    row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (valid == null ||
          (state.seasonId != null &&
              valid.agriculturalSeasonId != state.seasonId)) {
        throw StateError('invalid_assignment_context');
      }
    }
    state = state.copyWith(
      assignmentId: assignmentId,
      clearAssignment: assignmentId == null,
      revision: state.revision + 1,
    );
    await _persist();
  }

  Future<void> _persist() async {
    final ownerId = state.ownerId;
    if (ownerId == null) return;
    final dao = AppPreferencesDao(ref.read(appDatabaseProvider));
    await Future.wait([
      dao.write(ownerId, 'active_parcel_id', state.parcelId),
      dao.write(ownerId, 'active_sector_id', state.sectorId),
      dao.write(ownerId, 'active_season_id', state.seasonId),
      dao.write(ownerId, 'active_assignment_id', state.assignmentId),
      dao.write(ownerId, 'agricultural_context_revision', '${state.revision}'),
    ]);
  }
}
