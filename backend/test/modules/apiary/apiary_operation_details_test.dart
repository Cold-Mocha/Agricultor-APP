import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_test/flutter_test.dart';

ApiaryInspectionInput input(ApiaryTaskType task, {String observations = ''}) =>
    ApiaryInspectionInput(
      taskType: task,
      beekeeperName: 'Ana',
      hiveCount: 4,
      queenStatus: task == ApiaryTaskType.inspection ? 'Visible' : '',
      broodStatus: task == ApiaryTaskType.inspection ? 'Uniforme' : '',
      feedingStatus: task == ApiaryTaskType.feeding ? 'Suficiente' : '',
      healthNotes: task == ApiaryTaskType.health ? 'Sin novedades' : '',
      pestNotes: '',
      superInstalled: task == ApiaryTaskType.superPlacement,
      inspectedAt: DateTime.utc(2026),
      observations: observations,
    );

void main() {
  test('each apiary task retains its discriminator and own fields', () {
    for (final task in ApiaryTaskType.values) {
      final details = ApiaryOperationDetails.fromInput(input(task, observations: 'nota'));
      final json = details.toJson();
      expect(json['taskType'], task.name);
      expect(json['hiveCount'], 4);
      expect(json['observations'], 'nota');
    }
  });

  test('inspection, feeding and health validate their task-specific fields', () {
    expect(
      () => ApiaryOperationDetails.fromInput(
        input(ApiaryTaskType.inspection).copyWithForTest(queenStatus: ''),
      ).toJson(),
      throwsArgumentError,
    );
    expect(
      () => ApiaryOperationDetails.fromInput(
        input(ApiaryTaskType.feeding),
      ).toJson(),
      isNot(throwsArgumentError),
    );
  });
}

extension on ApiaryInspectionInput {
  ApiaryInspectionInput copyWithForTest({String? queenStatus}) =>
      ApiaryInspectionInput(
        taskType: taskType,
        beekeeperName: beekeeperName,
        hiveCount: hiveCount,
        queenStatus: queenStatus ?? this.queenStatus,
        broodStatus: broodStatus,
        feedingStatus: feedingStatus,
        healthNotes: healthNotes,
        pestNotes: pestNotes,
        superInstalled: superInstalled,
        inspectedAt: inspectedAt,
        observations: observations,
      );
}
