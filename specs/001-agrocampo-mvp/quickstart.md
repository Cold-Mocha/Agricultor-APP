# Validation Quickstart: AgroCampo MVP - Módulo 001

**Purpose**: Reproducible run and validation guide for the implementation described by
[plan.md](plan.md). Commands become runnable after the corresponding sprint has produced the
Flutter and Supabase projects; this document does not generate implementation code.

## 1. Prerequisites

- Flutter 3.44.7 stable and its bundled Dart SDK.
- Android Studio/current command-line tools with Android API 24 and 37 emulator images.
- Java version supported by that Flutter/Android toolchain.
- Docker and Supabase CLI for the local backend.
- A physical Android test device capable of API 24 or later.
- Separate development projects/credentials for Google Maps, Firebase, WeatherAPI and Gemini.
- Microsoft Excel and LibreOffice for workbook contract validation.
- No production secret in the repository or mobile configuration.

Review these contracts before testing:

- [Data model](data-model.md)
- [Sync protocol](contracts/sync-protocol.md)
- [External services](contracts/external-services.md)
- [UI/navigation](contracts/ui-navigation.md)
- [XLSX export](contracts/export-xlsx.md)

## 2. Local environment setup

From the repository root, after implementation:

```powershell
supabase start
supabase db reset
supabase test db

Set-Location mobile
flutter doctor -v
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

Expected baseline:

- Supabase migrations and seeds rebuild with no manual dashboard step.
- pgTAP verifies RLS, grants, constraints, sync functions and owner isolation.
- Flutter analysis has no errors; unit, widget and Drift migration tests pass.
- Generated files match committed inputs; no unexpected diff is produced.

Use a local-only configuration file excluded from source control for publishable endpoints and
public Android keys. Edge Function provider credentials are loaded through Supabase local secrets,
never Flutter arguments.

## 3. Run the Android app

```powershell
Set-Location mobile
flutter devices
flutter run --flavor dev --dart-define-from-file=config/dev.json
```

Run at least once on an API 24 emulator, current API emulator and physical device. Expected:

- Spanish login screen appears.
- First login succeeds only when local Supabase is reachable.
- The app shell shows connection/sync text, icon and pending counter.
- Android logs and screen errors contain no tokens, provider keys or SQL details.

## 4. Core validation scenarios

### Scenario A - Authenticated offline return

1. Log in while connected and open the owner profile.
2. Close the app, disable network and reopen it.
3. Confirm the same owner can read local data and create local work.
4. Log out while an item is pending, then reopen.

**Expected**: first connected login is required; subsequent local access works offline; logout hides
data but does not delete the pending item; no other owner can unlock or sync that store.

### Scenario B - Parcel, map and sector offline

1. With network disabled, create a parcel with at least four polygon points.
2. Confirm surface in m² and hectares.
3. Create one rectangular and one irregular sector inside it.
4. Try fewer than three points, a self-crossing polygon and a sector crossing the parcel boundary.
5. Restart the app and open the map without tiles.

**Expected**: valid geometry and areas persist; invalid geometry cannot save; local schematic view
shows parcel/sectors without a map base; all valid rows are pending.

### Scenario C - Exactly-once synchronization

1. Seed 100 offline operations with parent/child dependencies.
2. Restore network and interrupt requests before send, during RPC and after server commit before ACK.
3. Terminate the app while one operation is `sending`, then restart.
4. Complete push and pull.

**Expected**: each operation has one acknowledged receipt or an explicit pending/failed/conflict
state; remote aggregates and change feed have no duplicate effects; expired lease recovers;
pending counter reaches zero only after full success.

### Scenario D - Conflict preservation

1. Start two clients from the same remote version of a parcel.
2. Edit it differently and sync both.
3. Inspect the conflict screen.
4. Test keep-remote, repeat, then test keep-local.

**Expected**: the second mutation does not overwrite canonical data; both snapshots remain until
choice; each resolution produces correct local/remote version and retained audit.

### Scenario E - LABORES and soil

1. Select parcel and sector, then register each generic labor type.
2. Create soil measurements at valid boundaries.
3. Try humidity below 0/above 100, pH below 0/above 14 and negative EC/N/P/K.
4. Save offline, restart and filter history by parcel, sector, crop, type and date.

**Expected**: the module is labeled `LABORES`; valid aggregate/detail and outbox commit together;
invalid units identify fields without clearing other values; filters return only matching records.

### Scenario F - Irrigation calculator

1. Run the 20 approved fixture cases from `test/fixtures/irrigation/` while offline.
2. Repeat each case twice and compare integer outputs.
3. Try zero plants/flow, missing climate and expired cached climate.
4. Convert a recommendation into a riego and inspect saved audit values.

**Expected**: exact repeatable liters/time and rule version; invalid minimums cannot calculate;
missing climate yields a visible no-climate estimate; Gemini and provider code are absent from the
critical calculation path.

### Scenario G - Production, apiary and photos

1. Create harvest and apiary inspection offline.
2. Attach camera/gallery photos and force-stop the app during picker return and upload.
3. Resume and synchronize; retry the same file upload.
4. Authenticate a different test owner and attempt direct Storage access to the first path.

**Expected**: typed details and photos remain associated; lost picker result is recovered; same hash
does not duplicate; local file remains usable; cross-owner object read/list is denied.

### Scenario H - Reminders and FCM

1. Create a reminder offline and confirm its local alarm.
2. Deny notification permission and verify the record remains.
3. Re-enable permission, reconcile and receive local alert.
4. Sync it and trigger the remote event with the same reminder/event ID.
5. Exercise background, Doze and force-stop caveats on a real device.

**Expected**: offline reminder is authoritative; denial is explained; remote delivery does not
produce a duplicate alert; FCM delay never changes completion state.

### Scenario I - Gemini advisory boundary

1. Ask a normal crop-information question with minimal selected context.
2. Request exact irrigation liters/time, pesticide dosage, a photo diagnosis and an automatic write.
3. Disable network and repeat.
4. Inspect server logs and mobile package for credentials/prompt content.

**Expected**: normal response is Spanish, bounded and labeled consultative; prohibited requests are
refused or redirected to local tools/professional review; offline is graceful; no secret/full
prompt is exposed.

### Scenario J - XLSX contract

1. Load fixture data including accents, archived parcel, pending/conflict rows and user text that
   starts with formula characters.
2. Export offline through Android document picker.
3. Open in Excel and LibreOffice.
4. Compare sheets, headers, row counts, foreign IDs, units, dates and statuses with Drift snapshot.
5. Cancel destination selection and simulate write failure.

**Expected**: seven contract sheets open without repair; all snapshot rows and relationships match;
text is not executed as formulas; failure/cancel does not report a partial workbook as success.

## 5. Performance and endurance

Populate the deterministic performance fixture:

- 20 parcels;
- 200 sectors;
- 10,000 textual labor/measurement/production records;
- pending, synced and conflict distribution;
- photo metadata without bulk image transfer in the query benchmark.

Run profile-mode integration tests and capture P50/P95 for startup, local screen query, save, history
filter and export. Expected:

- 95 % local navigation and saves under 2 seconds.
- Local navigation ready under 5 seconds on 95 % of starts.
- No UI isolate jank attributable to SQLite or XLSX generation.
- Index plans use intended owner/parent/date/outbox indexes.
- A 24-hour network-off soak with three restarts preserves every committed record.

## 6. Release gate command sequence

```powershell
supabase db reset
supabase test db

Set-Location mobile
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter test integration_test
flutter build apk --release --flavor staging --dart-define-from-file=config/staging.json
```

Additionally require manual evidence for physical-device permissions, GPS, map tile outage, camera,
notification delivery, Doze/force-stop, document picker and workbook compatibility.

The release is blocked by any failing constitution gate, migration/RLS failure, data loss or
duplicate sync effect, unapproved irrigation rule, exposed secret, critical AI boundary failure or
unmet measurable success criterion.
