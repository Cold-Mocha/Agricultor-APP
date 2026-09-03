# Implementation Plan: AgroCampo Functional Core - Módulo 002

**Branch**: `002-agrocampo-functional-core` | **Date**: 2026-08-29 | **Spec**: [spec.md](./spec.md)

**Input**: Constitución 2.0.0, especificación 002, artefactos 001, `master.md` y auditoría del código Flutter, esquema Drift v9, migraciones/funciones Supabase y pruebas existentes.

## Summary

El Módulo 002 completa el núcleo funcional agrícola sobre la implementación parcial actual. Mantiene Flutter, Riverpod, `go_router`, Drift y Supabase; no crea otra aplicación ni reescribe los módulos existentes. El trabajo comienza estabilizando sesión, persistencia y sincronización. Después cierra, por dependencia, los flujos de territorio y contexto activo, temporadas/asignaciones de cultivo, labores/producción, riego por goteo, historial y las integraciones acotadas.

La UI seguirá leyendo exclusivamente el estado operativo de Drift. Cada mutación sincronizable confirmará entidad y outbox en una sola transacción. El coordinador enviará operaciones mediante un protocolo Supabase idempotente por entidad y sólo marcará `done/synced` después de un ACK que pruebe que el agregado fue aplicado o ya había sido aplicado con el mismo contenido. El diseño preserva las 24 tablas actuales y agrega sólo `agricultural_seasons` y `sector_irrigation_configs`; `crop_seasons` se conserva físicamente y evoluciona como asignación temporal de cultivo para no perder datos.

## Technical Context

**Language/Version**: Flutter 3.47.0, Dart 3.13.x, Kotlin/Java 17 para integración Android.

**Primary Dependencies**: `flutter_riverpod` 3.4.2, `go_router` 18.0.0, Drift 2.34.x, `supabase_flutter` 2.17.2, `flutter_map` 8.3.2, `latlong2` 0.10.1, `geolocator` 14.0.3, `flutter_local_notifications` 22.3.0, `workmanager` 0.10.9, `connectivity_plus` 7.3.1, `flutter_secure_storage` 10.3.1 y `local_auth` 3.0.2. El conjunto es compatible con Flutter 3.47/Dart 3.13 y Android SDK 24.

**Storage**: SQLite mediante Drift como fuente operativa local; PostgreSQL/Supabase como respaldo sincronizado; Android Keystore mediante `flutter_secure_storage` para material de sesión. No se agregan almacenes paralelos.

**Testing**: `flutter_test`, `integration_test`, `mocktail`, pruebas Drift con archivo temporal y reapertura, pruebas de migración con snapshots reales, Supabase CLI + pgTAP, pruebas de widget/golden/semántica y pruebas instrumentadas Android para biometría, GPS/mapa, notificaciones y ciclo de vida en background.

**Target Platform**: Android API 24+, `compileSdk`/`targetSdk` 36.

**Project Type**: Aplicación móvil Flutter con backend administrado Supabase y Edge Functions acotadas.

**Performance Goals**: guardar localmente sin esperar red; responder las consultas comunes de contexto e historial en menos de 2 segundos p95 con 20 parcelas, 200 sectores y 10.000 eventos; procesar 100 operaciones pendientes sin duplicados ni pérdidas; mantener interacción de mapa y formularios fluida en dispositivos Android soportados.

**Constraints**: offline-first; datos previos preservados; una sola cuenta propietaria a la vez; sin reescritura; geometría estable salvo edición explícita; cálculo de goteo determinista y sin IA; claves privadas sólo server-side; mapa/clima/AgroIA degradables; UX según `master.md`; ningún flujo local depende de una respuesta Supabase.

**Scale/Scope**: nueve historias 002 sobre una aplicación Flutter existente, 24 tablas Drift v9, 11 migraciones Supabase existentes, 21 features Flutter y aproximadamente 17 tipos de datos operativos/técnicos. Se agregan dos tablas y se modifican sólo los campos, índices, repositorios, pantallas y contratos que bloquean los flujos 002.

## Existing-State Audit and Disposition

La clasificación siguiente es vinculante para la futura generación de tareas. “Reemplazar” significa sustituir una implementación puntual defectuosa detrás del mismo límite, nunca reconstruir la feature completa.

| Área | Evidencia actual | Decisión 002 | Motivo y límite |
|---|---|---|---|
| Autenticación Supabase | `AuthRepository`, `SupabaseAuthRepository`, `SecureSessionStore`, `SessionController`; Android usa `FlutterActivity`, no declara `USE_BIOMETRIC` y sus temas no son AppCompat | **Corregir y extender** | Validar/restaurar la sesión real, distinguir bloqueada/firmada/offline y agregar desbloqueo biométrico opcional con los cambios Android mínimos requeridos. No cambiar proveedor ni almacenar contraseña. |
| Cliente Supabase | Cliente creado en bootstrap y usos directos de `Supabase.instance.client` | **Reemplazar uso puntual** | Inyectar una única instancia mediante Riverpod; eliminar singletons no inicializados en páginas/gateways tocados por 002. |
| Parcelas | Repositorio local-first, selección activa y outbox | **Reutilizar y corregir** | Conservar transacción; incluir archivo/edición/eliminación en payload/tombstone y cargar datos al editar. |
| Sectores y geometría | Repositorio, `PolygonGeometry`, GPS y mapa de creación | **Reutilizar y extender** | Agregar autocruce, render de sectores guardados, modo explícito de edición, cancelar/confirmar y fallback local. |
| Contexto agrícola | Preferencia de parcela; varias pantallas presuponen un solo sector | **Crear mínimo y corregir** | `AgriculturalContextController` persistido para parcela/sector/temporada/asignación; reemplazar `getSingleOrNull` por selectores visibles. |
| Catálogo/cultivos | Seed oficial, cultivos personalizados locales y `CropRotation` | **Reutilizar y extender** | Hacer visible/usable el catálogo combinado, sincronizar personalizados, admitir editar/archivar y completar rotación/intercambio. |
| Temporadas | `crop_seasons` mezcla temporada y asignación | **Extender y crear** | Crear temporada agrícola propia y conservar `crop_seasons` como asignación física migrada, sin renombrado destructivo. |
| Labores | Repositorio + outbox, tipos y `detailsJson` | **Reutilizar y extender** | Mantener especialización JSON pragmática; completar contexto, campos por tipo, edición trazable y payload. |
| Producción | Repositorio y tabla separados, formulario básico | **Corregir y extender** | Guardar cosecha+producción como un agregado/una transacción y mostrar un solo evento. |
| Riego | Calculadora entera determinista, reglas y registros/estimaciones | **Reutilizar y extender** | Crear configuración permanente, usar cultivo real, persistir snapshot/estimación y outbox. No implementar otros cálculos. |
| Historial | Proyección local de varias tablas | **Corregir y extender** | Consultas indexadas por sector/temporada; incorporar temporadas/asignaciones, etiquetas y estado sync sin duplicar cosecha. |
| Recordatorios | Drift, repositorio, scheduler local y notificaciones | **Reutilizar y corregir** | ID Android estable, fecha real, editar/completar/cancelar y reconciliar al arranque/reinicio. |
| Open-Meteo | Gateway + Edge Function + caché local | **Reutilizar y extender** | Inyectar/refrescar, agregar pronóstico normalizado y degradación; coordenada de respaldo y endpoint permanecen server-side. |
| AgroIA | Gateway/Edge Function sin tools; mensajes locales | **Reutilizar y corregir** | Sólo texto escrito por usuario, cliente inyectado, estados/idempotencia de reintento; no contexto privado ni acciones. |
| Apicultura | Modelo y flujo especializado existentes | **Reutilizar sin rediseño** | Ajustar sólo selección/contexto si es afectado; colmenas/revisiones continúan especializadas. No es gate 002. |
| Drift | 24 tablas y migraciones v1-v9 | **Reutilizar y migrar** | Evolución aditiva v10, dos tablas nuevas, campos/índices/constraints faltantes y pruebas de preservación. |
| Outbox/coordinador | Estados y esqueleto existen | **Corregir y extender** | Activar máquina de estados, dependencias, retry, tombstones, adapters por entidad y cursor transaccional. |
| RPC Supabase | `sync_push` sólo aplica parcelas pero ACKea todo; pull es genérico | **Reemplazar semántica** | Nueva migración append-only con resultados por operación y codecs por agregado; no ACK de operación no aplicada. |
| RLS/funciones | Propiedad directa por `auth.uid()`, RLS y Edge Functions existentes | **Reutilizar y extender** | Conservar seguridad proporcional; ampliar tablas/policies/tests para nuevas entidades. |
| Pruebas | Cobertura unitaria e “integración” mayormente en memoria/fakes | **Reutilizar y fortalecer** | Mantener pruebas válidas y sumar archivo/reapertura, migración real, Supabase local y Android instrumentado. |

La auditoría detallada y las alternativas están en [research.md](./research.md).

## Constitution Check

### Gate previo a Phase 0

| Principio v2.0.0 | Estado | Evidencia del plan |
|---|---|---|
| I. Funcionalidad antes que sobreingeniería | PASS | Reutiliza la base actual; sólo dos tablas nuevas y refactors ligados a defectos concretos de sesión, contexto, datos o sync. |
| II. Offline-first | PASS | Drift sigue siendo autoridad; cada escritura local incluye outbox; servicios externos degradan de forma aislada. |
| III. Flujos completos | PASS | Las fases se cierran verticalmente con UI, dominio, persistencia, reapertura, sync/degradación y pruebas observables. |
| IV. Modelo agrícola estable | PASS | Se explicitan temporada y asignación temporal; rotación/intercambio conservan historia; polígonos sólo cambian en modo edición. |
| V. Cálculos deterministas | PASS | Motor de goteo puro/versionado; misma entrada produce mismo resultado; IA excluida. |
| VI. Integraciones simples/configurables | PASS | Gateways existentes, cliente/configuración inyectados y secretos remotos; sin plataforma de integración adicional. |
| VII. Seguridad proporcional | PASS | Supabase se mantiene; biometría sólo desbloquea una sesión válida; logout bloquea datos sin borrarlos. |
| VIII. UX agrícola | PASS | Contexto activo visible, navegación normal, fallback textual de mapa y estados según `master.md`. |
| IX. Calidad suficiente | PASS | Pruebas según riesgo, incluyendo persistencia/reinicio, migración, ACK real, rotación, cálculo y Android nativo. |
| Límites técnicos y de alcance | PASS | Android/Flutter, una cuenta propietaria, sin web/roles/IoT/IA contextual/riego avanzado. |

### Revisión posterior a Phase 1 design

**PASS**. El modelo agrega únicamente las entidades que no pueden representarse correctamente con las 24 tablas actuales; los contratos extienden límites existentes y no introducen infraestructura empresarial. No quedan excepciones constitucionales ni decisiones técnicas sin resolver. La regla agronómica de goteo continúa como gate de datos: la infraestructura puede implementarse, pero ninguna recomendación se habilita sin regla y vectores aprobados.

## Project Structure

### Documentation (this feature)

```text
specs/002-agrocampo-functional-core/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── spec.md
├── checklists/
│   └── requirements.md
└── contracts/
    ├── agricultural-context.md
    ├── integration-boundaries.md
    ├── irrigation-drip-v2.md
    ├── local-write-contract.md
    └── sync-protocol-v2.md
```

`tasks.md` no se genera en esta ejecución; corresponde a `$speckit-tasks`.

### Source Code (repository root)

```text
lib/
├── app/
│   ├── bootstrap/                  # Instancia/configuración de servicios
│   ├── providers.dart              # DI de cliente, DB, contexto y gateways
│   └── routing/                    # Rutas visibles existentes
├── core/
│   ├── auth/                       # Supabase, sesión segura, biometría
│   ├── database/
│   │   ├── app_database.dart       # Drift v10 y migración preservadora
│   │   ├── daos/                   # Consultas/outbox/cursor/conflictos
│   │   └── tables/                 # 24 actuales + 2 nuevas
│   ├── geometry/                   # Validación de polígonos
│   ├── notifications/              # Scheduler y reconciliación local
│   └── sync/
│       ├── protocol/               # DTO/codec/resultados por operación
│       ├── conflicts/              # Mantener local/remoto por entidad
│       └── sync_coordinator.dart    # Máquina outbox/push/pull durable
├── features/
│   ├── auth/                       # Login, bloqueo y biometría
│   ├── parcels/                    # Parcelas y activa
│   ├── sectors/                    # Lista/detalle y contexto
│   ├── map/                        # Dibujo/edición explícita/fallback
│   ├── crops/                      # Temporadas, asignaciones y catálogo
│   ├── labors/                     # Formularios estructurados
│   ├── production/                 # Especialización de cosecha
│   ├── irrigation/                 # Configuración, cálculo y registro
│   ├── history/                    # Timeline local filtrable
│   ├── reminders/                  # CRUD y avisos offline
│   ├── weather/                    # Pronóstico/alertas degradables
│   ├── agro_ai/                    # Chat general sin contexto privado
│   ├── apiary/                     # Modelo especializado conservado
│   └── sync_status/                # Estado, reintento y conflictos
└── shared/                         # Componentes/tokens ya existentes

supabase/
├── migrations/
│   └── 0012_functional_core.sql    # Aditiva; nombre final según secuencia
├── functions/
│   ├── agro-ai/
│   └── weather-proxy/
└── tests/database/                 # pgTAP de RLS y protocolo real

test/                               # Dominio, Drift, widgets y contratos
integration_test/                   # Flujos con almacenamiento persistente
android/                            # Biometría/permisos/notificaciones
```

**Structure Decision**: conservar la raíz Flutter y los módulos actuales. Los archivos nuevos se ubican dentro de la feature o capacidad transversal que ya posee la responsabilidad; no se crea `mobile/`, backend propio, paquete compartido ni segunda arquitectura.

## Architecture

### Flujo operativo

```text
UI / Controller Riverpod
        ↓ comando validado
Repository / domain rule
        ↓ una transacción
Drift domain row(s) + SyncOutbox
        ↓ stream local
UI muestra guardado local/pendiente
        ↓ trigger oportunista
SyncCoordinator → SyncGateway → Supabase RPC
        ↓ resultado applied/duplicate real
Drift ACK/version/sync state
        ↓ pull page + cursor en una transacción
UI observa estado actualizado
```

- Los controllers de pantalla coordinan formularios, permisos y navegación, pero no hablan directamente con Supabase ni plugins.
- Las reglas críticas permanecen puras: polígonos, rangos temporales, rotación/intercambio y cálculo de riego.
- Los CRUD simples pueden llamar directamente al contrato de repositorio existente; no se crean casos de uso vacíos.
- El `AgriculturalContextController` resuelve y persiste la selección válida; las rutas pueden fijar un contexto para evitar que un cambio global redirija un formulario abierto silenciosamente.
- La UI observa Drift incluso después del sync. Pull nunca se convierte en una fuente paralela de pantalla.

### Sesión y acceso local

1. El primer login usa `SupabaseAuthRepository` y guarda refresh token/owner de forma segura.
2. Al arrancar, el controller requiere ambos datos, intenta reconstruir/validar la sesión cuando hay red y reconoce una sesión previamente válida para trabajo offline según el contrato.
3. Si el usuario habilitó biometría y la sesión no fue cerrada, `BiometricUnlockGateway` permite abrir el espacio local del mismo propietario; no crea ni refresca una identidad.
4. Logout detiene/coalesciona sync, cierra el acceso a la DB del propietario, borra token y habilitación de desbloqueo, y conserva archivo/outbox para un login posterior del mismo propietario.
5. Un propietario distinto no recibe providers, queries ni rutas del espacio anterior.

### Contexto agrícola

El contexto conceptual es `owner → activeParcel → activeSector? → activeSeason? → activeCropAssignment?`. La parcela es obligatoria cuando existe al menos una; sector, temporada y asignación se resuelven por operación. Formularios abiertos capturan un `contextRevision` y su identidad inicial: si cambia la selección global, deben conservar y mostrar su contexto original o pedir confirmar/descartar antes de cambiarlo.

### Territorio y mapas

- La geometría WGS84 confirmada permanece en Drift y es independiente de teselas/proveedor.
- Visualización y edición son estados separados. Entrar a edición crea un borrador; arrastrar/agregar/quitar vértices modifica sólo el borrador; confirmar valida y persiste; cancelar descarta.
- Validación local: tres puntos distintos, coordenadas válidas, anillo no autocruzado, área positiva y sector contenido en parcela. Supabase repite constraints espaciales al sincronizar.
- GPS requiere permiso foreground; denegación ofrece dibujo manual. Sin mapa remoto se muestran overlay/fallback local y lista equivalente accesible.

## Data and Migration Design

El modelo completo está en [data-model.md](./data-model.md). Las decisiones principales son:

- subir Drift de v9 a v10 mediante migración aditiva y comprobada;
- reconciliar `migration_policy.dart` con la versión real para eliminar la divergencia actual;
- crear `agricultural_seasons` y `sector_irrigation_configs`;
- conservar físicamente `crop_seasons`, añadir `agricultural_season_id` y metadata, y tratarla en dominio como `SectorCropAssignment`;
- añadir relaciones históricas explícitas a labores, producción, registros/estimaciones de riego;
- completar `remote_version`, `sync_state`, timestamps locales/remotos y `deleted_at` sólo en las entidades 002 que necesitan update/delete/sync;
- preservar `Labors.detailsJson` para datos específicos por tipo, con schema/version y validación de dominio, en vez de crear una tabla por labor;
- añadir índices que respaldan selección activa, rangos de asignación, timeline por sector y selección de outbox;
- introducir tombstones remotos/locales donde una eliminación sincronizada pueda resucitar datos;
- generar snapshots Drift reales y probar upgrade de fixtures, no usar el manifiesto JSON actual como sustituto del esquema.

La migración crea una temporada importada determinista por parcela que posea asignaciones/eventos antiguos, enlaza las filas existentes sin cambiar IDs, fechas ni geometrías, y deja trazabilidad del backfill. No borra ni recalcula resultados históricos.

## Offline and Synchronization Strategy

### Escritura local

Cada repository 002 cumple [local-write-contract.md](./contracts/local-write-contract.md): valida ownership/contexto, escribe el agregado completo, crea una operación outbox con payload contractual y confirma todo en una transacción. Sólo entonces comunica “guardado local”. Fallas de SQLite revierten entidad y outbox y no muestran éxito.

### Protocolo y estado

El contrato [sync-protocol-v2.md](./contracts/sync-protocol-v2.md) corrige el corte actual sin cambiar la responsabilidad general:

- adaptadores/codecs allowlisted por agregado compartidos conceptualmente por push y pull;
- resultado individual `applied`, `duplicate`, `conflict`, `rejected` o `retryableError`;
- ACK únicamente para `applied|duplicate` del mismo `operationId` y hash;
- una entidad no soportada o payload inválido nunca se confirma;
- payload JSON estructurado y decodificación estricta, sin `Map.toString()`;
- estados `pending → sending → done`, `sending → retryWait`, `blocked` o `conflict` realmente persistidos;
- recuperación de `sending` después de cierre, backoff exponencial acotado con jitter y reintento manual sólo para fallas retryables;
- orden causal por `dependsOnOperationId` para parcela → sector → temporada/asignación → registro;
- pull por `change_seq`; toda página, cambios y cursor se confirman juntos;
- tombstones para delete/archivo y resolución explícita de conflictos por entidad soportada;
- triggers al guardar, iniciar/reanudar, cambiar conectividad, reintentar y WorkManager; una sola ejecución por propietario y triggers coalescidos.

### Despliegue progresivo por entidad

1. Corregir y probar `parcel` como corte canónico.
2. Habilitar `sector`, `agriculturalSeason`, `sectorCropAssignment` y `customCrop`.
3. Habilitar agregados `labor` (incluida producción/irrigación especializada) y `irrigationConfig`.
4. Habilitar `reminder` y las entidades 002 restantes.

Cada entidad sólo entra en la allowlist cliente/servidor cuando sus pruebas de apply, duplicate, conflict, tombstone, pull y RLS pasan. El coordinador no envía tipos sin handler remoto habilitado.

## Irrigation Design

El flujo se divide en cinco piezas:

1. **Configuración permanente**: plantas, goteros/distribución, caudal efectivo, presión u otros campos aprobados por sector y vigencia.
2. **Datos variables**: fecha, duración realizada, humedad/temperatura opcionales, regla/cultivo activo y clima normalizado opcional.
3. **Motor puro**: reutiliza `IrrigationCalculator`, enteros/unidades canónicas, regla y versión explícitas; no accede a UI, DB, red ni AgroIA.
4. **Resultado**: volumen, tiempo, explicación estructurada, advertencias y versiones.
5. **Registro histórico**: snapshot de configuración+inputs+resultado unido a una labor de riego y su asignación/temporada.

Una interfaz simple por método (`IrrigationRecommendationEngine`) permite agregar otras estrategias en otro módulo, pero 002 registra recomendaciones sólo de `drip`; no se crean implementaciones vacías de aspersión/surco/gravedad. El contrato y gate agronómico están en [irrigation-drip-v2.md](./contracts/irrigation-drip-v2.md).

## Integrations

Los límites se detallan en [integration-boundaries.md](./contracts/integration-boundaries.md).

### OpenStreetMap/GPS

- Reutilizar `flutter_map`, `latlong2`, `LocationGateway` y la geometría persistida; OpenStreetMap no usa API key.
- Solicitar ubicación foreground en contexto, nunca background.
- Renderizar parcela/sectores persistidos, separar selección/edición/confirmación y mantener alternativa textual.
- `PlacesGateway` deshabilitado no bloquea 002; búsqueda se implementa sólo si el proveedor configurado la admite sin ampliar el alcance.

### Open-Meteo

- Reutilizar `WeatherGateway`, caché y `weather-proxy`; Open-Meteo se configura server-side con coordenada de respaldo y endpoint opcional de cliente.
- Ampliar DTO normalizado a condiciones y pronóstico; no persistir payload crudo ni presentar el pronóstico como alerta oficial.
- La UI distingue actual/antiguo/no disponible; una alerta futura requerirá una fuente autoritativa independiente y nunca bloqueará cálculo/registro local.

### AgroIA

- Reutilizar Edge Function/gateway sin tools ni function calling.
- En 002 se envía sólo el texto escrito por el usuario y metadata técnica mínima; no se lee Drift/Supabase para enriquecer la consulta.
- `clientMessageId` estable y estado `draft|sending|sent|error` evitan duplicar pregunta/respuesta al reintentar.
- No calcula riego, analiza imágenes ni escribe datos.

### Biometría

- Adaptador pequeño sobre `local_auth` 3.0.2; cambiar `MainActivity` a `FlutterFragmentActivity` conservando el canal XLSX, declarar `USE_BIOMETRIC` y usar tema AppCompat compatible para evitar fallos en Android soportado.
- Opt-in posterior a login, fallback a autenticación remota y bloqueo ante cancelación/error.
- No guardar biometría, no crear PIN propio y no conservar habilitación después de logout.

### Recordatorios y alertas

- Drift es autoridad del recordatorio; ID Android se deriva de una asignación estable persistida, no de `hashCode` del proceso.
- Reconciliar pendientes tras bootstrap, reboot, edición, completar/cancelar y cambio de zona horaria.
- Permiso denegado mantiene el registro y muestra limitación. Alertas meteorológicas online usan notificación local sólo después de recibir/validar datos recientes y deduplicados.

## UX and Navigation

- Mantener las cinco ramas de `master.md`: Inicio, Sectores, Registrar, AgroIA y Más.
- Parcelas y contexto activo son accesibles desde Inicio; temporada/cultivo desde detalle de sector; labores/riego/producción desde Registrar o sector; historial desde sector/Más; sync, recordatorios y configuración desde Más.
- Todo formulario dependiente muestra parcela, sector, temporada y cultivo aplicables; ningún flujo presupone “el único sector”.
- Estados locales y sync usan texto+icono además de color: guardado local, pendiente, sincronizando, respaldado, error y conflicto.
- En el conflicto entre `master.md` 001 y la especificación 002 sobre contexto de AgroIA, 002 gobierna los datos enviados; `master.md` continúa gobernando presentación, disclaimer, navegación y accesibilidad.
- No se bloquea un flujo funcional por diferencias cosméticas menores; sí se preservan jerarquía, tokens, semántica, tamaños táctiles y alternativas accesibles.

## Implementation Phases and Dependency Order

### Phase 0 — Estabilizar sesión, persistencia y sincronización

1. Congelar contratos v2, obtener snapshot/fixtures Drift v9 y añadir pruebas que reproducen los defectos actuales.
2. Unificar cliente Supabase inyectado y corregir restauración/logout/aislamiento local.
3. Añadir biometría opcional sobre sesión válida.
4. Implementar migración Drift v10 preservadora, metadata/índices técnicos y pruebas de reapertura.
5. Reemplazar semántica RPC/coordinador por resultados por operación, codecs, estados, ACK real, cursor atómico, retry/backoff, dependencias y tombstones.
6. Probar el corte `parcel` end-to-end contra Supabase local antes de generalizar.

**Salida verificable**: login/reapertura/bloqueo/logout correctos; un guardado local sobrevive reinicio; ACK perdido no produce falso `synced`; una operación no soportada permanece visible y no es confirmada.

### Phase 1 — Territorio y contexto agrícola

1. Completar CRUD/archivo de múltiples parcelas y contexto activo persistido.
2. Crear controller/selectores de parcela/sector/temporada/asignación y retirar presunciones de sector único en flujos 002.
3. Completar validación geométrica, mapa de geometrías guardadas y modo explícito de edición.
4. Habilitar sync de parcela/sector y fallback sin mapa/GPS.

**Salida verificable**: tres parcelas y diez sectores por parcela no mezclan datos; geometrías sobreviven reinicio y sólo cambian tras confirmación explícita.

### Phase 2 — Temporadas, cultivos y rotación

1. Exponer CRUD/cierre de temporadas con estado planned/active/closed.
2. Migrar y usar `crop_seasons` como asignación temporal enlazada a temporada.
3. Completar catálogo combinado, custom crops editables/archivables y sync.
4. Implementar rotación planificada/efectiva e intercambio atómico de dos sectores.
5. Actualizar contexto activo sin reescribir eventos previos.

**Salida verificable**: rotaciones/intercambios conservan asociaciones históricas exactas antes y después de la fecha efectiva, offline y después de sync.

### Phase 3 — Labores estructuradas y producción

1. Completar selector/contexto y formularios por riego, fertilización, fitosanitarios, siembra, poda, cosecha y otra.
2. Validar schemas `detailsJson` por tipo y persistir referencias históricas.
3. Unificar cosecha+producción en una sola transacción/agregado y evento de historial.
4. Añadir edición/corrección trazable y sync de labor agregada.

**Salida verificable**: cada tipo se guarda offline, reaparece tras reinicio y se respalda una vez; cosecha se visualiza una sola vez.

### Phase 4 — Riego por goteo

1. Implementar configuración permanente versionada por sector.
2. Conectar configuración, asignación/cultivo real y reglas aprobadas al motor puro existente.
3. Mostrar resultado/explicación/advertencias; preservar estado “sin regla aprobada”.
4. Guardar labor+riego+estimación+snapshot en una transacción/outbox.
5. Habilitar sync y vectores aprobados sin implementar otro método de recomendación.

**Salida verificable**: mismos inputs/versiones producen resultado idéntico offline; cambio de configuración no altera historia; ausencia de clima no bloquea si los inputs locales bastan.

### Phase 5 — Historial sectorial

1. Crear consultas Drift indexadas/proyección unificada de temporadas, asignaciones, labores y especializaciones.
2. Incorporar agrupación/filtros y estados pendiente/error/conflicto.
3. Resolver etiquetas de cultivo oficial/personalizado y evitar duplicación de producción/riego.
4. Validar aislamiento por sector y rendimiento con fixture de escala.

**Salida verificable**: timeline correcto por sector/temporada, incluye eventos offline inmediatos y conserva el contexto de su fecha.

### Phase 6 — Recordatorios, clima y AgroIA

1. Completar CRUD/reconciliación de recordatorios y permisos Android.
2. Conectar refresh/caché/pronóstico Open-Meteo con estado de antigüedad; reservar alertas para una fuente autoritativa futura.
3. Corregir inyección, estados y reintento idempotente de AgroIA sin contexto privado.
4. Verificar degradación independiente de cada servicio.

**Salida verificable**: recordatorios sobreviven reboot; clima antiguo no aparenta vigencia; AgroIA conserva un solo mensaje al reintentar y no recibe datos privados.

### Phase 7 — End-to-end, regresión y preparación de entrega

1. Ejecutar escenarios completos offline 24 h/100 cambios/tres reinicios y reconexión.
2. Probar conflictos, tombstones, logout con pendientes y dos propietarios secuenciales.
3. Ejecutar pruebas Android nativas, accesibilidad/goldens y comparación con `master.md`.
4. Confirmar que capacidades 001 fuera de 002 siguen compilando y sus contratos no fueron degradados.
5. Documentar environment, migración/rollback operativo y evidencia de aceptación.

**Salida verificable**: SC-001..SC-017 aplicables pasan con evidencia persistida o visible; no hay falso respaldo, pérdida de datos ni alcance excluido.

## Testing Strategy

| Nivel | Cobertura requerida |
|---|---|
| Dominio unitario | Polígonos/autocruce/contención, rangos de temporada, rotación/intercambio, validación de labor, unidades/redondeo/explicación de goteo, selección de conflicto. |
| Drift | Constraints/índices, transacción agregado+outbox y rollback, queries por contexto, tombstones, archivo temporal cerrado/reabierto, estado sync durable. |
| Migraciones | Snapshot real v9→v10 con datos de las 24 tablas; rutas representativas previas; IDs/geometrías/eventos/resultados preservados; backfill determinista. |
| Repositorios | Cada agregado 002 genera payload/version/dependencia correctos; update/delete no dejan divergencia local-outbox. |
| Sync cliente | Estados, lotes, dependencia, ACK parcial/perdido, respuesta malformada, backoff, reinicio, cursor rollback, tombstone y ambas resoluciones. |
| Supabase/pgTAP | Apply por entidad, idempotencia/hash, unsupported sin ACK, RLS A/B/anon, control de versión, conflicto, tombstone, change_seq y FK. |
| Widget/golden/semántica | Contexto visible, formularios por tipo, edición mapa, timeline/filtros, estados offline/sync, bloqueo/biometría, recordatorios/clima/AgroIA. |
| Integración Flutter | Flujos con DB de archivo y reapertura real, no sólo `NativeDatabase.memory()`; reconexión a Supabase local cuando corresponda. |
| Android instrumentado/manual | `local_auth`, permisos GPS/notificación, mapa platform view, reboot/reprogramación, resume/background/WorkManager. |
| Rendimiento | 20 parcelas, 200 sectores, 10.000 eventos, 100 outbox; p95 de consultas comunes <2 s y sin bloqueo apreciable de UI. |

Los fakes siguen siendo válidos para errores deterministas de unidad, pero no cuentan como evidencia del flujo offline-first completo ni del ACK remoto.

## Compatibility with Module 001

- 001 sigue gobernando suelo, fotografías, apicultura, exportación y otras capacidades no exigidas como gate 002.
- Se mantienen rutas, tema, navegación, IDs, catálogo seed, repositorios y tablas válidas.
- Los cambios de schema son aditivos/preservadores; no se renombra ni borra `crop_seasons` ni resultados previos.
- La especialización apícola continúa separada y puede usar sector/temporada como contexto sin convertir colmenas en cultivos genéricos.
- Otros tipos de riego pueden seguir registrándose conforme a 001, pero 002 no les calcula recomendaciones.
- AgroIA es la única modificación funcional deliberada: 002 prohíbe adjuntar automáticamente contexto privado. El contrato de datos de 002 prevalece y la presentación de `master.md` se conserva.
- Refactors compartidos se limitan a cliente Supabase, contexto, persistencia y sync porque actualmente bloquean o pueden perder/inconsistir datos.

## Technical Risks

| Riesgo | Impacto | Mitigación/condición de avance |
|---|---|---|
| ACK falso o handler faltante | Pérdida silenciosa del respaldo | Allowlist cliente/servidor, resultado por operación y pruebas pgTAP antes de habilitar entidad. |
| Migración de `crop_seasons` | Historia temporal mal asociada | Snapshot v9, backfill determinista por parcela, conteos/IDs antes-después y rollback de transacción. |
| Contexto equivocado con múltiples sectores | Registros agrícolas contaminados | Controller persistido, FK/contexto validado y selector visible; tests con varias parcelas/sectores. |
| Complejidad de sync por muchas entidades | Retraso o defectos | Despliegue incremental por agregado; registro pequeño de codecs, no framework genérico. |
| Reglas agronómicas no aprobadas | Recomendación engañosa | Estado `crop_rule_unavailable`; gate de fuente/revisor/20 vectores antes de activar. |
| Restricciones Android background | Avisos/sync tardíos | Reconciliación foreground/bootstrap, WorkManager oportunista, estado visible; no prometer exactitud no concedida. |
| Mapa/proveedor no disponible | Bloqueo territorial | Geometría local, lista/fallback y dibujo manual sin GPS. |
| Sesión offline revocada no conocida | Acceso local hasta reconexión | Sesión previamente válida, bloqueo/logout local inmediato y revocación aplicada al conocerla; no afirmar autorización remota offline. |
| Divergencia 001/002 | Regresión o scope creep | Matriz de compatibilidad y gates por historia 002; regresión selectiva de 001. |

## Definition of Architectural Done

El plan queda listo para `$speckit-tasks` cuando:

- cada componente relevante está clasificado como reutilizar, extender, corregir, reemplazar o crear;
- el schema v10 y su backfill preservador están definidos;
- sesión/biometría/logout y contexto activo tienen contratos observables;
- el protocolo sync no permite ACK sin aplicación remota y cubre todos los estados exigidos;
- configuración, cálculo y registro de goteo están separados y versionados;
- fases cierran flujos verticales por dependencia y no por capas aisladas;
- pruebas distinguen mocks de persistencia/reapertura/ACK reales;
- Constitución 2.0.0, límites 002, compatibilidad 001 y `master.md` pasan sin excepción.

## Complexity Tracking

No se identifican violaciones constitucionales que requieran excepción. Las dos tablas nuevas representan conceptos ausentes e irreducibles; el registro de codecs sync y el gateway biométrico están justificados por seguridad de datos y confirmación remota, no por arquitectura anticipada.
