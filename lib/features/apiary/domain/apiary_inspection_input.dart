enum ApiaryTaskType {
  inspection,
  feeding,
  health,
  harvest,
  superPlacement,
  other,
}

final class ApiaryInspectionInput {
  const ApiaryInspectionInput({
    required this.taskType,
    required this.beekeeperName,
    required this.hiveCount,
    required this.queenStatus,
    required this.broodStatus,
    required this.feedingStatus,
    required this.healthNotes,
    required this.pestNotes,
    required this.superInstalled,
    required this.inspectedAt,
    this.observations,
  });

  final ApiaryTaskType taskType;
  final String beekeeperName;
  final int hiveCount;
  final String queenStatus;
  final String broodStatus;
  final String feedingStatus;
  final String healthNotes;
  final String pestNotes;
  final bool superInstalled;
  final DateTime inspectedAt;
  final String? observations;

  void validate() {
    if (beekeeperName.trim().isEmpty ||
        hiveCount <= 0 ||
        queenStatus.trim().isEmpty ||
        broodStatus.trim().isEmpty) {
      throw ArgumentError('invalid_apiary_inspection');
    }
  }
}
