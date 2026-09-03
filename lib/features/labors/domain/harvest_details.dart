import 'package:agrocampo/features/labors/domain/labor_details.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:agrocampo/features/production/domain/harvest_input.dart';

final class HarvestDetails {
  const HarvestDetails({
    required this.quantity,
    required this.unit,
    this.qualityNotes,
  });

  factory HarvestDetails.fromInput(HarvestInput input) {
    input.validate();
    return HarvestDetails(
      quantity: input.quantity,
      unit: input.unit,
      qualityNotes: input.qualityNotes,
    );
  }

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
