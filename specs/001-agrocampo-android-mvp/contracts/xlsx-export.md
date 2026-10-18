# Contract: AgroCampo XLSX Export

**Format version**: `agrocampo_export_v1`  
**Source**: one consistent Drift read snapshot  
**Availability**: fully offline

## 1. Invariants

- Export never requires Supabase or another external service.
- It contains the records available on the device at snapshot start.
- Pending/error/conflict states are represented; export does not imply remote backup.
- IDs and FKs remain text so relationships are unambiguous.
- Dates, units and decimal precision are explicit and locale-independent in storage.
- Workbook contains data only; no formulas, macros, remote links or embedded photographs.
- User-facing generation/progress/error UI MUST **Implementar según master.md**.

## 2. Workbook metadata

Sheet `Metadatos` contains:

| Key | Value |
|---|---|
| `format_version` | `agrocampo_export_v1` |
| `generated_at` | ISO-8601 timestamp with offset |
| `owner_id` | UUID as text |
| `app_version` | Installed app version |
| `local_schema_version` | Drift schema version |
| `snapshot_status` | completed only after validation |
| `record_counts` | Count per sheet |
| `contains_pending_records` | yes/no |
| `units_policy` | metric |

No password, token, provider key, signed URL or exact local file path is exported.

## 3. Required sheets

| Sheet | Minimum columns |
|---|---|
| `Parcelas` | `parcel_id`, nombre, descripción, ubicación, superficie, estado, fechas, `sync_status` |
| `Sectores` | `sector_id`, `parcel_id`, número, nombre, tipo, forma, superficie, estado, `sync_status` |
| `Cultivos` | `crop_id`, propietario cuando aplique, origen oficial/personalizado, código, nombre, categoría, información propia y versión de contenido |
| `Temporadas` | `season_id`, `parcel_id`, nombre, inicio, fin, estado, `sync_status` |
| `Asignaciones` | `assignment_id`, `sector_id`, `crop_id`, `season_id`, estado vigente/planificado/finalizado/cancelado, desde, hasta, `sync_status` |
| `LABORES` | `labor_id`, `parcel_id`, `sector_id`, `season_id`, `assignment_id`, tipo, fecha, estado, revisión, observaciones, `sync_status` |
| `Suelo` | `labor_id`, indicadores, columnas de unidad y `sync_status` |
| `Riegos` | `labor_id`, tipo de riego, tipo de suelo, plantas, caudal/unidad, duración, litros, clima usado, regla/versión de algoritmo, limitaciones, `sync_status` |
| `Producción` | `labor_id`, cantidad, unidad, calidad y `sync_status` |

Apicultura, fotografías y recordatorios may be included in separate sheets only if required by the approved export capability when tasks are generated; they cannot replace any minimum sheet above. Photographs export metadata/relationship only, never image bytes or signed URLs.

## 4. Representation rules

- UUIDs, sector numbers that could be reformatted and relationship keys are text cells.
- Agricultural dates use ISO calendar form; timestamps include UTC offset.
- Numeric value and unit use separate columns.
- Missing measurement is blank; measured zero is numeric zero.
- Boolean values use a stable machine representation documented in metadata.
- Text starting with `=`, `+`, `-` or `@` is forced to text to prevent formula injection.
- Control characters invalid in OOXML are removed/rejected with a recorded export error.
- Deleted/archived rows remain when required for historical relationships and carry state columns.
- A row in conflict identifies conflict state but exports only the visible local candidate; conflict metadata remains in the sync sheet if that optional sheet is approved.

## 5. Generation flow

1. Validate owner session and open owner-scoped database.
2. Begin consistent read snapshot and collect version/count metadata.
3. Read each dataset in deterministic ID/date order.
4. Generate workbook outside the UI isolate through `WorkbookExporter`.
5. Save to an app-private temporary path.
6. Reopen and validate OOXML structure, required sheets, headers, row counts and FK references.
7. Ask the user for destination through Android Storage Access Framework `ACTION_CREATE_DOCUMENT`.
8. Copy atomically when possible; confirm only after destination write completes.
9. Delete temporary file on success, cancellation or failure.

Cancellation creates no export domain row and is not an error. A partial/invalid destination file is never presented as completed.

## 6. Adapter isolation

`WorkbookExporter` accepts a provider-neutral export snapshot and returns validated bytes/path plus diagnostics. No feature imports `excel_community` directly. The package version is pinned; an upgrade must pass the same workbook contract tests before merge.

## 7. Required tests

- Opens without repair warning in current Excel and LibreOffice reference versions.
- Exact sheet/header version and all minimum sheets present.
- 100% row counts match the Drift snapshot.
- Every FK resolves within exported sheets or is documented as intentionally external.
- Pending, error, conflict, archived and synced rows are distinguishable.
- Accents/ñ, multiline notes, dates, units, decimals, null vs zero and formula-injection strings.
- 10,000-record reference workload on a low-memory Android emulator without UI jank.
- Offline generation, user cancellation, no-space, destination failure and app process interruption.
- Temporary files removed and no secret/local paths present.

## 8. Acceptance

AC-004, AC-010 and SC-010 pass when the validated workbook opens, contains every minimum record and relationship from the snapshot exactly once, and truthfully reports synchronization state.
