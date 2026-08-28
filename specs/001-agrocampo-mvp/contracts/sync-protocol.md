# Contract: Offline Sync Protocol v1

**Participants**: Flutter sync coordinator, Supabase RPC, PostgreSQL transaction layer.

**Authority**: `spec.md` FR-047 through FR-053 and `data-model.md`.

**Goal**: At-least-once transport with exactly-once observable mutation per operation ID, durable
pull and explicit conflict preservation.

## 1. Push operation

The client submits one aggregate operation at a time or a bounded ordered batch. A batch is not
considered atomic across aggregates; each operation returns its own receipt.

### Request fields

| Field | Type | Required | Contract |
|---|---|---:|---|
| `protocol_version` | integer | yes | Must equal 1 |
| `operation_id` | UUID | yes | Stable across retries |
| `device_id` | UUID | yes | Registered installation |
| `aggregate_type` | enum | yes | Whitelisted domain aggregate |
| `aggregate_id` | UUID | yes | Matches payload root ID |
| `action` | enum | yes | create, update, delete, resolve_conflict |
| `base_version` | integer | conditional | 0 for create; current remote version otherwise |
| `payload` | object | conditional | Full aggregate for create/update/resolve; tombstone data for delete |
| `conflict_id` | UUID | conditional | Required for resolve_conflict |
| `captured_at` | UTC timestamp | yes | Audit only; never establishes precedence |

Authentication derives `owner_id` from the validated JWT. A client-supplied owner may be checked
for equality but can never override the JWT.

### Acknowledged response

| Field | Meaning |
|---|---|
| `status = acknowledged` | Mutation committed exactly once |
| `operation_id` | Echoed idempotency key |
| `aggregate_id` | Affected aggregate |
| `remote_version` | New authoritative version |
| `change_seq` | Pull-feed sequence produced by this mutation |
| `server_updated_at` | Authoritative timestamp |

Retrying an acknowledged `operation_id` must return the same receipt without incrementing version
or producing another change event.

### Conflict response

| Field | Meaning |
|---|---|
| `status = conflict` | `base_version` did not match |
| `conflict_id` | Stable conflict reference |
| `local_candidate` | Payload proposed by the device |
| `remote_snapshot` | Current server aggregate |
| `remote_version` | Version required for resolution |
| `detected_at` | Server timestamp |

The server does not alter the canonical aggregate. The client commits the conflict record and marks
the local aggregate `conflict` before presenting either version.

### Rejected response

| Class | Examples | Client behavior |
|---|---|---|
| `authentication` | invalid/expired JWT | Pause push; refresh session when connected |
| `authorization` | owner mismatch | Permanent visible failure; never retry automatically |
| `validation` | invalid geometry/range/FK | Permanent visible failure with field-safe error |
| `rate_limit` | quota or 429 | Retry after supplied time with jitter |
| `temporary` | timeout/5xx/unavailable | Exponential backoff with jitter |
| `protocol` | unsupported version/type | Block operation and require app update/repair |

Responses and logs never contain secrets, SQL details or another owner's data.

## 2. Aggregate boundaries

The following payloads are atomic aggregates:

- parcel;
- sector;
- crop assignment change, including closure of prior assignment;
- generic labor;
- soil labor plus `soil_measurements`;
- irrigation labor plus `irrigation_records` and optional recommendation link;
- harvest labor plus `production_records`;
- apiary labor plus `apiary_inspections`;
- irrigation recommendation;
- photo metadata, after object upload confirmation;
- reminder;
- profile and device registration.

An aggregate is either fully applied or fully rejected. Parent operations precede children using
`depends_on_operation_id`; a missing dependency is retryable only while the parent remains pending.

## 3. Pull changes

### Request fields

| Field | Type | Contract |
|---|---|---|
| `protocol_version` | integer | 1 |
| `after_seq` | integer | Last sequence atomically applied locally; 0 for bootstrap |
| `limit` | integer | 1-200; default 100 |

### Response fields

| Field | Meaning |
|---|---|
| `events` | Ordered by ascending `change_seq` |
| `next_seq` | Highest event in this page, or unchanged cursor when empty |
| `has_more` | Another page is immediately available |
| `server_time` | Diagnostic/freshness only |

Each event contains sequence, aggregate type/ID, action, version, payload or tombstone and server
timestamp. The client applies the full page and advances its cursor in one Drift transaction. If
that transaction fails, the same page is safe to download and apply again.

## 4. Sync cycle and exclusivity

1. Acquire a persisted owner/device sync lease.
2. Restore expired `sending` operations to `pending`.
3. Verify connected authentication.
4. Push eligible operations in causal order and commit each response locally.
5. Pull pages until `has_more` is false.
6. Reconcile photo uploads, reminders and local notifications.
7. Mark global state `Sincronizado` only when the cycle succeeded and no pending, failed or open
   conflict remains.
8. Release lease in success or failure.

Foreground and WorkManager use the same lease and protocol. Connectivity callbacks are only
triggers; successful authenticated network operations establish actual connected state.

## 5. Conflict resolution

- **Keep remote**: replace local aggregate with the remote snapshot, mark original operation
  resolved, preserve the conflict audit and continue pull.
- **Keep local**: create a new `resolve_conflict` operation using the latest `remote_version`; do
  not mutate the server until that operation is acknowledged.
- Automatic per-field merge and last-write-wins are not part of protocol v1.
- A second conflict during keep-local returns another explicit conflict rather than discarding data.

## 6. Deletion

- Synced deletions are tombstones and create pull events.
- A parcel with history is archived, not deleted.
- A local entity that has never synced may be removed with its unprocessed outbox entry in one
  transaction.
- No remote tombstone or change event is physically purged during the MVP.

## 7. Acceptance probes

- Repeat an operation before and after a lost ACK: one remote version and one change event result.
- Terminate the app with an operation `sending`: restart returns it to pending and completes it.
- Apply 100 offline operations with dependencies: all become acknowledged once or retain an
  explicit failed/conflict state.
- Edit the same version from two devices: canonical data is unchanged by the loser and both
  snapshots remain available.
- Interrupt pull before local commit: cursor does not move; replay produces the correct final state.
- A user authenticated as owner A cannot submit, pull or infer owner B data.
