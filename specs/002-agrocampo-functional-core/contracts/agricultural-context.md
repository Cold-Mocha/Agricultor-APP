# Contract: Agricultural Context v1

## Purpose

Prevent any 002 operation from using an implicit or stale parcel/sector/season/crop. The context is a validated local projection; it is not a new remote aggregate.

## Shape

```text
ownerId
activeParcelId
activeSectorId? 
activeSeasonId?
activeCropAssignmentId?
revision
resolvedAt
```

## Invariants

1. `ownerId` equals the unlocked session owner.
2. The active parcel belongs to owner, is not deleted and is selected exactly once when parcels exist.
3. Active sector, when present, belongs to active parcel and owner.
4. Active season, when present, belongs to active parcel and is valid for the requested operation/date.
5. Active assignment, when present, belongs to active sector+season and is effective for the requested date.
6. No query or form selects “the only/first sector” as a hidden fallback.
7. Context IDs are persisted in `app_preferences`; domain truth remains in domain tables.

## Resolution

- No parcel: return `needsParcel`, clear child selections and expose create-parcel action.
- Selected parcel unavailable: choose the sole/most recently active valid parcel deterministically only if no user choice is ambiguous; otherwise return `needsParcelSelection`.
- Sector-dependent action without sector: return `needsSectorSelection` with sectors filtered by parcel.
- Event action without a valid season/assignment: return `needsSeason` or `needsCropAssignment`; never invent an ID.
- Closed season: read is allowed; new event is rejected unless it is an explicit correction flow.

## Form Binding

Opening a form creates a `BoundAgriculturalContext` containing IDs, labels and `revision`. A later global context change must do one of:

1. keep the bound context and display it;
2. ask the user to discard/rebind unsaved values; or
3. cancel navigation.

It must never save valid fields under a silently changed context.

## Observable UI

- Forms show parcel, sector, season and crop applicable to the command.
- Global screens show active parcel and allow visible switching.
- Sector list/map/history are always filtered by active parcel/sector.
- Context errors offer a normal navigation action, not a hidden route.
- Labels and components follow `master.md`; IDs are never user-facing names.

## Required Tests

- Three parcels, ten sectors each, switching and restart.
- Archived selected parcel/sector and closed selected season.
- Form open while global parcel changes.
- Same sector name in different parcels.
- Event date before/after a crop rotation.
- Another owner cannot resolve previous owner IDs.

## Acceptance

Accepted when all FR-014..FR-017, FR-028, FR-029..FR-035 and FR-094 scenarios use only a validated context and no 002 screen relies on `getSingleOrNull` across owner sectors.
