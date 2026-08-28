# Contract: Flutter Navigation and Screen States

**Purpose**: Define stable destinations, guards and observable UI states without prescribing widget
implementation.

## 1. Route map

| Route | Purpose | Primary guard |
|---|---|---|
| `/login` | First/returning owner authentication | No active unlocked session |
| `/app/home` | Summary, active parcel and sync status | Authenticated/offline-unlocked owner |
| `/app/profile` | Owner profile and logout | Session |
| `/app/parcels` | Parcel list, select, archive/restore | Session |
| `/app/parcels/new` | Create parcel and polygon | Session |
| `/app/parcels/:parcelId` | Parcel detail/edit | Owner + parcel exists |
| `/app/map` | Active parcel map and geometry | Session; parcel optional for create flow |
| `/app/sectors/:sectorId` | Sector detail/crop assignment | Owner + parcel relationship |
| `/app/labors` | User-facing `LABORES` entry/list | Active parcel |
| `/app/labors/new` | Generic labor chooser/form | Active parcel + sector |
| `/app/soil/new` | Soil measurement form | Active parcel + sector |
| `/app/irrigation/new` | Irrigation record form | Active parcel + sector |
| `/app/irrigation/calculator` | Deterministic calculator | Active parcel + sector + crop |
| `/app/history` | Filtered agricultural history | Active parcel |
| `/app/production/new` | Harvest/production form | Active parcel + sector + crop |
| `/app/apiary/new` | Apiary inspection form | Apiary sector |
| `/app/photos/:targetType/:targetId` | Attach/view photos | Valid owner target |
| `/app/reminders` | Reminder list/create/edit | Session |
| `/app/export` | Generate and save XLSX | Session + exportable local data |
| `/app/advisory` | Text-only consultative assistant | Session; connectivity for request |
| `/app/sync` | Pending/error summary and retry | Session |
| `/app/sync/conflicts/:conflictId` | Compare and resolve versions | Open owner conflict |

Deep links never bypass owner, parcel or sector guards. An invalid route returns to the nearest
safe list with a Spanish explanation instead of exposing raw identifiers.

## 2. Session guards

- First login requires network authentication.
- A previously validated, not-logged-out owner may unlock the matching local store offline.
- Logout hides local data and removes credentials but preserves pending records.
- Push waits for connected session renewal; local read/write remains available during an offline
  session.
- A different authenticated owner cannot open the prior owner's database context.

## 3. Active parcel contract

- Exactly one active parcel ID is stored locally when active parcels exist.
- Changing it invalidates affected ViewModels and all contextual queries re-read Drift.
- A form opened for parcel A cannot silently save under parcel B after the active selection changes;
  it asks the user to continue in A or discard/navigate.
- Archiving the active parcel selects another active parcel or returns to the empty-selection state.

## 4. Standard screen states

Every data screen supports these explicit states where applicable:

- `loading`: local initialization or query in progress;
- `content`: data available;
- `empty`: no data, with one relevant next action;
- `offline`: content remains usable, external-only actions identified;
- `saving`: local transaction in progress; duplicate submit blocked;
- `pending`: local success awaiting remote ACK;
- `syncing`: remote cycle active;
- `error`: actionable failure without clearing valid form input;
- `conflict`: version decision required;
- `permission_denied`: camera/location/notification-specific explanation.

Connection/sync state is presented by text, icon and count, never color alone.

## 5. Form behavior

- Required fields and metric units appear before input.
- Validation occurs locally and identifies each invalid field in Spanish.
- A failed validation or remote operation never clears valid user-entered values.
- Save success means the local domain row and outbox committed atomically.
- Dates display in the device locale/zone, while the stored UTC or civil date remains explicit.
- Critical calculation results show inputs, rule version, warnings and advisory wording before the
  user can create a riego from them.

## 6. Accessibility and field use

- Touch targets follow the Flutter/Android minimum guidance used in the design system.
- Buttons and icons have semantic labels in Spanish.
- Map actions have non-map textual alternatives for point list, undo, coordinate entry and errors.
- Forms tolerate interrupted sessions and preserve drafts only when they can be stored safely.
- Essential flows remain usable under bright-light, one-handed and intermittent-network testing.
