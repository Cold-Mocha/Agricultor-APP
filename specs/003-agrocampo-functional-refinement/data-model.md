# Data Model: AgroCampo Functional Refinement - Módulo 003

## 1. Modeling Rules

1. Drift continúa como fuente operativa y Supabase como respaldo.
2. `Sector` continúa siendo territorio; “Cuadrante” y “platabanda” son nombres visibles.
3. `Sector` es la única identidad territorial y productiva durante 003; no existe una proyección 1:1
   con otro ID.
4. `sectors.kind` se exige al crear y permanece estable; nunca se infiere desde icono, cultivo o
   ruta. Cada evento nuevo conserva su categoría como snapshot.
5. Todo evento nuevo conserva contexto histórico y detalles confirmados. Un nulo no equivale a cero,
   falso, normal, vacío ni no aplica.
6. Una especialización comparte una labor raíz para contexto, outbox e historial único.
7. JSON versionado se usa para detalles variables; columnas se reservan para identidad, relaciones,
   filtrado frecuente, versionado y estado de sincronización.
8. Las correcciones crean una sucesión trazable; no reescriben el evento anterior.

## 2. Existing v10 Disposition

| Tabla/estructura v10 | Decisión | Razón 003 |
|---|---|---|
| `parcels` | REUTILIZAR | Ya conserva propietario, límite, superficie, versión y sync. |
| `sectors` | REUTILIZAR | `kind` ya conserva `crop|apiary`; sigue siendo la identidad territorial/productiva 1:1. |
| `agricultural_seasons` | REUTILIZAR | Periodo agrícola vigente. |
| `crop_seasons` | REUTILIZAR/CORREGIR | Ya es asignación fechada; debe validar categoría y no solapamiento. |
| `labors` | EXTENDER | Raíz histórica/versionada apropiada; falta snapshot de categoría y nuevos details v2. |
| `soil_measurements` | EXTENDER | Conserva indicadores, pero debe vincularse a una labor root. |
| `sector_irrigation_configs` | REUTILIZAR | Configuración de goteo versionada y efectiva. |
| `irrigation_records` | REUTILIZAR | Especialización existente; `performed_details_json` admite snapshot completo. |
| `crop_irrigation_rules` | REUTILIZAR | Permanece sin regla avanzada productiva; 003 no amplía su esquema. |
| `irrigation_estimates` | REUTILIZAR | Ya congela input, regla, resultado, warnings y explicación. |
| `production_records` | REUTILIZAR | Ya se enlaza de forma única a la labor cosecha. |
| `apiary_inspections` | EXTENDER | Conserva datos actuales, pero debe vincularse a una labor root y admitir details por tarea. |
| `photo_attachments` | REUTILIZAR | Puede asociarse al `laborId` confirmado mediante aggregate type permitido. |
| `sync_outbox`, `sync_cursors`, `sync_conflicts` | REUTILIZAR/CORREGIR | Protocolo v2 válido; faltan payloads compound completos y corrección de lotes vacíos. |
| `form_drafts` | REUTILIZAR | Es comportamiento heredado; 003 no amplía recuperación de formularios no confirmados. |
| `weather_cache`, `ai_messages`, `export_snapshots` | REUTILIZAR | Integraciones preservadas, no autoridad del dominio. |

Las demás tablas v10 se preservan sin cambios semánticos.

## 3. Logical Entities

### 3.1 SectorSummary v2 (extension of the existing public projection)

```text
sectorId
parcelId
ownerId
displayName
category               crop | apiary
status                 active | archived
allowedOperations[]    proyección informativa calculada por backend
```

Invariants:

- owner/parcel/Sector deben existir y ser coherentes;
- no se expone ni persiste `unitId`, `ProductiveUnitRef` u otra identidad equivalente;
- la categoría es obligatoria al crear y no puede cambiar durante 003;
- una categoría desconocida impide mutaciones pero no oculta lectura histórica.

### 3.2 BoundAgriculturalContext v2

```text
ownerId
parcelId
sectorId
category               crop | apiary
seasonId?              exigido sólo cuando la operación vegetal/fecha lo requiera
cropAssignmentId?      idem
cropId?
labels                 parcela/Sector/categoría/temporada/cultivo
revision
resolvedFor            instant UTC usado por la validación
allowedOperations[]
```

El contexto de un formulario es inmutable hasta una decisión explícita de re-vincular. Para una
operación apícola, temporada y cultivo permanecen nulos; no se fabrican asignaciones vegetales.

### 3.3 Domain Compatibility

| Operation | crop | apiary |
|---|---:|---:|
| `soil.measure` | sí | no |
| `irrigation.record` | sí | no |
| `irrigation.estimateBasicDrip` | sí, con caudal y duración válidos | no |
| `irrigation.recommendAdvanced` | sí, sólo con fórmula avanzada definida | no |
| `fertilization.record` | sí | no |
| `phytosanitary.record` | sí | no |
| `cultivation.record` | sí | no |
| `harvest.record` | sí | no; usa `apiary.harvest` |
| `labor.otherVegetable` | sí | no |
| `apiary.inspect/feed/health/harvest/super/other` | no | sí |
| `photo.attach` | sí, a agregado permitido | sí, a agregado permitido |

La decisión incluye `allowed`, `reasonCode`, `fieldErrors` y el contexto preservado. La UI puede
usar `allowedOperations`, pero cada write y cada pull vuelve a validar contra `sectors.kind`. Un
update/pull que intente cambiar una categoría confirmada se rechaza.

### 3.4 Labor root v2

Campos actuales preservados más:

```text
domainCategory?        crop | apiary; NULL se proyecta como legacyUnknown y sólo admite lectura
detailsJson            LaborDetailsEnvelope v1|v2
detailsSchemaVersion
supersedesLaborId?
status/version/syncState
```

`LaborDetailsEnvelope v2`:

```json
{
  "schemaVersion": 2,
  "type": "fertilization|diseaseAndPestControl|cultivation|sowing|pruning|harvest|irrigation|soil|apiary|other",
  "data": {},
  "contextCompleteness": "complete|legacyPartial"
}
```

Un decoder que desconozca un schema conserva el JSON y devuelve estado no interpretable; no lo
descarta ni lo sustituye por observaciones.

### 3.5 Specialized labor details

| Tipo | Datos canónicos confirmados |
|---|---|
| Suelo | colección de indicador `{code, value, unit}`; fecha y observaciones; ausentes no se serializan como cero. |
| Fertilización | método `manual|foliar|fertigation`, producto, dosis, unidad, observaciones, optional data aprobado y `irrigationLaborId?`. |
| Fitosanitario | producto, objetivo/tipo plaga o enfermedad, dosis, unidad, `safetyIntervalDays?`, observaciones; sin recomendación. |
| Cultivo | labor realizada, variedad, `affectedPlants?`, estado observado, observaciones. |
| Cosecha vegetal | cantidad, unidad, `quality?`, `destination?`, `workShift?`, observaciones. |
| Otra vegetal | nombre descriptivo, detalle, observaciones; no acepta datos de otro subtipo. |
| Riego | método, duración, caudal presentado+unidad, presión+unidad cuando aplique, volumen realizado/estimado y snapshot de contexto/config/recomendación. |
| Apicultura | `taskType`, colmenas, responsable descriptivo y mapa de campos propios de inspección/alimentación/sanidad/cosecha/alza/otra. |

Los `optional data` sólo pueden usar campos definidos por el formulario/contrato aprobado; no son
un mapa libre para introducir cálculos o recomendaciones fuera del spec.

### 3.6 SoilMeasurement specialization

Se preservan ID y columnas numéricas v10. Se agrega:

```text
laborId?               UNIQUE; requerido para toda escritura v11
```

La labor raíz contiene contexto, unidades y estado sync. Las columnas existentes siguen permitiendo
consultas eficientes; el detalle canónico se reconstruye desde `LaborDetails` y se verifica contra
la especialización.

### 3.7 Irrigation

#### Performed input

```text
method
occurredAt
duration {submittedValue, submittedUnit, normalizedSeconds}
flow? {submittedValue, submittedUnit, scope, normalizedTotalMlPerMinute}
emitterOrPlantCount?    requerido sólo cuando scope no es total
pressure? {submittedValue, submittedUnit, normalizedKpa}
appliedVolume? {submittedValue, submittedUnit, normalizedMl}
```

`irrigation_records.performed_details_json` conserva esta estructura. Columnas v10 siguen siendo
proyecciones compatibles; el JSON es la evidencia completa del evento.

#### Basic estimate snapshot

Para goteo, `performed_details_json` conserva `formulaVersion`, caudal total normalizado, duración,
volumen y política de redondeo de la estimación básica. La operación vigente es
`roundHalfUp(totalFlowMlPerMinute × durationSeconds / 60)`. No utiliza etapa, textura ni clima y no
se presenta como recomendación agronómica.

#### Advanced applicability

003 no agrega campos a `crop_irrigation_rules`: no existe una fórmula avanzada productiva. Etapa,
textura y clima permanecen ausentes del formulario avanzado y el resultado es
`crop_rule_unavailable`. Una futura fórmula deberá especificar y migrar su aplicabilidad sin
alterar registros previos.

#### Recommendation snapshot

`irrigation_estimates.inputs_json`, `explanation_json`, regla/config versionadas y warnings conservan
lo recomendado. Cambiar config/regla/input no recalcula registros históricos.

### 3.8 Production

`production_records` conserva cantidad/unidad para agregación. Calidad, destino, jornada y
observaciones viven también en `HarvestDetails v2`. `laborId` continúa único y es el grouping key;
no se crea otro evento de cosecha.

### 3.9 Apiary specialization

Se preservan tabla e IDs v10. Se agrega:

```text
laborId?               UNIQUE; requerido para toda escritura v11
```

Para `inspection`, los campos de reina/postura/sanidad/alimentación/plagas/alza se conservan cuando
se suministran. Otros task types validan únicamente sus campos propios. `beekeeperName` es texto, no
FK de usuario. Fotos referencian la labor raíz una vez confirmada.

### 3.10 HistoryEvent projection

```text
eventId                laborId o assignmentId para cambio de cultivo
groupingKey            labor:<id> | assignment:<id>
eventType/domainType
occurredAt
contextSnapshot        IDs, labels y categoría histórica
summary
details                DTO discriminado, no fila Drift
localState             confirmed
backupState            pending|syncing|backedUp|error|conflict
version/correctionRef?
```

El query filtra el conjunto lógico antes de aplicar `limit/offset` y ordena por
`occurredAt DESC, eventType, eventId`. Riego, suelo, cosecha y apiario unidos a una labor root sólo
aparecen una vez.

## 4. Physical Schema Delta v10 → v11

| Objeto | Cambio físico mínimo |
|---|---|
| `labors` | Agregar `domain_category TEXT NULL`; exigir `crop|apiary` en escrituras nuevas y admitir tipo `cultivation` en contratos/constraint remoto. |
| `soil_measurements` | Agregar `labor_id TEXT NULL UNIQUE` con FK lógica/física compatible. |
| `apiary_inspections` | Agregar `labor_id TEXT NULL UNIQUE`. |
| `crop_irrigation_rules` | Sin cambio; la recomendación avanzada permanece no disponible. |
| `irrigation_records` | Sin columna nueva; completar `performed_details_json` y proyecciones existentes. |
| `production_records` | Sin columna nueva; detalle adicional en labor root. |
| `photo_attachments` | Sin columna nueva; allowlist de aggregate type `labor`. |
| índices | Historia por categoría/fecha y enlaces únicos de especialización. |

Si una prueba de rendimiento demuestra que un filtro requerido no usa índice por el JSON, podrá
promoverse exclusivamente esa clave a columna durante 003; debe documentarse con evidencia antes de
alterar este delta.

## 5. Relationships

```text
Agricultor 1 ── N Parcela 1 ── N Sector
Sector 1 ── N CropAssignment N ── 1 AgriculturalSeason
Sector 1 ── N Labor
Labor 1 ── 0..1 SoilMeasurement
Labor 1 ── 0..1 IrrigationRecord ── 0..1 IrrigationEstimate
Labor 1 ── 0..1 ProductionRecord
Labor 1 ── 0..1 ApiaryInspection/Event
Labor 1 ── N PhotoAttachment
```

## 6. State Transitions

### Sector category

```text
uiDraft ──create with crop|apiary──> active(kind immutable during 003)
archived → no new operations; history remains readable
```

Un intento de cambiar `kind` después de crear no altera Sector, eventos ni outbox. Una rotación sólo
modifica la asignación de cultivo.

### Form/record

```text
uiDraft ──validate──> validationFailure (same draft preserved)
       └─confirm──> transaction(root + specialization + outbox)
                        ├─failure → rollback + storageFailure
                        └─commit → savedLocal/pending
uiDraft ──cancel/confirmed abandon──> last persisted state unchanged
```

### Correction

```text
recorded ──correct──> corrected (immutable prior) + replacement(supersedes prior)
recorded ──void─────> voided (still visible/auditable)
```

### Sync

Se reutiliza la máquina v2: `pending → sending → done`, con `retry_wait`, `blocked` y `conflict`.
El estado público traduce `done` a `backedUp`; nunca traduce un commit local directamente a respaldo.

## 7. Migration and Backfill Plan

1. Verificar que `AppDatabase.schemaVersion` y `migration_policy.dart` coincidan en 10 antes de
   comenzar; la discrepancia actual 10/9 es un defecto de baseline.
2. Crear fixture v10 con todas las tablas relevantes, polígonos, temporadas, asignaciones, detalles,
   riegos, producción, apiario, fotos, outbox en varios estados y conflictos.
3. Agregar `labors.domain_category`, `soil_measurements.labor_id` y
   `apiary_inspections.labor_id` como columnas nullable para preservar legado; las escrituras nuevas
   exigen vínculos y categoría válidos en dominio.
4. Para labores cuyo tipo y relaciones demuestran categoría, llenar `crop|apiary`; para otras dejar
   NULL y proyectar `legacyUnknown`, sin copiar automáticamente el `kind` actual.
5. Crear labor roots para suelo/apiario legado con UUID determinista derivado del ID de la
   especialización (o reutilizar el ID si no colisiona). Derivar parcela por FK Sector; no inventar
   temporada/asignación.
6. Transformar sólo operaciones `apiary_inspection` pendientes/no soportadas en payload `labor` v2
   completo, preservando aggregate ID/operation ID cuando sea seguro y recalculando hash antes del
   primer envío. Una operación con recibo remoto nunca se reescribe.
7. Crear índices/constraints y ejecutar validaciones de FK, unicidad, categoría y JSON; impedir
   actualizaciones de `sectors.kind` en los caminos 003.
8. Actualizar schema version a 11 sólo al completar la transacción; generar snapshot v11.
9. Aplicar migración Supabase `0020_*` append-only con columnas, función de compatibilidad,
   handlers y RLS; no editar 0001–0019.

## 8. Preservation Assertions

La prueba v10→v11 falla si cambia cualquiera de estos invariantes:

- conjunto y contenido de IDs de parcelas, Sectores, temporadas, asignaciones, labores, riegos,
  estimaciones, producción, suelo, apiario, fotos, outbox, cursores o conflictos;
- bytes/estructura canónica de geometrías confirmadas y superficies;
- fechas efectivas y relaciones de cultivo;
- detalles históricos y vínculos labor-riego/producción existentes;
- cantidad/estado/hash de operaciones ya enviadas o confirmadas;
- aislamiento por propietario.

Los snapshots de categoría y labor roots/links de backfill se verifican aparte y deben ser
deterministas o permanecer `legacyUnknown` cuando la evidencia no alcance.
No se ejecuta `db reset` sobre una base de usuario; `supabase db reset` del quickstart se limita al
stack local desechable de pruebas.
