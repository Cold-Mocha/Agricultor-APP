enum IrrigationType { drip, sprinkler, furrow, gravity }

enum SoilType { sandy, loamy, clay, unknown }

final class BasicIrrigationInput {
  const BasicIrrigationInput({
    required this.type,
    required this.soilType,
    required this.durationMinutes,
    this.flowLitersPerHour,
  });

  final IrrigationType type;
  final SoilType soilType;
  final int durationMinutes;
  final double? flowLitersPerHour;

  void validate() {
    if (durationMinutes <= 0) {
      throw ArgumentError('duration_must_be_positive');
    }
    if (flowLitersPerHour != null && flowLitersPerHour! <= 0) {
      throw ArgumentError('flow_must_be_positive');
    }
  }
}
