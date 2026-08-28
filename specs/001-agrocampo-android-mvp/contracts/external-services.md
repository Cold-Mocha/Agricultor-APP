# Contract: External Services and Platform Adapters

**Scope**: Maps/Places/GPS, weather, local notifications/FCM, Gemini, camera/gallery and Supabase Storage.  
**Rule**: external availability never changes the local source of truth.

## 1. Common adapter boundary

Every provider/plugin is hidden behind a domain-facing adapter. Presentation receives normalized domain values and typed failures, not SDK objects, provider widgets or raw responses.

Each operation defines:

- input schema and unit;
- output DTO and provenance;
- timeout/cancellation behavior;
- permission/auth precondition;
- transient vs permanent failure codes;
- cache/retention policy;
- offline fallback;
- secret location and logging policy.

Screens render loading, unavailable, stale, denied, error and recovery states exclusively according to `master.md`.

## 2. Maps, Places and GPS

### Selected services

- Google Maps Flutter for map and polygon rendering.
- Places SDK for Android (New) for connected location search through a small platform adapter.
- `geolocator` for foreground device location.

### Domain DTOs

`LocationFix` contains latitude, longitude, horizontal accuracy, capture time and source. `PolygonGeometry` contains shape, ordered WGS84 vertices, area, algorithm version and validation result. Search result contains provider place ID, display label and coordinate only for fields permitted by provider policy.

### Rules

- Maps renders geometry; it does not own it.
- Search moves camera/proposes location. Only explicit farmer confirmation changes parcel data.
- GPS permission is requested in context; denied/unavailable retains manual drawing.
- No background location.
- No custom caching, prefetch or offline storage of Google tiles/snapshots.
- Persist only provider fields allowed by Places policy; session token/debounce and field minimization apply.
- Google key is separate by environment and restricted by Android package, signing certificate and enabled APIs.

### Offline/failure behavior

Local geometries, area, sector list and editing data remain available. A local schematic/canvas and textual list provide map-equivalent access. Search and base tiles alone become unavailable. Presentation MUST **Implementar según master.md**.

### Tests

Valid/invalid/self-crossing/contained polygons, area fixtures, GPS denied/approximate/timeout, Places empty/429/error, missing tiles, process restart, TalkBack and physical-device platform view.

## 3. Weather

### Selected topology

Flutter calls authenticated Supabase Edge Function `weather-proxy` by `parcelId`. The function validates JWT/owner, obtains the parcel centroid server-side and queries WeatherAPI. It is not an open coordinate proxy.

### Normalized response

| Field | Rule |
|---|---|
| `provider` | Stable provider code. |
| `observedAt`, `fetchedAt`, `expiresAt` | Required timestamps. |
| `temperatureC` | Metric. |
| `humidityPct` | Valid percentage. |
| `precipitationMm` | Metric and non-negative. |
| `forecast[]` | Date, min/max °C, precipitation and normalized condition code. |
| `attributionCode` | Maps to approved content in `master.md`. |

Raw provider JSON is not returned or stored. Cache is parcel/location scoped and deduplicated. Expired data is never represented as current.

### Irrigation boundary

The calculator receives a `WeatherInputSnapshot` explicitly. It persists only the normalized variables actually used, provenance and limitation code. If current weather is absent, deterministic local calculation may proceed only when its required local inputs exist and must record `weather_unavailable`.

### Contractual policy (T002 approved 2026-08-28)

- WeatherAPI is the initial provider and is accessed only from the authenticated Edge Function.
- The provider key is an Edge Function secret. It is absent from Dart, Android resources, client configuration, fixtures and logs.
- Current-conditions cache expires after 60 minutes; forecast cache expires after 24 hours. Expired responses and normalized weather fields are deleted rather than shown as current.
- An irrigation estimate stores only its numeric weather adjustment, provider code, observation time and contract version; it never retains the WeatherAPI response or normalized condition/forecast fields beyond their cache expiry.
- The UI credits WeatherAPI.com by name or brand treatment and presents the approved informational/probabilistic disclaimer in `master.md`.
- Weather is auxiliary: provider failure, quota, timeout or stale cache never blocks local records or a valid local-only calculation.

Before production, verify the active WeatherAPI plan and terms again. Failure requires swapping
`WeatherGateway`; it does not allow omitting FR-065 or inventing a visual treatment.

### Failures

401 provider config, 429 quota, timeout, invalid response and no parcel location are typed separately. None blocks local records, history, reminders or a valid local-only calculation.

## 4. Local notifications and FCM

### Local source of truth

Drift reminder plus `notification_bindings` drives scheduling. `flutter_local_notifications` reconciles at bootstrap, resume, reboot, timezone/time change and after create/edit/complete/cancel.

### Permission and precision

- Notification permission is requested in context.
- Denial keeps reminder queryable and synced.
- Exact alarm access is requested only when a validated product need and store eligibility exist.
- Without exact access, schedule an inexact notification and communicate platform limitation according to `master.md`.

### FCM contract

FCM is remote delivery/sync hint, never reminder state or exact scheduler. Server sends HTTP v1 from a trusted environment. Payload is opaque:

| Field | Rule |
|---|---|
| `eventId`, `occurrenceId` | Stable dedupe IDs. |
| `type` | Allowlisted route intent. |
| `entityId` | UUID only. |
| `revision` | Prevents stale resurrection. |
| `expiresAt` | Client rejects late event. |

No parcel name, labor text or private prompt is included in transport/lockscreen payload. Local/remote notification share occurrence identity and Android notification ID. Completed/cancelled reminders reject stale FCM.

### Installation tokens

Token belongs to an installation, not a worker/user role. Refresh is uploaded authenticated; invalid/stale/UNREGISTERED tokens are disabled. Logout detaches the installation from that owner.

### Tests

Permission denied/revoked, exact alarm denied, DST/timezone/reboot, OEM/Doze, edit/complete/cancel, duplicate local+FCM, late event, rotated/invalid token, foreground/background/terminated tap.

## 5. AgroIA / Gemini

### Selected topology

Flutter calls authenticated Edge Function `agro-ai`; the function invokes a stable Gemini model ID configured by environment. No Gemini credential or direct SDK call exists in the APK.

### Request

| Field | Rule |
|---|---|
| `conversationId`, `clientMessageId` | Idempotent client IDs. |
| `parcelId` | Required active authorized context. |
| `sectorId` | Optional and validated under parcel/owner. |
| `prompt` | Non-empty bounded Spanish text. |

The server loads a whitelist of contextual fields through RLS. It excludes precise GPS, photos, credentials, unrelated history and personal data. Notes/context are treated as untrusted input against prompt injection.

### Response

| Field | Rule |
|---|---|
| `assistantMessageId` | Stable ID for retry dedupe. |
| `text` | Consultative text only. |
| `modelId`, `policyVersion` | Required audit metadata. |
| `createdAt` | Server timestamp. |
| `disclaimerCode` | Maps to approved `master.md` copy/presentation. |

### Guardrails

- Disable tools, function calls, code execution, search/maps grounding and image input.
- No writes, autonomous actions, irrigation control or photo diagnosis.
- Questions about surface/liters/time refer to deterministic AgroCampo calculations and do not generate an alternative figure.
- Apply timeout, per-user quota, bounded input/output and safety settings.
- Log metadata only; prompt/response retention follows approved privacy policy.
- Offline shows local history and preserves draft; send/retry requires explicit farmer action.

### Tests/evals

Critical calculation, request to edit/execute, photo diagnosis, prompt injection in notes, blocked safety response, 429/timeout/model unavailable, duplicate message ID, offline/retry and Spanish consultative disclaimer.

## 6. Camera, gallery and local files

### Acquisition

`image_picker` invokes camera/gallery system UI. App bootstrap calls lost-data recovery before presenting an interrupted selection.

### Local commit sequence

1. select/capture;
2. preview or cancel;
3. on confirm, copy to app-private temporary file;
4. validate MIME, dimensions, size and free space;
5. re-encode/compress within an approved evidence-preserving policy;
6. strip unnecessary EXIF GPS;
7. compute SHA-256;
8. atomic rename to stable owner/photo path;
9. insert photo metadata and outbox transaction.

Cancel or any pre-commit failure leaves no database row and removes partial file. SQLite stores paths/metadata, never bytes.

## 7. Supabase Storage

- Private bucket with owner RLS.
- Immutable path `{ownerId}/{photoId}/{sha256}.{ext}`.
- Standard upload within documented size threshold; `upsert=false`.
- Repeated upload is accepted only when path/hash/metadata match.
- Metadata is confirmed through sync after the object exists.
- Signed URLs are short-lived and not persisted as canonical data.
- Local copy remains available offline according to FR-055.
- Physical purge and remote backup policy are outside MVP; tombstone prevents resurrection.

Tests cover cross-owner RLS, expired signed URL, upload interruption, duplicate retry, delete before/during upload and insufficient local storage.

## 8. Secret inventory

| Item | APK allowed | Storage |
|---|---:|---|
| Supabase publishable key | yes | build environment, not treated as authorization |
| User access/refresh tokens | runtime only | Android Keystore-backed secure storage |
| Google Maps Android key | yes, restricted | environment-specific Android resource/build config |
| Firebase client configuration | yes | generated Android config |
| Weather provider key | no | Edge Function secret |
| Gemini authorization/API key | no | Edge Function secret/service account |
| Supabase secret/service-role key | no | trusted server secret only |
| FCM service account | no | notification server secret only |

Logs and crash reports redact all tokens, URLs with signatures, exact coordinates, prompts, agricultural payloads and local file paths.

## 9. Acceptance

An adapter is ready when success, timeout, offline, permission denial, unauthorized, rate-limited, invalid-response and provider-unavailable paths are contract tested; the local flow remains available where spec permits; and every visual state is supplied as semantic data to components governed by `master.md`.
