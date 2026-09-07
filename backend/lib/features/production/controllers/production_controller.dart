import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/backend_providers.dart';
import '../../auth/controllers/session_controller.dart';
import '../../labors/repositories/labor_repository.dart';
import '../domain/harvest_input.dart';
import '../dto/production_form_input.dart';
import '../repositories/production_repository.dart';

final productionControllerProvider = Provider<ProductionController>(
  ProductionController.new,
);

final class ProductionController {
  ProductionController(this._ref);
  final Ref _ref;

  Future<({String ownerId, LaborContext context, HarvestContextUiState ui})?>
  _loadContext(String? sectorId) async {
    final ownerId = _ref.read(sessionControllerProvider).ownerId;
    if (ownerId == null || sectorId == null) return null;
    final database = _ref.read(appDatabaseProvider);
    final sector =
        await (database.select(database.sectors)..where(
              (row) => row.ownerId.equals(ownerId) & row.id.equals(sectorId),
            ))
            .getSingleOrNull();
    if (sector == null) return null;
    try {
      final context = await LaborRepository(database).resolveContext(
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
        ownerId: ownerId,
        context: context,
        ui: HarvestContextUiState(seasonName: season.name, cropName: cropName),
      );
    } on Object {
      return null;
    }
  }

  Future<HarvestContextUiState?> loadContext(String? sectorId) async =>
      (await _loadContext(sectorId))?.ui;

  Future<ProductionSaveStatus> save(ProductionFormInput input) async {
    final resolved = await _loadContext(input.sectorId);
    if (resolved == null) return ProductionSaveStatus.missingContext;
    final context = resolved.context;
    await ProductionRepository(_ref.read(appDatabaseProvider)).save(
      ownerId: resolved.ownerId,
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
