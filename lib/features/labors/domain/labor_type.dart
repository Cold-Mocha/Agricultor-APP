enum LaborType {
  irrigation,
  soil,
  fertilization,
  diseaseAndPestControl,
  sowing,
  pruning,
  harvest,
  apiary,
  other,
}

extension LaborTypeLabel on LaborType {
  String get label => switch (this) {
    LaborType.irrigation => 'Riego',
    LaborType.soil => 'Suelo',
    LaborType.fertilization => 'Fertilización',
    LaborType.diseaseAndPestControl => 'Control de enfermedades y plagas',
    LaborType.sowing => 'Siembra',
    LaborType.pruning => 'Poda',
    LaborType.harvest => 'Cosecha',
    LaborType.apiary => 'Apicultura',
    LaborType.other => 'Otra labor',
  };
}
