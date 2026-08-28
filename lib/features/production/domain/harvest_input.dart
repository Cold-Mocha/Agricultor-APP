final class HarvestInput {
  const HarvestInput({
    required this.cropId,
    required this.quantity,
    required this.unit,
    required this.harvestedAt,
    this.qualityNotes,
  });

  final String cropId;
  final double quantity;
  final String unit;
  final DateTime harvestedAt;
  final String? qualityNotes;

  void validate() {
    if (cropId.isEmpty || quantity <= 0 || unit.trim().isEmpty) {
      throw ArgumentError('invalid_harvest');
    }
  }
}
