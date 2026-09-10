# Contract: Bound Sector Context v2

**Extends**: Módulo 002 `contracts/agricultural-context.md`.

## Shape

```text
ownerId
parcelId
sectorId
category               crop | apiary
seasonId?
cropAssignmentId?
cropId?
labels {
  parcel
  sector
  category
  season?
  crop?
}
allowedOperations[]
revision
resolvedFor
```

## Invariants

1. All IDs belong to the unlocked owner.
2. Sector belongs to parcel and is the only territorial/productive identity.
3. Category equals the persisted `sectors.kind` and cannot change during 003.
4. Vegetable season/assignment/crop are included only when required and must be effective at the
   command date.
5. Apiary operations do not receive a fabricated crop or vegetable season.
6. No first-Sector/category fallback is permitted.
7. IDs, category and labels shown before save match the bound command.

## Resolution States

```text
ready(context)
needsParcel
needsParcelSelection(options)
needsSectorSelection(options)
needsSeason(options)
needsCropAssignment(options)
categoryUnsupported(code)
staleContext(currentRevision, originalContext)
```

Options are filtered by owner, parent, active status, effective date and category. No public type,
route or preference introduces `unitId` or `domainPeriodId`.

## Form Binding

Opening a form captures the complete context and revision. If global context changes, frontend must
keep and display the original, or ask to discard/rebind/cancel. It never silently changes IDs.
`cancel` leaves persisted data unchanged. A confirmed rebind runs full backend resolution again.

## Restore

The active parcel/Sector selection continues in `app_preferences`. On restart:

- valid selections are restored;
- missing/archived child selections are cleared with an actionable state;
- ambiguous selections remain unresolved;
- category and capabilities are recomputed by backend, never cached as UI authority.

## History

History uses the event's stored category/crop/season snapshot. Legacy events whose context cannot be
proven remain visible with `legacyPartial`; labels must not invent a value.

## Required Tests

- Representative crop/apiary/legacy-unknown Sectores across restart.
- Form open while global context changes.
- Direct operation using stale category or revision.
- Rotation before/at/after effective date.
- Attempted mutation of an existing Sector's `kind`.
- Same visible Sector name under different parcels.
- Previous owner IDs rejected after session change.
