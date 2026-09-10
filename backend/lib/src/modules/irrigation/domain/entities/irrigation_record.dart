enum IrrigationType { drip, sprinkler, furrow, gravity }

enum SoilType { sandy, loamy, clay, unknown }

final class BasicIrrigationInput {
  const BasicIrrigationInput({
    required this.type,
    required this.soilType,
    required this.durationMinutes,
    this.flowLitersPerHour,
    this.pressureKpa,
  });

  final IrrigationType type;
  final SoilType soilType;
  final int durationMinutes;
  final double? flowLitersPerHour;
  final int? pressureKpa;

  /// Basic deterministic drip estimate in litres: total flow × duration.
  double? get estimatedVolumeLiters => flowLitersPerHour == null
      ? null
      : flowLitersPerHour! * durationMinutes / 60;

  void validate() {
    if (durationMinutes <= 0) {
      throw ArgumentError('duration_must_be_positive');
    }
    if (flowLitersPerHour != null && flowLitersPerHour! <= 0) {
      throw ArgumentError('flow_must_be_positive');
    }
    if (pressureKpa != null && pressureKpa! <= 0) {
      throw ArgumentError('pressure_must_be_positive');
    }
  }

  Map<String, Object?> toJson() => {
    'type': type.name,
    'soil_type': soilType.name,
    'duration_minutes': durationMinutes,
    'flow_liters_per_hour': flowLitersPerHour,
    'pressure_kpa': pressureKpa,
    'estimated_liters': estimatedVolumeLiters,
  };
}
