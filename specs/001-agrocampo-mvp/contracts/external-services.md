# Contract: External Service Adapters

**Purpose**: Keep provider behavior, secrets and failures outside domain and presentation code.
Every adapter returns typed, sanitized results and supports deterministic fakes for tests.

## 1. Google Maps and location

### `MapRenderer`

Input is local WGS84 geometry: parcel polygon, sector polygons, selected vertices and camera target.
Output is visual interaction events: tap coordinate, selected vertex, camera position and provider
availability. The renderer does not calculate area, validate containment or own domain geometry.

### `LocationReader`

- Input: one foreground location request with user action.
- Success: latitude, longitude, accuracy meters and captured UTC time.
- Failure: permission denied, service disabled, timeout or unavailable.
- No background tracking and no automatic collection before a contextual permission request.

### `PlaceSearchGateway`

- Input: query of at least three characters, session ID and optional Chile bias.
- Output: provider place ID, display label and, only after selection, latitude/longitude.
- Requires connectivity and debounce; an unavailable response leaves manual/GPS positioning usable.
- Provider content is not persisted except selected provider ID and farmer-confirmed coordinates.

## 2. Weather proxy

The Flutter app calls an authenticated Supabase Edge Function, never WeatherAPI directly.

### Request

| Field | Rule |
|---|---|
| latitude/longitude | Valid WGS84, rounded server-side for cache key |
| requested_at | Diagnostic UTC timestamp |
| locale | `es` |
| units | Metric only |

### Response

| Field | Rule |
|---|---|
| `observed_at`, `fetched_at`, `expires_at` | UTC and explicit freshness |
| `temperature_c` | Celsius |
| `humidity_pct` | 0-100 |
| `precipitation_mm` | Non-negative |
| `forecast` | Up to provider free-plan horizon |
| `provider`, `attribution` | Required display metadata |
| `stale` | True only for display fallback; stale data cannot adjust a new calculation |

The function validates JWT, coordinates and quota; caches according to provider terms; stores the
provider key in environment secrets; and does not log the full upstream URL. Timeout, quota and
provider failure map to `unavailable`, which never blocks the local calculator.

## 3. Gemini advisory proxy

The Flutter app calls an authenticated Edge Function. It does not access a Gemini key directly.

### Request

| Field | Rule |
|---|---|
| `question` | Plain text, configured character limit |
| `crop_context` | Optional crop name only |
| `sector_context` | Optional farmer-selected, non-secret summary |
| `measurements` | Optional selected values with unit/date; no full history |
| `request_id` | UUID for tracing/rate limit, not agricultural mutation |

Photos, exact coordinates, credentials and full history are rejected by contract in the MVP.

### Response

| Field | Rule |
|---|---|
| `advice_text` | Spanish, consultative, bounded length |
| `disclaimer` | Always present |
| `uncertainty` | Explicit when information is insufficient |
| `model_id` | Stable configured model used |
| `safety_status` | allowed/blocked |

The system instruction forbids diagnostic claims, pesticide dosage, physical actions, data writes,
surface/volume/time calculations and replacement of professional judgment. Offline returns
`unavailable`; requests are not queued indefinitely. Logs retain status, latency, model and token
counts, not full prompts or responses.

## 4. Notification delivery

### Local reminder contract

Drift is authoritative. Each scheduled reminder maps to a stable Android notification ID. Creation,
edit, completion or cancellation updates Drift first, then reconciles the OS schedule. Application
start, boot/restart path and timezone change re-run reconciliation. Permission denial retains the
record and exposes remediation.

### FCM remote contract

- Device registration syncs `device_id`, FCM token and freshness.
- Only a trusted Edge Function sends HTTP v1 messages.
- Payload contains `event_id`, `reminder_id`, notification type and route; it excludes farm details.
- Client deduplicates `event_id` and loads content from Drift.
- Invalid tokens are disabled. Token refresh updates the same device registration.
- FCM is best-effort and never replaces the local alarm or marks a reminder completed.

## 5. Photo selection and storage

### Local intake

- Source is camera or gallery through `image_picker`.
- File is copied from temporary storage to a UUID-named private app path before success is shown.
- Metadata includes MIME, size, SHA-256, source, capture time and one domain target.
- The app recovers Android lost-picker results during bootstrap.
- Unsupported MIME, insufficient space or failed copy returns an actionable error and no DB row.

### Remote storage

- Private bucket: `agricultural-photos`.
- Immutable path: `owner_id/photo_id/sha256.extension`.
- Standard upload for compressed files at or below configured 6 MB limit; `upsert=false`.
- An existing object is treated as retry success only when owner, path, hash and metadata match.
- RLS permits owner insert/select only; mobile update/delete is not granted during MVP.

## 6. Secret and environment contract

| Secret/config | Mobile | Trusted server | Control |
|---|---:|---:|---|
| Supabase publishable key | yes | optional | RLS + environment separation |
| Supabase service/secret key | never | yes | Secret store; least privilege |
| Google Maps Android key | yes | no | Package/SHA-1/API restrictions |
| Place web-service key | never | yes | Quota/API restrictions |
| WeatherAPI key | never | yes | Edge Function secret |
| Gemini credential | never | yes | Edge Function secret and spend cap |
| FCM sender credential | never | yes | HTTP v1 service identity |

Development, staging and production use separate projects/keys. No secret enters source control,
logs, crash reports, XLSX exports or user-visible error messages.
