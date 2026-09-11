import 'package:agrocampo_backend/src/modules/agricultural_context/contracts/dto/context_options.dart';
import 'package:agrocampo_backend/src/modules/agricultural_context/domain/entities/agricultural_context.dart';
import 'package:agrocampo_backend/src/modules/agricultural_context/domain/policies/domain_compatibility_policy.dart';
import 'package:agrocampo_backend/src/modules/territory/territory_api.dart';
import 'package:agrocampo_backend/src/shared/contracts/productive_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contextOptionsQueriesProvider = Provider<ContextOptionsQueries>(
  (ref) => ContextOptionsQueries(
    ref.watch(parcelFacadeProvider),
    ref.watch(territoryMapFacadeProvider),
  ),
);

final class ContextOptionsQueries {
  ContextOptionsQueries(this._parcels, this._territory);

  final ParcelFacade _parcels;
  final TerritoryMapFacade _territory;

  Stream<List<ContextOption>> watchParcels(String ownerId) => _parcels
      .watchAll(ownerId)
      .map(
        (parcels) => parcels
            .where((parcel) => !parcel.isArchived)
            .map((parcel) => ContextOption(id: parcel.id, name: parcel.name))
            .toList(growable: false),
      );

  Stream<List<ContextOption>> watchSectors(String ownerId, String? parcelId) =>
      _territory
          .watchContextSectors(ownerId: ownerId, parcelId: parcelId ?? '')
          .map(
            (sectors) => sectors
                .map(
                  (sector) => ContextOption(
                    id: sector.id,
                    name: sector.name,
                    category: ProductiveCategory.fromCode(sector.kind),
                  ),
                )
                .toList(growable: false),
          );

  Future<BoundContextSummary> loadBound(BoundAgriculturalContext bound) async {
    final ownerId = bound.ownerId;
    final parcel = ownerId == null || bound.parcelId == null
        ? null
        : await _parcels.loadOwned(ownerId: ownerId, id: bound.parcelId!);
    final sector = ownerId == null || bound.sectorId == null
        ? null
        : await _territory.loadContextSector(
            ownerId: ownerId,
            sectorId: bound.sectorId!,
            parcelId: bound.parcelId,
          );
    return BoundContextSummary(
      parcelName: parcel?.name,
      sectorName: sector?.name,
      category: sector == null
          ? null
          : ProductiveCategory.fromCode(sector.kind),
      allowedOperations: sector == null
          ? const []
          : const DomainCompatibilityPolicy().allowedOperations(
              ProductiveCategory.fromCode(sector.kind),
            ),
    );
  }
}
