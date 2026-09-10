import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/irrigation/contracts/dto/irrigation_form_input.dart';
import 'package:agrocampo_backend/src/modules/irrigation/domain/entities/irrigation_calculator.dart';
import 'package:agrocampo_backend/src/modules/irrigation/domain/entities/irrigation_explanation.dart';
import 'package:agrocampo_backend/src/modules/irrigation/domain/entities/irrigation_record.dart';
import 'package:agrocampo_backend/src/modules/irrigation/domain/entities/sector_irrigation_config.dart';
import 'package:agrocampo_backend/src/modules/irrigation/infrastructure/persistence/irrigation_estimate_repository.dart';
import 'package:agrocampo_backend/src/modules/irrigation/infrastructure/persistence/irrigation_repository.dart';
import 'package:agrocampo_backend/src/modules/irrigation/infrastructure/persistence/sector_irrigation_config_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final irrigationFacadeProvider = Provider<IrrigationFacade>(
  IrrigationFacade.new,
);

/// Display message plus an opaque calculation snapshot owned by the backend.
/// Persistence rows and calculation inputs never cross the public boundary.
final class IrrigationCalculation {
  const IrrigationCalculation._({
    required this.unavailableCode,
    required this.explanation,
    required this._preview,
    this.basicVolumeLiters,
    this.basicFormula,
    this.previewFingerprint,
  });

  final String? unavailableCode;
  final String? explanation;
  final IrrigationPreview? _preview;
  final double? basicVolumeLiters;
  final String? basicFormula;
  final String? previewFingerprint;
}

final class IrrigationFacade {
  IrrigationFacade(this._ref);
  final Ref _ref;

  Future<IrrigationCalculation?> calculate({
    required String ownerId,
    required IrrigationFormInput input,
  }) async {
    if (input.type != IrrigationType.drip) {
      return const IrrigationCalculation._(
        unavailableCode: 'method_not_drip',
        explanation: null,
        preview: null,
      );
    }
    final sectorId = input.sectorId;
    if (sectorId == null) return null;
    final database = _ref.read(appDatabaseProvider);
    final sector =
        await (database.select(database.sectors)..where(
              (row) => row.ownerId.equals(ownerId) & row.id.equals(sectorId),
            ))
            .getSingleOrNull();
    if (sector == null) return null;
    if (sector.kind != 'crop') {
      return const IrrigationCalculation._(
        unavailableCode: 'operation_not_valid_for_apiary',
        explanation: null,
        preview: null,
      );
    }
    final durationMinutes = int.tryParse(input.duration.trim());
    final flowLitersPerHour = double.tryParse(
      input.flow.trim().replaceAll(',', '.'),
    );
    final basicVolumeLiters = durationMinutes != null &&
            durationMinutes > 0 &&
            flowLitersPerHour != null &&
            flowLitersPerHour > 0
        ? flowLitersPerHour * durationMinutes / 60
        : null;
    final preview =
        await IrrigationEstimateRepository(
          database,
          _ref.read(laborContextReaderProvider),
        ).calculateForSector(
          ownerId: ownerId,
          parcelId: sector.parcelId,
          sectorId: sector.id,
          soilTypeCode: input.soilType.name,
          occurredAt: DateTime.now().toUtc(),
          performedDurationSeconds: (int.tryParse(input.duration) ?? 0) * 60,
        );
    return switch (preview.result) {
      IrrigationUnavailable(:final code) => IrrigationCalculation._(
        unavailableCode: code,
        explanation: null,
        preview: preview,
        basicVolumeLiters: basicVolumeLiters,
        basicFormula: basicVolumeLiters == null
            ? null
            : 'total_flow_l_per_h*duration_min/60',
        previewFingerprint: _fingerprint(input),
      ),
      final IrrigationEstimateResult result => IrrigationCalculation._(
        unavailableCode: null,
        explanation: IrrigationExplanation.short(result),
        preview: preview,
        basicVolumeLiters: basicVolumeLiters,
        basicFormula: basicVolumeLiters == null
            ? null
            : 'total_flow_l_per_h*duration_min/60',
        previewFingerprint: _fingerprint(input),
      ),
    };
  }

  Future<bool> save({
    required String ownerId,
    required IrrigationFormInput input,
    IrrigationCalculation? calculation,
  }) async {
    final sectorId = input.sectorId;
    if (sectorId == null) return false;
    final database = _ref.read(appDatabaseProvider);
    final sector =
        await (database.select(database.sectors)..where(
              (row) => row.ownerId.equals(ownerId) & row.id.equals(sectorId),
            ))
            .getSingleOrNull();
    if (sector == null) return false;
    if (sector.kind != 'crop') return false;
    final durationMinutes = int.tryParse(input.duration.trim());
    final flowLitersPerHour = double.tryParse(
      input.flow.trim().replaceAll(',', '.'),
    );
    if (durationMinutes == null || durationMinutes <= 0) return false;
    if (input.flow.trim().isNotEmpty &&
        (flowLitersPerHour == null || flowLitersPerHour <= 0)) {
      return false;
    }
    var preview = calculation?._preview;
    if (input.type == IrrigationType.drip && preview == null) {
      preview =
          await IrrigationEstimateRepository(
            database,
            _ref.read(laborContextReaderProvider),
          ).calculateForSector(
            ownerId: ownerId,
            parcelId: sector.parcelId,
            sectorId: sector.id,
            soilTypeCode: input.soilType.name,
            occurredAt: DateTime.now().toUtc(),
            performedDurationSeconds: (int.tryParse(input.duration) ?? 0) * 60,
          );
    }
    await IrrigationRepository(
      database,
      _ref.read(laborContextReaderProvider),
    ).savePerformed(
      ownerId: ownerId,
      parcelId: sector.parcelId,
      sectorId: sector.id,
      occurredAt: DateTime.now().toUtc(),
      preview: preview,
      input: BasicIrrigationInput(
        type: input.type,
        soilType: input.soilType,
        durationMinutes: durationMinutes,
        flowLitersPerHour: flowLitersPerHour,
        pressureKpa: input.pressure == null || input.pressure!.trim().isEmpty
            ? null
            : int.tryParse(input.pressure!.trim()),
      ),
    );
    return true;
  }

  static String _fingerprint(IrrigationFormInput input) => [
    input.sectorId ?? '',
    input.type.name,
    input.soilType.name,
    input.duration.trim(),
    input.flow.trim(),
    input.pressure?.trim() ?? '',
  ].join('|');

  Future<String> configurationLabel(String ownerId, String? sectorId) async {
    if (sectorId == null) return 'Selecciona un sector.';
    final row = await SectorIrrigationConfigRepository(
      _ref.read(appDatabaseProvider),
    ).current(ownerId: ownerId, sectorId: sectorId);
    return row == null
        ? 'Sin configuración vigente.'
        : 'Versión ${row.configVersion}: ${row.plantCount} plantas · ${row.emitterCount} goteros · ${row.flowMlMin} ml/min';
  }

  Future<bool> saveConfiguration({
    required String ownerId,
    required String sectorId,
    required SectorIrrigationConfigInput input,
  }) async {
    await SectorIrrigationConfigRepository(_ref.read(appDatabaseProvider))
        .saveVersion(ownerId: ownerId, sectorId: sectorId, input: input);
    return true;
  }
}
