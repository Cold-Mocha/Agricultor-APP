import 'apiary_inspection_input.dart';

/// Discriminated, task-specific payload for the apiary aggregate. It contains
/// no crop/soil/irrigation fields and keeps the beekeeper as descriptive text.
final class ApiaryOperationDetails {
  const ApiaryOperationDetails({
    required this.taskType,
    required this.beekeeperName,
    required this.hiveCount,
    required this.queenStatus,
    required this.broodStatus,
    required this.feedingStatus,
    required this.healthNotes,
    required this.pestNotes,
    required this.superInstalled,
    this.observations,
  });

  factory ApiaryOperationDetails.fromInput(ApiaryInspectionInput input) =>
      ApiaryOperationDetails(
        taskType: input.taskType,
        beekeeperName: input.beekeeperName,
        hiveCount: input.hiveCount,
        queenStatus: input.queenStatus,
        broodStatus: input.broodStatus,
        feedingStatus: input.feedingStatus,
        healthNotes: input.healthNotes,
        pestNotes: input.pestNotes,
        superInstalled: input.superInstalled,
        observations: input.observations,
      );

  final ApiaryTaskType taskType;
  final String beekeeperName;
  final int hiveCount;
  final String queenStatus;
  final String broodStatus;
  final String feedingStatus;
  final String healthNotes;
  final String pestNotes;
  final bool superInstalled;
  final String? observations;

  Map<String, Object?> toJson() {
    if (beekeeperName.trim().isEmpty || hiveCount <= 0) {
      throw ArgumentError('apiary_responsible_or_hives_invalid');
    }
    final needsInspectionFields = taskType == ApiaryTaskType.inspection;
    if (needsInspectionFields &&
        (queenStatus.trim().isEmpty || broodStatus.trim().isEmpty)) {
      throw ArgumentError('apiary_inspection_fields_required');
    }
    if (taskType == ApiaryTaskType.feeding && feedingStatus.trim().isEmpty) {
      throw ArgumentError('apiary_feeding_status_required');
    }
    if (taskType == ApiaryTaskType.health && healthNotes.trim().isEmpty) {
      throw ArgumentError('apiary_health_notes_required');
    }
    return {
      'taskType': taskType.name,
      'beekeeperName': beekeeperName.trim(),
      'hiveCount': hiveCount,
      if (queenStatus.trim().isNotEmpty) 'queenStatus': queenStatus.trim(),
      if (broodStatus.trim().isNotEmpty) 'broodStatus': broodStatus.trim(),
      if (feedingStatus.trim().isNotEmpty)
        'feedingStatus': feedingStatus.trim(),
      if (healthNotes.trim().isNotEmpty) 'healthNotes': healthNotes.trim(),
      if (pestNotes.trim().isNotEmpty) 'pestNotes': pestNotes.trim(),
      'superInstalled': superInstalled,
      if (observations?.trim().isNotEmpty ?? false)
        'observations': observations!.trim(),
    };
  }
}
