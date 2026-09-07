import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/backend_providers.dart';
import '../../auth/controllers/session_controller.dart';
import '../domain/irrigation_calculator.dart';
import '../domain/irrigation_explanation.dart';
import '../domain/irrigation_record.dart';
import '../domain/sector_irrigation_config.dart';
import '../dto/irrigation_form_input.dart';
import '../repositories/irrigation_estimate_repository.dart';
import '../repositories/irrigation_repository.dart';
import '../repositories/sector_irrigation_config_repository.dart';

final irrigationFormControllerProvider = Provider<IrrigationFormController>(
  IrrigationFormController.new,
);

/// Display message plus an opaque calculation snapshot owned by the backend.
/// Persistence rows and calculation inputs never cross the public boundary.
final class IrrigationCalculationUiState {
  const IrrigationCalculationUiState._(this.message, this._preview);
  final String message;
  final IrrigationPreview? _preview;
}

final class IrrigationFormController {
  IrrigationFormController(this._ref);
  final Ref _ref;

  Future<IrrigationCalculationUiState?> calculate(
    IrrigationFormInput input,
  ) async {
    if (input.type != IrrigationType.drip) {
      return const IrrigationCalculationUiState._(
        '002 solo calcula recomendaciones para riego por goteo.',
        null,
      );
    }
    final ownerId = _ref.read(unlockedOwnerIdProvider);
    final sectorId = input.sectorId;
    if (ownerId == null || sectorId == null) return null;
    final database = _ref.read(appDatabaseProvider);
    final sector =
        await (database.select(database.sectors)..where(
              (row) => row.ownerId.equals(ownerId) & row.id.equals(sectorId),
            ))
            .getSingleOrNull();
    if (sector == null) return null;
    final preview = await IrrigationEstimateRepository(database)
        .calculateForSector(
          ownerId: ownerId,
          parcelId: sector.parcelId,
          sectorId: sector.id,
          soilTypeCode: input.soilType.name,
          occurredAt: DateTime.now().toUtc(),
          performedDurationSeconds: (int.tryParse(input.duration) ?? 0) * 60,
        );
    final message = switch (preview.result) {
      IrrigationUnavailable(:final code) =>
        code == 'drip_config_unavailable'
            ? 'Configura plantas, goteros y caudal del sector antes de calcular.'
            : code == 'crop_rule_unavailable'
            ? 'Regla agronómica no disponible. Puedes guardar el riego básico sin recomendación.'
            : 'Completa entradas positivas para calcular.',
      final IrrigationEstimateResult result => IrrigationExplanation.short(
        result,
      ),
    };
    return IrrigationCalculationUiState._(message, preview);
  }

  Future<bool> save(
    IrrigationFormInput input, {
    IrrigationCalculationUiState? calculation,
  }) async {
    final ownerId = _ref.read(unlockedOwnerIdProvider);
    final sectorId = input.sectorId;
    if (ownerId == null || sectorId == null) return false;
    final database = _ref.read(appDatabaseProvider);
    final sector =
        await (database.select(database.sectors)..where(
              (row) => row.ownerId.equals(ownerId) & row.id.equals(sectorId),
            ))
            .getSingleOrNull();
    if (sector == null) return false;
    var preview = calculation?._preview;
    if (input.type == IrrigationType.drip && preview == null) {
      preview = await IrrigationEstimateRepository(database).calculateForSector(
        ownerId: ownerId,
        parcelId: sector.parcelId,
        sectorId: sector.id,
        soilTypeCode: input.soilType.name,
        occurredAt: DateTime.now().toUtc(),
        performedDurationSeconds: (int.tryParse(input.duration) ?? 0) * 60,
      );
    }
    await IrrigationRepository(database).savePerformed(
      ownerId: ownerId,
      parcelId: sector.parcelId,
      sectorId: sector.id,
      occurredAt: DateTime.now().toUtc(),
      preview: preview,
      input: BasicIrrigationInput(
        type: input.type,
        soilType: input.soilType,
        durationMinutes: int.tryParse(input.duration) ?? 0,
        flowLitersPerHour: double.tryParse(input.flow.replaceAll(',', '.')),
      ),
    );
    return true;
  }

  Future<String> configurationLabel(String? sectorId) async {
    final ownerId = _ref.read(sessionControllerProvider).ownerId;
    if (ownerId == null || sectorId == null) return 'Selecciona un sector.';
    final row = await SectorIrrigationConfigRepository(
      _ref.read(appDatabaseProvider),
    ).current(ownerId: ownerId, sectorId: sectorId);
    return row == null
        ? 'Sin configuración vigente.'
        : 'Versión ${row.configVersion}: ${row.plantCount} plantas · ${row.emitterCount} goteros · ${row.flowMlMin} ml/min';
  }

  Future<bool> saveConfiguration({
    required String sectorId,
    required SectorIrrigationConfigInput input,
  }) async {
    final ownerId = _ref.read(sessionControllerProvider).ownerId;
    if (ownerId == null) return false;
    await SectorIrrigationConfigRepository(_ref.read(appDatabaseProvider))
        .saveVersion(ownerId: ownerId, sectorId: sectorId, input: input);
    return true;
  }
}
