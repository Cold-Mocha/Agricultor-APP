# Repository Guidelines

## Project Structure & Module Organization

This repository contains the canonical AgroCampo Android MVP documentation, an initial Flutter
scaffold at repository root and two static prototypes used only as evidence. The only functional
source of truth is `specs/001-agrocampo-android-mvp/`; the only visual source is `master.md`.
`index.html` is the GitHub Pages prototype, `agrocampo-highfi.html` is an audited visual/flow
reference, and `agrocampo-acceptance.test.js` validates the deployed prototype. Neither HTML file
defines production architecture or adds product scope.

## Build, Test, and Development Commands

For documentation-only changes, use the validation procedures in the canonical `quickstart.md` and
run the Spec Kit consistency checks. The Flutter scaffold has `pubspec.yaml`; implementation commands
and version gates are defined in `specs/001-agrocampo-android-mvp/quickstart.md`.

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

## Testing Guidelines

Update `agrocampo-acceptance.test.js` when a requested behavior changes the required copy, routes, selectors, or safety checks. Keep assertions specific and user-facing. Test names are not framework-based; add clear assertion messages that describe the expected behavior. Always run the acceptance test after editing `agrocampo-highfi.html`.

## Commit & Pull Request Guidelines

The current Git history has only one short commit (`Innit`), so no detailed convention is established. Use concise imperative commit messages, for example `Update irrigation form copy` or `Fix map section editing`. Pull requests should summarize the visible change, list verification commands run, link any related issue or request, and include screenshots or screen recordings for UI changes.

## Agent-Specific Instructions

Follow `AGENTES.md` for prototype edits and the canonical `tasks.md` for Android implementation.
Every UI task must cite `master.md`. Do not introduce any excluded functionality or a second
functional module. Backend/APIs/frameworks remain forbidden in the static prototype, while the
Android implementation uses only the stack explicitly approved by the canonical plan.
