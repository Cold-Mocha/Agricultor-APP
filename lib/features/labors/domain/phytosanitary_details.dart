import 'package:agrocampo/features/labors/domain/labor_details.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';

final class PhytosanitaryDetails {
  const PhytosanitaryDetails({
    required this.product,
    required this.target,
    required this.dose,
    required this.unit,
    this.safetyIntervalDays,
  });

  final String product;
  final String target;
  final double dose;
  final String unit;
  final int? safetyIntervalDays;

  LaborDetails toEnvelope() {
    if (product.trim().isEmpty ||
        target.trim().isEmpty ||
        dose <= 0 ||
        unit.trim().isEmpty ||
        (safetyIntervalDays != null && safetyIntervalDays! < 0)) {
      throw ArgumentError('phytosanitary_details_invalid');
    }
    return LaborDetails.current(LaborType.diseaseAndPestControl, {
      'product': product.trim(),
      'target': target.trim(),
      'dose': dose,
      'unit': unit.trim(),
      'safetyIntervalDays': safetyIntervalDays,
    });
  }
}
