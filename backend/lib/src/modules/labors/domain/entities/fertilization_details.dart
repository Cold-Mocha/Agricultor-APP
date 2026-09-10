import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';

final class FertilizationDetails {
  const FertilizationDetails({
    required this.product,
    required this.amount,
    required this.unit,
    required this.applicationMethod,
    this.observations,
    this.irrigationLaborId,
  });

  final String product;
  final double amount;
  final String unit;
  final String applicationMethod;
  final String? observations;
  final String? irrigationLaborId;

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
      if (observations?.trim().isNotEmpty ?? false)
        'observations': observations!.trim(),
      if (irrigationLaborId?.trim().isNotEmpty ?? false)
        'irrigationLaborId': irrigationLaborId!.trim(),
    });
  }
}

enum FertilizationMethod {
  manual('manual'),
  foliar('foliar'),
  fertigation('fertigation');

  const FertilizationMethod(this.code);
  final String code;
}
