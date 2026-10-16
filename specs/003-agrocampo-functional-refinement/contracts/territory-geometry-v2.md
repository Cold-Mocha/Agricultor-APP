# Contract: Territory Geometry v2

## Scope

Extends the existing `territory` API for parcel and Sector creation/editing. Map rendering remains
frontend presentation; geometry validation/persistence remains backend domain/data.

## Commands

```text
CreateParcelBoundary {
  commandId, parcelId, expectedVersion?, closedPolygon
}

CreateSector {
  commandId, parcelId, displayName, category: crop|apiary, closedPolygon
}

EditSectorGeometry {
  commandId, parcelId, sectorId, expectedVersion, closedPolygon
}
```

The backend derives `ownerId` from the active session. No create command defaults name, Sector or
category, and no 003 edit command may change a confirmed `kind`.

## Draft Ownership

Frontend owns an explicit UI state:

```text
viewing → creating|editing → closedDraft → confirming → viewing
                       └─ cancel ────────────────────────┘
```

- Viewing gestures cannot move vertices.
- Creating/editing starts from an empty or copied polygon.
- The farmer explicitly closes/reviews the polygon before confirmation.
- Cancel discards the draft and makes no backend call.
- Navigation with a dirty draft follows `master.md` confirmation behavior.

Backend may expose a pure `validateGeometry` for immediate feedback, but the save command repeats
all validation against current persisted data.

## Validation

Reject without replacing the last confirmed geometry when:

- fewer than three distinct vertices;
- non-finite/out-of-range coordinates;
- draft not explicitly closed;
- duplicate points, self-intersection or negligible area;
- Sector not fully contained within its parcel boundary;
- owner/parent/version/category mismatch;
- attempted category change after creation;
- concurrent update changed the confirmed geometry.

Results use stable field/error codes and preserve the draft.

## Persistence

A valid confirmation writes polygon, calculated surface, Sector metadata/version and one outbox
operation atomically. Reopening the database returns the same normalized WGS84 vertices and surface
within the existing approved tolerance. A remote tile, GPS or network failure never deletes or
blocks confirmed local geometry.

## Provider Contract

- Frontend continues with `flutter_map` and OpenStreetMap tiles from `MAP_TILE_URL`.
- `cl.agrocampo.app` remains the user-agent package and attribution stays visible.
- GPS proposes/centers only; it never confirms geometry.
- Tile failure preserves local overlays and an equivalent textual Sector list.

## Tests

The representative matrix covers creation, explicit close, edit, vertex movement, confirm, cancel,
each declared invalid-polygon partition, containment, stale version, tile failure, GPS denial and
file-backed reopen. Every valid fixture round-trips and every invalid fixture leaves the prior
geometry byte-equivalent after normalization.
