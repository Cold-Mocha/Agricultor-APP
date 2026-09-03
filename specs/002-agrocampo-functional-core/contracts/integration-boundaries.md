# Contract: Integration Boundaries v1

All integrations are optional capabilities around Drift-backed flows. URL/IDs/client keys come from environment; private credentials stay server-side. A failure affects only its own capability.

## 1. Supabase Client

- Bootstrap creates one `SupabaseClient?` from `SUPABASE_URL` and publishable key.
- Riverpod injects it into auth, sync, weather/AI callers and any retained 001 gateway.
- No 002 page calls `Supabase.instance.client` directly.
- Missing config supports local shell/testing where allowed, with explicit service-unavailable state.

## 2. Maps and GPS

### Configuration

- OpenStreetMap uses no API key; `userAgentPackageName` is the Android application ID `cl.agrocampo.app`.
- Provider-specific IDs are not domain values.
- GPS uses foreground permission only.

### Gateway result

```text
location: available(point, accuracy, observedAt)
        | permissionRequired
        | permissionDenied
        | serviceDisabled
        | unavailable(code)

map base: available | loading | unavailable(code)
```

### Rules

- Confirmed WGS84 polygon is stored before/independent of map availability.
- GPS may center/propose; user confirms geometry.
- Permission denial leaves manual drawing/list/history usable.
- View mode cannot mutate vertices. Edit uses draft, explicit save/cancel.
- Remote map failure renders local geometry/fallback and equivalent sector list for TalkBack.
- Places search is optional; disabled gateway is acceptable if manual map/GPS meets 002.

## 3. Open-Meteo

### Configuration and security

- Flutter calls authenticated Supabase `weather-proxy` by parcel/location contract.
- Deployment coordinates and optional customer endpoint configuration exist only in the Edge Function environment.
- Gateway shields UI/domain from provider response shape.
- The public forecast endpoint has no API key; if commercial service is contracted, its customer endpoint/key is never added to Flutter.

### Normalized response

```text
provider/contractVersion/attribution
parcelId or normalized location
observedAt/fetchedAt/expiresAt
current conditions
bounded forecast entries
bounded alert entries { condition, severity, validFrom, validTo, sourceUpdatedAt }
```

No raw payload is persisted. Current/forecast retention follows the approved 001 provider contract and must be rechecked before production.
Open-Meteo forecast data does not populate official alert entries; those require a separately approved authoritative source.

### Degradation

- fresh cache: show timestamp/attribution;
- stale cache: label as stale, never current alert;
- offline/no cache: show unavailable and keep all local operations;
- malformed/no timestamp: do not present as current alert;
- alerts require user opt-in and deduplication by stable fingerprint.

Weather never blocks a local write or a valid local-only drip calculation.

## 4. AgroIA

### Request

```json
{
  "clientMessageId": "uuid",
  "text": "user-authored text",
  "locale": "es-CL",
  "policyVersion": "agro-ai-general-v1"
}
```

No parcel, sector, crop, production, history, Drift row, Supabase record, photo or irrigation calculation is attached automatically. Server does not query private agricultural tables for enrichment.

### Response

Text guidance, stable response/policy/model metadata and consultative disclaimer. Tools, function calling, grounding/actions, images and data mutation are disabled. Requests for critical calculation/action receive a boundary response and normal application navigation may be suggested, but no command is executed.

### Retry

- Save one local user message with stable ID.
- Offline/failure sets `error` and preserves text.
- Explicit retry reuses same ID; server/client deduplicate response.
- At most one active assistant reply is linked to one user message.

## 5. Biometric Unlock

### Gateway and Android setup

```text
capability: available | noHardware | notEnrolled | temporarilyUnavailable
authenticate(reason): success | cancelled | failed | lockedOut | unavailable
```

- Implemented with `local_auth` 3.0.2.
- `MainActivity` inherits from `FlutterFragmentActivity` while preserving the existing XLSX MethodChannel and activity-result behavior.
- Android manifest declares `android.permission.USE_BIOMETRIC`; launch/normal themes inherit from compatible AppCompat parents required by the plugin.
- Opt-in only after valid Supabase login.
- Success unlocks the stored valid owner session locally; it does not authenticate to Supabase, refresh tokens or create identity.
- Failure/cancel stays locked and offers remote login when possible.
- Logout clears opt-in/eligibility and tokens; local pending data remains inaccessible.
- No biometric template/result is stored.

## 6. Local Notifications

- `flutter_local_notifications` schedules from Drift reminder rows.
- Stable persisted Android notification ID; never process-random hash.
- Permission is requested in context. Denial returns `permissionDenied` but reminder save succeeds.
- Reconcile at unlock/bootstrap, reboot, timezone change, edit, complete and cancel.
- Exact alarm is not required unless separately justified/approved; fallback timing limitations are communicated.
- Online weather alert notifications use a separate stable fingerprint and do not alter reminder rows.

## 7. Sync/Background

- WorkManager is a retry opportunity, not the source of truth.
- Sync runs on app bootstrap/resume/local save/connectivity hint/manual retry and eligible background work.
- Logout cancels scheduling for owner.
- See [sync-protocol-v2.md](./sync-protocol-v2.md) for ACK and failure behavior.

## 8. Environment Matrix

| Value | Flutter/APK | Server environment |
|---|---:|---:|
| Supabase URL + publishable key | yes | as required |
| OpenStreetMap API key | no | no |
| Open-Meteo fallback coordinate/customer endpoint | no | yes |
| Gemini/AgroIA private key | no | yes |
| Supabase service role/secret key | no | yes |
| FCM server credential | no | yes |

Dev/staging/prod use separate values. Logs exclude tokens, exact coordinates when unnecessary, private prompts and agricultural payloads.

## 9. Required Tests

- Each integration timeout/5xx/malformed/offline path leaves unrelated local flow usable.
- Map/GPS permission and map-base failure preserve geometry/list.
- Weather fresh/stale/missing timestamp and alert opt-in/dedup.
- AgroIA request capture proves absence of private context; retry produces one question/answer.
- Biometric capability/success/cancel/lockout/logout on Android.
- Notification permission denied, reboot reconciliation, edit/complete/cancel.
- Environment scan finds no private Weather/Gemini/service-role secret in source/APK.

## Acceptance

Accepted when FR-026/027, FR-077, FR-080..FR-092 and SC-012..SC-014 pass with independent degradation and visible recovery states.
