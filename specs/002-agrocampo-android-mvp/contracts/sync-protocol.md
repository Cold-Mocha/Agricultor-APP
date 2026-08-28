# Contract: Offline Synchronization Protocol

**Protocol version**: `agrocampo-sync-v1`  
**Local authority**: Drift  
**Remote authority**: Supabase PostgreSQL behind RLS and transactional RPC

## 1. Invariants

1. Every permitted mutation is durable in Drift before user-facing success.
2. Domain row and outbox operation commit or roll back together.
3. UI reads only repositories backed by Drift; it never swaps to a remote data source.
4. An `operationId` is stable through all retries and process restarts.
5. Only `applied` or `duplicate` acknowledge remote backup.
6. Conflict never overwrites the local candidate or remote canonical row silently.
7. Pull cursor advances only with the page it represents.
8. Network reachability is established by the operation result, not connectivity type.
9. Timestamps never resolve conflicts.
10. Synchronization never blocks navigation or another local save.

## 2. Observable synchronization state

The sync coordinator publishes:

| Field | Meaning |
|---|---|
| `connectionState` | unknown, offline, reachable or degraded |
| `cycleState` | idle, authenticating, pushing, pulling, completed or error |
| `pendingCount` | queued/retryable operations |
| `errorCount` | blocked/non-retryable operations |
| `conflictCount` | unresolved conflicts |
| `current`, `total` | bounded progress of current cycle |
| `lastSuccessfulSyncAt` | server-confirmed completed cycle |
| `lastErrorCode` | stable recovery code, no provider secret/text |

Each domain record publishes `pending`, `syncing`, `synced`, `error` or `conflict`. Presentation of all fields MUST **Implementar según master.md** and must distinguish local save from remote backup.

## 3. Outbox operation

| Field | Required | Rule |
|---|---:|---|
| `protocolVersion` | yes | Must equal supported server version. |
| `operationId` | yes | UUID PK/idempotency key. |
| `deviceId` | yes | Stable app installation ID. |
| `ownerId` | yes | Must equal authenticated user. |
| `aggregateType` | yes | Allowlisted type only. |
| `aggregateId` | yes | UUID generated locally. |
| `action` | yes | create, update, archive, delete or resolveConflict. |
| `baseVersion` | conditional | Null only for a never-backed-up create. |
| `payload` | conditional | Versioned aggregate snapshot; absent for pure tombstone when allowed. |
| `dependsOnOperationId` | no | Causal predecessor, same owner/device. |
| `attemptCount` | local | Increments per network attempt. |
| `nextAttemptAt` | local | Exponential backoff with jitter. |
| `lastErrorCode` | local | Stable classification. |
| `createdAt` | yes | Local ordering only, not conflict authority. |

Aggregate payload includes root and specialization together. Examples: soil = labor + soil measurement; irrigation = labor + irrigation record + estimate; harvest = labor + production; apiary = labor + inspection.

## 4. Scheduling and triggers

A sync cycle may start after:

- app bootstrap with recovered session;
- app resume;
- successful local save;
- connectivity-change hint;
- manual retry;
- remote FCM/Realtime hint;
- eligible WorkManager execution.

Only one cycle per owner runs at a time. Repeated triggers coalesce. Background execution is opportunistic; foreground/resume always reconciles remaining work.

## 5. Cycle order

1. Acquire local owner-scoped mutex.
2. Recover `sending` rows as `pending` after prior interruption.
3. Refresh/validate Supabase session.
4. Build a causally ready push batch, maximum 25 operations for v1.
5. Push batches until no ready operation or a blocking auth/network condition.
6. Pull ordered pages until `hasMore=false`.
7. Re-check outbox once, because pull/conflict resolution may have changed readiness.
8. Publish summary and release mutex.

The batch size is a protocol parameter, not a visual value. It can be tuned compatibly after measurements.

## 6. Push contract

### Request

| Field | Rule |
|---|---|
| `protocolVersion` | Required. |
| `deviceId` | Required and owner-scoped. |
| `operations` | 1..25 ordered, all same authenticated owner. |

### Server processing per owner transaction

1. Verify JWT and `ownerId = auth.uid()`.
2. Acquire owner/advisory lock or equivalent serialization boundary.
3. Validate protocol, action, payload schema, ownership and dependencies.
4. Look up `(owner_id, operation_id)` receipt.
5. If receipt exists and request hash matches, return the recorded result.
6. If receipt ID exists with different hash, reject as idempotency misuse.
7. For create, require entity absent or matching prior idempotent create.
8. For update/archive/delete, compare `baseVersion` to canonical version.
9. If equal, validate and atomically apply the whole aggregate, increment version and append `sync_changes`.
10. If unequal, create `sync_conflicts` with candidate and canonical snapshots without changing canonical business data.
11. Record receipt and commit.

### Per-operation response

| Field | Values/rule |
|---|---|
| `operationId` | Echoed stable ID. |
| `status` | `applied`, `duplicate`, `conflict`, `rejected` or `retryableError`. |
| `serverVersion` | Present for applied/duplicate/conflict when entity exists. |
| `conflictId` | Present for conflict. |
| `remoteSnapshot` | Present for conflict, limited to authorized aggregate. |
| `validationErrors` | Stable field/code list for rejected. |
| `retryAfter` | Optional for rate limiting/transient failure. |

### Client handling

- `applied|duplicate`: update local remote version and mark operation done/record synced in one Drift transaction.
- `conflict`: persist both snapshots, mark operation/record conflict.
- `rejected`: mark blocked, retain local data and expose correction path.
- `retryableError`: keep queued with backoff.
- partial/malformed response: acknowledge none of the missing operations; retry them with the same IDs.

## 7. Pull contract

### Request

| Field | Rule |
|---|---|
| `protocolVersion` | Required. |
| `cursor` | Last committed `changeSeq`, zero for initial pull. |
| `limit` | Bounded page size accepted by server. |

### Response

| Field | Rule |
|---|---|
| `protocolVersion` | Compatible version. |
| `changes` | Strictly ascending by `changeSeq`. |
| `nextCursor` | Last change included, or input cursor for empty page. |
| `hasMore` | Whether another page is immediately available. |

Each change contains sequence, aggregate type/ID, action, server version, payload or tombstone and server timestamp.

### Application

For each page, within one Drift transaction:

1. ensure sequences are ordered and greater than cursor;
2. for each aggregate, inspect local outbox/conflict;
3. if no pending local change, apply canonical payload/tombstone;
4. if a local change edits an older base, create/update conflict and preserve local candidate;
5. if the change acknowledges the same operation already handled, keep the idempotent result;
6. advance cursor to `nextCursor` only after all rows succeed.

Any decode, validation or database failure rolls back the whole page and cursor.

## 8. Failure classification

| Condition | Client action |
|---|---|
| no network, timeout, 5xx, 429 | Retry with same ID; respect server delay and backoff. |
| ACK lost after commit | Retry same operation; server returns duplicate receipt. |
| 401/session expired | Refresh once; pause push and request sign-in if refresh fails. |
| 403/owner mismatch | Block operation; never retarget to another owner. |
| validation/schema error | Block until corrected or app upgraded; no infinite retry. |
| unsupported protocol | Stop sync, preserve local data and require compatible app. |
| local storage full/corrupt | Stop writes/sync, report recovery; never claim local save. |

Manual retry resets the wait for retryable errors only; it does not bypass validation or authorization.

## 9. Conflict contract

An open conflict records:

- conflict and operation IDs;
- aggregate identity/type;
- base version;
- complete local candidate;
- canonical remote snapshot/version;
- creation time and validation metadata.

The local domain row remains visible with `sync_state=conflict`; it is not replaced during pull.

Resolution options in v1:

- **Keep remote**: apply canonical snapshot locally, close conflicting local operation, then send a resolution receipt if required.
- **Keep local**: create a new `resolveConflict` operation based on current remote version and the retained local candidate.

No automatic field merge is provided. If the remote version changes again before resolution, server returns a refreshed conflict; both prior snapshots remain audited. Visual comparison and actions MUST **Implementar según master.md**.

## 10. Deletes, archive and dependencies

- Delete creates `deleted_at` plus tombstone change; it does not physically remove the row.
- Parcel with history uses archive. Restore is a versioned update.
- Remote FKs use restrict for history; no destructive cascade.
- Entity created and deleted before first backup cancels its create and dependent operations; no remote tombstone is sent.
- Parent operation must be acknowledged before a dependent child when server FK does not yet exist.
- A rejected parent blocks its causal descendants with an explicit dependency error.

## 11. Photo subprotocol

1. Domain association and stable local file commit first.
2. Outbox marks photo metadata/upload required.
3. Upload to private immutable path derived from owner/photo/hash with `upsert=false`.
4. “Already exists” is success only when identity/hash/metadata match.
5. Confirm photo metadata through the normal versioned RPC.
6. Keep local path for offline visibility.
7. If deleted before upload, cancel upload/metadata operations and remove local file recoverably.
8. If tombstoned after upload, sync tombstone; physical object purge is outside MVP.

## 12. Session and owner isolation

- Password is never stored.
- Session material is backed by Android Keystore.
- Database path and coordinator are owner-scoped.
- Logout closes database, cancels scheduled sync and removes tokens, while preserving pending local data.
- A different user cannot open, query, sync or deep-link into the prior owner's local space.
- A cached session allows local work but does not authorize remote push until refreshed/validated.

## 13. Required tests

- 24 hours offline with process/device restarts;
- 100 pending operations and causal parent/child order;
- ACK loss before/after server commit;
- interruption before/after every local commit and pull cursor update;
- duplicate operation ID with same and different payload;
- two devices update the same base version;
- keep-local and keep-remote, including a second remote change;
- late tombstone and archived parcel restoration;
- photo delete before/during upload and repeated upload;
- expired session, failed refresh, logout with pending data and another user;
- RLS for anonymous, owner A, owner B, direct DML, RPC and Storage;
- workload target of 20 parcels, 200 sectors and 10,000 records.

## 14. Acceptance

The protocol is accepted when AC-003, AC-007, SC-003, SC-004, SC-005 and SC-006 pass without silent loss, duplicate business rows or UI reading directly from remote state.
