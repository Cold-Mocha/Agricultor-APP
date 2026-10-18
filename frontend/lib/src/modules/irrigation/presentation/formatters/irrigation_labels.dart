import 'package:agrocampo_backend/agrocampo_backend.dart';

extension IrrigationTypeLabel on IrrigationType {
  String get label => switch (this) {
    IrrigationType.drip => 'Goteo',
    IrrigationType.sprinkler => 'Aspersión',
    IrrigationType.furrow => 'Surco',
    IrrigationType.gravity => 'Gravedad',
  };
}

extension SoilTypeLabel on SoilType {
  String get label => switch (this) {
    SoilType.sandy => 'Arenoso',
    SoilType.loamy => 'Franco',
    SoilType.clay => 'Arcilloso',
    SoilType.unknown => 'No lo sé',
  };
}
