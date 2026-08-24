# Repository Guidelines

## Project Structure & Module Organization

This repository contains a static AgroCampo prototype. The main application lives in `agrocampo-highfi.html`, with embedded HTML, CSS, and JavaScript. Acceptance checks are in `agrocampo-acceptance.test.js`. Visual assets are stored in `assets/icons/`, and `ImagenSuperior.png` is used by the map background. `README.md` is minimal; `AGENTES.md` contains an existing Spanish workflow for agent-driven edits.

## Build, Test, and Development Commands

There is no package manifest or build step. Open `agrocampo-highfi.html` directly in a browser to run the prototype.

Use these commands before finishing changes:

```bash
node agrocampo-acceptance.test.js
node -e "const fs=require('fs'); const html=fs.readFileSync('agrocampo-highfi.html','utf8'); const scripts=[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1]); for (const script of scripts) new Function(script); console.log('Embedded JavaScript syntax OK:', scripts.length);"
```

The first command validates required product behavior and copy. The second catches syntax errors in embedded scripts.

## Coding Style & Naming Conventions

Keep the prototype dependency-light and framework-free. Follow the existing single-file style: compact CSS, plain JavaScript functions, hash-based routing, and `data-*` attributes for event handling. Use two-space indentation when adding readable multi-line blocks, and keep Spanish UI copy consistent with the existing app. Prefer existing helpers such as `setRoute`, `renderIcons`, `escapeHtml`, `sectorPicker`, and `labelIrrigation` before adding new patterns.

## Testing Guidelines

Update `agrocampo-acceptance.test.js` when a requested behavior changes the required copy, routes, selectors, or safety checks. Keep assertions specific and user-facing. Test names are not framework-based; add clear assertion messages that describe the expected behavior. Always run the acceptance test after editing `agrocampo-highfi.html`.

## Commit & Pull Request Guidelines

The current Git history has only one short commit (`Innit`), so no detailed convention is established. Use concise imperative commit messages, for example `Update irrigation form copy` or `Fix map section editing`. Pull requests should summarize the visible change, list verification commands run, link any related issue or request, and include screenshots or screen recordings for UI changes.

## Agent-Specific Instructions

Follow `AGENTES.md` for task analysis, scoped editing, and review. Do not add a backend, real APIs, frameworks, or unrelated features unless explicitly requested.
