import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class IrrigationCalculationUiState {
  const IrrigationCalculationUiState._(this.message, this._calculation);

  final String message;
  final IrrigationCalculation _calculation;
  bool get isUnavailable => _calculation.unavailableCode != null;
  bool get needsCrop => _calculation.unavailableCode == _missingCropCode;
  double? get basicVolumeLiters => _calculation.basicVolumeLiters;
  String? get basicFormula => _calculation.basicFormula;
  String? get previewFingerprint => _calculation.previewFingerprint;
}

const _missingCropCode = 'labor_crop_context_required';

/// Why an irrigation could not be stored; [needsCrop] lets the page offer the
/// crop assignment shortcut.
typedef IrrigationSaveFailure = ({String message, bool needsCrop});

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
      'method_not_drip' =>
        'Sólo se calculan recomendaciones para riego por goteo.',
      'drip_config_unavailable' =>
        'Configura plantas, goteros y caudal del sector antes de calcular.',
      'crop_rule_unavailable' => 'Regla agronómica no disponible. Puedes guardar el riego básico sin recomendación.',
      'invalid_input' => 'Completa entradas positivas para calcular.',
      final String code => _failureMessage(code),
      null => calculation.explanation ?? '',
    };
    return IrrigationCalculationUiState._(message, calculation);
  }

  /// Returns `null` when the irrigation was stored, otherwise what is missing
  /// or failing.
  Future<IrrigationSaveFailure?> save(
    IrrigationFormInput input, {
    IrrigationCalculationUiState? calculation,
  }) async {
    final ownerId = _ref.read(unlockedOwnerIdProvider);
    if (ownerId == null) {
      return (message: _failureMessage('session_locked'), needsCrop: false);
    }
    final code = await _ref
        .read(irrigationFacadeProvider)
        .save(
          ownerId: ownerId,
          input: input,
          calculation: calculation?._calculation,
        );
    return code == null
        ? null
        : (message: _failureMessage(code), needsCrop: code == _missingCropCode);
  }

  static String _failureMessage(String code) => switch (code) {
    'session_locked' =>
      'Inicia sesión o desbloquea la app para registrar riego.',
    'sector_required' => 'Selecciona un sector antes de continuar.',
    'operation_not_valid_for_apiary' =>
      'El riego no aplica a una unidad apícola.',
    'duration_required' => 'Ingresa la duración del riego en minutos.',
    'flow_invalid' => 'El caudal debe ser un número mayor a cero.',
    _missingCropCode => 'El sector no tiene un cultivo vigente. Asígnale un cultivo en una temporada antes de registrar riego.',
    'labor_season_closed_or_missing' || 'labor_season_context_invalid' => 'La temporada del sector está cerrada o no existe. Abre una temporada activa.',
    'labor_sector_context_invalid' =>
      'El sector ya no existe. Vuelve a elegirlo.',
    _ => 'No se pudo completar la operación ($code).',
  };

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
