# Contract: Specialized Apiary Operations v2

## Scope

Apiary data belongs to the apiary domain even when it shares a territorial Sector. It uses a labor
root for context/history/sync mechanics and `apiary_inspections` as its specialization; it is never
presented or validated as vegetable labor/production.

## Category Gate

Every command requires a bound context with `category=apiary`. A `crop` context returns
`operation_requires_apiary`. Irrigation, soil, vegetable fertilization and agricultural
phytosanitary commands against an apiary context return `operation_not_valid_for_apiary`.

## Discriminated Inputs

```text
ApiaryTask =
  inspection
  | feeding
  | health
  | harvest
  | superPlacement
  | other

ApiaryDetailsV2 {
  queenStatus?
  broodOrLayingStatus?
  healthNotes?
  feedingStatus?
  pestNotes?
  superState?
  taskDetail?
}

RecordApiaryOperation {
  commandId
  boundContext
  task
  occurredAt
  hiveCount
  responsibleName?
  details: ApiaryDetailsV2
  observations?
  pendingPhotoIds[]
}
```

`responsibleName` is descriptive text only. It does not create a user, worker, role or
organization.

## Task Rules

- **Inspection** preserves supplied queen, laying/brood, health, feeding, pest and super status.
- **Feeding**, **health** and **harvest** preserve the supplied fields from `ApiaryDetailsV2` that
  apply to the selected task and reject incompatible fields instead of inventing defaults.
- **Super placement** preserves installed/removed state and supplied observations.
- **Other** requires a descriptive name/detail.
- Hive count and date are retained for every task when supplied/required by its form.
- Missing optional fields remain null; irrelevant fields are not forced to false/empty.

The field catalog is limited to the named fields above and existing confirmed v1 fields;
this contract does not authorize chemical advice or new agronomic recommendations.

## Persistence

One transaction writes:

1. labor root with apiary category snapshot and no fabricated crop assignment;
2. apiary specialization linked by unique `laborId`;
3. one compound labor outbox operation.

Photos are imported privately first and linked to the confirmed labor target without exposing a
filesystem path publicly. A failed attachment does not corrupt the event and reports its own state.

## Legacy Rows

Existing `apiary_inspections.id` and fields are preserved. Migration creates a deterministic labor
root/link and marks unknown historical context as partial. Pending unsupported
`apiary_inspection` operations are converted to the complete compound payload before first send;
none is discarded or acknowledged locally.

## Public Detail

The detail projection returns task, date, hive count, responsible descriptive value, every supplied
task field, observations, photos, bound Sector/category, correction relation and sync state.
History uses one `labor:<id>` grouping key.

## Tests

A representative matrix covers each task type, null-vs-false, category rejection by facade/direct
pull, file-backed restart, photo link, compound rollback, legacy migration, sync retry/duplicate and
specialized history.
