import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class IrrigationCalculationUiState {
  const IrrigationCalculationUiState._(this.message, this._calculation);

  final String message;
  final IrrigationCalculation _calculation;
}

final irrigationFormControllerProvider = Provider<IrrigationFormController>(
  IrrigationFormController.new,
);

final class IrrigationFormController {
  IrrigationFormController(this._ref);

  final Ref _ref;

  Future<IrrigationCalculationUiState?> calculate(
    IrrigationFormInput input,
  ) async {
    final ownerId = _ref.read(unlockedOwnerIdProvider);
    if (ownerId == null) return null;
    final calculation = await _ref
        .read(irrigationFacadeProvider)
        .calculate(ownerId: ownerId, input: input);
    if (calculation == null) return null;
    final message = switch (calculation.unavailableCode) {
      'drip_only' => '002 solo calcula recomendaciones para riego por goteo.',
      'drip_config_unavailable' =>
        'Configura plantas, goteros y caudal del sector antes de calcular.',
      'crop_rule_unavailable' => 'Regla agronómica no disponible. Puedes guardar el riego básico sin recomendación.',
      final String code when code.isNotEmpty =>
        'Completa entradas positivas para calcular.',
      _ => calculation.explanation ?? '',
    };
    return IrrigationCalculationUiState._(message, calculation);
  }

  Future<bool> save(
    IrrigationFormInput input, {
    IrrigationCalculationUiState? calculation,
  }) {
    final ownerId = _ref.read(unlockedOwnerIdProvider);
    if (ownerId == null) return Future.value(false);
    return _ref
        .read(irrigationFacadeProvider)
        .save(
          ownerId: ownerId,
          input: input,
          calculation: calculation?._calculation,
        );
  }

  Future<String> configurationLabel(String? sectorId) {
    final ownerId = _ref.read(unlockedOwnerIdProvider);
    if (ownerId == null) return Future.value('Selecciona un sector.');
    return _ref
        .read(irrigationFacadeProvider)
        .configurationLabel(ownerId, sectorId);
  }

  Future<bool> saveConfiguration({
    required String sectorId,
    required SectorIrrigationConfigInput input,
  }) {
    final ownerId = _ref.read(unlockedOwnerIdProvider);
    if (ownerId == null) return Future.value(false);
    return _ref
        .read(irrigationFacadeProvider)
        .saveConfiguration(ownerId: ownerId, sectorId: sectorId, input: input);
  }
}
