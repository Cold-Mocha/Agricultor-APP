# Contract: Local-First Repository Write v1

## Invariants

1. A valid command is durable in Drift before success is shown.
2. A synchronized aggregate mutation and its outbox operation commit or roll back together.
3. A compound aggregate —harvest+production or irrigation+record+estimate— is one transaction and one contractual operation.
4. UI success means `savedLocal`; it does not mean remote backup.
5. Storage failure leaves the last valid state and reports failure.
6. Ownership, parent relations, context/date and domain constraints are validated before commit.
7. Update/delete/archive payload includes the complete fields required by the remote handler; no second local update may occur outside the transaction.

## Command Envelope

| Field | Rule |
|---|---|
| `commandId` | Stable for one user confirmation; prevents double-submit locally. |
| `ownerId` | Unlocked session owner. |
| `aggregateType`, `aggregateId` | Allowlisted sync aggregate and stable local ID. |
| `action` | create, update, archive, delete or resolveConflict. |
| `baseVersion` | Remote version edited; null only for never-backed create. |
| `context` | Parcel/sector/season/assignment IDs required by aggregate. |
| `payloadSchemaVersion` | Positive supported version. |
| `payload` | Canonical structured JSON snapshot/tombstone contract. |
| `dependsOnOperationId` | Parent operation when remote FK may not yet exist. |

## Transaction Sequence

1. Resolve and validate bound context.
2. Validate domain input without discarding valid form values.
3. Start Drift transaction.
4. Read current row/version and detect stale local edit.
5. Insert/update root and specializations.
6. Insert exactly one outbox operation, or coalesce only under an explicitly tested safe rule.
7. Set local sync state pending.
8. Commit.
9. Publish `savedLocal/pending` from Drift stream.
10. Trigger/coalesce a sync attempt after commit; trigger failure does not roll back local data.

## Delete and Archive

- Never-synced create deleted with no dependents may cancel its create and be removed locally in one transaction.
- A backed row uses tombstone; history-bearing parcel/sector/custom crop is archived where required.
- Tombstone remains until every supported device can observe it under retention policy; physical purge is outside 002.

## Compound Aggregates

- `labor.harvest`: labor root + production specialization.
- `labor.irrigation`: labor root + irrigation record + optional valid estimate/config snapshot.
- Existing soil/apiary compound rules remain compatible with 001.
- History projects one event per root.

## Result

```text
savedLocal { aggregateId, operationId, syncState: pending }
validationFailure { fieldCodes }
storageFailure { stableCode }
staleLocalEdit { currentLocalVersion }
```

No result returns `synced` from a local repository save.

## Required Tests

- Inject failure after root, specialization and outbox insert; each rolls back all writes.
- Double tap same command ID creates one aggregate mutation.
- Archive/delete payload exactly matches local state.
- Restart exposes saved aggregate and pending outbox.
- Harvest and irrigation appear once in history.
- Parent dependency generated for an offline-created child.

## Acceptance

Accepted when every mutable 002 aggregate proves local commit+outbox atomicity, restart durability and truthful local/sync UI state.
