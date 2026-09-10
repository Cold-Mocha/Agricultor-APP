import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/agricultural_context/domain/entities/agricultural_context.dart';
import 'package:agrocampo_backend/src/modules/agricultural_context/domain/entities/productive_domain.dart';
import 'package:agrocampo_backend/src/modules/agricultural_context/domain/services/domain_compatibility_policy.dart';
import 'package:agrocampo_backend/src/modules/agricultural_context/infrastructure/persistence/daos/app_preferences_dao.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/crop_cycles_api.dart';
import 'package:agrocampo_backend/src/modules/territory/territory_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final agriculturalContextFacadeProvider = Provider<AgriculturalContextFacade>(
  (ref) => AgriculturalContextFacade(
    AppPreferencesDao(ref.watch(appDatabaseProvider)),
    ref.watch(parcelFacadeProvider),
    ref.watch(territoryMapFacadeProvider),
    ref.watch(cropCyclesFacadeProvider),
  ),
);

/// Validates and persists the agricultural scope. Presentation owns which
/// context is currently selected and asks this facade for each transition.
final class AgriculturalContextFacade {
  AgriculturalContextFacade(
    this._preferences,
    this._parcels,
    this._territory,
    this._cropCycles,
  );

  final AppPreferencesDao _preferences;
  final ParcelFacade _parcels;
  final TerritoryMapFacade _territory;
  final CropCyclesFacade _cropCycles;

  Future<AgriculturalContext> restore(String ownerId) async {
    final values = await _preferences.readAll(ownerId);
    var parcelId = values['active_parcel_id'];
    var sectorId = values['active_sector_id'];
    var seasonId = values['active_season_id'];
    var assignmentId = values['active_assignment_id'];

    final validParcels = (await _parcels.listAll(ownerId))
        .where((parcel) => !parcel.isArchived)
        .toList(growable: false);
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
          : await _territory.loadContextSector(
              ownerId: ownerId,
              sectorId: sectorId,
              parcelId: parcelId,
            );
      if (sector == null) {
        sectorId = null;
        assignmentId = null;
      }
      final season = seasonId == null
          ? null
          : await _cropCycles.loadSeason(ownerId: ownerId, id: seasonId);
      if (season == null || season.parcelId != parcelId) {
        seasonId = null;
        assignmentId = null;
      }
      final assignment = assignmentId == null || sectorId == null
          ? null
          : await _cropCycles.loadAssignment(
              ownerId: ownerId,
              id: assignmentId,
            );
      if (assignment == null ||
          assignment.sectorId != sectorId ||
          (seasonId != null && assignment.agriculturalSeasonId != seasonId)) {
        assignmentId = null;
      }
    }
    final context = AgriculturalContext(
      ownerId: ownerId,
      parcelId: parcelId,
      sectorId: sectorId,
      seasonId: seasonId,
      assignmentId: assignmentId,
      revision:
          int.tryParse(values['agricultural_context_revision'] ?? '') ?? 0,
      category: sectorId == null
          ? null
          : ProductiveCategory.fromCode(
              (await _territory.loadContextSector(
                ownerId: ownerId,
                sectorId: sectorId,
                parcelId: parcelId,
              ))?.kind,
            ),
      resolvedFor: DateTime.now().toUtc(),
    );
    await _persist(context);
    return context;
  }

  Future<AgriculturalContext> selectParcel(
    AgriculturalContext current,
    String parcelId,
  ) async {
    final ownerId = current.ownerId;
    if (ownerId == null) return current;
    final parcel = await _parcels.loadOwned(ownerId: ownerId, id: parcelId);
    if (parcel == null || parcel.isArchived) {
      throw StateError('invalid_parcel_context');
    }
    await _parcels.selectActiveForContext(ownerId: ownerId, id: parcelId);
    final next = current.copyWith(
      parcelId: parcelId,
      clearSector: true,
      clearSeason: true,
      clearAssignment: true,
      revision: current.revision + 1,
    );
    await _persist(next);
    return next;
  }

  Future<AgriculturalContext> selectSector(
    AgriculturalContext current,
    String? sectorId,
  ) async {
    if (sectorId != null && current.parcelId == null) {
      throw StateError('parcel_context_required');
    }
    if (sectorId != null) {
      final valid = await _territory.loadContextSector(
        ownerId: current.ownerId!,
        sectorId: sectorId,
        parcelId: current.parcelId!,
      );
      if (valid == null) throw StateError('invalid_sector_context');
    }
    final next = current.copyWith(
      sectorId: sectorId,
      clearSector: sectorId == null,
      clearAssignment: true,
      revision: current.revision + 1,
      category: sectorId == null
          ? ProductiveCategory.legacyUnknown
          : ProductiveCategory.fromCode(
              (await _territory.loadContextSector(
                ownerId: current.ownerId!,
                sectorId: sectorId,
                parcelId: current.parcelId,
              ))!.kind,
            ),
      allowedOperations: sectorId == null
          ? const []
          : const DomainCompatibilityPolicy().allowedOperations(
              ProductiveCategory.fromCode(
                (await _territory.loadContextSector(
                  ownerId: current.ownerId!,
                  sectorId: sectorId,
                  parcelId: current.parcelId,
                ))!.kind,
              ),
            ),
      resolvedFor: DateTime.now().toUtc(),
    );
    await _persist(next);
    return next;
  }

  Future<AgriculturalContext> selectSeason(
    AgriculturalContext current,
    String? seasonId,
  ) async {
    if (seasonId != null) {
      if (current.ownerId == null || current.parcelId == null) {
        throw StateError('parcel_context_required');
      }
      final valid = await _cropCycles.loadSeason(
        ownerId: current.ownerId!,
        id: seasonId,
      );
      if (valid == null || valid.parcelId != current.parcelId) {
        throw StateError('invalid_season_context');
      }
    }
    final next = current.copyWith(
      seasonId: seasonId,
      clearSeason: seasonId == null,
      clearAssignment: true,
      revision: current.revision + 1,
    );
    await _persist(next);
    return next;
  }

  Future<AgriculturalContext> selectAssignment(
    AgriculturalContext current,
    String? assignmentId,
  ) async {
    if (assignmentId != null) {
      if (current.ownerId == null || current.sectorId == null) {
        throw StateError('sector_context_required');
      }
      final valid = await _cropCycles.loadAssignment(
        ownerId: current.ownerId!,
        id: assignmentId,
      );
      if (valid == null ||
          valid.sectorId != current.sectorId ||
          (current.seasonId != null &&
              valid.agriculturalSeasonId != current.seasonId)) {
        throw StateError('invalid_assignment_context');
      }
    }
    final next = current.copyWith(
      assignmentId: assignmentId,
      clearAssignment: assignmentId == null,
      revision: current.revision + 1,
    );
    await _persist(next);
    return next;
  }

  Future<void> _persist(AgriculturalContext context) async {
    final ownerId = context.ownerId;
    if (ownerId == null) return;
    await Future.wait([
      _preferences.write(ownerId, 'active_parcel_id', context.parcelId),
      _preferences.write(ownerId, 'active_sector_id', context.sectorId),
      _preferences.write(ownerId, 'active_season_id', context.seasonId),
      _preferences.write(ownerId, 'active_assignment_id', context.assignmentId),
      _preferences.write(
        ownerId,
        'agricultural_context_revision',
        '${context.revision}',
      ),
    ]);
  }
}
