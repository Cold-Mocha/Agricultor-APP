# Data Model: AgroCampo Android MVP - Módulo 001

**Feature**: `001-agrocampo-android-mvp`  
**Fecha**: 2026-08-28  
**Autoridad**: `spec.md`, constitución y decisiones cerradas en `research.md`.

## 1. Conventions

### 1.1 Identidad y propiedad

- Todos los IDs de dominio son UUID generados en Android antes del primer guardado.
- El mismo ID identifica la entidad en Drift, PostgreSQL, Storage, outbox y XLSX.
- Cada tabla privada remota contiene `owner_id uuid` y RLS por `auth.uid()`.
- No existe `farm_id`, organización, membresía, trabajador ni rol en el MVP.
- Las FKs privadas incluyen propietario cuando sea viable para impedir referencias cruzadas.

### 1.2 Tiempo y fechas

- Instantes técnicos se guardan en UTC y se presentan en la zona del dispositivo.
- Fechas agrícolas sin hora usan tipo `date` remoto y representación de fecha civil local.
- `created_at` y `updated_at` son técnicos; nunca resuelven conflictos.
- `deleted_at` es tombstone. Parcelas con historial usan además `archived_at`.

### 1.3 Números, unidades y reproducibilidad

- Drift guarda valores críticos como enteros con escala explícita; PostgreSQL usa `numeric(p,s)` equivalente.
- Cada campo conserva una unidad canónica métrica; la UI puede convertir entre las unidades métricas aprobadas sin cambiar el valor canónico.
- Escalas iniciales: superficie en centésimas de m², volumen en milésimas de litro, duración en segundos, caudal en milésimas de L/min, temperatura y pH en centésimas, porcentajes en centésimas de punto porcentual y producción en milésimas de unidad.
- EC y N/P/K guardan además el código de unidad aprobado para evitar mezclar mediciones de distinto origen.
- Toda fórmula crítica conserva `algorithm_version`, entradas canónicas, limitaciones y resultado.

### 1.4 Columnas comunes sincronizables

Remoto, salvo catálogo global:

| Campo | Tipo conceptual | Regla |
|---|---|---|
| `id` | UUID | PK, generado localmente. |
| `owner_id` | UUID | FK `auth.users`, obligatorio y protegido por RLS. |
| `version` | bigint | Inicia en 1 y sólo incrementa en RPC autorizado. |
| `created_at` | timestamptz | Server-side al primer commit. |
| `updated_at` | timestamptz | Server-side por mutación aceptada. |
| `deleted_at` | timestamptz nullable | Tombstone; no implica purga física. |

Drift refleja los datos de dominio y añade:

| Campo | Regla |
|---|---|
| `remote_version` | Última versión canónica aplicada; nulo antes del primer respaldo. |
| `sync_state` | `pending`, `syncing`, `synced`, `error` o `conflict`. |
| `last_operation_id` | Operación local más reciente asociada. |
| `last_sync_error_code` | Código estable recuperable; no texto de proveedor. |
| `local_updated_at` | Orden técnico local; no se usa para resolver conflictos. |

## 2. Remote and mirrored domain entities

### 2.1 `profiles`

Perfil 1:1 con `auth.users`.

| Campo | Regla |
|---|---|
| `id` | PK y FK a usuario autenticado; también actúa como `owner_id`. |
| `display_name` | Nombre visible no vacío. |
| `email_display` | Copia sólo para presentación si está aprobada; Auth sigue siendo autoridad. |
| `locale` | Fijo a español latinoamericano en el MVP. |
| `created_at`, `updated_at` | Auditoría. |

No contiene roles, empresa, plan, trabajadores ni permisos organizacionales.

### 2.2 `parcels`

| Campo | Regla |
|---|---|
| comunes | ID, propietario, versión y timestamps. |
| `name` | Obligatorio, normalizado y no vacío. |
| `description` | Opcional. |
| `location_label` | Texto opcional elegido/confirmado por el agricultor. |
| `place_id` | Opcional; sólo si la política del proveedor permite persistirlo. |
| `centroid_lat`, `centroid_lon` | Opcionales hasta confirmar ubicación; rangos geográficos válidos. |
| `geometry` | Polígono WGS84 válido; GeoJSON local y PostGIS remoto. |
| `area_m2` | Positivo, calculado con algoritmo versionado. |
| `geometry_algorithm_version` | Obligatorio con geometría. |
| `archived_at` | Nulo mientras admite nuevos registros; reversible. |

Una parcela con dependencias no puede borrarse físicamente. La parcela activa es preferencia local y no una columna remota de esta entidad.

### 2.3 `sectors`

| Campo | Regla |
|---|---|
| comunes | ID, propietario, versión y timestamps. |
| `parcel_id` | FK obligatoria a parcela del mismo propietario. |
| `number` | Entero positivo, único dentro de la parcela mientras no esté borrado. |
| `name` | Obligatorio, no vacío. |
| `sector_type` | `agricultural` o `apiary`. |
| `geometry_shape` | `square`, `rectangle` o `irregular`. |
| `geometry` | Polígono WGS84 válido y contenido completamente en la parcela. |
| `area_m2` | Positivo y coherente con geometría/versionado. |
| `centroid_lat`, `centroid_lon` | Derivados de geometría. |

El servidor revalida geometría y contención. Superposición relevante produce advertencia antes del guardado; la política exacta se versiona con la regla geométrica, no se infiere visualmente.

### 2.4 `crop_catalog`

Catálogo combinado: entradas oficiales sembradas y fichas personalizadas propiedad del agricultor.
Las entradas oficiales son de sólo lectura; las personalizadas se crean local-first y se sincronizan.

| Campo | Regla |
|---|---|
| `id` | UUID estable compartido entre seed local/remoto. |
| `owner_id` | Nulo para catálogo oficial; obligatorio para cultivo personalizado y protegido por RLS. |
| `source_type` | `system` o `custom`; inmutable después de crear. |
| `code` | Único e inmutable para `system`; único por propietario para `custom`. |
| `name` | Nombre en español. |
| `category` | Cultivo o apicultura. |
| `sowing_season_info` | Texto informativo. |
| `soil_requirements` | Texto informativo. |
| `water_needs` | Texto informativo. |
| `agricultural_info` | Texto informativo general. |
| `common_diseases` | Texto/lista informativa. |
| `asset_key` | Clave de SVG local aprobada; un cultivo personalizado usa el activo genérico definido en `master.md`. |
| `content_version` | Permite actualizar catálogo sin cambiar IDs. |
| `is_active` | Oculta entradas obsoletas sin romper historia. |

Seed obligatorio: frambuesa, arándanos, papas, sandía, melones, maíz, physalis, frutilla y apicultura.
Una ficha personalizada pertenece a un solo propietario, puede dejar campos informativos
explícitamente vacíos y no puede suplantar el código/nombre normalizado de una entrada oficial.

### 2.5 `seasons`

| Campo | Regla |
|---|---|
| comunes | ID, propietario, versión y timestamps. |
| `parcel_id` | FK a parcela del propietario. |
| `name` | Nombre corto obligatorio. |
| `start_date` | Fecha obligatoria. |
| `end_date` | Opcional; no anterior a inicio. |
| `status` | `active` o `closed`. |

Cerrar una temporada no reescribe asignaciones ni eventos previos.

### 2.6 `sector_crop_assignments`

| Campo | Regla |
|---|---|
| comunes | ID, propietario, versión y timestamps. |
| `sector_id` | FK al sector. |
| `crop_id` | FK al catálogo. |
| `season_id` | FK a temporada de la parcela del sector. |
| `effective_from` | Fecha obligatoria. |
| `effective_to` | Nula para la asignación vigente; no anterior a inicio. |
| `status` | `planned`, `active`, `ended` o `cancelled`. |
| `notes` | Opcional. |

Existe como máximo una asignación `active` no eliminada por sector. Una asignación `planned` puede
tener fecha futura, no altera el contexto activo y no puede solaparse con otra planificación del
mismo sector. Activar una rotación cierra la vigente y activa la planificada dentro de una
transacción; cancelar o reemplazar una planificación conserva su rastro y nunca modifica la
asignación histórica de una labor.

### 2.7 `labors`

Agregado raíz de todos los eventos `LABORES`.

| Campo | Regla |
|---|---|
| comunes | ID, propietario, versión y timestamps. |
| `parcel_id` | FK obligatoria. |
| `sector_id` | FK obligatoria dentro de la parcela. |
| `season_id` | FK a temporada aplicable. |
| `crop_assignment_id` | FK histórica opcional; no se reemplaza al cambiar cultivo. |
| `labor_type` | `irrigation`, `soil`, `fertilization`, `disease_pest_control`, `sowing`, `pruning`, `harvest`, `apiary` u `other`. |
| `other_labor_name` | Obligatorio y no vacío sólo cuando `labor_type=other`; nulo en los demás tipos. |
| `occurred_on` | Fecha agrícola obligatoria. |
| `notes` | Opcional. |
| `status` | `recorded`, `corrected` o `voided`. |
| `supersedes_labor_id` | FK opcional a la revisión anterior. |

Corregir una labor crea una revisión enlazada y marca la anterior como corregida; no sobrescribe silenciosamente el evento histórico. Una especialización existe sólo cuando coincide con `labor_type`.

### 2.8 `soil_measurements`

PK/FK 1:1 con `labors` de tipo `soil`.

| Campo | Regla |
|---|---|
| `labor_id`, `owner_id` | PK/FK compuesta al agregado. |
| `humidity_pct` | Opcional, entre 0 y 100 inclusive. |
| `ph` | Opcional, entre 0 y 14 inclusive. |
| `soil_temperature_c` | Opcional. |
| `ec_value`, `ec_unit` | Ambos nulos o ambos presentes; valor no negativo. |
| `nitrogen_value`, `nitrogen_unit` | Pareja opcional no negativa. |
| `phosphorus_value`, `phosphorus_unit` | Pareja opcional no negativa. |
| `potassium_value`, `potassium_unit` | Pareja opcional no negativa. |

Al menos un indicador debe ser no nulo. Nulo significa no medido; cero es una medición válida cuando el rango lo admite.

### 2.9 `irrigation_records`

PK/FK 1:1 con `labors` de tipo `irrigation`.

| Campo | Regla |
|---|---|
| `labor_id`, `owner_id` | PK/FK al agregado. |
| `irrigation_type` | `drip`, `sprinkler`, `furrow` o `gravity`. |
| `soil_type_code` | Código versionado aprobado en el contrato agronómico v1. |
| `plant_count` | Positivo cuando participa en cálculo. |
| `flow_lpm` | Positivo. |
| `duration_seconds` | Positivo. |
| `estimated_volume_liters` | Resultado positivo marcado como estimado. |

### 2.10 `crop_irrigation_rules`

Configuración versionada del cálculo determinista, liberable sólo después de aprobar
`contracts/irrigation-calculation.md`.

| Campo | Regla |
|---|---|
| `id` | UUID estable de la regla. |
| `crop_id` | Cultivo oficial o personalizado al que aplica; una regla personalizada pertenece al mismo propietario. |
| `rule_version` | Entero positivo e inmutable por cultivo. |
| `base_ml_per_plant` | Positivo y aprobado agronómicamente. |
| `soil_type_adjustments_bp` | Ajustes acotados por código de tipo de suelo aprobado. |
| `humidity_adjustments_bp` | Umbrales y ajustes acotados. |
| `temperature_adjustments_bp` | Umbrales y ajustes acotados. |
| `max_weather_adjustment_bp` | Límite del ajuste climático opcional. |
| `source_reference`, `reviewed_by`, `approved_at` | Evidencia obligatoria antes de activar. |
| `valid_from`, `retired_at` | Vigencia; las versiones retiradas siguen reproduciendo historial. |

No existe regla activa sin fuente, aprobación y al menos veinte vectores de prueba asociados al
contrato. Un cultivo personalizado sin regla aprobada puede registrarse, pero la calculadora debe
indicar que no existe recomendación disponible para ese cultivo.

### 2.11 `irrigation_estimates`

1:1 con `irrigation_records`; conserva reproducción de la recomendación.

| Campo | Regla |
|---|---|
| `irrigation_labor_id`, `owner_id` | PK/FK. |
| `algorithm_version` | Identificador inmutable de fórmula aprobada. |
| `rule_id`, `rule_version` | Regla exacta utilizada. |
| `plant_count`, `flow_lpm`, `input_duration_seconds` | Entradas canónicas. |
| `crop_id` | Cultivo usado para la regla. |
| `soil_type_code` | Clasificación de suelo usada por la regla. |
| `soil_humidity_pct`, `temperature_c` | Opcionales según disponibilidad. |
| `weather_snapshot` | Sólo variables normalizadas usadas, proveedor y momento; no respuesta cruda. |
| `weather_availability` | `current`, `stale_not_used`, `unavailable` o `not_required`. |
| `variables_used` | Lista/versionado de entradas efectivas. |
| `limitations` | Códigos estables, incluido cálculo sin clima actual. |
| `estimated_liters` | Resultado determinista. |
| `recommended_duration_seconds` | Resultado determinista. |
| `calculated_at` | Instante de ejecución. |

Las entradas insuficientes o no positivas no crean una estimación utilizable. El snapshot queda sujeto al gate contractual del proveedor definido en `research.md`.

### 2.12 `production_records`

PK/FK 1:1 con `labors` de tipo `harvest`.

| Campo | Regla |
|---|---|
| `labor_id`, `owner_id` | PK/FK. |
| `quantity` | Positiva. |
| `unit` | Unidad métrica admitida, inicialmente kilos u otra autorizada por spec/regla. |
| `quality` | Texto descriptivo no vacío; una taxonomía futura requiere especificación separada. |

Parcela, sector, cultivo, temporada, fecha y observaciones se obtienen del agregado labor.

### 2.13 `apiary_inspections`

PK/FK 1:1 con `labors` de tipo `apiary`, sólo en sector apícola.

| Campo | Regla |
|---|---|
| `labor_id`, `owner_id` | PK/FK. |
| `task_type` | Texto obligatorio que describe la tarea apícola realizada. |
| `hive_count` | Entero no negativo. |
| `responsible_name` | Texto descriptivo; nunca FK a usuario. |
| `queen_status` | Dato de inspección. |
| `brood_status` | Estado de postura. |
| `feeding_status` | Dato de alimentación. |
| `diseases` | Observación estructurada/textual acotada. |
| `pests` | Observación estructurada/textual acotada. |
| `super_installed` | Booleano/nulo si no fue observado. |

### 2.14 `photos`

| Campo | Regla |
|---|---|
| comunes | ID, propietario, versión y timestamps. |
| `sector_id` | FK opcional. |
| `labor_id` | FK opcional. |
| `origin` | `camera` o `gallery`. |
| `captured_at` | Fecha disponible de captura/selección. |
| `description` | Opcional. |
| `mime_type`, `byte_size`, `sha256` | Metadata validada obligatoria. |
| `remote_path` | Ruta privada inmutable; nula hasta confirmar upload. |

Al menos `sector_id` o `labor_id` debe existir y pertenecer al propietario. Drift añade `local_path`, estado de archivo/upload y error. El archivo no se guarda como BLOB.

### 2.15 `reminders`

| Campo | Regla |
|---|---|
| comunes | ID, propietario, versión y timestamps. |
| `sector_id` | FK opcional. |
| `reminder_type` | Fertilización, riego, revisión apícola, cosecha u otra labor permitida. |
| `title` | Obligatorio. |
| `scheduled_at` | Fecha/hora con zona de origen conservada. |
| `description` | Opcional. |
| `status` | `scheduled`, `completed` o `cancelled`; vencido se deriva por reloj. |
| `completed_at`, `cancelled_at` | Coherentes con estado. |

El permiso de notificación no pertenece a la entidad: se mantiene como estado local de plataforma. Completar/cancelar impide nuevas ocurrencias.

### 2.16 `device_installations`

Tabla remota técnica para FCM, no representa usuarios adicionales.

| Campo | Regla |
|---|---|
| `id` | UUID de instalación. |
| `owner_id` | Propietario autenticado. |
| `fcm_token` | Cifrado/protegido y único por instalación activa. |
| `platform` | Sólo `android`. |
| `app_version` | Diagnóstico de compatibilidad. |
| `refreshed_at`, `last_seen_at`, `disabled_at` | Ciclo de vida y limpieza. |

## 3. Local-only Drift entities

### 3.1 `sync_outbox`

| Campo | Regla |
|---|---|
| `operation_id` | UUID PK estable entre reintentos. |
| `device_id`, `owner_id` | Ámbito de ejecución. |
| `aggregate_type`, `aggregate_id` | Agregado afectado. |
| `action` | `create`, `update`, `archive`, `delete` o `resolve_conflict`. |
| `base_version` | Versión remota editada; nula para creación. |
| `payload` | Snapshot/version contractual del agregado, sin archivos binarios. |
| `depends_on_operation_id` | Dependencia causal opcional. |
| `state` | `pending`, `sending`, `retry_wait`, `blocked`, `conflict` o `done`. |
| `attempt_count`, `next_attempt_at`, `last_error_code` | Control de reintento. |
| `created_at` | Orden causal local. |

Operaciones `sending` vuelven a `pending` al recuperar un proceso interrumpido. `done` puede compactarse sólo después de conservar el recibo necesario.

### 3.2 `sync_cursors`

Una fila por propietario y stream de protocolo: `owner_id`, `stream`, `last_change_seq`, `updated_at`. El cursor sólo avanza en la misma transacción que aplica todos los cambios de la página.

### 3.3 `local_conflicts`

Refleja `sync_conflicts`: ID, agregado, operación, versión base, snapshot local, snapshot remoto, versión remota, estado, elección, timestamps y error de resolución. La fila de dominio permanece en `sync_state=conflict` hasta confirmar la resolución.

### 3.4 `form_drafts`

Clave compuesta por propietario, ruta/tipo de formulario e identidad de contexto; payload validable, fecha de actualización y versión de schema. No entra a outbox. Se elimina al confirmar o cancelar explícitamente.

### 3.5 `local_preferences`

Propietario, `active_parcel_id` opcional, preferencias permitidas y marcas de onboarding. No almacena tokens ni decisiones remotas de autorización.

### 3.6 `local_session_state`

Sólo metadata no secreta: propietario, base local asociada, último acceso y estado bloqueado. Tokens viven en almacenamiento seguro.

### 3.7 `weather_cache`

Clave de ubicación/parcela, proveedor, variables normalizadas, `observed_at`, `fetched_at`, `expires_at`, estado y error. La respuesta cruda no se persiste. Un valor expirado nunca se ofrece como actual.

### 3.8 `notification_bindings`

Relaciona recordatorio/ocurrencia con ID Android, fecha programada, precisión, permiso observado, última reconciliación y estado. Permite cancelar y deduplicar local/FCM.

### 3.9 `ai_threads` y `ai_messages`

- `ai_threads`: propietario, contexto activo referenciado, fecha y posición/estado local.
- `ai_messages`: ID de cliente, rol `user|assistant|system_notice`, texto, fecha, estado `draft|sending|sent|error`, ID server/modelo/política opcionales y código de disclaimer.

No se sincronizan como datos agrícolas en el MVP. No contienen fotografía, credencial, acción ejecutable ni resultado crítico.

## 4. Server-only synchronization entities

### 4.1 `sync_operations`

Recibo idempotente único por `(owner_id, operation_id)`: hash del request, status final, versión, conflicto/error y respuesta mínima. Repetir la misma operación devuelve el mismo resultado; mismo ID con hash distinto se rechaza.

### 4.2 `sync_changes`

Bitácora append-only: `change_seq` global/monotónico, propietario, agregado, acción, versión, payload o tombstone y `changed_at`. Índice principal `(owner_id, change_seq)`.

### 4.3 `sync_conflicts`

ID, propietario, agregado, operación, versión base, candidato local, snapshot canónico, versión canónica, estado `open|resolution_pending|resolved`, elección, operación de resolución y timestamps. Se conserva después de resolver para auditoría.

## 5. Relationships and aggregate boundaries

```text
auth.users 1 ── 1 profiles
profiles   1 ── N parcels
parcels    1 ── N sectors
parcels    1 ── N seasons
profiles   1 ── N crop_catalog (sólo source_type=custom)
sectors    1 ── N sector_crop_assignments N ── 1 crop_catalog
seasons    1 ── N sector_crop_assignments
parcels    1 ── N labors N ── 1 sectors
labors     N ── 0..1 sector_crop_assignments
labors     1 ── 0..1 soil_measurements
labors     1 ── 0..1 irrigation_records 1 ── 1 irrigation_estimates N ── 1 crop_irrigation_rules
labors     1 ── 0..1 production_records
labors     1 ── 0..1 apiary_inspections
sectors    1 ── N photos
labors     1 ── N photos
sectors    1 ── N reminders
```

### Aggregate rules

- Parcela y sectores son agregados separados con validación de contención server-side.
- Cambiar cultivo modifica atómicamente asignación anterior, nueva asignación y evento histórico.
- Planificar/cancelar una rotación no modifica la asignación activa; activarla aplica la transición
  atómica definida en el contrato de dominio.
- Labor y su única especialización se validan/persisten/sincronizan como un agregado.
- Foto usa pipeline de archivo más metadata; la asociación sólo aparece confirmada después de persistencia local estable.
- Recordatorio y binding Android se reconcilian después de confirmar el recordatorio local; una falla de plataforma no revierte el dato.

No se usan cascadas destructivas sobre historia agrícola. FKs históricas usan `RESTRICT`; archivo/tombstone preserva la relación.

## 6. Index strategy

### PostgreSQL/Supabase

- B-tree `owner_id` en cada tabla privada RLS.
- Dependientes: `(owner_id, parcel_id)` y/o `(owner_id, sector_id)`.
- Único parcial de sector `(owner_id, parcel_id, number) WHERE deleted_at IS NULL`.
- Único parcial de asignación vigente `(owner_id, sector_id) WHERE status='active' AND deleted_at IS NULL`.
- Restricción/consulta de solapamiento para asignaciones `planned` por propietario, sector y rango efectivo.
- Cultivo personalizado único por `(owner_id, normalized_name)` y catálogo oficial único por `code`.
- Historial: `(owner_id, occurred_on DESC)`, `(owner_id, parcel_id, occurred_on DESC)`, `(owner_id, sector_id, occurred_on DESC)` y cultivo/temporada donde el filtro lo exige.
- Recordatorios activos: `(owner_id, scheduled_at) WHERE status='scheduled' AND deleted_at IS NULL`.
- Fotos por sector/labor y estado/tombstone.
- `sync_operations` único `(owner_id, operation_id)`.
- `sync_changes (owner_id, change_seq)`.
- Conflictos abiertos por propietario/fecha.
- GiST en geometrías de parcela y sector.

### Drift

- Los mismos índices de navegación/historial adaptados a SQLite.
- Outbox `(state, next_attempt_at, created_at)` y por `aggregate_id`.
- Entidades `(sync_state, local_updated_at)` para resumen global.
- Unicidad de número de sector y asignación vigente equivalente a remoto.
- Fotos por estado de upload y relación.
- Weather cache por parcela/expiración; recordatorios por fecha/estado.

Cada índice debe demostrar una consulta de spec o una restricción; no crear índices especulativos.

## 7. State transitions

### Parcel

`draft(local only) -> active -> archived -> active(restored)`  
`active -> deleted` sólo si no existen dependencias y la operación está permitida; por defecto se archiva.

### Season and crop assignment

`season active -> closed`  
`assignment planned -> active -> ended`; `planned -> cancelled`. Activar una rotación cierra la
vigente en la misma transacción y nunca ocurre antes de `effective_from`.

### Labor revision

`recorded -> corrected` cuando una nueva labor la supersede.  
`recorded -> voided` sólo con confirmación y auditoría; especialización permanece trazable.

### Reminder

`scheduled -> completed` o `scheduled -> cancelled`. `overdue` se deriva del reloj y no crea otro estado persistido.

### Photo local/upload

`preview -> local_pending -> uploading -> synced`  
`local_pending|uploading -> upload_error -> uploading`  
`local_pending -> deleted_local` cancela operaciones; `synced -> deleted_pending -> tombstoned`.

### Sync item

`pending -> sending -> done`  
`sending -> pending` tras interrupción  
`sending -> retry_wait -> pending` en error transitorio  
`sending -> blocked` en error corregible/autorización  
`sending -> conflict -> pending(resolve) -> done`.

### Conflict

`open -> resolution_pending -> resolved`; cualquier falla vuelve a `open` conservando ambas versiones.

## 8. Derived views and queries

- `history_events`: proyección local que combina labor, especialización y cambio de cultivo, ordenada por fecha e ID estable; no duplica datos.
- `active_crop_by_sector`: asignación con fin nulo, útil para nuevos formularios; nunca reemplaza FK histórica.
- `planned_crop_rotation`: próximas asignaciones por sector, sin modificar `active_crop_by_sector`.
- `sync_summary`: conteos por estado, último respaldo y progreso de ciclo para la UI.
- `parcel_dashboard`: métricas agregadas locales y clima cacheado opcional.
- `export_snapshot`: transacción de lectura que fija conjuntos y estado de sync al inicio del XLSX.

Todas las vistas remotas respetan RLS y no son una vía alternativa de escritura.

## 9. Migration and seed policy

- Drift incrementa `schemaVersion`, conserva snapshot por versión y prueba upgrade sin pérdida.
- PostgreSQL usa migraciones append-only revisables; nunca ediciones manuales de producción como fuente de verdad.
- El catálogo oficial usa IDs/códigos estables idénticos en asset local y seed remoto; los cultivos
  personalizados usan UUID local, `owner_id` y el activo genérico aprobado por `master.md`.
- Nuevas columnas sincronizables requieren compatibilidad de lectura entre al menos la app actual y la versión inmediatamente anterior durante rollout.
- Cambiar fórmula de riego o geometría crea una nueva versión de algoritmo; no recalcula historia silenciosamente.

## 10. Model validation checklist

- [ ] Todo registro histórico conserva parcela, sector, cultivo/asignación y temporada aplicables.
- [ ] Nulo y cero permanecen distinguibles en suelo.
- [ ] Sólo existe una especialización compatible por labor.
- [ ] Un sector no referencia otra parcela/propietario y su geometría está contenida.
- [ ] Una asignación histórica no cambia al cambiar el cultivo vigente.
- [ ] Una rotación planificada no cambia el cultivo vigente ni se solapa con otra planificación.
- [ ] Un cultivo personalizado sólo es visible/modificable por su propietario y no altera el seed oficial.
- [ ] “Otra labor” conserva nombre descriptivo y no crea una especialización incompatible.
- [ ] Toda estimación conserva tipo de suelo y regla/versión aprobada.
- [ ] Un responsable apícola nunca crea identidad o autorización.
- [ ] Toda revisión apícola conserva el tipo de tarea.
- [ ] Un archivo fotográfico local es estable antes de insertar metadata.
- [ ] Un recordatorio persiste aunque falle/sea denegada la notificación.
- [ ] Outbox y agregado confirman o revierten juntos.
- [ ] Pull y cursor confirman o revierten juntos.
- [ ] Conflicto conserva ambas versiones hasta resolución confirmada.
- [ ] XLSX se construye desde un snapshot consistente y trazable.
