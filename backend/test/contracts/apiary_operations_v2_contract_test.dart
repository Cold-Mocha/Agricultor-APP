import 'package:agrocampo_backend/src/modules/apiary/domain/entities/apiary_inspection_input.dart';
import 'package:agrocampo_backend/src/modules/apiary/domain/entities/apiary_operation_details.dart';
import 'package:agrocampo_backend/src/modules/media/domain/entities/photo_attachment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public apiary contract discriminates task and keeps descriptive beekeeper', () {
    final details = ApiaryOperationDetails.fromInput(
      ApiaryInspectionInput(
        taskType: ApiaryTaskType.inspection,
        beekeeperName: 'Ana',
        hiveCount: 3,
        queenStatus: 'visible',
        broodStatus: 'uniform',
        feedingStatus: 'sufficient',
        healthNotes: '',
        pestNotes: '',
        superInstalled: false,
        inspectedAt: DateTime.utc(2026),
      ),
    ).toJson();
    expect(details['taskType'], 'inspection');
    expect(details['beekeeperName'], 'Ana');
    expect(details['hiveCount'], 3);
    const target = PhotoAttachmentInput(
      ownerId: 'owner-1',
      aggregateType: 'labor',
      aggregateId: 'labor-1',
      sourcePath: 'capture.jpg',
      mimeType: 'image/jpeg',
    );
    expect(target.aggregateType, 'labor');
  });
}
