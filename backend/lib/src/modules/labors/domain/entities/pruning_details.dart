import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';

final class PruningDetails {
  const PruningDetails({required this.method, this.plantCount});

  final String method;
  final int? plantCount;

  LaborDetails toEnvelope() {
    if (method.trim().isEmpty || (plantCount != null && plantCount! <= 0)) {
      throw ArgumentError('pruning_details_invalid');
    }
    return LaborDetails.current(LaborType.pruning, {
      'method': method.trim(),
      'plantCount': plantCount,
    });
  }
}
