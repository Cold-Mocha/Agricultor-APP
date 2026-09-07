final class ProductionFormInput {
  const ProductionFormInput({
    required this.sectorId,
    required this.quantity,
    required this.unit,
    required this.qualityNotes,
  });
  final String sectorId, quantity, unit, qualityNotes;
}

final class HarvestContextUiState {
  const HarvestContextUiState({
    required this.seasonName,
    required this.cropName,
  });
  final String seasonName, cropName;
}

enum ProductionSaveStatus { saved, missingContext }
