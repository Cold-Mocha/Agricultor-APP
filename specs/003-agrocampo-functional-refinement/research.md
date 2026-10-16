# Phase 0 Research: AgroCampo Functional Refinement - Módulo 003

## Scope and Method

Esta investigación resuelve únicamente decisiones técnicas abiertas por el spec 003. Se auditó el
código real de `/frontend` y `/backend`, sus dependencias, composición, APIs públicas, tablas Drift,
migraciones, repositorios, outbox, RPC/RLS, Edge Functions, pruebas, artefactos 001/002,
`master.md`, `jerarquía 01.md` y documentación de arquitectura. Graphify se usó como índice, pero su
grafo conserva rutas anteriores al split; toda conclusión se verificó en archivos actuales.

No se investigaron frameworks alternativos porque no existe una limitación que justifique cambiar
Flutter, Riverpod, go_router, Drift, Supabase ni la Feature-Based Architecture vigente.

## D3-001 — Conservar el backend local y el monorepositorio

**Decision**: Extender los módulos actuales de `/frontend` y `/backend`. `backend` continúa siendo
un paquete Flutter local dentro del APK, no un servidor. El frontend importa sólo
`package:agrocampo_backend/agrocampo_backend.dart`.

**Rationale**: `AgroCampoBackend.initialize()` ya compone Drift, sesión, sync e integraciones en un
`ProviderContainer`; los `*_api.dart` ofrecen un límite por feature y los tests de arquitectura lo
protegen. Es la estructura aprobada y funcional.

**Alternatives considered**:

- REST/microservicio: rechazado; duplicaría el backend local y rompería offline-first.
- Paquete o módulo de código `003`: rechazado; 003 es un incremento transversal, no un dominio.
- Fusionar frontend/backend: rechazado; elimina el desacoplamiento ya validado.

## D3-002 — Contratos públicos antes del trabajo paralelo

**Decision**: Versionar los DTOs/resultados en los APIs existentes y congelar los contratos Markdown
de `contracts/` antes de separar carriles frontend/backend.

**Rationale**: hoy la frontera física es correcta, pero inputs como `LaborFormInput` e
`IrrigationFormInput` aplanan datos y errores. Contratos discriminados permiten probar backend sin UI
y frontend con dobles sin importar infraestructura.

**Alternatives considered**:

- Compartir repositorios/filas Drift: rechazado por acoplamiento e incumplimiento constitucional.
- Crear casos de uso vacíos para cada campo: rechazado por sobreingeniería; se mantienen facades.
- OpenAPI: rechazado porque no existe una API HTTP entre los paquetes.

## D3-003 — Sector como única identidad territorial y productiva

**Decision**: En 003, `sectorId` es la única identidad. Se reutilizan `SectorSummary` y
`BoundAgriculturalContext`, extendidos con la categoría `crop|apiary` y capacidades. No se crean
`productive_units`, `ProductiveUnitRef`, `unitId` ni otra proyección 1:1.

**Rationale**: código, datos y flujos actuales demuestran un contexto operativo por Sector.
Parcelas, asignaciones, riego, suelo y apiario ya referencian `sectorId`; otro DTO identificable o
tabla duplicaría identidad y permitiría divergencia sin resolver un requisito actual.

**Alternatives considered**:

- Tabla `productive_units`: rechazada por falta de evidencia de múltiples unidades concurrentes por
  Sector.
- `ProductiveUnitRef` con el mismo ID: rechazado; anticipa una cardinalidad futura no solicitada.
- Inferir categoría desde cultivo/icono/copy: rechazado; el frontend ya infiere apicultura también
  por la etiqueta “Apicultura”, lo que no es una regla de dominio.
- Renombrar Sector a Cuadrante: rechazado; `Sector` es el concepto interno constitucional.

## D3-004 — Categoría estable y snapshot por evento

**Decision**: `sectors.kind` se exige al crear y permanece inmutable durante 003. Las labores nuevas
guardan `domainCategory` como snapshot; las filas legadas ambiguas se mantienen como
`legacyUnknown`. Cambiar vegetal↔apícola in-place queda fuera de alcance.

**Rationale**: ninguna historia, prototipo ni flujo vigente requiere transformar un Sector vegetal
en apícola. Rotar papa→frutilla sigue dentro de `crop`. Un snapshot por evento satisface los filtros
y evita que una futura evolución reinterprete historia, sin crear periodos que 003 no utiliza.

**Alternatives considered**:

- Permitir cambios de `kind` durante 003: rechazado; exigiría un flujo histórico no especificado.
- Reconstruir la categoría histórica desde el Sector: rechazado; el evento nuevo guarda snapshot.
- Crear `sector_domain_periods`: rechazado; modela una transición inexistente en el alcance.
- Event sourcing: rechazado; ampliaría radicalmente la arquitectura.

## D3-005 — Una política backend de compatibilidad

**Decision**: Crear `DomainCompatibilityPolicy` dentro de `agricultural_context/domain/services`.
Resuelve propietario, Sector, `kind`, operación y fecha; devuelve una decisión tipada. La usan todos
los facades/repositorios mutantes y los codecs de pull. Supabase implementa una función SQL
equivalente y pruebas de paridad con una única matriz contractual; las rutas de update/pull rechazan
un cambio de `kind`.

**Rationale**: hoy `kind` es `String`, Drift local no restringe sus valores y las operaciones de
riego, suelo, cultivos, labores y apiario no validan uniformemente la categoría. Ocultar botones no
impide una invocación directa.

**Alternatives considered**:

- Condicionales independientes por pantalla: rechazados; son el defecto que la Constitución prohíbe.
- Sólo constraint/RLS remoto: rechazado; el flujo offline debe validar antes del commit local.
- Sólo política Dart: insuficiente; una escritura remota directa o pull inválido también debe fallar.

## D3-006 — Extender el contexto ligado, no crear selección paralela

**Decision**: Evolucionar `AgriculturalContext`/`BoundAgriculturalContext` a v2 con categoría,
labels, capacidades, temporada/asignación/cultivo aplicables y revisión sobre el `sectorId`
existente. Se reutilizan `app_preferences` y los selectores actuales.

**Rationale**: la implementación ya persiste parcela/Sector/temporada/asignación y detecta cambios
globales. Sólo faltan categoría/capacidades y resolución de asignación por fecha. Un formulario conserva su contexto
original o exige re-vincular; no elige un Sector por fallback.

**Alternatives considered**:

- Contexto nuevo por módulo: rechazado; produciría selecciones divergentes.
- Guardar sólo labels: rechazado; no garantiza identidad ni integridad histórica.

## D3-007 — Completar la geometría existente

**Decision**: Reutilizar `flutter_map`, OpenStreetMap, `SectorGeometryDraft`, `PolygonGeometry` y
`SectorRepository`. Extender creación con nombre y categoría obligatorios, y edición con cierre
explícito, `expectedVersion` y errores tipados sin permitir cambiar `kind`. Agregar el mismo flujo
para el límite de parcela. Cancelar no llama al backend; confirmar revalida y persiste.

**Rationale**: la página actual ya separa vista/borrador, permite mover/agregar/quitar/deshacer y
tiene Confirmar/Cancelar. Las brechas reales son fallback silencioso `kind='crop'`, nombre generado,
geometría de parcela y ausencia de un estado de cierre explícito. La geometría Drift ya sobrevive a
la navegación y el mapa base puede fallar sin perderla.

**Alternatives considered**:

- Reimplementar el editor: rechazado; duplicaría funcionalidad válida.
- Google Maps: rechazado; el proveedor real es OSM y no hay limitación demostrada.
- Persistir cada arrastre: rechazado; violaría el borrador confirmable.

## D3-008 — Detalles de labor discriminados y versionados

**Decision**: Mantener `labors.detailsJson` como sobre canónico y crear inputs sellados por tipo. Se
mantienen `sowing` y `pruning`; se agrega `cultivation`. Fertilización, fitosanitario, cultivo,
cosecha y otra labor evolucionan a schema v2 sin tablas separadas.

**Rationale**: el repositorio ya valida tipo/schema, conserva correcciones por `supersedesLaborId`
y escribe labor+outbox atómicamente. La brecha está en el DTO genérico, `tryParse ?? 0`, errores no
diferenciados y campos incompletos.

**Alternatives considered**:

- Tabla por tipo de labor: rechazada; no mejora los requisitos actuales y multiplica migraciones.
- Guardar todo como observaciones: rechazado; impide round-trip y detalle verificable.
- Reinterpretar Siembra/Poda como Cultivo: rechazado; alteraría datos heredados.

## D3-009 — Suelo y apiario como especializaciones de una labor raíz

**Decision**: Conservar `soil_measurements` y `apiary_inspections`, añadir `laborId` nullable/único y
crear una labor raíz para cada nuevo registro. El `detailsJson` de la raíz conserva unidades,
omisiones y detalles por subtipo; la tabla especializada conserva campos consultables. Un solo
outbox `labor` respalda raíz+especialización.

**Rationale**: suelo hoy no crea outbox ni contexto; apiario crea un aggregate type que el registry
no soporta. El patrón compuesto ya funciona para riego y cosecha y permite que historial muestre un
evento sin crear otro timeline.

**Alternatives considered**:

- Agregados sync nuevos `soilMeasurement` y `apiaryInspection`: rechazados porque duplican el patrón
  de labor compound y complican la deduplicación.
- Eliminar tablas especializadas: rechazado; perdería estructura y compatibilidad.
- Inventar temporada/asignación en backfill: rechazado; contexto desconocido queda marcado.

## D3-010 — Rotaciones sobre las asignaciones actuales

**Decision**: Mantener `agricultural_seasons` y `crop_seasons` como temporada y asignación fechada.
Agregar validación de categoría antes de asignar/activar/intercambiar; conservar los algoritmos
actuales de no solapamiento y activación por fecha.

**Rationale**: los repositorios y `CropAssignmentReconciler` ya modelan planificación, activación,
cancelación e intercambio. Sólo falta integrarlos con la categoría del Sector y probar historia.

**Alternatives considered**:

- Nueva tabla de rotaciones: rechazada; `crop_seasons` ya representa la relación efectiva.
- Reemplazar el cultivo actual en Sector: rechazado; reescribe historia.

## D3-011 — Estimación básica de riego separada de ciencia avanzada

**Decision**: Extender el contrato v2. El registro realizado captura fecha, método, duración,
caudal+unidad, presión cuando corresponda, volumen y contexto; el snapshot conserva valores
ingresados y normalizados. La estimación básica de goteo reutiliza la aritmética existente
`roundHalfUp(totalFlowMlPerMinute × durationSeconds / 60)` y se rotula como cálculo matemático, no
como recomendación. Etapa, textura y clima sólo aparecen si una futura fórmula avanzada definida
los declara. Cualquier cambio de borrador invalida el preview.

**Rationale**: configuración, cálculo entero y snapshots existen. El cálculo de volumen aplicado ya
está implementado dentro del motor, pero queda indebidamente detrás del gate de regla agronómica.
Separarlo permite completar el flujo sin inventar coeficientes; además corrige que el facade ignore
el caudal del input, que presión sólo esté en config y que la UI oculte caudal en goteo.

**Alternatives considered**:

- Agregar coeficientes/etapas/texturas de ejemplo: rechazado; serían invención agronómica.
- Usar Gemini: rechazado por Constitución y spec.
- Exigir reviewer, firma o un número fijo de vectores para la estimación básica: rechazado; su
  fórmula y redondeo se verifican automáticamente.
- Bloquear el registro manual sin regla/clima: rechazado; viola offline-first y FR-039/044/056.

## D3-012 — Fertilización manual primero

**Decision**: Tipar `Manual`, `Foliar` y `Fertirriego` dentro de `labors`. Los campos comunes son
producto, dosis, unidad, fecha, contexto y observaciones; datos técnicos definidos permanecen
opcionales y nulos. Fertirriego puede referenciar un `irrigationLaborId` sin modificarlo. Una
corrección crea una nueva versión/supersesión trazable.

**Rationale**: `FertilizationDetails` ya ofrece una base pero usa método libre. No existe regla de
cálculo definida y el registro manual completo es el valor requerido.

**Alternatives considered**:

- Motor predictivo/económico o de dosis: rechazado y fuera de alcance.
- Forzar todos los campos técnicos: rechazado; bloquearía registros válidos.

## D3-013 — Historial como proyección única

**Decision**: Extender `HistoryRepository`/`HistoryFacade`; no crear tabla timeline. Las
especializaciones se agrupan por `laborId`, se decodifica el detalle tipado y se filtra antes de
paginar por parcela, Sector, categoría, temporada, cultivo, tipo y fechas.

**Rationale**: el historial actual ya fusiona labor/asignación/suelo y deduplica cosecha/producción,
pero omite apiario, aplana detalles, fija suelo como `local` y pagina fuentes antes de fusionar.

**Alternatives considered**:

- Tabla de eventos duplicada: rechazada por riesgo de divergencia y duplicados.
- Calcular contexto desde el estado actual: rechazado; reinterpreta historia.

## D3-014 — Extender sync v2, no versionar el protocolo completo

**Decision**: Conservar protocolo, outbox, hashes, ACK, retry, pull y conflictos v2. Crear payload
schema v2 para `labor` compound y handlers append-only; migrar operaciones apícolas no soportadas a
labor usando la fila completa. Corregir el coordinador para no invocar RPC con lote vacío.

**Rationale**: la infraestructura idempotente ya existe. Las brechas son cobertura: suelo no
encola, apiario usa `apiary_inspection` sin codec, el payload apícola es parcial y handlers no
validan categoría.

**Alternatives considered**:

- Sync v3 nuevo de extremo a extremo: rechazado; no hay defecto transversal que lo exija.
- ACK local optimista: rechazado; contradice el contrato vigente.
- Saltar un cambio pull inválido: rechazado; avanzaría cursor con pérdida silenciosa.

## D3-015 — Migración v11 mínima y preservadora

**Decision**: Corregir primero la discrepancia `schemaVersion=10` vs `migration_policy=9`, después
crear snapshot/fixture v11. Añadir sólo `domain_category` a `labors` y enlaces `laborId` de
suelo/apiario, junto con índices estrictamente necesarios. Supabase recibe una migración `0020_*`
append-only equivalente. No se agrega `sector_domain_periods`, `domain_period_id` ni extensión de
reglas avanzadas sin fórmula actual.

**Rationale**: son los únicos cambios no representables limpiamente con columnas/JSON existentes:
el snapshot consultable de categoría y los enlaces de las especializaciones a su labor raíz. La
migración debe probar conteos, IDs, geometrías, relaciones, details JSON, outbox y estados.

**Alternatives considered**:

- Reset/recrear la DB: rechazado; perdería datos y está prohibido.
- Editar migraciones 0001–0019: rechazado; rompe historial desplegado.
- Backfill de categoría desde el estado actual cuando el tipo histórico es ambiguo: rechazado; se
  conserva `legacyUnknown`.

## D3-016 — Mantener proveedores reales y sus límites

**Decision**:

- mapa: `flutter_map` + OpenStreetMap, URL configurable y atribución visible;
- ubicación: `GeolocatorLocationGateway` detrás de facade;
- clima: `weather-proxy` + Open-Meteo, ubicación por límite remoto de parcela o coordenada server;
- AgroIA: `agro-ai` + Gemini (`GEMINI_MODEL`, default actual `gemini-2.5-flash`), sólo texto del
  agricultor y metadata mínima.

**Rationale**: es la implementación encontrada en código y pruebas. Los gateways indisponibles
permiten continuar sin Supabase en ambientes admitidos. No hay geocodificación de localidad; la
ausencia de límite remoto/coordenada server produce clima no disponible.

**Alternatives considered**:

- Google Maps, WeatherAPI u otro proveedor histórico: rechazados; no son la configuración actual.
- Contexto automático en AgroIA: rechazado; 002/003 sustituyen el contrato 001.
- Clima como requisito de guardado: rechazado; es auxiliar.

## D3-017 — Gate funcional automatizado y dependencias directas

**Decision**: Implementar por cortes verticales US1→US7; P1/P2 sólo ordenan y US8 es P3. SC-004 y
SC-014 se demuestran mediante navegación, contexto visible, confirmación, detalle, historial y
reapertura automatizados. T016/T096/T115/T118 siguen bajo 002 y sólo bloquean 003 cuando una
verificación concreta depende directamente de código modificado por 003.

**Rationale**: una suite verde por capa no demuestra el flujo completo, pero una sesión humana
irrepetible tampoco es necesaria para probar persistencia o contratos. Las matrices representativas
y tests verticales reproducibles aportan evidencia suficiente sin mezclar incrementos.

**Alternatives considered**:

- Declarar completitud por prioridad P1: rechazado; US1–US7 son obligatorias.
- Aceptar fakes como respaldo/reapertura: rechazado; no prueba infraestructura real.
- Usar sesiones o cronometrajes humanos como gate: rechazado; pueden informar UX, no aceptación 003.
- Cerrar en bloque tareas 002: rechazado; sólo se reutiliza evidencia de dependencias directas.
- Considerar reportes históricos como ejecución actual: rechazado; 002 sigue en validación.

## Resolved Unknowns

No quedan decisiones técnicas pendientes para Phase 1. La estimación básica usa una fórmula
aritmética ya definida y una matriz automatizada; la recomendación agronómica avanzada permanece
`recommendationUnavailable` hasta que exista una fórmula versionada, trazable y verificable. Esto
no bloquea el registro manual ni exige aprobación externa.
