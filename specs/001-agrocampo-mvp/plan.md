# Implementation Plan: AgroCampo MVP - Módulo 001

**Branch**: `001-agrocampo-mvp` | **Date**: 2026-08-28 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-agrocampo-mvp/spec.md`

**Scope note**: Este plan produce diseño y orden de implementación. No crea código ni incorpora
funcionalidades fuera del MVP.

## Summary

AgroCampo se implementará como una única aplicación Flutter Android, modular por feature, con
Drift/SQLite como fuente de verdad local y Supabase como autenticación, respaldo remoto, Storage y
autoridad de versiones. Cada escritura se confirmará primero en una transacción local que también
crea una operación outbox. La sincronización será idempotente, versionada, por push seguido de pull
y con resolución explícita de conflictos, nunca last-write-wins.

La aplicación renderizará mapas con Google Maps, calculará y validará geometría localmente,
consultará clima y Gemini mediante funciones protegidas, programará recordatorios locales y usará
FCM para entrega remota complementaria. Fotografías se guardarán primero en almacenamiento privado
del dispositivo y luego en Supabase Storage. La exportación `.xlsx` se generará completamente desde
Drift, incluso offline. El trabajo se divide en siete sprints verticales con pruebas de dominio,
migración, RLS, sincronización, dispositivo y aceptación.

## Technical Context

**Language/Version**: Flutter 3.44.7 estable con Dart incluido; SQL/PLpgSQL para migraciones y RPC
Supabase; TypeScript/Deno limitado a Edge Functions de proveedores y FCM.

**Primary Dependencies**: `provider`, `go_router`, Drift, `supabase_flutter`,
`google_maps_flutter`, `geolocator`, `connectivity_plus` como señal, WorkManager,
`image_picker`, `path_provider`, `flutter_local_notifications`, `firebase_messaging`,
`excel_community` y utilidades de zona horaria/UUID. Las versiones se fijarán tras una matriz de
compatibilidad en Sprint 1.

**Storage**: SQLite/Drift local; archivos privados Android para fotografías temporales y
persistentes; PostgreSQL/PostGIS, Auth y Storage privado en Supabase; Android Storage Access
Framework para exportaciones elegidas por el usuario.

**Testing**: `flutter_test`, `integration_test`, Drift en memoria y migraciones generadas, pgTAP y
Supabase CLI, fakes de proveedores, emuladores Android y al menos un dispositivo físico.

**Target Platform**: Android API 24-37; compilación contra el API estable más reciente admitido;
sin target iOS.

**Project Type**: Aplicación móvil Flutter con backend administrado Supabase y funciones serverless
mínimas para proteger credenciales externas.

**Performance Goals**: 95 % de navegación/guardados locales bajo 2 segundos; inicio local bajo 5
segundos; 20 parcelas, 200 sectores y 10.000 registros textuales; exportación de ese fixture sin
bloquear el isolate UI.

**Constraints**: Offline First no negociable; escritura local antes de éxito; español
latinoamericano; unidades métricas; cero pérdida silenciosa/duplicados; IA consultiva; mapa base,
clima y red no pueden bloquear registros ni cálculos locales.

**Scale/Scope**: Un agricultor propietario por cuenta en el MVP, múltiples parcelas y sectores, un
dispositivo primario probado y escenarios de dos dispositivos solo para validar conflictos y la
evolución futura.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Pre-research gate

| Constitutional gate | Status | Evidence in planned approach |
|---|---|---|
| Utilidad agrícola, español y métricas | PASS | Flujos centrados en terreno, validaciones y unidades de dominio |
| Android con Flutter/Dart | PASS | Única app productiva en `mobile/`; prototipo HTML queda como referencia UX |
| Offline First | PASS | Drift source of truth, outbox transaccional, estados y pull durable |
| Trazabilidad y cálculos deterministas | PASS | Reglas Dart versionadas, entradas/resultados persistidos, IA aislada |
| Alcance disciplinado | PASS | Sin iOS, roles, ERP, IoT, inventario, panel web ni automatización física |
| Tecnologías obligatorias | PASS | Drift, Supabase, Google Maps, clima, Gemini, FCM y XLSX incluidos |
| Calidad y verificación | PASS | Pirámide de pruebas, migraciones, RLS, fault injection y aceptación |

No existe una violación que requiera excepción. La fase de investigación resolvió proveedor de
mapas/clima, patrón sync, librerías, seguridad y límites Android.

### Post-design gate

| Check after data model and contracts | Status | Result |
|---|---|---|
| Toda escritura local genera outbox atómico | PASS | `sync-protocol.md` lo exige por contrato |
| Conflictos conservan ambas versiones | PASS | Control optimista y resolución explícita |
| Datos críticos son reproducibles | PASS | Unidades escaladas, versión de regla y entradas guardadas |
| Proveedores no controlan dominio | PASS | Adaptadores; geometría/irrigación permanecen en Dart |
| RLS y secretos están cerrados por defecto | PASS | `owner_id`, grants mínimos, RPC, secrets server-side |
| Futuros módulos no fueron implementados en diseño | PASS | Solo puntos de extensión, sin roles/IoT/web/ERP |

Phase 1 design passes all constitutional gates.

## Project Structure

### Documentation (this feature)

```text
specs/001-agrocampo-mvp/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── sync-protocol.md
│   ├── external-services.md
│   ├── ui-navigation.md
│   └── export-xlsx.md
├── checklists/
│   └── requirements.md
└── tasks.md                 # Created later by $speckit-tasks
```

### Source Code (repository root)

```text
mobile/
├── pubspec.yaml
├── analysis_options.yaml
├── android/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── bootstrap.dart
│   │   ├── agro_campo_app.dart
│   │   ├── router/
│   │   └── theme/
│   ├── core/
│   │   ├── auth/
│   │   ├── database/
│   │   │   ├── tables/
│   │   │   ├── daos/
│   │   │   └── migrations/
│   │   ├── sync/
│   │   ├── geometry/
│   │   ├── files/
│   │   ├── network/
│   │   ├── notifications/
│   │   ├── security/
│   │   ├── units/
│   │   ├── errors/
│   │   └── ui/
│   └── features/
│       ├── auth/
│       ├── profile/
│       ├── parcels/
│       ├── map/
│       ├── sectors/
│       ├── crops/
│       ├── labors/
│       ├── soil/
│       ├── irrigation/
│       ├── history/
│       ├── production/
│       ├── beekeeping/
│       ├── photos/
│       ├── reminders/
│       ├── export/
│       ├── weather/
│       └── advisory_ai/
├── test/
│   ├── core/
│   ├── features/
│   ├── fixtures/
│   └── generated_migrations/
├── integration_test/
└── drift_schemas/

supabase/
├── config.toml
├── migrations/
├── seed.sql
├── tests/
│   ├── rls/
│   ├── constraints/
│   └── sync/
└── functions/
    ├── weather-proxy/
    ├── place-search/
    ├── gemini-advisory/
    └── send-reminder/

agrocampo-highfi.html         # Existing UX prototype; reference only
agrocampo-acceptance.test.js  # Existing prototype checks
assets/                       # Existing prototype assets
```

**Structure Decision**: La aplicación productiva vive en `mobile/` para no mezclar Flutter con el
prototipo estático existente. Cada feature contiene `data`, `domain` y `presentation` solo cuando
las necesita. `core` se reserva para capacidades verdaderamente transversales. `supabase/`
versiona schema, pruebas y funciones; no constituye un segundo producto ni un backend paralelo.

## Architecture and responsibility boundaries

| Layer/component | Owns | Must not own |
|---|---|---|
| View | Rendering, accessibility, user events | SQL, HTTP, formulas, provider secrets |
| ViewModel | Screen state and commands | Persistent source of truth |
| Domain service | Irrigation, geometry, sync policy, units | Widgets or provider DTOs |
| Repository | Domain-oriented reads/writes | UI navigation |
| Drift DAO | Local tables, joins, transactions | Network calls |
| Sync coordinator | Outbox leases, push/pull, retries | Business form validation |
| Supabase gateway | Authenticated RPC/pull/storage | UI state |
| External adapter | Provider mapping, timeout, quota errors | Domain decisions |
| Edge Function | Secrets, provider normalization, rate limits | Offline domain state |

### Read flow

Views observe immutable ViewModel state. ViewModels subscribe to repositories. Repositories query
Drift only. Remote pull writes Drift; it never returns provider rows directly to a widget.

### Write flow

ViewModel validates presentation fields, then calls a domain/repository command. A single Drift
transaction validates domain state, writes the aggregate and inserts outbox. Only commit means
user-visible success. Sync occurs separately and updates local version/status after an ACK.

### Critical rule ownership

- Polygon validity, sector containment and surface: pure Dart geometry service with golden fixtures.
- Irrigation: pure Dart calculator using versioned local rules and integer units.
- Sync conflict: coordinator plus explicit conflict ViewModel; no widget-side merges.
- XLSX: exporter reads a repository snapshot; it never queries Supabase.
- Gemini: output is display-only advisory text and cannot call domain commands.

## Database design

Full field definitions, relations, state machines and indexes are in [data-model.md](data-model.md).

### Supabase tables

- Domain: `profiles`, `parcels`, `sectors`, `crop_catalog`, `seasons`,
  `sector_crop_assignments`, `labors`, `soil_measurements`, `irrigation_records`,
  `crop_irrigation_rules`, `irrigation_recommendations`, `production_records`,
  `apiary_inspections`, `photos`, `reminders`, `device_registrations`.
- Sync/audit: `sync_operations`, `sync_changes`, `sync_conflicts`.
- PostGIS polygons use SRID 4326 and GiST indexes. The server recomputes area and validates that a
  sector lies within its parcel.
- Every private table has direct `owner_id`, RLS, least-privilege grants, version and tombstone.
- Historical FKs use `RESTRICT`; profiles alone may cascade from account deletion, which is not an
  MVP flow.

### Drift entities

Drift mirrors domain tables plus local-only `sync_outbox`, `sync_cursors`, `sync_lock`,
`app_settings` and `weather_cache`. It also retains local `sync_conflicts` and photo paths/upload
state. Each aggregate and outbox operation commit together.

### Index strategy

- User-facing history indexes by owner, parcel, sector, crop/type and descending event date.
- Unique partial sector number per active parcel and one active crop assignment per sector.
- RLS owner indexes and composite parent FKs.
- GiST remote geometry indexes.
- Pending outbox, unresolved conflicts, scheduled reminders and photo upload queues use partial or
  compound indexes matching worker queries.
- Sprints validate real queries using `EXPLAIN` and target fixtures before adding more indexes.

## Offline First strategy

### Local write guarantee

1. Validate IDs, ranges, relationships and metric units.
2. Start Drift transaction.
3. Write root and specialized detail rows.
4. Insert/update one outbox aggregate operation with UUID and `base_version`.
5. Commit; then update UI to pending success.

If any step fails, nothing commits. Forms keep user input and present a recoverable error.

### Synchronization algorithm

1. Acquire owner/device lease and recover abandoned `sending` operations.
2. Confirm authenticated connectivity; connectivity plugin is a hint, not proof.
3. Push operations in dependency order to versioned Supabase RPC.
4. Handle acknowledged, conflict, permanent or retryable results atomically in Drift.
5. Pull ordered `sync_changes` pages after local cursor.
6. Apply each page and cursor in one transaction.
7. Reconcile files, alarms and status; release lease.

The same coordinator runs at start, resume, connectivity recovery, manual retry and best-effort
WorkManager execution. Realtime may trigger an earlier pull later but is not required or trusted as
the durable feed.

### Sync states

- Row/outbox: pending, sending, synced/acked, conflict, failed.
- Global UI: Conectado, Offline, Sincronizando, Sincronizado, Error.
- `Sincronizado` requires a successful cycle and zero pending/failed/conflict work.
- `Error` never prevents new local records unless local persistence itself is unavailable.

### Conflict resolution

`base_version` mismatch creates a conflict with both snapshots. Keep-remote replaces local only
after explicit choice. Keep-local creates a new mutation against latest remote version. The audit
remains. Automatic merge and last-write-wins are outside v1.

### Recovery and deletion

- Timeout after remote commit is safe because `operation_id` returns the prior receipt.
- Expired leases return to pending at startup.
- Synced deletes are tombstones; parcels with history are archived.
- No remote tombstone/change purge in MVP.
- Logout removes session secrets and hides the store, but preserves pending work for the same owner.

Detailed request/response behavior is in [sync-protocol.md](contracts/sync-protocol.md).

## External integrations

### Google Maps and GPS

Use official Flutter Maps rendering, a restricted Android key, foreground GPS permissions and a
provider-neutral geometry service. No Google tile cache is promised. When offline, the app shows
saved polygons on a local schematic canvas; search and map tiles are visibly unavailable.

### WeatherAPI

An authenticated `weather-proxy` Edge Function hides the key, normalizes metric data, applies
quota/rate limits and caches according to provider terms. Drift stores a short-lived normalized
cache. Expired or absent climate adds a warning and zero weather adjustment; it never blocks the
calculator.

### Notifications

Local scheduled notifications are authoritative offline. FCM is supplementary and sent only by a
trusted `send-reminder` function using HTTP v1. Payloads carry IDs, not agricultural content, and
client dedupe prevents double alerts.

### Gemini

`gemini-advisory` accepts text and minimal user-selected context, applies safety and cost limits,
and returns visibly consultative Spanish text. It cannot accept photos, write data or calculate
critical agricultural values. The configured GA model and credentials are release-checked because
Google model/key policies change.

### Photos

`image_picker` copies camera/gallery output to the app's private directory, strips unnecessary EXIF
and writes metadata locally. Sync uploads compressed files to a private immutable Storage path,
then confirms metadata. Local copies remain available offline.

### XLSX

`excel_community` generates seven fixed sheets from one Drift snapshot on a worker isolate. Android
Storage Access Framework lets the user choose the destination without broad storage permission.
The contract is [export-xlsx.md](contracts/export-xlsx.md).

All adapter fields, failure states and secret boundaries are in
[external-services.md](contracts/external-services.md).

## Delivery plan by sprint

Assumption: seven two-week sprints for a small team, adjusted by measured capacity. Each sprint
must finish with a demonstrable vertical slice and green gates; incomplete gates roll forward
before new scope starts.

### Sprint 1 - Foundation, local data and authenticated shell

**Deliver**:

- Flutter project in `mobile/`, analysis rules, environments and CI baseline.
- App bootstrap, provider/DI, router, Spanish theme and standard screen states.
- Drift v1 connection, common columns, schema snapshots and migration tests.
- Supabase local project/migrations baseline, provisioned email/password login and profile.
- Secure session handling, offline unlock for last validated owner and logout preserving data.
- Crop seed identities and app settings with active parcel placeholder.

**Validation gate**:

- Flutter analyze/test passes; Android API 24 and latest emulator launch.
- First login requires connection; cached owner reopens offline; another owner cannot view the store.
- Drift restart preserves seed/settings; migration and FK checks pass.
- RLS smoke test proves anonymous and cross-owner access denied.

### Sprint 2 - Sync vertical slice and parcels

**Deliver**:

- Outbox, lease, cursors, retry classifier, RPC wrapper and remote operation/change ledger.
- Parcel create/edit/select/archive through local-first repository.
- Versioned push/pull and visible global/row synchronization status.
- Conflict screen with keep-local/keep-remote using parcel as first aggregate.
- Fault-injection test harness and pgTAP RLS/RPC suite.

**Validation gate**:

- Parcel can be created offline, survives restart and syncs exactly once.
- 100 operations with lost ACK/retry yield zero duplicates and no silent loss.
- Two clients editing one version preserve both snapshots and complete both resolution paths.
- Pull restart never advances cursor without committed local data.

### Sprint 3 - Map, sectors and crop assignments

**Deliver**:

- Google Maps rendering, key restrictions, legal attribution and foreground GPS.
- Local schematic/offline geometry view and optional connected place search.
- Deterministic polygon close/edit/undo, self-cross detection, area and containment.
- Sector create/edit with number uniqueness and irregular polygons.
- Crop catalog display, assignment/change history and active parcel propagation.

**Validation gate**:

- Valid polygons calculate expected fixture areas within documented tolerance.
- Invalid/open/self-crossed polygons and sectors outside parcel cannot save.
- Map-base outage still allows viewing saved geometry and GPS/manual coordinate flow.
- Crop change closes prior assignment without rewriting existing history.

### Sprint 4 - LABORES, soil, irrigation and weather

**Deliver**:

- User-facing module named exactly `LABORES` with common transaction flow.
- Generic labor types plus soil and irrigation specialized aggregates.
- Metric/scaled value objects and all range validations.
- Versioned irrigation rule service, recommendation audit and create-riego handoff.
- Weather proxy/cache as optional bounded adjustment.
- History foundation for parcel, sector, crop, type and date filters.

**Validation gate**:

- Soil/riego records save offline with their outbox atomically and survive restart.
- Twenty known irrigation cases reproduce exact liters/time and inputs offline.
- Missing/expired weather produces a labeled no-climate estimate, never a failure.
- No advanced evapotranspiration, IA result or provider calculation enters the formula.
- Agronomic rule seed has documented source and explicit owner/reviewer approval.

### Sprint 5 - Production, history, apiary and photos

**Deliver**:

- Production/cosecha with season relationships and future-comparison-ready queries.
- Complete historical filters and crop assignment changes.
- Apiary sector and inspection aggregate with all required fields.
- Camera/gallery intake, lost-data recovery, private local files, compression and metadata.
- Private Supabase Storage bucket, RLS and idempotent photo upload flow.

**Validation gate**:

- Crossed fixture filters return only matching rows in chronological order.
- Production stores positive metric quantities and retains sector/crop/season.
- Apiary inspection works offline and synchronizes atomically with photos.
- Interrupted/retried upload neither duplicates nor re-associates a photo.
- Owner A cannot list/read owner B Storage paths.

### Sprint 6 - Reminders, FCM, advisory AI and XLSX

**Deliver**:

- Offline reminder scheduling/reconciliation and contextual Android permission flow.
- Device token lifecycle and server-side FCM HTTP v1 with event dedupe.
- Gemini text advisory proxy, policy, privacy limits and UI disclaimer.
- `.xlsx` snapshot exporter with seven contract sheets and safe text handling.
- Provider quotas, cache, timeout, circuit breaker and secrets per environment.

**Validation gate**:

- Reminder created offline alerts locally and later synchronizes without double FCM alert.
- Denied notification permission preserves reminder and explains remediation.
- Gemini cannot accept photos/critical commands, cannot write data and is unavailable gracefully
  offline.
- Reference workbook opens in Excel and LibreOffice with exact sheet/row/relationship checks,
  accents, metrics and pending statuses.
- No privileged credential exists in APK, repo, logs or exported workbook.

### Sprint 7 - Hardening and release candidate

**Deliver**:

- WorkManager best-effort sync, lease concurrency and resume invalidation.
- Full migration rehearsal, backup/runbook for Storage metadata and objects.
- Accessibility, field usability, performance profiling and error-copy review.
- Security review of RLS/grants/functions/keys, provider terms and quota alerts.
- End-to-end acceptance matrix, offline soak and signed Android release candidate.

**Validation gate**:

- 24-hour offline test with three restarts retains 100 % of committed records.
- Recovery of 100 offline changes reaches ACK or explicit pending/error/conflict for every item.
- Dataset 20/200/10.000 meets P95 <2 s and startup <5 s on target device.
- All 54 FR, 11 NFR and 12 success criteria have passing evidence or a release blocker.
- Android API 24/latest, notification states, Doze/force-stop caveats and low-storage paths tested.
- Constitution, spec, data model and contracts show no unresolved contradiction.

## Recommended implementation order

1. Fix Flutter/Android/package compatibility and create reproducible local Supabase environment.
2. Establish IDs, clock, metric value objects, Drift schema/migrations and test fixtures.
3. Complete authentication/session boundaries and owner-specific local access.
4. Prove one full local-write/outbox/RPC/pull/conflict slice with parcels.
5. Add maps, sectors and crop assignments on top of that proven aggregate pattern.
6. Add `LABORES` and deterministic soil/riego rules before secondary modules.
7. Add history/production/apiary, then file-based photos.
8. Add reminders locally first, then FCM; add climate and Gemini only behind stable adapters.
9. Add XLSX after finalizing data queries and units.
10. Harden concurrency, performance, migrations, security and release evidence before expansion.

Do not build all screens before the sync vertical slice: that would multiply unverified persistence
and conflict behavior across every feature.

## Riesgos técnicos

| Risk | Likelihood/impact | Mitigation | Release evidence |
|---|---|---|---|
| Lost/duplicated offline writes | Medium/Critical | Atomic outbox, operation ledger, sequence pull, fault tests | 100-op and lost-ACK suites |
| Foreground/background race | Medium/High | Persisted lease, small batches, resume refresh | Forced WorkManager/concurrency tests |
| Drift/Supabase schema drift | Medium/High | Shared model review, migrations/snapshots, contract fixtures | Reset + migration CI |
| Incorrect irrigation advice | Medium/Critical | Integer math, versioned rules, capped weather, owner/agronomic review | 20 deterministic cases + approval |
| Invalid map geometry/area | Medium/High | Pure Dart validation, server PostGIS check, tolerance fixtures | Polygon/containment suite |
| No offline map tiles | High/Medium | Schematic local view and clear state; persist own geometry only | Tile outage usability test |
| Provider quota/terms change | Medium/Medium | Adapter interfaces, cache, alerts, release review | Staging quota/failure tests |
| Gemini unsafe/private output | Medium/High | Server proxy, minimal context, safety policy, paid production terms | Adversarial policy tests |
| FCM late/duplicate delivery | High/Medium | Local alarm primary, event dedupe, token hygiene | Offline/Doze/double-delivery tests |
| Photo loss or storage growth | Medium/High | Private durable copy, hash, compression, immutable path | Kill/retry/low-space tests |
| XLSX library regression | Medium/Medium | Version pin, contract fixture, Excel+LibreOffice | 10k-row open/row-count test |
| Unauthorized cross-owner data | Low/Critical | owner_id, RLS, grants, RPC-only mutation, private Storage | pgTAP adversarial suite |
| Overarchitecture slows MVP | Medium/Medium | Domain services only for critical rules; feature-first slices | Sprint review of unused abstractions |

## Phase validation policy

- A sprint is complete only when its validation gate has automated or reproducible manual evidence.
- Failed migration, RLS, sync-integrity or critical-rule tests block all later feature work.
- Provider sandbox success never substitutes offline/failure-path validation.
- Every UI feature demonstrates loading, empty, offline, saving, error and permission states that
  apply to it.
- Every remote table/function passes owner isolation and least-privilege tests.
- Every release compares artifacts against the current constitution and specification.
- The executable validation sequence is documented in [quickstart.md](quickstart.md).

## Complexity Tracking

No constitutional violation requires justification. Repository interfaces, outbox, versioned RPC,
PostGIS and four small Edge Functions exist only to meet explicit Offline First, geometry,
notification and secret-handling requirements; they do not add a second product, roles, ERP, IoT,
panel web or other excluded scope.
