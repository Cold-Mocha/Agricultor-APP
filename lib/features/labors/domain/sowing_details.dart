import 'package:agrocampo/features/labors/domain/labor_details.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';

final class SowingDetails {
  const SowingDetails({
    required this.seedQuantity,
    required this.unit,
    this.spacingCentimeters,
  });

  final double seedQuantity;
  final String unit;
  final double? spacingCentimeters;

  LaborDetails toEnvelope() {
    if (seedQuantity <= 0 ||
        unit.trim().isEmpty ||
        (spacingCentimeters != null && spacingCentimeters! <= 0)) {
      throw ArgumentError('sowing_details_invalid');
    }
    return LaborDetails.current(LaborType.sowing, {
      'seedQuantity': seedQuantity,
      'unit': unit.trim(),
      'spacingCentimeters': spacingCentimeters,
    });
  }
}
