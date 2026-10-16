# Contract: Flutter Navigation

**Router**: `go_router` with `StatefulShellRoute.indexedStack`  
**Authority for visual navigation**: `master.md`

## 1. Top-level shell

The authenticated shell contains exactly these branches, in this order:

| Index | Route | Destination | Preserved state |
|---:|---|---|---|
| 0 | `/inicio` | Inicio | scroll, parcel context and dashboard state |
| 1 | `/sectores` | Sectores | parcel, view/list selection, filters and branch stack |
| 2 | `/registrar` | Registrar | selected context and recoverable draft |
| 3 | `/agroia` | AgroIA | context, thread and scroll |
| 4 | `/mas` | Más | branch stack and local options state |

Labels, order, icons and visual behavior MUST **Implementar según master.md**. Repeated tap on a branch never pushes a duplicate page; the defined branch-root behavior is deterministic.

## 2. Route registry

| Route ID | Path | Parent/logical origin | Required context | Return contract |
|---|---|---|---|---|
| `signIn` | `/acceso` | Outside shell | none | Successful auth resolves initial valid branch. |
| `home` | `/inicio` | Shell branch 0 | recovered owner | System back follows Android top-level convention. |
| `parcelSelection` | `/inicio/parcelas` | Inicio | owner | Returns to Inicio with selected parcel. |
| `profile` | `/inicio/perfil` | Inicio | owner | Returns to Inicio. |
| `sectors` | `/sectores` | Shell branch 1 | active `parcelId` or empty state | Preserves list/map selection. |
| `parcelMap` | `/sectores/parcela/:parcelId/mapa` | Sectores | valid parcel | Returns to Sectores without reset. |
| `sectorDetail` | `/sectores/:sectorId` | Sectores/list/map | valid sector and its parcel | Returns to logical origin. |
| `cropChange` | `/sectores/:sectorId/cultivo` | Sector detail | valid sector | Confirm returns to updated sector. |
| `cropCatalog` | `/sectores/cultivos` | Sector/crop flow | owner | Returns with selection/search preserved. |
| `customCropForm` | `/sectores/cultivos/nuevo` or `/:cropId/editar` | Crop catalog | owner and custom crop when editing | Returns to catalog/detail after local save. |
| `cropRotation` | `/sectores/:sectorId/rotacion` | Sector detail | valid sector | Returns without changing active crop before effective date. |
| `sectorHistory` | `/sectores/:sectorId/historial` | Sector detail | valid sector | Returns to sector with filters/scroll. |
| `register` | `/registrar` | Shell branch 2 | optional parcel/sector query | Context is visible and editable only through allowed selection. |
| `soilForm` | `/registrar/suelo` | Inicio, sector or Registrar | parcel and sector | Successful local save opens sector. |
| `irrigationForm` | `/registrar/riego` | Inicio, sector or Registrar | parcel and sector | Successful local save opens sector. |
| `laborForm` | `/registrar/labor/:laborType` | Registrar/context | valid MVP labor type | Successful local save opens sector. |
| `productionForm` | `/registrar/produccion` | Registrar/context | agricultural sector and crop | Successful local save opens sector. |
| `apiaryForm` | `/registrar/apicultura` | Registrar/context | apiary sector | Successful local save opens apiary sector. |
| `photoAttach` | `/registrar/foto` | Sector or labor | valid local target | Successful local attach returns to target. |
| `agroAi` | `/agroia` | Shell branch 3 or sector | optional authorized context | Preserves context/thread. |
| `more` | `/mas` | Shell branch 4 | owner | Opens approved secondary options. |
| `history` | `/mas/historial` | Más | optional filters | Returns to Más; contextual route retains logical origin. |
| `reminders` | `/mas/recordatorios` | Más | owner | Returns to Más. |
| `syncStatus` | `/mas/sincronizacion` | Más | owner | Returns to Más. |
| `conflictResolution` | `/mas/sincronizacion/conflictos/:conflictId` | Sync status | open conflict | Returns after local resolution state is persisted. |
| `export` | `/mas/exportar` | Más | owner | Returns to Más after success/cancel/error. |
| `settings` | `/mas/configuracion` | Más | owner | Returns to Más. |

Production, apiary and photo entry remain contextual secondary routes; they do not add top-level destinations.

## 3. Guards and resolution

1. No recovered session: only `/acceso` is reachable.
2. First access without network: remain on access with recoverable explanation; do not create anonymous local owner.
3. Recovered owner session: open only that owner's local space, even while offline.
4. Route entity not present locally: show a recoverable route error; request pull only if connected.
5. Route entity belongs to another owner: reject and return to a safe branch root without revealing existence.
6. Archived parcel: history/detail may open; new record routes reject it.
7. Wrong sector type: apiary form rejects agricultural sectors and redirects to sector detail with explanation.
8. Official crop: editable route is rejected; custom crop from another owner is not disclosed.
9. Planned rotation overlaps another plan or precedes allowed effective date: preserve draft and reject confirmation.

## 4. Context rules

- `parcelId`, `sectorId`, `conflictId` and labor type are route inputs, not implicit widget globals.
- Active parcel is persisted per owner and observed by Riverpod.
- A sector route derives parcel from the local repository and validates any supplied parcel ID.
- Changing active parcel invalidates providers for the prior context and moves an incompatible screen to a valid branch root.
- AgroIA receives a verified context snapshot; it never reads IDs supplied only by prompt text.

## 5. Restoration and drafts

- Router, shell, branches and restorable pages have stable restoration IDs.
- Scroll/filter controllers use stable page keys by route/context.
- Restored navigation never substitutes for domain recovery.
- Critical form draft is persisted in Drift by owner + route + context; it survives process death.
- A confirmed save or explicit cancel clears its draft. Navigation failure does not.

## 6. Android back and exit

- System back, predictive gesture and visual back use the same router stack.
- Modal/sheet closes before the underlying route.
- Keyboard closes before leaving a form.
- Unsaved and not-yet-persisted input activates `PopScope` confirmation; the farmer may cancel departure.
- Once the draft is durably recoverable, leaving follows the approved UX without data loss.
- Back at a top-level root follows Android system convention; it does not jump to another branch arbitrarily.

## 7. Notification deep links

Payload contains opaque event/entity IDs and route intent, not agricultural copy. On tap:

1. recover/validate session;
2. open the owner's database;
3. resolve entity locally;
4. reject expired/completed/cancelled occurrence when appropriate;
5. build a coherent parent stack;
6. navigate to an existing route.

No notification creates a sixth destination or bypasses guards.

## 8. Navigation tests

- exact branch count/order and no duplicate roots;
- independent branch stacks and scroll/filter preservation;
- contextual register success returns to sector;
- crop change and history return contracts;
- official/custom crop guards, custom edit and planned-rotation return contracts;
- production, apiary and photo contextual return contracts;
- owner/parcel switch invalidation;
- process restoration plus Draft recovery;
- Android predictive back and cancelable abandonment;
- valid, stale, unauthorized and offline notification taps;
- narrow/large/landscape behavior according to `master.md`.
