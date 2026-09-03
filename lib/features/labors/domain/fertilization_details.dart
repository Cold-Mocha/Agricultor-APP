import 'package:agrocampo/features/labors/domain/labor_details.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';

final class FertilizationDetails {
  const FertilizationDetails({
    required this.product,
    required this.amount,
    required this.unit,
    required this.applicationMethod,
  });

  final String product;
  final double amount;
  final String unit;
  final String applicationMethod;

  LaborDetails toEnvelope() {
    if (product.trim().isEmpty ||
        amount <= 0 ||
        unit.trim().isEmpty ||
        applicationMethod.trim().isEmpty) {
      throw ArgumentError('fertilization_details_invalid');
    }
    return LaborDetails.current(LaborType.fertilization, {
      'product': product.trim(),
      'amount': amount,
      'unit': unit.trim(),
      'applicationMethod': applicationMethod.trim(),
    });
  }
}
