# Contract: AgroCampo Synchronization Protocol v2

**Local authority**: Drift  
**Remote backup**: Supabase PostgreSQL behind RLS and transactional RPC  
**Compatibility**: replaces defective runtime semantics of v1 through an additive migration; does not edit migrations 0001-0011.

## 1. Non-negotiable Invariants

1. No operation is `done/synced` before a real `applied` or matching `duplicate` response.
2. An unsupported aggregate/action or invalid payload is never acknowledged.
3. Operation ID and canonical request hash are stable across retries/restarts.
4. Pull change and cursor commit in one Drift transaction.
5. Unknown/undecodable pull change rolls back the page; it is never skipped while cursor advances.
6. Local candidate remains visible during error/conflict.
7. Owner comes from authenticated session; payload cannot retarget data.
8. Sync never blocks a valid local save/navigation.

## 2. Enabled Aggregate Registry

The client and server maintain a versioned allowlist. Each entry supplies:

- aggregate type and payload schema versions;
- allowed actions;
- client encode/apply-pull/apply-tombstone functions;
- server validate/apply/delete/version functions;
- conflict snapshot function;
- required parent dependencies.

Activation order: `parcel`; `sector`, `agriculturalSeason`, `sectorCropAssignment`, `customCrop`; `labor`, `irrigationConfig`; `reminder`. An aggregate enters the list only after contract and pgTAP tests pass.

This is a small explicit registry, not a generic sync framework.

## 3. Push Request

```json
{
  "protocolVersion": "agrocampo-sync-v2",
  "deviceId": "uuid",
  "operations": [
    {
      "operationId": "uuid",
      "aggregateType": "sector",
      "aggregateId": "uuid",
      "action": "create",
      "baseVersion": null,
      "payloadSchemaVersion": 1,
      "payload": {},
      "dependsOnOperationId": "uuid-or-null",
      "requestHash": "canonical-hash"
    }
  ]
}
```

- Batch contains 1..25 operations for one authenticated owner/device.
- `payload` is a JSON object, not Dart `Map.toString()` or an opaque double-encoded string.
- Canonical hash covers protocol-relevant fields.

## 4. Push Response

Every submitted operation has exactly one result, or the client treats a missing/malformed result as retryable with no ACK.

```json
{
  "protocolVersion": "agrocampo-sync-v2",
  "results": [
    {
      "operationId": "uuid",
      "status": "applied|duplicate|conflict|rejected|retryableError",
      "serverVersion": 2,
      "changeSeq": 123,
      "conflictId": null,
      "remoteSnapshot": null,
      "errorCode": null,
      "retryAfterSeconds": null
    }
  ]
}
```

### Server behavior

1. Verify JWT/protocol/batch and derive owner.
2. For each causally ready operation, validate allowlist/action/schema/ownership.
3. Check receipt `(owner_id, operation_id)`.
4. Same ID+hash returns recorded `duplicate`; same ID+different hash returns `rejected:idempotency_mismatch`.
5. Compare base version where required.
6. Apply whole aggregate and append exactly one `sync_changes` entry in a transaction, or record conflict without applying candidate.
7. Record receipt/result.
8. Never create a success receipt before business rows and change log commit.

### Client behavior

| Status | Local transaction |
|---|---|
| `applied` | Set remote version/server time, operation done, domain synced if no newer local op. |
| `duplicate` | Same as applied only if receipt/hash matches. |
| `conflict` | Persist both snapshots, operation/domain conflict. |
| `rejected` | Operation blocked, preserve candidate and stable correction code. |
| `retryableError` | `retry_wait`, increment attempts, persist next attempt. |
| missing/malformed | No ACK; retry same ID/hash. |

## 5. Outbox State Machine

```text
pending ──eligible──> sending ──applied/duplicate──> done
                         ├── transient ──> retry_wait ──due/manual──> pending
                         ├── validation/authz ──> blocked
                         └── version mismatch ──> conflict
stale sending after interruption ──> pending
```

- Transition to `sending` and attempt metadata is committed before request.
- Backoff is exponential with jitter, minimum 30 s, practical cap (for example 30 min) and server `retryAfter` respected. Exact constants may be tuned by evidence without changing contract.
- Auth 401 refreshes once; failed refresh pauses owner sync and requires sign-in.
- Connectivity state is a trigger hint, not proof.

## 6. Ordering and Dependencies

- Ready rows are ordered by dependency then `created_at`/operation ID.
- Child waits for parent ACK when remote FK may not exist.
- Rejected parent blocks descendants with `dependency_blocked`.
- Create followed by delete before any ACK may cancel root and descendants in one local transaction.
- Only one coordinator per owner runs; repeated triggers coalesce.

Triggers: successful local save, authenticated bootstrap/unlock, app resume, connectivity hint, manual retry and eligible WorkManager execution.

## 7. Pull

Request: protocol version, last durable `changeSeq`, bounded page size. Response changes strictly ascend and contain aggregate/action/version/structured payload or tombstone.

For one page, one Drift transaction:

1. Validate protocol and monotonic sequence.
2. Resolve enabled codec for every change.
3. Inspect pending local operation/conflict.
4. Apply canonical row/tombstone if safe; otherwise create/update conflict and preserve candidate.
5. Update versions/sync state without deleting newer local candidates.
6. Advance cursor to last applied sequence.
7. Commit all or none.

## 8. Conflicts

- `keepRemote`: apply remote snapshot through aggregate codec, close conflicting op, persist resolution; send receipt only if protocol requires.
- `keepLocal`: create a new `resolveConflict` operation using retained local candidate and latest remote version.
- A second remote version returns a new/refreshed conflict; no automatic field merge.
- UI shows both values/differences and keeps other local flows available.

## 9. Tombstones

- Remote delete/archive emits change with version and `deletedAt/archivedAt`.
- Pull tombstone cannot resurrect older local/remote payload.
- A local edit based on pre-tombstone version becomes explicit conflict/rejection.
- Historical roots use archive/void where destructive delete would break traceability.

## 10. Scheduling/Logout

- Background sync is opportunistic; foreground resume repairs remaining work.
- Logout stops current coordinator at a safe boundary, cancels future owner schedule, removes auth material and closes access. Pending outbox remains on disk.
- Login by same owner resumes after session validation; different owner opens an isolated scope.

## 11. Mandatory Tests

- Server applies each enabled entity and returns ACK only afterward.
- Unsupported aggregate and invalid payload return rejected and no success receipt.
- Same ID+same hash after lost ACK returns duplicate; different hash rejects.
- Partial/malformed result ACKs none of omitted operations.
- 100 operations with parent/child ordering and three restarts.
- Transient retry/backoff/manual retry and stale sending recovery.
- Pull decode/storage failure rolls back changes+cursor.
- Conflict from two devices, keep local/remote and second remote change.
- Delete/tombstone cannot resurrect.
- RLS anonymous, owner A, owner B, RPC and direct table access.

## Acceptance

Accepted when SC-007/008 and FR-066..FR-076 pass against file-backed Drift and local Supabase; fakes alone are insufficient.
