# Quickstart and Validation Guide: AgroCampo Android MVP

This guide defines the reproducible setup and verification sequence for implementing the canonical
`001-agrocampo-android-mvp`. It does not replace `plan.md`, `spec.md`, `master.md` or provider setup documentation.

## 1. Required toolchain

- Flutter 3.47.0 stable with Dart 3.13.0; `pubspec.lock` pins the compatible dependency set.
- Android Studio/SDK with API 36 and an Android API 24+ emulator/device.
- Java version required by the selected Flutter/Android Gradle toolchain.
- Node.js for the existing static-prototype acceptance checks.
- Docker and Supabase CLI for local PostgreSQL/Auth/Storage/Functions tests.
- Firebase CLI plus FlutterFire configuration tooling for Android FCM.
- A real Android device for GPS, network map behavior, camera, notification and OEM/background verification.

Run first:

```powershell
flutter doctor -v
flutter --version
dart --version
node --version
supabase --version
```

The implementation must not create or validate an iOS release.

## 2. Environment separation

Maintain independent development, staging and production configuration. Each environment has separate Supabase, Firebase, Weather and Gemini resources. OpenStreetMap uses no API key.

### Values allowed in Android build/app

- Supabase URL and publishable key.
- Firebase Android client configuration.
- Non-secret environment identifiers and feature contract versions.

### Server-only secrets

- Supabase secret/service-role keys.
- Weather provider key.
- Gemini authorization/API key or service-account material.
- FCM service-account credentials.

Do not store server secrets in Dart constants, `.env` bundled as an asset, Gradle resources committed to Git, test fixtures or logs.

## 3. Bootstrap order

Implement in this dependency order:

1. Complete T001 irrigation approval and T002 Weather contractual gate; no affected code starts first.
2. Pin Flutter/Android identity, SDK and dependencies; commit `pubspec.lock`.
3. Create modular directories and bootstrap failure handling.
4. Transcribe approved `master.md` values into `lib/app/theme/**` and add the literal-policy test.
5. Register local Inter/SVG assets and shared components.
6. Create the five-branch router and restoration IDs.
7. Add Drift technical schema, secure session and owner-scoped local database.
8. Prove a minimal Parcel + outbox + RLS + push/pull vertical slice, including lost ACK/restart.
9. Generalize sync/conflicts only after the vertical slice passes.
10. Implement territory, `LABORES` and the remaining stories in `plan.md`/`tasks.md` order.

At no point should a screen read Supabase directly or introduce a visual literal outside the theme package.

## 4. Dependency setup checkpoint

After selecting the compatible versions documented in `research.md`:

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

Reject the dependency set if Android API 24 no longer builds, if a package requires a prerelease chain, or if two packages provide competing state/database/navigation systems.

## 5. Supabase local setup

The local stack must reproduce production migrations and RLS:

```powershell
supabase start
supabase db reset
supabase test db
supabase functions serve
```

Required local personas/scenarios:

- anonymous client;
- owner A with independent parcels/history;
- owner B with independent parcels/history;
- expired/revoked session;
- private Storage object owned by each user;
- duplicate and conflicting sync operations.

Seed only the approved crop catalog and explicit test fixtures. Do not seed workers, roles, organizations, inventory or future modules.

## 6. Android provider setup

### OpenStreetMap

- Use `https://tile.openstreetmap.org/{z}/{x}/{y}.png` as visual layer only.
- Set `userAgentPackageName` to the real application ID, `cl.agrocampo.app`.
- Keep `© OpenStreetMap contributors` permanently visible.
- Do not add an API key, bulk download or prefetch. Respect HTTP cache headers and the OSM tile policy.
- Validate that persisted parcel/sector polygons remain usable when tile requests fail.

### Firebase/FCM

- Configure the Android application and notification channel.
- Enable runtime notification permission flow.
- Keep FCM sending credentials server-side.
- Test token refresh, revoked permission and stale event handling.

### Weather and Gemini

- Store keys in Supabase Function secrets.
- Require JWT on both functions.
- Complete the Weather contractual/attribution gate in `research.md` before production.
- Fix a Gemini model ID and policy version; never use a floating alias in release.

## 7. Local database validation

Before adding feature UI, verify:

- schema creates with foreign keys enabled;
- every migration upgrades a previous snapshot without data loss;
- owner spaces are isolated;
- entity and outbox roll back together on injected failure;
- nullable measurement differs from measured zero;
- active crop assignment and sector number uniqueness hold;
- custom crops are owner-isolated and official seed rows are immutable;
- planned rotations do not change the active crop and cannot overlap;
- “Otra labor”, soil type and apiary task type survive restart/sync;
- history filters return only matching records;
- process restart preserves pending rows, drafts and photos.

Generate/update Drift migration artifacts through the approved Drift tooling and review generated diffs; never edit generated output manually.

## 8. Sync validation

Run the scenarios in `contracts/sync-protocol.md` against Supabase local:

1. save offline and restart;
2. queue parent/child records;
3. reconnect and push 100 operations;
4. lose ACK after server commit;
5. interrupt each push/pull boundary;
6. edit the same base from two devices;
7. resolve with local and remote choices;
8. receive a late tombstone;
9. expire session during pending work;
10. upload/delete/retry a photograph.

Success requires no silent loss, no duplicate business rows and a durable cursor.

## 9. Design System enforcement

Before accepting any screen:

- confirm its task cites the exact `master.md` screen/component/state section;
- compare its roles/components/states with `master.md`;
- ensure all values come from ThemeData/ThemeExtension/tokens;
- run the policy test that scans feature/shared presentation paths;
- verify the screen in loading, empty, content, error and recovery states;
- add pending/sync/conflict states for writers;
- run golden, semantics and accessibility checks;
- verify narrow phone, large phone, tablet and landscape;
- verify text scaling, TalkBack, keyboard, safe areas and reduced motion.

If a value or variant is missing, update and approve `master.md` first. Do not suppress the policy test locally.

## 10. Test commands

Flutter gates:

```powershell
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter test integration_test
flutter build apk --debug
```

Release-candidate gates add:

```powershell
flutter build appbundle --release
```

The integration suite runs on emulator and on at least one physical Android device. Camera, native permission dialogs, GPS/map behavior with real connectivity, FCM delivery and OEM background restrictions require the physical-device matrix even when automated tests pass.

## 11. Existing prototype regression checks

The Flutter plan does not modify the prototype, but repository governance still requires its checks before completion:

```powershell
node agrocampo-acceptance.test.js
node -e "const fs=require('fs'); const html=fs.readFileSync('agrocampo-highfi.html','utf8'); const scripts=[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1]); for (const script of scripts) new Function(script); console.log('Embedded JavaScript syntax OK:', scripts.length);"
```

## 12. Performance fixture

Use deterministic local fixtures containing:

- 20 parcels;
- 200 sectors;
- 10,000 textual/history records;
- mixed synced, pending, error and conflict states;
- local photo metadata with bounded fixture files.

Measure local query P95 against SC-012, UI frame behavior for lists/maps and memory/time for XLSX. Geometry, image processing and workbook generation must not execute on the UI isolate.

## 13. Release checklist

- [ ] Every FR-001..FR-091, AC-CAP and AC-001..AC-010 mapped to passing evidence.
- [ ] SC-003, SC-004, SC-006, SC-007, SC-010, SC-012, SC-013, SC-014 and SC-015 measured.
- [ ] Constitution Check remains PASS.
- [ ] Design literal policy and golden/accessibility suite pass.
- [ ] Supabase migrations, RLS, RPC and Storage tests pass.
- [ ] No Weather/Gemini/service-role/FCM-server secret exists in APK or repository.
- [ ] Weather retention/attribution and Gemini privacy/model gates are approved.
- [ ] Offline, restart, reconnect and conflict tests pass on physical Android.
- [ ] XLSX opens and reconciles counts/FKs.
- [ ] Dependency/license/security audit has no unaccepted critical issue.
- [ ] No iOS, workers, roles, organizations, inventory, ERP, IoT, irrigation automation, advanced AI or photo analysis exists.
- [ ] Existing prototype checks pass.

## 14. Ready for implementation

Begin with T001 and do not skip phase gates. `tasks.md` is the canonical dependency-ordered backlog;
the traceability matrix inside it must be updated with evidence as each task completes.
