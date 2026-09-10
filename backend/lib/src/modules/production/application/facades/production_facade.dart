import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/labors/labors_api.dart';
import 'package:agrocampo_backend/src/modules/production/contracts/dto/production_form_input.dart';
import 'package:agrocampo_backend/src/modules/production/domain/entities/harvest_input.dart';
import 'package:agrocampo_backend/src/modules/production/infrastructure/persistence/production_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productionFacadeProvider = Provider<ProductionFacade>(
  ProductionFacade.new,
);

final class ProductionFacade {
  ProductionFacade(this._ref);
  final Ref _ref;

  Future<({LaborContext context, HarvestContextSummary summary})?> _loadContext(
    String ownerId,
    String? sectorId,
  ) async {
    if (sectorId == null) return null;
    final database = _ref.read(appDatabaseProvider);
    final sector =
        await (database.select(database.sectors)..where(
              (row) => row.ownerId.equals(ownerId) & row.id.equals(sectorId),
            ))
            .getSingleOrNull();
    if (sector == null) return null;
    try {
      final context = await _ref
          .read(laborContextReaderProvider)
          .resolveContext(
            ownerId: ownerId,
            parcelId: sector.parcelId,
            sectorId: sector.id,
            occurredAt: DateTime.now().toUtc(),
          );
      final season = await (database.select(
        database.agriculturalSeasons,
      )..where((row) => row.id.equals(context.seasonId))).getSingle();
      final cropName = context.isCustomCrop
          ? (await (database.select(
              database.customCrops,
            )..where((row) => row.id.equals(context.cropId))).getSingle()).name
          : (await (database.select(
                  database.officialCrops,
                )..where((row) => row.id.equals(context.cropId))).getSingle())
                .commonName;
      return (
        context: context,
        summary: HarvestContextSummary(
          seasonName: season.name,
          cropName: cropName,
        ),
      );
    } on Object {
      return null;
    }
  }

  Future<HarvestContextSummary?> loadContext(
    String ownerId,
    String? sectorId,
  ) async => (await _loadContext(ownerId, sectorId))?.summary;

  Future<ProductionSaveStatus> save(
    String ownerId,
    ProductionFormInput input,
  ) async {
    final resolved = await _loadContext(ownerId, input.sectorId);
    if (resolved == null) return ProductionSaveStatus.missingContext;
    final context = resolved.context;
    await ProductionRepository(
      _ref.read(appDatabaseProvider),
      _ref.read(laborContextReaderProvider),
    ).save(
      ownerId: ownerId,
      parcelId: context.parcelId,
      sectorId: context.sectorId,
      seasonId: context.seasonId,
      cropAssignmentId: context.assignmentId,
      input: HarvestInput(
        cropId: context.cropId,
        quantity: double.tryParse(input.quantity.replaceAll(',', '.')) ?? 0,
        unit: input.unit,
        qualityNotes: input.qualityNotes,
        harvestedAt: DateTime.now().toUtc(),
      ),
    );
    return ProductionSaveStatus.saved;
  }
}
