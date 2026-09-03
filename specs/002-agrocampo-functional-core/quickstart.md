# Quickstart and Validation Guide: AgroCampo Functional Core - Módulo 002

This guide defines the implementation/verification order for 002. It does not authorize scope beyond [spec.md](./spec.md) or replace the Módulo 001 quickstart for unaffected capabilities.

## 1. Required Toolchain

- Flutter 3.47.0 / Dart 3.13.x.
- Android SDK API 36, minimum API 24, Java 17.
- Docker and Supabase CLI for local PostgreSQL/Auth/Functions/pgTAP.
- An Android emulator/device with Google APIs; at least one real device for biometrics, GPS, notification/reboot checks.
- Node.js for existing prototype regression checks.
- `local_auth` 3.0.2 for the optional biometric gateway; do not add the Android implementation package separately unless its APIs are imported directly.

Verify local tools before implementation:

```powershell
flutter --version
dart --version
flutter doctor -v
supabase --version
docker info
node --version
```

## 2. Environment

Client/build values:

- `SUPABASE_URL`
- Supabase publishable/anon key under the existing configuration name

OpenStreetMap needs no client or server API key. The map must use the real application ID as its
user agent and retain visible attribution.

Server-only Supabase Function configuration/secrets:

- `OPEN_METEO_DEFAULT_LATITUDE`, `OPEN_METEO_DEFAULT_LONGITUDE`
- optional `OPEN_METEO_FORECAST_URL` for the contracted customer endpoint
- Gemini/AgroIA provider key and pinned model/policy configuration
- any service-role/FCM server credential

Do not add server secrets to Flutter `.env`, Dart constants, Gradle source or test snapshots. Use separate dev/staging/prod resources.

## 3. First Implementation Gate: Reproduce Existing Defects

Before feature expansion, add failing regression evidence for:

1. restoring local access with owner ID but no valid refresh/session material;
2. logout followed by biometric/local reopen attempt;
3. a second sector causing a single-sector screen to fail or become ambiguous;
4. `sync_push` receiving a non-parcel operation and returning an ACK without applying its business row;
5. pull receiving a non-parcel or invalid JSON payload and advancing cursor without applying it;
6. app interruption while an outbox row is `sending`;
7. file-backed local save surviving close/reopen.

The biometric implementation gate also verifies that `MainActivity` uses `FlutterFragmentActivity` without breaking the XLSX MethodChannel, `USE_BIOMETRIC` is declared and Android themes meet the plugin's AppCompat requirement.

Implementation must make these tests pass before enabling another sync entity.

## 4. Drift v9 Fixture and Migration Gate

1. Export a real schema snapshot with approved Drift tooling.
2. Build a v9 fixture containing rows in all 24 existing tables, multiple owners/parcels/sectors, rotations, labors, irrigation, production, pending outbox and conflicts.
3. Record counts, IDs, geometry vertices and representative value hashes.
4. Upgrade to v10.
5. Close and reopen the file.
6. Verify imported seasons, assignment links, historical context and unchanged old values.
7. Inject a migration validation failure and verify rollback leaves v9 usable.

Recommended commands after migration code exists:

```powershell
dart run build_runner build --delete-conflicting-outputs
flutter test test/core/database
flutter test test/core/database/migrations
```

The current custom `drift_schema_v9.json` table manifest is not sufficient evidence by itself.

## 5. Supabase Local Gate

Start/reset the local stack only after reviewing that reset targets the local development instance:

```powershell
supabase start
supabase db reset
supabase test db
```

Required pgTAP behaviors:

- migrations 0001 through the new additive 002 migration apply in order;
- RLS denies anonymous/cross-owner access and permits the owner;
- each enabled aggregate applies atomically and appends one change;
- unsupported/invalid operations receive no success ACK;
- duplicate same ID/hash is idempotent, mismatched hash is rejected;
- base-version divergence creates a conflict without overwriting canonical row;
- tombstone pulls and cannot resurrect;
- cursor order/pagination are monotonic;
- new season/config tables enforce ownership/FKs/checks.

Do not enable an aggregate in the Flutter sync registry until these tests and the matching client codec tests pass.

## 6. Incremental Sync Validation

For each activation wave:

1. Save aggregate offline into file-backed Drift.
2. Confirm domain row and one outbox row commit together.
3. Close/reopen app/database.
4. Reconnect to local Supabase.
5. Lose the first ACK after server commit.
6. Retry the same operation ID/hash.
7. Verify one business row, duplicate receipt result and local `synced` only after response.
8. Pull into a second clean device/database and verify the same data.
9. Exercise update, conflict, keep-local/keep-remote and tombstone where applicable.

Activation waves:

```text
parcel
→ sector + agriculturalSeason + sectorCropAssignment + customCrop
→ labor (harvest/irrigation aggregate) + irrigationConfig
→ reminder
```

## 7. Vertical Flow Checkpoints

### Access/session

- First login online.
- App close/reopen with valid session.
- Offline reopen of previously valid session.
- Enable/disable biometric; success/cancel/unavailable.
- Logout with pending operations; data hidden, token/unlock removed, data retained.
- Login same owner resumes; different owner cannot see prior data.

### Territory/context

- Create three parcels and ten sectors each offline.
- Switch active parcel and verify map/list/forms/history all switch.
- Draw valid free polygon; reject duplicate points/self-cross/zero area/outside parcel.
- Navigate in view mode without mutation.
- Edit draft, cancel unchanged; edit+confirm changes once.
- Disable map/network/GPS permission and use local geometry/list/manual drawing.

### Seasons/crops

- Create planned/active/closed seasons.
- Use official and custom crops.
- Rotate at effective date and exchange crops between two sectors atomically.
- Reopen/sync and verify old labor context unchanged.
- Archive referenced custom crop and keep historical label.

### Labors/production

- Offline save each 002 labor type with type-relevant fields.
- Validate “other” description and invalid quantity/unit paths.
- Save harvest once and verify one timeline event with production.
- Change date across assignment boundary; require warning/correction.

### Drip irrigation

- Save permanent config, close/reopen.
- Verify unavailable rule state before agronomic approval.
- Once approved vectors exist, run all vectors twice and compare exact integers.
- Calculate without weather and with a normalized fresh adjustment.
- Record performed irrigation; update current config; old event remains unchanged.

### History

- Two seasons, two sectors, rotations, labor, irrigation and harvest.
- Filter by season/crop/type/date.
- Verify no cross-sector rows and correct stable order.
- Verify pending/error/conflict is visible without waiting for network.
- Run scale fixture: 20 parcels, 200 sectors, 10.000 events; p95 common query <2 s.

### Reminder/weather/AgroIA

- Reminder offline, permission allowed/denied, edit, complete, cancel and reboot reconciliation.
- Weather fresh/stale/offline/missing timestamp, alert opt-in and dedup.
- Capture AgroIA request: only user text/technical metadata; no private context.
- Offline/error retry keeps one user message and one response.

## 8. Test Commands

### Matrices cuantitativas obligatorias

| Criterio | Matriz ejecutable | Prueba principal |
|---|---|---|
| SC-003 | 3 parcelas × 10 sectores; contexto y FK exactos | `integration_test/multi_context_e2e_test.dart` |
| SC-004 | 30 geometrías confirmadas × 5 reaperturas | `test/features/map/territory_persistence_flow_test.dart` |
| SC-005 | 20 rotaciones/intercambios con eventos antes y después | `test/features/crops/crop_rotation_test.dart` |
| SC-007/008 | 100 mutaciones, 3 cierres/reaperturas, ACK/conflicto/tombstone | `integration_test/functional_core_offline_restart_test.dart` y `integration_test/sync_conflict_tombstone_e2e_test.dart` |
| SC-009 | 20 vectores agronómicos aprobados o estado explícito no disponible | `test/features/irrigation/irrigation_rule_approval_test.dart` |
| SC-012 | 30 recordatorios, 3 reinicios lógicos y reconciliación Android | `integration_test/reminder_restart_flow_test.dart` y `integration_test/android_platform_flow_test.dart` |
| SC-015 | 20 parcelas, 200 sectores, 10.000 eventos y p95 < 2 s | `test/performance/functional_core_performance_test.dart` |
| SC-016 | Inventario completo de rutas/pantallas 002, semántica, estados, teléfono estrecho/grande y landscape | pruebas widget/golden por feature y `integration_test/android_platform_flow_test.dart` |

Las 24 horas de SC-007 se representan mediante persistencia durable y reaperturas controladas, sin
esperas literales en CI. Un ensayo prolongado de campo puede complementar esta matriz, pero no
reemplaza las afirmaciones de cero pérdida, outbox durable y ausencia de falso ACK.

After implementation, run targeted tests during each phase, then the full suite:

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --no-pub
flutter test
flutter test integration_test
```

Run Supabase tests separately:

```powershell
supabase test db
deno test supabase/functions/weather-proxy/tests
deno test supabase/functions/agro-ai/tests
```

Run Android integration on configured emulator/device as defined by the project runner. Native/platform-view checks must include real device evidence where emulator behavior is insufficient.

## 9. Existing Prototype Regression Checks

Documentation or Flutter work must not silently break prototype evidence. From repository root:

```powershell
node agrocampo-acceptance.test.js
node -e "const fs=require('fs'); const html=fs.readFileSync('agrocampo-highfi.html','utf8'); const scripts=[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1]); for (const script of scripts) new Function(script); console.log('Embedded JavaScript syntax OK:', scripts.length);"
```

The static HTML remains evidence only; passing these checks does not prove Android functionality.

## 10. Scope and Constitution Review

Before accepting each phase, verify:

- no full rewrite or purely aesthetic refactor entered the work;
- every claimed flow includes UI, domain validation, local persistence, reopen and sync/degradation;
- no direct remote read became UI authority;
- no operation is marked synced before real ACK;
- no geometry changes outside explicit edit;
- no rotation changes history;
- no AI performs a critical calculation/action or receives private context automatically;
- no roles, organizations, web/admin, IoT, fertility calculation or advanced irrigation were added;
- `master.md` navigation, active context, offline/sync states and accessibility are maintained.

## 11. Release Evidence

The final 002 acceptance bundle should contain:

- toolchain/environment version record without secrets;
- Drift v9→v10 migration report and row/hash comparison;
- pgTAP/RLS/sync protocol results;
- 24-hour offline/three restart/100 operation report;
- irrigation approval record and 20 exact vectors, or explicit disabled-recommendation evidence;
- multi-parcel/sector/rotation/history screen recordings or screenshots;
- Android biometric/GPS/notification/reboot results;
- performance measurements;
- regression results for selected 001 capabilities and prototype checks.

## 12. Ready for Task Generation

This design is ready for `$speckit-tasks`. Task generation must preserve the phase order in [plan.md](./plan.md), trace tasks to 002 requirements and avoid turning non-gate 001 capabilities into a second implementation scope.
