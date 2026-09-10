# Contract: Synchronization Protocol v2 — Módulo 003 Delta

**Base**: Módulo 002 `sync-protocol-v2.md`. Protocol name, RPCs, state machine, ACK semantics,
idempotency, pull cursor, conflict handling and tombstones remain unchanged.

## Enabled Aggregate Delta

No code aggregate `003` is introduced.

| Aggregate | Payload schema | 003 delta |
|---|---:|---|
| `sector` | existing schema | require explicit `kind` on create and reject changes after creation |
| `sectorCropAssignment` | v2 | validate category=`crop` |
| `labor` | v2 | include domain snapshot and optional soil/irrigation/production/apiary specialization |
| `irrigationConfig` | v1 compatible | require Sector category=`crop` |
| all other enabled v2 aggregates | unchanged | regression only |

Existing v1 payloads remain decodable. A codec retains unknown future fields and rejects unsupported
schema versions without advancing the cursor.

## Compound Labor Payload

```json
{
  "id": "uuid",
  "owner_id": "derived-not-trusted",
  "parcel_id": "uuid",
  "sector_id": "uuid",
  "domain_category": "crop|apiary|legacyUnknown",
  "agricultural_season_id": "uuid-or-null",
  "crop_assignment_id": "uuid-or-null",
  "type": "labor discriminator",
  "details": {},
  "details_schema_version": 2,
  "occurred_at": "UTC",
  "version": 1,
  "specialization": {
    "kind": "none|soil|irrigation|production|apiary",
    "payload": {}
  }
}
```

One server transaction validates and applies root+specialization, appends one `sync_changes` row
and then records one successful receipt. A specialization failure rejects the operation and writes
neither root nor receipt.

## Domain Validation

Before apply, the handler:

1. derives owner from JWT;
2. loads Sector/parcel and its stable `kind`;
3. validates `type` and specialization against `operation_allowed`;
4. validates season/assignment for `crop` operations and their absence/applicability for apiary;
5. compares payload category snapshot and base version; a Sector payload that changes `kind` fails.

RLS alone is not sufficient. A direct authenticated write that bypasses RPC must be protected by
constraints/triggers or denied by privileges/policies.

## Client Registry and Batching

- `createAgroCampoSyncRegistry()` registers the updated codecs before a repository can enqueue its
  payload.
- The coordinator never calls `sync_push` when filtering leaves zero supported operations.
- Unsupported legacy rows stay blocked/visible; they are never silently skipped as done.
- Parent dependencies remain Sector → assignment when applicable → labor.

## Legacy Apiary Migration

An `apiary_inspection` outbox row that has never received a success receipt is rewritten
idempotently to compound `labor` v2 using the complete local row and stable aggregate identity.
Request hash is recalculated before its first supported send. Rows with any remote receipt are not
rewritten and require an explicit reconciliation path.

## Pull

Root and specialization apply in the same Drift transaction as cursor movement. Category mismatch,
missing parent, unknown schema or specialization failure rolls back the whole page. A local pending
candidate becomes a conflict; it is not overwritten.

## Status

Public state distinguishes the confirmed local save from
`BackupState(pending|syncing|backedUp|error|conflict)`. Only `applied` or matching `duplicate` can
produce `backedUp`.

## Required Tests

- Dart/PostgreSQL compatibility-matrix parity.
- Sector creation with explicit category and rejection of category mutation by update/pull.
- Every compound specialization push/pull and rollback.
- Same ID/hash duplicate; same ID/different hash rejected.
- Empty filtered batch performs no RPC.
- Representative operation/specialization matrix with restarts at each critical state, lost ACK,
  parent ordering and no duplicates.
- Two-device conflict preserves both versions until farmer choice.
- RLS owner A/owner B/anonymous and direct table bypass attempts.
