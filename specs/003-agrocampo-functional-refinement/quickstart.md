# Quickstart and Vertical Validation: AgroCampo Functional Refinement - Módulo 003

## Purpose

Este documento define los gates ejecutables para demostrar 003 después de su implementación. No
convierte las pruebas del HTML en evidencia de la aplicación Flutter y no permite declarar listo un
flujo por una pantalla o repositorio aislado.

User Stories 1–7 deben superar todos los gates aplicables. P1/P2 sólo determinan el orden. La
indisponibilidad de un proveedor externo no bloquea los flujos locales; sí debe superar su gate de
degradación/privacidad cuando la integración está configurada.

## 1. Prerequisites

- Flutter 3.47.x / Dart 3.13.x y Android SDK API 24–36.
- Node para regresión del prototipo.
- Deno para Edge Function tests.
- Supabase CLI y Docker para pgTAP/RPC/RLS local. En la estación auditada, `supabase` no estaba en
  `PATH`; resolverlo antes de G10.
- Emulador/dispositivo Android API 24+ para GPS, lifecycle y background.

Check:

```powershell
flutter --version
dart --version
flutter doctor -v
node --version
deno --version
supabase --version
```

Valores públicos del APK: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` y, opcionalmente,
`MAP_TILE_URL`/centro inicial. Secretos y coordenadas fallback de proveedor permanecen en Supabase:
`GEMINI_API_KEY`, `GEMINI_MODEL`, `OPEN_METEO_FORECAST_URL` y
`OPEN_METEO_DEFAULT_LATITUDE/LONGITUDE`. Nunca imprimirlos en evidencia.

## 2. G0 — Baseline and Architecture

Desde la raíz:

```powershell
flutter pub get
dart pub workspace list
dart run tool/check_architecture.dart
```

Pass:

- workspace contiene únicamente `frontend` y `backend`;
- frontend productivo sólo importa `package:agrocampo_backend/agrocampo_backend.dart`;
- backend no importa frontend ni contiene UI;
- la baseline mantiene T016, T096, T115 y T118 bajo 002; cada una sólo bloquea 003 si se documenta
  una dependencia directa de código o comportamiento modificado por este incremento;
- `AppDatabase.schemaVersion` y `migration_policy.dart` coinciden antes de iniciar v11.

## 3. G1 — Preserving Migration and Offline Reopen

```powershell
Set-Location backend
dart run build_runner build
flutter test test/platform/database/migrations/functional_refinement_v11_test.dart
flutter test test/integration/functional_refinement_offline_restart_scenario.dart
Set-Location ..
```

Fixture required: v10 populated with each affected aggregate, the representative
sync/outbox/conflict partitions and legacy partial context.

Pass:

- all prior IDs, counts, geometries, assignments, labors, soil, irrigation, estimates, production,
  apiary, photos, outbox, cursors and conflicts are preserved;
- new category snapshots, roots and links are deterministic and legacy unknowns stay explicit;
- the representative matrix of mixed local confirmations survives file-backed reopenings at each
  critical point and controlled clock advancement;
- no migration test uses a reset of the user database.

## 4. G2 — Vegetable / Apiary Compatibility

```powershell
Set-Location backend
flutter test test/modules/agricultural_context
flutter test test/integration/productive_domain_compatibility_scenario.dart
Set-Location ..
```

Run every incompatible cell in the operation × category matrix through facade command, alternate
entry point, retry and pull/RPC where applicable. Include irrigation, fertilization, agricultural
phytosanitary and soil against an apiary; include apiary work against a crop Sector and unknown
legacy category.

Pass: every attempt returns the expected typed rejection and leaves root, specialization, outbox and
current data unchanged. Allowed operations persist normally. Dart/SQL parity is completed again in
G10.

## 5. G3 — Territory and Geometry

```powershell
Set-Location backend
flutter test test/shared/kernel/polygon_geometry_test.dart
flutter test test/modules/territory
Set-Location ..\frontend
flutter test test/modules/territory/territory_map_page_test.dart
flutter test integration_test/territory_flow_test.dart
Set-Location ..
```

Demonstrate parcel and Sector draw, explicit polygon close, review, edit mode, vertex movement,
undo/remove, confirm, cancel, stale version and reopening. Exercise insufficient/duplicate/out-of-
range points, open/self-crossing/zero-area shapes and Sector outside parcel.

Pass: representative valid and boundary shapes retain their normalized confirmed vertices after a
real reopen; cancel and every declared invalid partition leave the previous geometry intact. With
tiles/GPS unavailable, local polygons and textual Sector list remain usable.

## 6. G4 — Registrar and Complete Details

```powershell
Set-Location backend
flutter test test/modules/labors
flutter test test/modules/soil
flutter test test/modules/production
Set-Location ..\frontend
flutter test test/modules/labors
flutter test integration_test/labors_production_flow_test.dart
Set-Location ..
```

Dataset: representative matrix covering Suelo, Riego, Fertilización, Control de Enfermedades y
Plagas, Cultivo, Cosecha, Apicultura, Otra, plus inherited Siembra/Poda where applicable. Include
required/optional, null/zero, invalid numeric boundaries, supported units, context change while form
is open, correction and storage failure.

Pass: every confirmed field/unit/omission/context round-trips through detail and restart; invalid
input retains the draft and writes nothing; fitosanitario generates no chemical advice; Cosecha
appears once.

## 7. G5 — Crops, Seasons and Rotation

```powershell
Set-Location backend
flutter test test/modules/crop_cycles
flutter test test/integration/multi_context_scenario.dart
Set-Location ..\frontend
flutter test integration_test/seasons_crops_flow_test.dart
Set-Location ..
```

Cover current, future, boundary-date, overlapping, cancelled and archived assignments across
representative seasons. Include an attempted crop assignment to apiary and verify that rotation
never changes `sectors.kind`.

Pass: future rotation does not activate early, overlaps reject without mutation, events before/after
retain original assignment/category and archived items remain readable but absent from new choices.

## 8. G6 — Irrigation

```powershell
Set-Location backend
flutter test test/modules/irrigation
Set-Location ..\frontend
flutter test test/modules/irrigation
flutter test integration_test/irrigation_calculation_flow_test.dart
Set-Location ..
```

Pass:

- manual records for inherited methods preserve method, date, duration, caudal/unit, pressure when
  applicable, volume, context and sync state after restart;
- the basic drip estimate reproduces
  `roundHalfUp(totalFlowMlPerMinute × durationSeconds / 60)` for representative normal, conversion,
  boundary and rounding cases and is labelled as mathematical, not agronomic;
- changing any input invalidates preview; cancel leaves confirmed state untouched;
- apiary requests reject;
- every advanced request returns `crop_rule_unavailable` because no advanced formula is defined,
  while manual save and the basic estimate remain available;
- no test fabricates a production rule, coefficient, stage or texture.

No reviewer, signature, external approval or fixed vector count is a gate. A future advanced formula
requires its own machine-readable version, source, applicability, tolerances and automated reference
fixtures before it can change the unavailable state.

## 9. G7 — Fertilization

```powershell
Set-Location backend
flutter test test/modules/labors/fertilization_details_test.dart
flutter test test/integration/fertilization_flow_scenario.dart
Set-Location ..\frontend
flutter test test/modules/labors/fertilization_form_test.dart
Set-Location ..
```

Run the method × field-state matrix for Manual, Foliar and Fertirriego, with optional data omitted,
present and later corrected. Include invalid method fields, apiary context and related irrigation
absent/stale.

Pass: every method keeps its own fields, optional values remain null, correction preserves prior
version/context, optional irrigation link never mutates the riego and no dose is invented.

## 10. G8 — Specialized Apiary

```powershell
Set-Location backend
flutter test test/modules/apiary
flutter test test/integration/apiary_functional_refinement_scenario.dart
Set-Location ..\frontend
flutter test test/modules/apiary
flutter test integration_test/apiary_flow_test.dart
Set-Location ..
```

Run each task family across applicable field states: inspection, feeding, health, harvest, super
placement and other. Include task-specific omissions, responsible descriptive text, photos, reopen,
correction and sync failure.

Pass: all fields/photos reappear in the correct unit/history, irrelevant fields are not required,
responsible does not create identity and vegetable forms are absent/rejected.

## 11. G9 — History

```powershell
Set-Location backend
flutter test test/modules/history
flutter test test/performance/functional_core_performance_test.dart
Set-Location ..\frontend
flutter test test/modules/history
flutter test integration_test/history_production_flow_test.dart
Set-Location ..
```

Pass:

- filters work for parcel, Sector, category, season, crop, type and date range;
- detail returns all typed values/units/context/correction/sync state;
- labor compound events (soil, riego, harvest, apiary) occur exactly once;
- ordering/pagination is stable;
- a named, seeded and versioned representative load profile returns correct results and records a
  p95 below 2 seconds on the documented Android reference environment.

## 12. G10 — Supabase, Outbox and Exact-Once Backup

The following reset is permitted only against the disposable local Supabase stack:

```powershell
supabase --workdir backend start
supabase --workdir backend db reset
supabase --workdir backend test db

Set-Location backend
flutter test test/platform/sync
flutter test test/integration/sync_functional_refinement_scenario.dart
Set-Location ..
```

Pass:

- migrations 0001–0020 apply append-only and RLS isolates anonymous/owner A/owner B;
- Dart and SQL compatibility matrices match;
- every enabled payload v1/v2 has codec+handler tests before registry activation;
- unsupported/invalid/lote-vacío never receives success ACK;
- after lost ACK, same ID/hash returns duplicate without a second domain row;
- the representative aggregate/specialization and fault matrix, with reopen at every critical sync
  state, ends exactly once as backed up or visibly pending/error/conflict;
- pull failure rolls back both changes and cursor; conflicts preserve both versions until farmer
  choice.

## 13. G11 — External Integration Isolation and Privacy

```powershell
deno test --allow-env backend/supabase/functions/weather-proxy/tests
deno test --allow-env backend/supabase/functions/agro-ai/tests

Set-Location frontend
flutter test integration_test/weather_alert_flow_test.dart
flutter test integration_test/agro_ai_privacy_flow_test.dart
flutter test integration_test/android_platform_flow_test.dart
Set-Location ..
```

Simulate timeout, offline, malformed response, missing configuration and permission denial for map,
GPS, weather, AgroIA and Supabase.

Pass: unrelated local flows remain available and communicate limitation/recovery. Capture each
generated AgroIA request partition: keys are limited to message ID, user text, locale and policy
metadata; none contains parcel, Sector, crop, history, irrigation, production or photo data; no response mutates data or
performs a critical calculation.

## 14. G12 — Prototype Traceability and Automated UX Flow

Review PF-01..PF-30 in [plan.md](./plan.md) against `jerarquía 01.md` and `master.md`. Each ID must
have exactly one result: pass as completed/preserved, or confirmed out of scope. The static HTML is
evidence/regression only:

```powershell
node agrocampo-acceptance.test.js
node -e "const fs=require('fs'); const html=fs.readFileSync('agrocampo-highfi.html','utf8'); const scripts=[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1]); for (const script of scripts) new Function(script); console.log('Embedded JavaScript syntax OK:', scripts.length);"
```

Automated widget/integration/E2E checks must:

- prove SC-004 by showing parcel, Sector, category, crop and season when applicable before save and
  by blocking absent, ambiguous or incompatible context while preserving the draft;
- prove SC-014 by entering through public navigation and completing a representative general labor,
  soil, irrigation, fertilization and apiary inspection through local confirmation, detail,
  history and reopen.

A later usability session MAY provide product feedback, but is not a gate for 003 and does not
replace automated evidence.

## 15. Full Static Verification

```powershell
Set-Location backend
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test
Set-Location ..\frontend
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --no-pub
flutter test
flutter test integration_test
flutter build apk --debug
Set-Location ..
```

## 16. Release Decision

Record a matrix for SC-001..SC-018, FR-001..FR-087, PF-01..PF-30 and gates G0..G12. 003 is complete
only when:

1. G0–G10 and G12 pass;
2. G11 passes for every configured integration and proves degradation when unavailable;
3. all applicable User Stories 1–7 criteria pass;
4. no source secret, data reset, hidden category fallback, duplicate history event, unapproved
   recommendation or private AgroIA context remains.
