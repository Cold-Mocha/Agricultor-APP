final class ProductionFormInput {
  const ProductionFormInput({
    required this.sectorId,
    required this.quantity,
    required this.unit,
    required this.qualityNotes,
    this.destination,
    this.workShift,
    this.observations,
  });
  final String sectorId, quantity, unit, qualityNotes;
  final String? destination;
  final String? workShift;
  final String? observations;
}

final class HarvestContextSummary {
  const HarvestContextSummary({
    required this.seasonName,
    required this.cropName,
  });
  final String seasonName, cropName;
}

enum ProductionSaveStatus { saved, missingContext }
