final class SoilMeasurementInput {
  const SoilMeasurementInput({
    this.moisturePercent,
    this.ph,
    this.temperatureCelsius,
    this.conductivity,
    this.nitrogen,
    this.phosphorus,
    this.potassium,
  });

  final double? moisturePercent;
  final double? ph;
  final double? temperatureCelsius;
  final double? conductivity;
  final double? nitrogen;
  final double? phosphorus;
  final double? potassium;

  void validate() {
    if ([
      moisturePercent,
      ph,
      temperatureCelsius,
      conductivity,
      nitrogen,
      phosphorus,
      potassium,
    ].every((value) => value == null)) {
      throw ArgumentError('soil_requires_one_measurement');
    }
    if (moisturePercent case final value? when value < 0 || value > 100) {
      throw ArgumentError('moisture_out_of_range');
    }
    if (ph case final value? when value < 0 || value > 14) {
      throw ArgumentError('ph_out_of_range');
    }
    for (final value in [conductivity, nitrogen, phosphorus, potassium]) {
      if (value != null && value < 0) {
        throw ArgumentError('soil_value_negative');
      }
    }
  }
}
