# Contract: Productive Domain Compatibility v1

## Purpose

Provide one backend authority for deciding whether an operation is compatible with the stable
category persisted in a Sector. UI visibility is advisory and cannot replace this decision.

## Public Model

```text
ProductiveCategory = crop | apiary

ProductiveOperation =
  soilMeasure
  | irrigationRecord
  | dripBasicEstimate
  | irrigationAdvancedRecommendation
  | fertilizationRecord
  | phytosanitaryRecord
  | cultivationRecord
  | vegetableHarvest
  | otherVegetableLabor
  | apiaryInspection
  | apiaryFeeding
  | apiaryHealth
  | apiaryHarvest
  | apiarySuperPlacement
  | otherApiaryOperation
  | photoAttach

CompatibilityDecision =
  allowed(context)
  | rejected(code, message, context?, fieldErrors[])
```

The public and storage codes are `crop|apiary`; presentation maps them to “Vegetal” and “Apícola”.
Unknown values are readable as unsupported legacy data but reject every mutation. 003 never infers
or changes their category.

## Matrix

| Operation family | crop | apiary |
|---|---:|---:|
| Soil | allow | reject `operation_not_valid_for_apiary` |
| Manual irrigation | allow | reject `operation_not_valid_for_apiary` |
| Basic drip estimate | allow with valid flow/duration | reject `operation_not_valid_for_apiary` |
| Advanced irrigation recommendation | allow only with a defined versioned formula | reject `operation_not_valid_for_apiary` |
| Fertilization | allow | reject `operation_not_valid_for_apiary` |
| Agricultural phytosanitary | allow | reject `operation_not_valid_for_apiary` |
| Cultivation/vegetable harvest/other vegetable | allow | reject `operation_not_valid_for_apiary` |
| Apiary tasks | reject `operation_requires_apiary` | allow |
| Photo attachment | allow only for owned compatible target | allow only for owned compatible target |

## Required Backend Flow

1. Resolve authenticated/unlocked `ownerId`.
2. Load the owned Sector and its persisted `kind`; reject unknown or mismatched category.
3. Resolve required season/crop assignment only for the requested vegetable operation.
4. Evaluate the matrix.
5. Validate operation-specific fields.
6. Store the category snapshot with the event and commit root, specialization and outbox atomically.

Every facade, repository entry point that remains callable, pull codec and remote handler executes
this flow or a tested equivalent. Validation occurs again inside the write transaction when stale
context could change the answer.

## Category Stability

- Creation requires an explicit `crop|apiary` value; no default is accepted.
- Updates, pull and remote handlers reject any attempt to change the confirmed `kind`.
- Crop assignments and rotations never modify `kind`.
- Converting a Sector between domains requires a future specification and migration; it is not an
  operation in 003.

## Remote Parity

Supabase provides one `operation_allowed(category, operation)` function used by sync handlers or
triggers. A shared fixture enumerates every matrix pair and tests identical allow/reject codes in
Dart and PostgreSQL. RLS remains ownership protection, not domain validation; a separate invariant
prevents updates to `sectors.kind`.

## Acceptance

- All normal UI, direct facade and pull/sync attempts for incompatible operations are rejected.
- A rejection creates no root, specialization, outbox or remote change.
- The returned message identifies the Sector/category and compatible next action.
- Adding a category or operation requires changing this contract and both parity suites.
