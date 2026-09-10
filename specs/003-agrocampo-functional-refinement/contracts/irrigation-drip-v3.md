# Contract: Irrigation Record, Basic Drip Estimate and Advanced Recommendation v3

**Extends**: Módulo 002 `irrigation-drip-v2.md`. It separates arithmetic already present in the
product from an agronomic recommendation.

## 003 Release State

- Manual irrigation registration remains fully available for inherited methods.
- A basic drip-volume estimate is available from confirmed flow and duration. It is a mathematical
  calculation, not an agronomic recommendation.
- No advanced agronomic formula is defined in the repository. Advanced recommendation therefore
  returns `recommendationUnavailable(cropRuleUnavailable)`.
- The basic estimate does not require a reviewer, signature, external approval or a fixed number of
  vectors. Its formula, units, boundary cases and rounding are verified automatically.

## Public Inputs

```text
IrrigationDraft {
  boundContext
  method                 drip|sprinkler|furrow|gravity
  occurredAt
  duration               value + unit
  flow?                  value + unit + scope(total|perEmitter|perPlant)
  emitterOrPlantCount?   required only when flow is not total
  pressure?              value + unit; retained but not used by the basic formula
  appliedVolume?         value + unit
}

BasicEstimateApplicability {
  method
  available
  requiredInputs[]       flow, duration and count only when flow scope requires it
  formulaVersion
  unavailableCode?
}

AdvancedRecommendationApplicability {
  available
  unavailableCode        cropRuleUnavailable in 003
}
```

The backend returns applicability before presentation chooses fields. Frontend must not hard-code
stage/texture catalogs, scientific ranges or advanced recommendation behavior.

## Basic Drip Estimate

Normalize the confirmed flow to `totalFlowMlPerMinute`, then calculate:

```text
volumeMl = roundHalfUp(totalFlowMlPerMinute × durationSeconds / 60)
```

If flow is per emitter or per plant, the total is derived from the explicitly confirmed count before
applying the formula. The outcome is:

```text
BasicEstimateOutcome =
  available {
    volume, units,
    submittedInputs,
    canonicalInputs,
    formulaVersion,
    roundingPolicy,
    explanationFacts,
    previewFingerprint
  }
  | unavailable { code, missingInputs[], preservedDraft }
  | invalid { fieldErrors[], preservedDraft }
```

Pressure is always retained when applicable but does not alter this formula. Same canonical inputs
and formula version produce exactly the same integer result. Gemini/AgroIA, weather, growth stage,
soil texture and crop coefficients are never used in the basic estimate.

## Advanced Recommendation

003 does not enable an advanced recommendation. A future increment may do so only with a
machine-readable formula that declares version, source, units, applicability, ranges, tolerances
and automated reference fixtures. Until then, stage, texture and weather are not requested for this
purpose and the result stays unavailable. This does not block a valid manual record or the basic
estimate.

## Draft Invalidation

Changing method, duration, flow, flow scope/count, pressure, volume, context or formula version
invalidates the prior preview fingerprint. A stale preview cannot be submitted. Cancel or confirmed
abandon leaves the last persisted configuration/record unchanged.

## Confirm Performed Irrigation

```text
RecordIrrigationCommand {
  commandId
  draft
  basicEstimateFingerprint?
  performedValues
}
```

A valid command writes labor root, irrigation row and one outbox operation. The immutable
`performedDetails` retains:

- submitted and normalized duration;
- submitted and normalized flow/caudal, its scope and count when supplied;
- pressure when applicable;
- applied or basic-estimated volume and how it was obtained;
- Sector/category/crop/season snapshot;
- configuration snapshot and basic formula version when used.

Entered, basic-estimated and any future recommended values remain distinguishable. Later edits to
configuration, flow, pressure or formula cannot recalculate history. The basic result is stored in
`irrigation_records.performed_details_json`; it does not require a synthetic row in
`irrigation_estimates` with a fake agronomic rule.

## Manual Methods

Drip, sprinkler, furrow and gravity records inherited from 001 may be saved manually when their
basic fields are valid. Methods other than drip return `basicEstimateUnavailable(methodNotDrip)`.
The UI must not disguise arithmetic as an agronomic recommendation.

## Error Codes

`operation_not_valid_for_apiary`, `method_not_drip`, `crop_rule_unavailable`,
`required_basic_input_missing`, `preview_stale` and field-specific validation codes.

## Acceptance

- Manual records round-trip caudal, duration, pressure, volume, units and context.
- No apiary command writes data.
- The representative automated matrix covers normal values, unit conversions, missing inputs,
  numeric boundaries and half-up rounding for the basic formula.
- Advanced recommendation remains unavailable without a complete formula contract; no fixture
  invents crop, stage, texture or weather coefficients.
- Cancel and restart preserve only confirmed state.
