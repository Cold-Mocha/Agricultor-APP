# Contract: Frontend ↔ Backend Public API for 003

## Boundary

Production frontend code may import backend symbols only through:

```dart
import 'package:agrocampo_backend/agrocampo_backend.dart';
```

`agrocampo_backend.dart` remains an allowlist of module `*_api.dart` files. It may expose immutable
DTOs, sealed outcomes, facade providers and domain enums needed for presentation. It must not expose
Drift rows/tables/DAOs, repositories, outbox payloads, sync codecs, `SupabaseClient`, gateways,
filesystem paths or provider-specific responses.

Backend code must not import `package:agrocampo/` or Flutter visual widgets.

## Responsibility Matrix

| Responsibility | Frontend | Backend |
|---|---:|---:|
| Layout, navigation, accessibility, copy and visual state | MUST | MUST NOT |
| Form draft before confirmation | MUST | MAY persist only inherited draft behavior |
| Context/category/operation validation | reflect result | MUST |
| Parsing canonical values and field validation | MAY prevalidate for UX | MUST |
| Domain calculation | MUST NOT | MUST |
| Drift write/read and transaction | MUST NOT | MUST |
| Outbox/sync/RLS/gateway | MUST NOT | MUST |
| Present provider degradation | MUST | return typed state |

## Common Public Types

```text
CommandId(value)
FieldError(fieldId, code, message)
DomainFailure(operation, category, code, message)
StorageFailure(code, retryable)
BackupState(pending|syncing|backedUp|error|conflict)

SaveOutcome<T> =
  savedLocal(value: T, backupState: pending)
  | validationFailed(fieldErrors, preservedInput)
  | domainRejected(failure, preservedInput)
  | staleVersion(currentVersion, preservedInput)
  | storageFailed(failure, preservedInput)
```

- `commandId` is stable for one confirmation and prevents double-submit.
- A local save never returns `backedUp`.
- Failures use stable codes plus Spanish presentation-safe messages.
- The backend returns the preserved typed input; it does not clear a valid draft on failure.

## Module APIs to Extend

| API | Public surface required by 003 |
|---|---|
| `agricultural_context_api.dart` | bound Sector context, stable category, capabilities and validation result |
| `territory_api.dart` | create/edit parcel/Sector geometry, immutable category and typed outcomes |
| `crop_cycles_api.dart` | category-aware assignment/rotation commands and effective projections |
| `labors_api.dart` | discriminated labor inputs/details and correction outcomes |
| `soil_api.dart` | measurement input with units and detail |
| `irrigation_api.dart` | performed input, applicability, preview and snapshot summary |
| `production_api.dart` | complete harvest input/detail |
| `apiary_api.dart` | task-specific inputs/detail |
| `media_api.dart` | validated attachment target and result |
| `history_api.dart` | expanded filter, summary, detail and sync state |

## Parallel Development Rule

Backend tests instantiate facades with in-memory/file-backed providers without importing frontend.
Frontend tests override only exported providers/interfaces with doubles. Integration tests use the
real `AgroCampoBackend.initialize()`. A breaking contract change requires updating this document,
both consumers and contract tests before merge.

## Architecture Gate

`dart run tool/check_architecture.dart` plus frontend boundary tests must pass. No 003 artifact may
introduce an HTTP API between the packages or a second composition root.
