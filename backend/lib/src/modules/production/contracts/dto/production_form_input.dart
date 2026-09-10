final class ProductionFormInput {
  const ProductionFormInput({
    required this.sectorId,
    required this.quantity,
    required this.unit,
    required this.qualityNotes,
  });
  final String sectorId, quantity, unit, qualityNotes;
}

final class HarvestContextSummary {
  const HarvestContextSummary({
    required this.seasonName,
    required this.cropName,
  });
  final String seasonName, cropName;
}

enum ProductionSaveStatus { saved, missingContext }
