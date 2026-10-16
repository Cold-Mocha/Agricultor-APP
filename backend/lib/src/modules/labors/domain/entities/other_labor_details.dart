import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';

final class OtherLaborDetails {
  const OtherLaborDetails({
    required this.name,
    required this.description,
    this.observations,
  });

  final String name;
  final String description;
  final String? observations;

  LaborDetails toEnvelope() {
    if (name.trim().isEmpty || description.trim().isEmpty) {
      throw ArgumentError('other_labor_details_invalid');
    }
    return LaborDetails.current(LaborType.other, {
      'name': name.trim(),
      'description': description.trim(),
      if (observations?.trim().isNotEmpty ?? false)
        'observations': observations!.trim(),
    });
  }
}
