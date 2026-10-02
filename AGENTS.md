# Repository Guidelines

## Project Structure & Module Organization

This repository contains the canonical AgroCampo Android MVP documentation, the executable Flutter
Android application in `frontend/`, a local Flutter backend package plus Supabase in `backend/`,
and two static prototypes used only as evidence. Functional requirements remain in
`specs/001-agrocampo-android-mvp/` and its approved `specs/002-agrocampo-functional-core/` extension;
the only visual source is `master.md`.
`index.html` is the GitHub Pages prototype, `agrocampo-highfi.html` is an audited visual/flow
reference, and `agrocampo-acceptance.test.js` validates the deployed prototype. Neither HTML file
defines production architecture or adds product scope. Project documentation lives in `README.md`
and `docs/` (`architecture/`, `deployment.md`, `status.md`); keep `docs/status.md` current when a
task or verification run closes.

## Build, Test, and Development Commands

For documentation-only changes, use the validation procedures in the canonical `quickstart.md` and
run the Spec Kit consistency checks. Resolve dependencies once from the root Pub Workspace, then
run Flutter analysis/tests inside `frontend/` or `backend/`. Run Drift generation inside `backend/`; run APK builds and Android
integration tests inside `frontend/`. Use `supabase --workdir backend ...` from repository root.
Commands and ownership are documented in `docs/architecture/frontend-backend-boundary.md` and
version gates remain in `specs/001-agrocampo-android-mvp/quickstart.md`.

All local credentials live in the root `.env` (template `.env.example`). Run the app with
`./scripts/run_app.sh`; only the `[APP]` allowlist in `scripts/lib/env.sh` reaches `--dart-define`.
Edge Function secrets go to Supabase via `./scripts/supabase_secrets.sh push|serve`. Never add a
secret to the `[APP]` list or read one with `String.fromEnvironment`.

Open `index.html` or `agrocampo-highfi.html` directly to inspect the static prototypes.

Use these commands before finishing changes:

```bash
node agrocampo-acceptance.test.js
node -e "const fs=require('fs'); const html=fs.readFileSync('agrocampo-highfi.html','utf8'); const scripts=[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1]); for (const script of scripts) new Function(script); console.log('Embedded JavaScript syntax OK:', scripts.length);"
```

The first command validates required product behavior and copy. The second catches syntax errors in embedded scripts.

## Coding Style & Naming Conventions

For prototype-only changes, keep HTML dependency-light and framework-free: compact CSS, plain
JavaScript, hash routes and existing helpers. For the Android product, follow the canonical plan:
Flutter/Dart, feature-first `presentation -> domain <- data`, Riverpod, go_router, Drift and
Supabase. Do not infer Flutter behavior from prototype mock state.

The approved physical boundary is `frontend/` (pages, widgets, navigation, theme and presentation
controllers/state) to `backend/` (contracts, application facades, domain, repositories and
infrastructure). Production frontend
code may import only `package:agrocampo_backend/agrocampo_backend.dart` from the backend package.
Never import backend implementation paths, Drift, DAOs, Supabase clients, outbox or sync payloads
in `frontend/lib/`. Backend code must never import `package:agrocampo/` or contain visual UI.
Keep Drift offline-first; this separation does not introduce another server or functional module.
`frontend/android/` stays with the executable app; backend owners may edit its native integrations.

## Testing Guidelines

Update `agrocampo-acceptance.test.js` when a requested behavior changes the required copy, routes, selectors, or safety checks. Keep assertions specific and user-facing. Test names are not framework-based; add clear assertion messages that describe the expected behavior. Always run the acceptance test after editing `agrocampo-highfi.html`.

## Commit & Pull Request Guidelines

Use Conventional Commits in English with a scope, for example `fix(irrigation): validate flow units` or `docs(deployment): document FCM wiring`. Keep milestones in separate commits. Pull requests should summarize the visible change, list verification commands run, link any related issue or request, and include screenshots or screen recordings for UI changes.

## Agent-Specific Instructions

For prototype edits: change only the files needed, keep plain HTML/CSS/JavaScript with hash
routes and existing helpers, keep mock state coherent, reuse existing components and icons, check
whether edited copy or styles repeat on other screens, and run both prototype commands above
before finishing. Follow the canonical `tasks.md` for Android implementation.
Every UI task must cite `master.md`. Do not introduce functionality outside the approved specs.
The frontend/backend split is explicitly approved and does not expand product scope.
Backend/APIs/frameworks remain forbidden in the static prototype, while the
Android implementation uses only the stack explicitly approved by the canonical plan.
