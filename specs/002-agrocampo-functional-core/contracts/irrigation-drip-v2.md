# Contract: Deterministic Drip Irrigation v2

**Scope**: configuration, recommendation and historical registration for drip irrigation only.  
**Base**: extends Módulo 001 `contracts/irrigation-calculation.md`; it does not alter an approved formula or invent coefficients.

## 1. Release Gate

The architecture, configuration and unavailable-rule state may be implemented immediately. A crop recommendation is enabled only when its immutable rule includes source, reviewer, approval date, ranges/bounds and at least 20 approved reference vectors. Without that evidence, return `crop_rule_unavailable` and no usable recommendation.

## 2. Separation of Concerns

| Component | Responsibility |
|---|---|
| `SectorIrrigationConfig` | Persistent sector hardware/agronomic configuration and version. |
| `DripCalculationInput` | Config snapshot + crop/rule + event variables. |
| `IrrigationRecommendationEngine` | Pure deterministic calculation contract. |
| `DripCalculationResult` | Exact numeric result, explanation facts and warnings. |
| Irrigation labor aggregate | Performed event + immutable input/config/result snapshot. |

The engine has no dependency on Flutter, Drift, Supabase, Open-Meteo or AgroIA.

## 3. Permanent Configuration

Required for a recommendation:

- `sectorId`, `configId`, `configVersion`;
- `plantCount > 0`;
- `emitterCount > 0`;
- `flowMlMin > 0` as total effective sector flow;
- method exactly `drip`.

Optional, only used if an approved rule names it: emitters-per-plant distribution, pressure kPa and bounded configuration notes. Null is not silently converted to zero.

Changing a used configuration creates a new version/effective range. Historical estimates retain the old snapshot.

## 4. Variable Input

- crop assignment effective at calculation/event date;
- approved rule ID/version for that crop;
- optional/required soil code, humidity basis points and temperature milli-C according to rule;
- optional normalized fresh weather adjustment and timestamp;
- performed duration only when comparing/registering actual irrigation.

Weather absence sets adjustment zero plus `weather_unavailable` or `weather_stale_not_used`; it does not block a calculation whose required local inputs exist.

## 5. Deterministic Formula

Use the integer operations and rounding of Módulo 001:

```text
appliedVolumeMl = roundHalfUp(flowMlMin × performedDurationSeconds / 60)
baseVolumeMl = plantCount × baseMlPerPlant
rawAdjustmentBp = 10000 + approved simple adjustments
boundedAdjustmentBp = clamp(rawAdjustmentBp, approved min, approved max)
recommendedVolumeMl = roundHalfUp(baseVolumeMl × boundedAdjustmentBp / 10000)
recommendedDurationSeconds = ceil(recommendedVolumeMl × 60 / flowMlMin)
```

If approved future rule semantics replace this formula, they require a new `algorithmVersion`; old results are not recalculated.

## 6. Result

```text
valid:
  recommendedVolumeMl
  recommendedDurationSeconds
  algorithmVersion
  ruleId/ruleVersion
  configId/configVersion
  canonicalInputs
  adjustmentFacts
  explanationFacts
  warningCodes

invalid:
  fieldErrorCodes
  preservedInputs
```

The UI renders volume/time in metric units and a brief explanation from structured facts, for example configuration version, plants/emitters, total flow, crop rule and whether current weather was used. Generative text is not used.

## 7. Validation

No usable recommendation when:

- plants, emitters or flow are null/non-positive;
- method is not drip;
- sector/context/crop assignment is invalid;
- crop rule is absent/unapproved;
- a required rule input is absent;
- value is outside approved bounds;
- configuration/rule version cannot be reproduced.

Form errors identify fields and preserve other entries.

## 8. Persistence

Requesting a preview does not create a labor. Confirming performed irrigation writes in one local transaction:

1. labor root with parcel/sector/season/assignment/time;
2. irrigation record with performed duration/volume/method;
3. valid estimate and immutable configuration/input/result snapshot, if one was used;
4. one compound outbox operation.

The timeline displays one irrigation event decorated with recommendation/performed comparison.

## 9. Extension Boundary

The interface accepts an irrigation method discriminator. 002 registers recommendations only for `drip`. Existing basic records for sprinkler/furrow/gravity may remain for 001 compatibility; no placeholder engines, coefficients or advanced UI are implemented for them.

## 10. Tests and Acceptance

- At least 20 approved vectors reproduce all intermediate and final integers exactly.
- Same config/rule/input bytes produce identical result across repeated runs/restart.
- Boundary, rounding, missing/stale weather, unavailable rule and invalid input tests.
- Config v2 does not alter an event recorded under config v1.
- File-backed offline save/reopen and sync compound-aggregate test.
- AgroIA/Weather failure cannot change deterministic result beyond an explicitly provided approved weather adjustment.

Accepted when FR-049..FR-059 and SC-009 pass without an unapproved rule or generative calculation.
