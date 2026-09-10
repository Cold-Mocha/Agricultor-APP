import 'package:agrocampo_backend/src/modules/irrigation/irrigation_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('draft fingerprint includes every confirmed input, including pressure', () {
    const draft = IrrigationDraft(
      sectorId: 'sector-1',
      method: IrrigationType.drip,
      duration: '30',
      flow: '120',
      pressure: '80',
    );
    const changed = IrrigationDraft(
      sectorId: 'sector-1',
      method: IrrigationType.drip,
      duration: '30',
      flow: '120',
      pressure: '90',
    );
    expect(draft.previewFingerprint, isNot(changed.previewFingerprint));
    expect(
      const AdvancedRecommendationApplicability().unavailableCode,
      'crop_rule_unavailable',
    );
  });

  test('typed basic outcomes preserve submitted draft and formula metadata', () {
    const draft = IrrigationDraft(
      sectorId: 'sector-1',
      method: IrrigationType.drip,
      duration: '30',
      flow: '120',
    );
    final outcome = BasicEstimateAvailable(
      volumeMl: 60000,
      submittedInputs: draft,
      canonicalInputs: const {'flow_ml_min': 2000, 'duration_seconds': 1800},
      formulaVersion: 1,
      roundingPolicy: 'roundHalfUp',
      previewFingerprint: draft.previewFingerprint,
    );
    expect(outcome.volumeMl, 60000);
    expect(outcome.submittedInputs, draft);
    expect(outcome.roundingPolicy, 'roundHalfUp');
  });
}
