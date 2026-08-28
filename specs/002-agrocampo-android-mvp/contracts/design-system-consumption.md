# Contract: Design System Consumption

**Authority**: `master.md` is the only visual source for the MVP.  
**Applies to**: every Flutter screen, component, state, route transition, map overlay and accessibility behavior.

## 1. Binding rule

Every visual decision MUST **Implementar según master.md**. This contract defines how code consumes that authority; it does not repeat or reinterpret its values.

If a required visual role, component variant, legal attribution or accessible behavior is absent from `master.md`, implementation of that visual element stops until `master.md` is updated and approved. A feature MUST NOT invent a local fallback style.

## 2. Token ownership

Only `lib/app/theme/**` may contain normative visual values transcribed from `master.md`:

- Material `ColorScheme` roles;
- semantic state colors through a `ThemeExtension`;
- typography and local Inter assets;
- spacing, radii, elevation, iconography, layout and motion tokens;
- component themes and approved crop asset references.

Every value includes a traceable comment/reference to its section in `master.md`. There is one light `ThemeData` for the MVP. A dark theme, seed-generated scheme or dynamic device palette is not permitted.

## 3. Consumption boundary

Files under `lib/features/**` and `lib/shared/presentation/**`:

- obtain visual roles from `Theme.of(context)`, component themes or approved theme extensions;
- may compose tokens, but never restate their raw values;
- may receive semantic variants such as `pending`, `error` or `success`;
- MUST NOT accept arbitrary `color`, `padding`, `radius`, `shadow`, `fontSize`, `iconSize` or animation-duration parameters as feature-level customization;
- MUST NOT contain HEX/ARGB literals, raw font metrics, numeric padding/radius/shadow/icon/motion values or unapproved asset styles;
- MUST NOT use `ColorScheme.fromSeed`, dynamic color or an additional ThemeData.

Non-visual domain quantities, map coordinates, calculation constants and database batch sizes are outside this prohibition but must not be disguised as visual constants.

## 4. Component contract

A shared component exposes:

- semantic content and labels;
- an explicit domain/UI state;
- callbacks and accessibility description;
- optional data slots already supported by its `master.md` pattern.

It owns:

- visual tokens and Material interaction states;
- focus, pressed, disabled and loading behavior when applicable;
- text scaling, wrapping, safe areas and orientation response;
- semantic role, label, value and selected/expanded state;
- reduced-motion behavior.

A component variant may be added only when the same variant exists in `master.md`. One-feature UI remains in that feature unless it is a documented shared pattern.

## 5. Required component families

The implementation provides reusable families for:

- application shell, header, bottom navigation and central Registrar action;
- connection/synchronization summary and per-record state;
- standard, hero, action, sector/crop and metric cards;
- buttons, icon actions, chips and selectors;
- fields, units, help, validation, error summary and save feedback;
- banners, alerts, snackbar, progress, empty and recoverable error states;
- timeline/history and attachment state;
- profile/settings rows and destructive confirmation.

Map editing and AgroIA components may remain feature-local, but consume the same theme and follow their sections in `master.md`.

## 6. State contract

Screens with data implement the functional states required by `spec.md`; presentation of every state is **Implementar según master.md**. In particular:

- connection and record sync state are separate;
- “saved locally” and “backed up” are separate results;
- status never relies only on color;
- loading, empty, content, error and recovery exist for every data screen;
- writers additionally expose local saving, pending, syncing, synchronized, conflict and error where applicable;
- unavailable external services affect only their own surface and preserve local actions.

## 7. Navigation visual boundary

The five destinations, order, labels and central Registrar position are immutable for this feature. Secondary routes do not add destinations. Tablet/landscape may adapt content constraints, but MUST NOT replace primary navigation with an unapproved rail or drawer.

## 8. Automated enforcement

CI adds a design-policy test that scans presentation paths and fails for:

- color literals or HEX strings;
- visual constructors containing raw sizes outside the theme package;
- direct font-family declarations outside the theme;
- unapproved icon packages, emoji or remote font/asset loading;
- a second ThemeData, seed scheme or dynamic color;
- bottom navigation with a different count/order;
- a component state represented by color only.

Allowlisting requires the exact `master.md` reference and a theme token; feature-local suppression is prohibited.

## 9. Verification matrix

Each affected screen is verified through:

- widget tests for every functional state;
- golden comparison against the approved identity;
- narrow phone, large phone, tablet and landscape constraints;
- text scaling, TalkBack/semantics, contrast and reduced motion;
- keyboard, safe area and Android back behavior;
- offline, pending, reconnection, error and retry states.

The mandatory comparison set is Inicio, Sectores, Detalle, Registrar, AgroIA and Perfil, plus any later screen explicitly required by `master.md`.

## 10. Acceptance

This contract is satisfied only when:

- all visual literals are confined to the approved theme layer;
- each token maps to `master.md` and exists once;
- screens use shared components before adding variants;
- no design alternative or identity change exists;
- AC-002, SC-005 and SC-013 pass review.
