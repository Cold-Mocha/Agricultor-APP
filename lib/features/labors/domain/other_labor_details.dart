import 'package:agrocampo/features/labors/domain/labor_details.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';

final class OtherLaborDetails {
  const OtherLaborDetails({required this.name, required this.description});

  final String name;
  final String description;

  LaborDetails toEnvelope() {
    if (name.trim().isEmpty || description.trim().isEmpty) {
      throw ArgumentError('other_labor_details_invalid');
    }
    return LaborDetails.current(LaborType.other, {
      'name': name.trim(),
      'description': description.trim(),
    });
  }
}
