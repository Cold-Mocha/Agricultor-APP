import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';

final class HarvestDetails {
  const HarvestDetails({
    required this.quantity,
    required this.unit,
    this.qualityNotes,
    this.destination,
    this.workShift,
    this.observations,
  });

  final double quantity;
  final String unit;
  final String? qualityNotes;
  final String? destination;
  final String? workShift;
  final String? observations;

  LaborDetails toEnvelope() {
    if (quantity <= 0 || unit.trim().isEmpty) {
      throw ArgumentError('harvest_details_invalid');
    }
    return LaborDetails.current(LaborType.harvest, {
      'quantity': quantity,
      'unit': unit.trim(),
      'qualityNotes': qualityNotes?.trim(),
      if (destination?.trim().isNotEmpty ?? false)
        'destination': destination!.trim(),
      if (workShift?.trim().isNotEmpty ?? false) 'workShift': workShift!.trim(),
      if (observations?.trim().isNotEmpty ?? false)
        'observations': observations!.trim(),
    });
  }
}
