# Data Model: AgroCampo Functional Core - Módulo 002

**Target local schema**: Drift v10  
**Target remote change**: additive Supabase migration after `0011_apiary.sql`  
**Compatibility**: preserves every valid v9 row and all Módulo 001 identifiers.

## 1. Modeling Rules

### Identity and ownership

- Domain IDs are UUID strings generated locally and reused in Drift, PostgreSQL and outbox.
- Every private row is scoped by `owner_id`; remote ownership derives from `auth.uid()` and is never trusted from payload alone.
- Child ownership and parent relationships are validated locally before commit and remotely before ACK.
- No organization, role, worker or membership entity is introduced.

### Time

- Instants are stored in UTC; agricultural dates preserve their intended local date.
- Effective ranges use `[effective_from, effective_to)` semantics: start inclusive, end exclusive.
- Historical event rows keep explicit season and crop-assignment references/snapshots; current context never rewrites them.

### Syncable metadata

Entities mutated by 002 use the following conceptual fields. Existing physical names can remain where compatible.

| Field | Rule |
|---|---|
| `remote_version` | Non-negative canonical version; `0`/null before first ACK according to current code convention. |
| `sync_state` | `pending`, `syncing`, `synced`, `error`, `conflict`. Derived/updated with outbox result. |
| `local_updated_at` | UTC instant of last local candidate change; not conflict authority. |
| `server_updated_at` | UTC timestamp returned by server, optional until ACK. |
| `deleted_at` | Tombstone; physical removal only for never-synced rows with no history/dependencies. |
| `last_sync_error_code` | Stable code, optional. |

Do not copy these fields to local-only caches/drafts merely for uniformity.

### Numeric values

- Geometry stores ordered WGS84 coordinates and area in square metres with a versioned algorithm.
- Irrigation uses canonical integers: millilitres, seconds, milli-degrees Celsius and basis points as defined by contract.
- Production quantity uses a positive value and an explicit metric unit; no locale-dependent parsing is persisted.

## 2. Audit of the 24 Existing Drift Tables

| Existing table | 002 role | Change |
|---|---|---|
| `local_profiles` | Local owner profile/access scope | Keep; ensure access only through unlocked owner session. |
| `app_preferences` | Active context and integration preferences | Extend with active sector/season/assignment, context revision, biometric/alert preferences only if non-secret. |
| `sync_outbox` | Durable local mutations | Extend/activate attempts, next attempt, dependency, error and full state machine; add payload/protocol schema version if absent. |
| `sync_cursors` | Durable pull cursor | Keep; commit each page and cursor atomically. |
| `sync_conflicts` | Local/remote snapshots | Extend resolver metadata/state where needed; do not drop resolved audit immediately. |
| `form_drafts` | Durable forms/editor drafts | Reuse for long forms and geometry draft if needed; no sync. |
| `parcels` | Parcel aggregate | Extend/correct archive, tombstone, version/sync metadata and indexes; preserve geometry/area. |
| `sectors` | Sector aggregate | Extend version/tombstone/indexes; preserve polygon and number/name. |
| `official_crops` | Offline immutable seed | Reuse without outbox; stable IDs/codes. |
| `custom_crops` | Owner crop catalog | Extend edit/archive/sync metadata; never hard-delete referenced crops. |
| `crop_seasons` | Existing sector-crop temporal rows | Preserve physical table; extend as `SectorCropAssignment` with `agricultural_season_id`, effective range, notes/version/tombstone. |
| `labors` | Root agricultural event | Extend historical references, occurred time, details schema/version, correction/status and sync payload completeness. |
| `soil_measurements` | 001 specialization | Preserve; add/adjust only relationships required by migration compatibility. Not a 002 completion gate. |
| `irrigation_records` | Performed irrigation specialization | Extend to reference configuration snapshot/estimate and historical context through labor. |
| `crop_irrigation_rules` | Approved deterministic rules | Reuse/version; no active recommendation without approval evidence/vectors. |
| `irrigation_estimates` | Calculation snapshot/result | Extend relation to config/assignment, explanation/warnings and sync as part of irrigation aggregate. |
| `production_records` | Harvest specialization | Extend with `labor_id` relation/uniqueness and avoid independent duplicate event. |
| `photo_attachments` | 001 evidence | Preserve; not a 002 gate. |
| `reminders` | Offline reminder source | Extend edit/complete/cancel, stable Android binding/identity, context and sync metadata. |
| `device_installations` | FCM technical state | Preserve; 002 local reminders do not depend on it. |
| `apiary_inspections` | Specialized apiary record | Preserve model; only context compatibility changes if necessary. |
| `weather_cache` | Normalized external cache | Extend forecast/alert metadata/freshness, not raw provider payload. |
| `ai_messages` | AgroIA local conversation | Extend stable client ID, send status, retry/response linkage; ensure no automatic private context fields. |
| `export_snapshots` | 001 export state | Preserve; not a 002 gate. |

## 3. New Entity: `agricultural_seasons`

Represents an agricultural season at parcel level, independent from the crop assigned to each sector.

| Field | Required | Rule |
|---|---:|---|
| `id` | yes | UUID stable, local-first. |
| `owner_id` | yes | Same owner as parcel. |
| `parcel_id` | yes | Existing, non-deleted parcel. |
| `name` | yes | Trimmed, non-empty, distinguishable within parcel. |
| `starts_on` | yes | Agricultural date. |
| `ends_on` | conditional | Null unless closed/planned range; not before start. |
| `status` | yes | `planned`, `active`, `closed`. |
| `notes` | no | Bounded text. |
| `is_migration_backfill` | yes | True only for deterministic imported season. |
| sync metadata | yes | As section 1. |

### Invariants

- A sector assignment can reference only a season of its parcel.
- At most one `active` non-deleted season per parcel.
- A `closed` season accepts no new event except explicit correction with audit.
- Closing does not edit assignments/events.
- Planned seasons may overlap only if product rules permit planning; active ranges cannot create ambiguous event context.

### Indexes

- `(owner_id, parcel_id, status)`.
- `(owner_id, parcel_id, starts_on DESC)`.
- Partial unique active season per parcel where supported; equivalent transactional check in Drift.

## 4. Existing `crop_seasons` as `SectorCropAssignment`

No physical rename is required in v10. Domain/repository/UI use `SectorCropAssignment` terminology.

| Field | Required | Rule/change |
|---|---:|---|
| `id` | yes | Preserve existing ID. |
| `owner_id` | yes | Same owner as sector/season/custom crop. |
| `sector_id` | yes | Existing sector. |
| `agricultural_season_id` | yes after migration | New FK to season of sector parcel. |
| `crop_id` | yes | Official or custom ID. |
| `is_custom` / `crop_source` | yes | Preserve current discriminant; validate referenced table. |
| `status` | yes | `planned`, `active`, `ended`, `cancelled`. Map legacy values deterministically. |
| `effective_from` | yes | Existing `starts_on` may map without semantic change. |
| `effective_to` | no | Existing `ends_on`; greater than start. |
| `notes` | no | Optional addition. |
| sync metadata | yes | Add version/tombstone/error fields required by 002. |

### Invariants

- Maximum one effective assignment for a sector at any instant.
- An active assignment must belong to active/current permissible season.
- Planned assignment does not change current context before `effective_from`.
- Activation transaction ends previous assignment at the same effective instant.
- Exchange transaction validates both sectors, seasons and crops, then closes/creates both pairs atomically.
- An assignment referenced by history may end/cancel but is not physically deleted.

### Indexes

- `(owner_id, sector_id, effective_from DESC)`.
- `(owner_id, agricultural_season_id, sector_id)`.
- `(owner_id, crop_id, is_custom, effective_from DESC)`.
- Unique/transactional enforcement for one active row per sector and no overlapping effective ranges.

## 5. New Entity: `sector_irrigation_configs`

Permanent, versioned configuration for drip irrigation. It is not a performed irrigation.

| Field | Required | Rule |
|---|---:|---|
| `id` | yes | UUID. |
| `owner_id` | yes | Same owner as sector. |
| `sector_id` | yes | Existing non-deleted sector. |
| `method` | yes | `drip` only for recommendations in 002. |
| `plant_count` | yes | Integer > 0. |
| `emitter_count` | yes | Integer > 0. |
| `emitters_per_plant_milli` | no | Optional exact scaled distribution; consistent with counts when present. |
| `flow_ml_min` | yes | Effective total flow > 0 in canonical unit. |
| `pressure_kpa` | no | Positive when supplied; informational unless approved rule uses it. |
| `distribution_notes` | no | Bounded text for line/zones. |
| `effective_from` | yes | UTC/date boundary for version. |
| `effective_to` | no | Null for current config. |
| `config_version` | yes | Positive per sector/method; immutable after historical use. |
| sync metadata | yes | Version, state, timestamps, tombstone/error. |

### Invariants

- At most one current non-deleted drip config per sector.
- Editing a config closes current version and creates a new one if the previous was used by a historical irrigation; it does not rewrite history.
- Other methods may be recorded in `irrigation_records` for 001 compatibility but have no config/recommendation implementation in 002.

### Indexes

- `(owner_id, sector_id, method, effective_from DESC)`.
- Partial unique current config per `(owner_id, sector_id, method)`.

## 6. Parcel and Sector Changes

### `parcels`

- Preserve ID, name, location, polygon JSON, area and active state.
- Archive/restore participates in the same local transaction and payload; never update `isArchived` outside outbox creation.
- `deleted_at` only for deletable rows; a parcel with history archives.
- Exactly one active, non-archived parcel per owner when any exists. Selection changes transactionally.
- Index `(owner_id, is_active, archived/deleted)` and name/list ordering.

### `sectors`

- Preserve ID, parcel, name/number, polygon and area.
- Polygon: ≥3 distinct points, valid lat/lon, no self-intersection, positive area, contained in parcel.
- Geometry change increments domain/version and is created only by explicit confirm action.
- Deleting a sector with history becomes archive/tombstone according to product action; no destructive cascade.
- Index `(owner_id, parcel_id, deleted_at)` and unique distinguishable number/identity where current design requires.

## 7. Custom Crop Changes

`official_crops` remains immutable. `custom_crops` adds or confirms:

| Field | Rule |
|---|---|
| `name` / `normalized_name` | Trimmed; owner-unique among active custom crops. |
| `description` | Optional bounded text. |
| `archived_at` | Hides from new assignment while preserving history. |
| sync metadata | Required for create/edit/archive. |

Custom crop IDs participate in assignments, labor context, irrigation rules/results, production and history identically to official IDs through a `CropRef(id, source)` value.

## 8. Labor Aggregate

### `labors` root

| Field | Required | Rule/change |
|---|---:|---|
| `id`, `owner_id` | yes | Stable aggregate identity/owner. |
| `parcel_id`, `sector_id` | yes | Sector belongs to parcel. |
| `agricultural_season_id` | yes | Season applicable at event time. |
| `crop_assignment_id` | yes for crop-related 002 event | Assignment applicable at event time; may be explicit correction. |
| `labor_type` | yes | `irrigation`, `fertilization`, `phytosanitary`, `sowing`, `pruning`, `harvest`, `other`; retain compatible 001 values. |
| `occurred_at` | yes | UTC instant plus local date semantics where needed. |
| `notes` | no | Bounded text. |
| `details_json` | yes | Valid JSON object conforming to type/version. |
| `details_schema_version` | yes | Starts at `1` for each defined contract. |
| `status` | yes | `recorded`, `corrected`, `voided`. |
| `supersedes_labor_id` | no | Previous revision when correction creates a new event. |
| sync metadata | yes | Aggregate-level. |

### Minimal detail shapes

These are contract fields, not database columns. Tasks may refine UI labels without changing meaning.

| Type | Required structured details |
|---|---|
| `fertilization` | product/input name, positive quantity, unit; method optional. |
| `phytosanitary` | product, target/problem, positive quantity/dose and unit; safety note optional. |
| `sowing` | seed/crop ref and positive quantity/plant count with unit as applicable. |
| `pruning` | pruning kind/work description; quantity optional. |
| `other` | non-empty description/name. |
| `harvest` | production specialization supplies quantity/unit; quality optional. |
| `irrigation` | irrigation specialization supplies method/config/result. |

Unknown detail schema versions are retained and shown as unsupported rather than discarded.

### Edit/correction

- Field edits create a new outbox version.
- Changing occurred date/context across an assignment boundary requires warning and explicit correction; it must resolve a valid assignment or preserve original via supersession.
- Voiding leaves root and specialization for audit/history.

## 9. Production Specialization

`production_records` is 1:1 with a harvest labor.

| Field | Rule |
|---|---|
| `labor_id` | Required, unique, references labor type `harvest`. Existing independent rows receive/link a deterministic labor during migration only where safe. |
| `quantity` | Positive. |
| `unit` | Allowlisted metric unit/code. |
| `quality` | Optional bounded text. |

Parcel, sector, season, crop assignment, time, notes and sync state come from the labor root. History projects one harvest event decorated with production values.

## 10. Irrigation Aggregate

### `irrigation_records`

1:1 with labor type `irrigation`.

| Field | Rule/change |
|---|---|
| `labor_id` | Unique root reference. |
| `method` | Existing method value; recommendation only when `drip`. |
| `config_id`, `config_version` | Exact config used, required for drip recommendation/performed record when available. |
| `duration_seconds` | Positive performed duration. |
| `applied_volume_ml` | Deterministic from effective flow × duration, positive. |
| `performed_details_json` | Optional event-only data that is not configuration. |

### `irrigation_estimates`

| Field | Rule/change |
|---|---|
| `id` / `irrigation_labor_id` | Stable 1:1 result identity. |
| `crop_assignment_id` | Assignment used. |
| `config_id`, `config_version` | Exact permanent config. |
| `algorithm_version`, `rule_id`, `rule_version` | Reproducibility. |
| canonical inputs | Plant/emitter count, flow, humidity/temperature and weather adjustment used. |
| `recommended_volume_ml` | Positive valid result. |
| `recommended_duration_seconds` | Positive valid result. |
| `explanation_json` | Stable facts/units used to render brief explanation. |
| `warnings_json` | Stable codes. |
| `calculated_at` | UTC. |

Estimate is persisted with the irrigation aggregate/outbox, not as an unsynchronized orphan. Updating current config/rule never recalculates it.

## 11. Reminder Changes

| Field | Rule/change |
|---|---|
| `parcel_id`, `sector_id` | Optional context; if sector exists parcel must match. |
| `title`, `description` | Title required; description optional. |
| `scheduled_at`, `source_time_zone` | Future or explicit save-without-future-notification path. |
| `status` | `scheduled`, `completed`, `cancelled`. |
| `completed_at`, `cancelled_at` | Coherent with status. |
| `android_notification_id` | Stable persisted integer/binding; collision-safe. |
| `notification_state` | scheduled/permissionDenied/error/none, platform-local. |
| sync metadata | Reminder domain changes sync; platform binding fields do not need remote authority. |

Reconciliation never deletes the reminder when scheduling fails.

## 12. Weather and AgroIA Local Data

### `weather_cache`

Keyed by owner/parcel/location/provider. Store only normalized current/forecast/alert fields, `observed_at`, `fetched_at`, `expires_at`, provider attribution/version and error code. An alert includes condition/severity, location/parcel, valid interval and source timestamp. Raw provider payload is not retained.

### `ai_messages`

| Field | Rule/change |
|---|---|
| `client_message_id` | Stable UUID, unique per owner/thread. |
| `role` | `user`, `assistant`, `system_notice`. |
| `text` | User-authored or returned text. |
| `state` | `draft`, `sending`, `sent`, `error`. |
| `reply_to_client_message_id` | Assistant response relation. |
| `remote_response_id`, `policy_version`, `error_code` | Optional technical metadata. |

No parcel, sector, history or production snapshot is added automatically. A retry updates the same user message state and accepts at most one response relation.

## 13. Technical Tables and Sync State

### `sync_outbox`

Required fields/semantics:

- `operation_id`, `owner_id`, `device_id`;
- `protocol_version`, `aggregate_type`, `aggregate_id`, `action`;
- `base_version`, JSON payload and payload schema version;
- optional `depends_on_operation_id`;
- state `pending|sending|retry_wait|blocked|conflict|done`;
- attempt count, next attempt, error code, created/last attempted/completed timestamps;
- request hash or enough canonical data to verify receipt.

Eligible query uses `(owner_id, state, next_attempt_at, created_at)`. A dependency is eligible only when its operation is done or no longer required under the create-delete cancellation rule.

### `sync_cursors`

One row per owner/protocol stream: cursor and updated time. Pull page application and cursor update share a transaction. Unknown/invalid aggregate aborts page; it is never skipped with cursor advancement.

### `sync_conflicts`

Keep base/local/remote snapshots, remote version, source operation, state `open|resolution_pending|resolved`, choice, resolution operation and errors. Domain row remains local/visible in conflict until resolution receives ACK.

## 14. Remote Supabase Changes

The next additive migration must:

1. Create `agricultural_seasons` and `sector_irrigation_configs` with RLS.
2. Add required columns/indexes/checks/FKs/version/tombstones to mirrored 002 tables.
3. Backfill remote legacy rows under the same deterministic policy as Drift.
4. Replace RPC definitions with protocol v2 handlers/results without editing 0001-0011.
5. Keep `sync_operations` receipt uniqueness `(owner_id, operation_id)` and add request hash/status/result if absent.
6. Ensure every applied aggregate writes one ordered `sync_changes` record with structured JSON/tombstone.
7. Derive owner from authenticated session and validate child ownership.
8. Add pgTAP tests for RLS and behavior before client allowlist activation.

Remote history uses `RESTRICT`/tombstones, not destructive cascades.

## 15. Relationships

```text
auth.users 1 ── 1 local/remote profile
profile    1 ── N parcels
parcel     1 ── N sectors
parcel     1 ── N agricultural_seasons
sector     1 ── N sector_crop_assignments N ── 1 agricultural_season
sector_crop_assignments N ── 1 crop_ref (official OR owner custom)
sector     1 ── N sector_irrigation_configs
sector     1 ── N labors N ── 1 agricultural_season
labors     N ── 1 sector_crop_assignment (where applicable)
labors     1 ── 0..1 production_record
labors     1 ── 0..1 irrigation_record 1 ── 0..1 irrigation_estimate
irrigation_record N ── 1 sector_irrigation_config version snapshot
sector     1 ── N reminders (optional relation)
labors     1 ── 0..1 existing soil/apiary specializations
```

## 16. State Transitions

### Session

`signedOut → authenticating → locked/signedIn`  
`locked → biometricPrompt → signedInLocal | locked`  
`signedIn → locked` on app policy  
`signedIn|locked → signedOut` on logout, with local data retained but inaccessible.

### Season and assignment

`season: planned → active → closed`  
`assignment: planned → active → ended`  
`assignment: planned → cancelled`

### Irrigation config

`draft → current → superseded`; a used/synced config is never overwritten in place.

### Labor

`recorded → corrected` with superseding row, or `recorded → voided` with audit.

### Sync operation

`pending → sending → done`  
`sending → retry_wait → pending`  
`sending → blocked`  
`sending → conflict → pending(resolution) → done`  
stale `sending → pending` on recovery.

### Reminder

`scheduled → completed | cancelled`; platform scheduling is related state, not domain status.

## 17. Derived Queries

- `active_context`: validates selected parcel/sector/season/assignment against current non-deleted rows.
- `active_crop_by_sector_at(date)`: assignment effective for a date.
- `planned_rotations`: future assignments per sector.
- `sector_history`: union/projection of season boundaries, assignment changes and labor roots decorated by specializations.
- `sync_summary`: pending/retry/error/conflict counts, last ACK and current cycle.
- `current_drip_config`: latest open config version per sector.
- `weather_for_active_parcel`: current/stale/unavailable projection with attribution.

All queries filter by `owner_id` first and use indexes; no presentation layer loads every table to filter in memory.

## 18. Migration v9 → v10

1. Capture a real v9 schema snapshot and fixture counts/hashes.
2. Begin one Drift migration transaction.
3. Create both new tables and required indexes.
4. Add nullable columns to existing tables where SQLite requires staged backfill.
5. Insert deterministic imported seasons for parcels with legacy data.
6. Link legacy assignments and events using existing parcel/sector/date relationships.
7. Normalize legacy statuses without changing effective dates.
8. Link production to harvest labor when a unique valid relation exists; otherwise preserve row and flag a deterministic migration review state rather than delete/guess.
9. Backfill sync metadata from existing outbox/version fields; never mark remotely synced without evidence.
10. Validate FK-like ownership, counts, unique active context and JSON decodability.
11. Make required columns non-null through Drift-supported table recreation only where necessary, copying every row and validating counts.
12. Commit; on any validation failure roll back the whole upgrade and keep v9 file usable.

The same semantic backfill is implemented append-only in Supabase. Local and remote IDs for imported seasons must use the same deterministic algorithm so later sync converges.

## 19. Migration Acceptance

- Row counts for all 24 existing tables are unchanged except intentional additive relation rows.
- Every original ID, geometry vertex, event date, crop reference, production value and irrigation result is preserved byte-for-byte or by declared canonical conversion.
- Every legacy sector assignment maps to exactly one agricultural season.
- No legacy outbox item becomes `done` due to migration.
- No historical record changes crop/season on later context change.
- A migrated file closes/reopens and all 002 common queries succeed.
- A migration failure leaves the previous DB untouched and does not display local-save success.
