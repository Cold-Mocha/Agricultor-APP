import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';

final class IrrigationLaborDetails {
  const IrrigationLaborDetails({
    required this.method,
    required this.durationMinutes,
    this.appliedVolumeLiters,
    this.flowLitersPerHour,
    this.pressureKpa,
    this.calculationFormula,
    this.roundingMode,
  });

  final String method;
  final int durationMinutes;
  final double? appliedVolumeLiters;
  final double? flowLitersPerHour;
  final int? pressureKpa;
  final String? calculationFormula;
  final String? roundingMode;

  LaborDetails toEnvelope() {
    if (method.trim().isEmpty || durationMinutes <= 0) {
      throw ArgumentError('irrigation_details_invalid');
    }
    if (appliedVolumeLiters != null && appliedVolumeLiters! <= 0) {
      throw ArgumentError('irrigation_volume_invalid');
    }
    if (flowLitersPerHour != null && flowLitersPerHour! <= 0) {
      throw ArgumentError('irrigation_flow_invalid');
    }
    if (pressureKpa != null && pressureKpa! <= 0) {
      throw ArgumentError('irrigation_pressure_invalid');
    }
    return LaborDetails.current(LaborType.irrigation, {
      'method': method.trim(),
      'durationMinutes': durationMinutes,
      'appliedVolumeLiters': appliedVolumeLiters,
      'flowLitersPerHour': flowLitersPerHour,
      'pressureKpa': pressureKpa,
      'calculationFormula': calculationFormula,
      'roundingMode': roundingMode,
    });
  }
}
