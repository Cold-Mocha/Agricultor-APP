import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';

final class HarvestDetails {
  const HarvestDetails({
    required this.quantity,
    required this.unit,
    this.qualityNotes,
  });

  final double quantity;
  final String unit;
  final String? qualityNotes;

  LaborDetails toEnvelope() {
    if (quantity <= 0 || unit.trim().isEmpty) {
      throw ArgumentError('harvest_details_invalid');
    }
    return LaborDetails.current(LaborType.harvest, {
      'quantity': quantity,
      'unit': unit.trim(),
      'qualityNotes': qualityNotes?.trim(),
    });
  }
}
