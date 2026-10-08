import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';

final class CultivationDetails {
  const CultivationDetails({
    required this.performedWork,
    required this.observedState,
    this.variety,
    this.affectedPlants,
    this.observations,
  });

  final String performedWork;
  final String observedState;
  final String? variety;
  final int? affectedPlants;
  final String? observations;

  LaborDetails toEnvelope() {
    if (performedWork.trim().isEmpty || observedState.trim().isEmpty) {
      throw ArgumentError('cultivation_details_invalid');
    }
    if (affectedPlants != null && affectedPlants! <= 0) {
      throw ArgumentError('cultivation_affected_plants_invalid');
    }
    return LaborDetails.current(LaborType.cultivation, {
      'performedWork': performedWork.trim(),
      'observedState': observedState.trim(),
      if (variety?.trim().isNotEmpty ?? false) 'variety': variety!.trim(),
      if (affectedPlants != null) 'affectedPlants': affectedPlants,
      if (observations?.trim().isNotEmpty ?? false)
        'observations': observations!.trim(),
    });
  }
}
