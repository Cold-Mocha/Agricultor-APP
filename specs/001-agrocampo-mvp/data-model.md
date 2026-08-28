# Data Model: AgroCampo MVP - Módulo 001

**Date**: 2026-08-28

**Purpose**: Definir el modelo lógico compartido por Drift/SQLite y Supabase/PostgreSQL, sus
relaciones, validaciones, estados e índices. Este documento no contiene migraciones ejecutables.

## 1. Design principles

- El dispositivo crea UUID y conserva el mismo identificador local y remoto.
- Drift es la fuente de verdad de la interfaz; Supabase es respaldo compartido y autoridad de
  versión remota.
- Toda tabla privada remota lleva `owner_id`, aunque el propietario se pueda inferir por una FK.
- Las fechas con hora se almacenan en UTC; la zona horaria se conserva cuando afecta recordatorios.
- Las fechas agrícolas sin hora usan una fecha civil, no medianoche convertida por zona horaria.
- Borrados sincronizados usan tombstone; historia agrícola usa `RESTRICT`, nunca cascade.
- Cálculos críticos usan unidades enteras escaladas y guardan versión de regla y entradas.
- Geometría remota usa PostGIS; geometría local usa GeoJSON WGS84 validado en Dart.
- Fotografías viven como archivos; la base solo almacena rutas, hash y metadatos.

## 2. Common synchronized fields

Todas las entidades privadas sincronizables incorporan estos campos además de sus datos de
dominio.

| Logical field | Supabase | Drift | Rule |
|---|---|---|---|
| `id` | `uuid` PK | `text` PK | Generado en dispositivo, inmutable |
| `owner_id` | `uuid` FK Auth | `text` indexed | Nunca cambia |
| `version` | `bigint` | `remote_version integer` | Incrementado solo por servidor |
| `created_at` | `timestamptz` | UTC integer/text | No se reescribe |
| `updated_at` | `timestamptz` | UTC integer/text | Servidor manda al sincronizar |
| `deleted_at` | nullable `timestamptz` | nullable UTC | Tombstone, no borrado físico |
| `sync_status` | derivado | text enum | Solo local: pending/sending/synced/conflict/failed |
| `local_updated_at` | no aplica | UTC integer/text | Orden local y diagnóstico, no resuelve conflictos |

Las relaciones privadas remotas usan FKs compuestas que incluyen `owner_id`, de modo que una fila
no pueda referenciar accidentalmente datos de otro propietario.

## 3. Relationship overview

```text
auth.users 1---1 profiles
    |
    +---* parcels 1---* sectors 1---* sector_crop_assignments *---1 crop_catalog
    |        |            |                    |
    |        |            |                    +---0..1 seasons
    |        |            |
    |        |            +---* labors 1---0..1 soil_measurements
    |        |                 |       +---0..1 irrigation_records
    |        |                 |       +---0..1 production_records
    |        |                 |       +---0..1 apiary_inspections
    |        |                 |
    |        |                 +---* photos
    |        |
    |        +---* seasons
    |
    +---* irrigation_recommendations
    +---* reminders
    +---* device_registrations

Local only: app_settings, weather_cache, sync_outbox, sync_cursors, sync_lock
Local + remote audit: sync_conflicts
Remote only: sync_operations, sync_changes
```

## 4. Domain entities

### 4.1 `profiles`

One public profile per authenticated owner.

| Field | Type | Required | Validation/meaning |
|---|---|---:|---|
| `id` | UUID | yes | Equals `auth.users.id`; PK |
| `display_name` | text | yes | Trimmed, 1-120 characters |
| `phone` | text | no | Display/contact only; no SMS login in MVP |
| `locale` | text | yes | Fixed to `es-CL` initially |
| common timestamps | UTC | yes | Audit fields |

The account is provisioned; public registration, roles and workers do not exist in the MVP.

### 4.2 `parcels`

A farm property managed by the owner.

| Field | Type | Required | Validation/meaning |
|---|---|---:|---|
| `name` | text | yes | 1-120 characters |
| `description` | text | no | Up to 2,000 characters |
| `center_latitude` | decimal | yes | -90 to 90 |
| `center_longitude` | decimal | yes | -180 to 180 |
| `boundary` | polygon/GeoJSON | yes | WGS84, closed, valid, positive area |
| `area_m2` | decimal | yes | Positive; server recomputes from boundary |
| `archived_at` | UTC | no | Hidden from new work but retained in history |

**Relations**: one owner; many sectors, seasons and labors. A parcel with dependent history can be
archived but not physically deleted.

### 4.3 `sectors`

A management subdivision completely contained in one parcel.

| Field | Type | Required | Validation/meaning |
|---|---|---:|---|
| `parcel_id` | UUID FK | yes | Same owner, active or archived parcel |
| `number` | positive integer | yes | Unique among non-deleted sectors of parcel |
| `name` | text | yes | 1-120 characters |
| `sector_type` | enum | yes | `agricultural` or `apiary` |
| `boundary` | polygon/GeoJSON | yes | Square, rectangle or irregular valid polygon |
| `area_m2` | decimal | yes | Positive; recomputed from polygon |

**Rules**: boundary must be within parcel; overlaps are warned but allowed only after explicit
confirmation because the specification does not forbid them. Server repeats containment checks.

### 4.4 `crop_catalog`

Read-only catalog seeded locally and remotely.

| Field | Type | Required | Validation/meaning |
|---|---|---:|---|
| `id` | UUID | yes | Stable across environments |
| `slug` | text | yes | Unique immutable key |
| `display_name_es` | text | yes | Spanish name |
| `sowing_period` | text | yes | General information, not an automated rule |
| `soil_requirements` | text | yes | General information |
| `water_needs` | text | yes | General information |
| `common_diseases` | text | yes | General information |
| `catalog_version` | integer | yes | Seed/content version |

Required slugs: raspberry, blueberry, potato, watermelon, melon, corn, physalis, strawberry,
beekeeping. The last item activates the apiary sector presentation.

### 4.5 `seasons`

An agricultural period for grouping history and production.

| Field | Type | Required | Validation/meaning |
|---|---|---:|---|
| `parcel_id` | UUID FK | yes | Same owner |
| `name` | text | yes | 1-100 characters |
| `start_date` | date | yes | Civil date |
| `end_date` | date | no | Must be on/after start |
| `status` | enum | yes | `open` or `closed` |

Only one open season per parcel is the default, but imported history may reference closed seasons.

### 4.6 `sector_crop_assignments`

Temporal relationship that preserves rotations instead of overwriting the current crop.

| Field | Type | Required | Validation/meaning |
|---|---|---:|---|
| `sector_id` | UUID FK | yes | Same owner |
| `crop_id` | UUID FK | yes | Catalog item |
| `season_id` | UUID FK | no | Same parcel when present |
| `valid_from` | date | yes | Effective assignment date |
| `valid_to` | date | no | On/after valid_from |

There is at most one non-deleted assignment with `valid_to` null per sector. Changing crop closes
the previous row and inserts a new row atomically.

### 4.7 `labors`

Base aggregate for the user-facing module named `LABORES`.

| Field | Type | Required | Validation/meaning |
|---|---|---:|---|
| `parcel_id` | UUID FK | yes | Same owner |
| `sector_id` | UUID FK | yes | Belongs to parcel |
| `crop_assignment_id` | UUID FK | no | Assignment active at capture when applicable |
| `season_id` | UUID FK | no | Same parcel |
| `labor_type` | enum | yes | irrigation, soil, fertilization, pest_disease, sowing, pruning, harvest, apiary |
| `occurred_at` | UTC | yes | Capture/event time |
| `notes` | text | no | Up to 5,000 characters |
| `general_details` | structured text | no | Only fields defined by generic labor form |

Soil, irrigation, harvest and apiary types require exactly one matching detail row. Other types use
the common fields; no unrequested inventory or product model is introduced.

### 4.8 `soil_measurements`

One-to-one detail where `labor_id` is both PK and FK to a soil labor.

| Field | Stored unit | Required | Validation |
|---|---|---:|---|
| `humidity_bp` | 0.01 % | no | 0-10,000 |
| `ph_milli` | 0.001 pH | no | 0-14,000 |
| `temperature_milli_c` | 0.001 °C | no | Plausibility warning outside configured agronomic range |
| `ec_us_cm` | µS/cm | no | Non-negative; UI shows mS/cm |
| `nitrogen_mg_kg_milli` | 0.001 mg/kg | no | Non-negative |
| `phosphorus_mg_kg_milli` | 0.001 mg/kg | no | Non-negative |
| `potassium_mg_kg_milli` | 0.001 mg/kg | no | Non-negative |

At least one indicator must be present. The UI never labels manual input as an automatic sensor.

### 4.9 `irrigation_records`

One-to-one detail where `labor_id` is PK/FK to an irrigation labor.

| Field | Stored unit | Required | Validation |
|---|---|---:|---|
| `irrigation_type` | enum | yes | drip, sprinkler, furrow, gravity |
| `flow_ml_min` | ml/min | yes | Positive |
| `duration_seconds` | seconds | yes | Positive |
| `estimated_volume_ml` | ml | yes | Equals documented calculation or explicit estimate |
| `recommendation_id` | UUID FK | no | Recommendation used, if any |

When flow and duration are the source, volume equals `flow_ml_min * duration_seconds / 60` using a
single documented rounding rule.

### 4.10 `crop_irrigation_rules`

Versioned configuration required by the deterministic hybrid calculator.

| Field | Type/unit | Required | Validation/meaning |
|---|---|---:|---|
| `crop_id` | UUID FK | yes | Crop rule belongs to |
| `rule_version` | integer | yes | Unique per crop |
| `base_ml_per_plant` | ml | yes | Positive, agronomically reviewed |
| humidity thresholds/adjustments | basis points | yes | Bounded simple rules |
| temperature thresholds/adjustments | milli-°C/basis points | yes | Bounded simple rules |
| `max_weather_adjustment_bp` | basis points | yes | Caps optional climate influence |
| `source_reference` | text | yes | Reviewer/source and date |
| `valid_from` | date | yes | Rule activation |
| `retired_at` | UTC | no | Old versions stay readable |

Seed values cannot be released until the product owner accepts an agronomic source or reviewer.
No evapotranspiration model belongs in this table.

### 4.11 `irrigation_recommendations`

Auditable output of the local calculation.

| Field | Type/unit | Required | Validation/meaning |
|---|---|---:|---|
| `sector_id` | UUID FK | yes | Calculation context |
| `crop_id` | UUID FK | yes | Selected crop |
| `rule_id`/`rule_version` | reference | yes | Exact rules used |
| `calculated_at` | UTC | yes | Calculation time |
| `plant_count` | integer | yes | Positive |
| `flow_ml_min` | ml/min | yes | Positive |
| `soil_humidity_bp` | 0.01 % | yes | 0-10,000 |
| `soil_temperature_milli_c` | 0.001 °C | yes | Input value |
| `weather_adjustment_bp` | basis points | yes | Zero when weather absent; capped by rule |
| `weather_reference_at` | UTC | no | Freshness reference, not full provider payload |
| `weather_provider` | text | no | Attribution/audit only |
| `recommended_volume_ml` | ml | yes | Positive |
| `recommended_duration_seconds` | seconds | yes | Positive |
| `warning_codes` | list/text | no | Missing climate, unusual input, advisory notice |

The full provider response is not retained. Inputs and the derived adjustment are enough to replay
the calculation while respecting provider cache limits.

### 4.12 `production_records`

One-to-one detail where `labor_id` is PK/FK to a harvest labor.

| Field | Type/unit | Required | Validation/meaning |
|---|---|---:|---|
| `crop_id` | UUID FK | yes | Crop harvested |
| `season_id` | UUID FK | no | Comparison grouping |
| `quantity_grams` | grams | yes | Positive; UI may show kilograms |
| `quality` | enum/text | no | Defined labels plus explicit unclassified state |
| `observations` | text | no | Up to 5,000 characters |

### 4.13 `apiary_inspections`

One-to-one detail where `labor_id` is PK/FK and the sector type is apiary.

| Field | Type | Required | Validation/meaning |
|---|---|---:|---|
| `hive_count` | integer | yes | Non-negative |
| `beekeeper_name` | text | yes | 1-120 characters |
| `queen_status` | enum/text | yes | Visible configured value |
| `laying_status` | enum/text | yes | Visible configured value |
| `feeding_notes` | text | no | Manual note |
| `disease_present` | boolean | yes | Explicit yes/no |
| `disease_notes` | text | no | Required if present |
| `pest_present` | boolean | yes | Explicit yes/no |
| `pest_notes` | text | no | Required if present |
| `super_added` | boolean | yes | Colocación de alza |

Photos attach to the base labor and are not duplicated here.

### 4.14 `photos`

Metadata for a local and/or remotely stored image.

| Field | Type | Required | Validation/meaning |
|---|---|---:|---|
| `sector_id` | UUID FK | conditional | Exactly one of sector/labor target |
| `labor_id` | UUID FK | conditional | Exactly one of sector/labor target |
| `description` | text | no | Up to 1,000 characters |
| `captured_at` | UTC | yes | Capture/selection time |
| `source` | enum | yes | camera or gallery |
| `local_path` | text | local yes | Private app path; never remote |
| `storage_path` | text | remote yes | Immutable private bucket path |
| `sha256` | text | yes | Content identity |
| `mime_type` | text | yes | Allowed image MIME |
| `size_bytes` | integer | yes | Positive and within configured limit |
| `upload_status` | enum | local yes | local_only/uploading/uploaded/failed/delete_pending |

Remote path: `owner_id/photo_id/sha256.extension`. The remote database row is confirmed only when
the object exists at the matching path and hash.

### 4.15 `reminders`

| Field | Type | Required | Validation/meaning |
|---|---|---:|---|
| `sector_id` | UUID FK | no | Optional same-owner context |
| `title` | text | yes | 1-160 characters |
| `scheduled_at_utc` | UTC | yes | Future for an active alert |
| `timezone_id` | text | yes | Used to present/reconcile local alarm |
| `description` | text | no | Up to 2,000 characters |
| `status` | enum | yes | scheduled/completed/cancelled/historical |
| `local_notification_id` | integer | local | Stable Android alarm identifier |
| `last_remote_event_id` | UUID | no | Dedupe FCM/local delivery |

### 4.16 `device_registrations`

Remote registry for remote notifications.

| Field | Type | Required | Validation/meaning |
|---|---|---:|---|
| `device_id` | UUID | yes | Unique per installation |
| `fcm_token` | encrypted/protected text | yes | Never exported to domain history |
| `platform` | enum | yes | Android only in MVP |
| `last_seen_at` | UTC | yes | Token freshness |
| `disabled_at` | UTC | no | Invalid/revoked token |

## 5. Local infrastructure tables

### 5.1 `sync_outbox`

| Field | Type | Meaning |
|---|---|---|
| `operation_id` | UUID PK | Idempotency key |
| `device_id`, `owner_id` | UUID | Origin and tenant |
| `aggregate_type`, `aggregate_id` | text/UUID | Aggregate target |
| `action` | enum | create/update/delete/resolve_conflict |
| `base_version` | integer | Remote version user edited |
| `payload` | structured text | Complete aggregate mutation |
| `depends_on_operation_id` | UUID nullable | Causal ordering |
| `state` | enum | pending/sending/acked/conflict/failed |
| `attempt_count` | integer | Starts at zero |
| `next_attempt_at` | UTC | Backoff schedule |
| `lease_until` | UTC | Recovers abandoned sending work |
| `last_error_code` | text nullable | Sanitized classification |
| `created_at`, `updated_at` | UTC | Audit |

Entity mutation and outbox insertion are one transaction. `acked` rows are retained for a bounded
diagnostic period, then purged only after the domain row is confirmed.

### 5.2 `sync_conflicts`

| Field | Type | Meaning |
|---|---|---|
| `conflict_id` | UUID PK | Stable conflict identity |
| entity reference | type + UUID | Affected row/aggregate |
| `local_payload` | structured text | Candidate user change |
| `remote_payload` | structured text | Current server snapshot |
| `remote_version` | integer | Version required for resolution |
| `state` | enum | open/resolving/resolved |
| `resolution` | enum nullable | keep_local/keep_remote |
| timestamps | UTC | detected/resolved |

Remote audit retains resolved conflicts; local UI retains them until the resolution ACK and pull
are both confirmed.

### 5.3 `sync_cursors`, `sync_lock`, `app_settings`, `weather_cache`

- `sync_cursors`: one row per owner/feed with last applied `change_seq`.
- `sync_lock`: a lease that prevents foreground and WorkManager workers from racing.
- `app_settings`: local-only active parcel, last authenticated owner, locale and non-secret prefs.
- `weather_cache`: provider DTO normalized by rounded location and forecast type, with fetched and
  expires timestamps; expired data cannot influence a new irrigation recommendation.

## 6. Remote synchronization tables

### 6.1 `sync_operations`

Unique `(owner_id, operation_id)` ledger containing aggregate reference, result state, resulting
version, receipt payload and processed time. It is written in the same transaction as the mutation.

### 6.2 `sync_changes`

Append-only feed with `change_seq bigint identity`, owner, aggregate type/ID, action, version,
payload or tombstone and commit time. Pull is paginated by `(owner_id, change_seq)` ascending. The
MVP does not purge this feed.

### 6.3 `sync_conflicts`

Server audit of version mismatches and explicit resolutions. It never replaces the local conflict
record used by the UI; both share `conflict_id`.

## 7. State transitions

### 7.1 Synchronized entity

```text
synced -> pending -> sending -> synced
                    |          ^
                    +-> failed-+
                    +-> conflict -> pending (keep local) -> sending
                                 -> synced  (keep remote)
```

`sending` with an expired lease becomes `pending` after restart. A row is never shown as synced
before a remote receipt and subsequent local commit.

### 7.2 Parcel

```text
active <-> archived
new local unsynced -> discarded locally
synced row -> tombstoned remotely; never physically purged in MVP
```

### 7.3 Crop assignment

```text
planned/current -> closed
```

Closing and creating the replacement assignment occur atomically. Historical assignments are not
reopened by later edits.

### 7.4 Reminder

```text
scheduled -> completed
scheduled -> cancelled
past date explicitly saved -> historical
```

### 7.5 Photo upload

```text
local_only -> uploading -> uploaded
                |             |
                +-> failed ---+
local_only/uploaded -> delete_pending -> tombstoned
```

## 8. Required indexes

### Supabase/PostgreSQL

- B-tree `owner_id` on every private table used by RLS.
- Unique partial sectors `(owner_id, parcel_id, number)` where not deleted.
- GiST on parcel and sector geometry.
- Active crop lookup `(owner_id, sector_id, valid_from desc)` and unique partial active assignment.
- Labors `(owner_id, occurred_at desc)`, `(owner_id, parcel_id, occurred_at desc)`,
  `(owner_id, sector_id, occurred_at desc)`, `(owner_id, crop_assignment_id, occurred_at desc)` and
  `(owner_id, labor_type, occurred_at desc)`.
- Production `(owner_id, season_id, crop_id, occurred_at)` through its labor relationship or a
  denormalized indexed occurred date maintained atomically.
- Photos `(owner_id, labor_id)` and `(owner_id, sector_id)`.
- Active reminders `(owner_id, scheduled_at_utc)` where scheduled and not deleted.
- Operations unique `(owner_id, operation_id)`; changes `(owner_id, change_seq)`; open conflicts
  `(owner_id, resolved_at)` where unresolved.

### Drift/SQLite

Mirror user-facing lookup indexes above, plus:

- outbox partial/compound `(state, next_attempt_at, created_at)`;
- conflict `(entity_type, entity_id, state)`;
- photo `(upload_status, created_at)`;
- settings/cursor uniqueness by owner.

Do not add speculative indexes. Validate with `EXPLAIN`/`EXPLAIN QUERY PLAN` on the target fixture.

## 9. Migration and seed policy

- Remote changes are timestamped Supabase migrations; local changes increment Drift schema version.
- CI rebuilds Supabase from zero and tests every Drift upgrade path from saved snapshots.
- A release cannot ship if foreign-key checks, pgTAP, RLS tests or migration data-preservation tests
  fail.
- Catalog UUIDs are stable across local seed, remote seed and tests.
- Irrigation rule seeds require source, version and explicit agronomic/product-owner approval before
  production; placeholder numbers are forbidden.
- Destructive migration is split into add/backfill/read-switch/remove across releases; the MVP has
  no emergency manual edits as part of normal deployment.
