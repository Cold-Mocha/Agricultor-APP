final class HarvestInput {
  const HarvestInput({
    required this.cropId,
    required this.quantity,
    required this.unit,
    required this.harvestedAt,
    this.qualityNotes,
    this.destination,
    this.workShift,
    this.observations,
  });

  final String cropId;
  final double quantity;
  final String unit;
  final DateTime harvestedAt;
  final String? qualityNotes;
  final String? destination;
  final String? workShift;
  final String? observations;

  void validate() {
    if (cropId.isEmpty || quantity <= 0 || unit.trim().isEmpty) {
      throw ArgumentError('invalid_harvest');
    }
  }
}
