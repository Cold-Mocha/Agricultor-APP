import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';

final class IrrigationLaborDetails {
  const IrrigationLaborDetails({
    required this.method,
    required this.durationMinutes,
    this.appliedVolumeLiters,
  });

  final String method;
  final int durationMinutes;
  final double? appliedVolumeLiters;

  LaborDetails toEnvelope() {
    if (method.trim().isEmpty || durationMinutes <= 0) {
      throw ArgumentError('irrigation_details_invalid');
    }
    if (appliedVolumeLiters != null && appliedVolumeLiters! <= 0) {
      throw ArgumentError('irrigation_volume_invalid');
    }
    return LaborDetails.current(LaborType.irrigation, {
      'method': method.trim(),
      'durationMinutes': durationMinutes,
      'appliedVolumeLiters': appliedVolumeLiters,
    });
  }
}
