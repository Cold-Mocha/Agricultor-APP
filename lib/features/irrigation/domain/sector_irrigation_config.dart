final class SectorIrrigationConfigInput {
  const SectorIrrigationConfigInput({
    required this.plantCount,
    required this.emitterCount,
    required this.flowMlMin,
    this.emittersPerPlantMilli,
    this.pressureKpa,
    this.distributionNotes,
  });

  final int plantCount;
  final int emitterCount;
  final int flowMlMin;
  final int? emittersPerPlantMilli;
  final int? pressureKpa;
  final String? distributionNotes;

  void validate() {
    if (plantCount <= 0 || emitterCount <= 0 || flowMlMin <= 0) {
      throw ArgumentError('drip_config_positive_values_required');
    }
    if (emittersPerPlantMilli != null && emittersPerPlantMilli! <= 0) {
      throw ArgumentError('emitters_per_plant_invalid');
    }
    if (pressureKpa != null && pressureKpa! <= 0) {
      throw ArgumentError('pressure_invalid');
    }
    if ((distributionNotes?.length ?? 0) > 500) {
      throw ArgumentError('distribution_notes_too_long');
    }
  }
}
