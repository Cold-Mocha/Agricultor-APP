# Implementation Plan: AgroCampo Functional Refinement - Módulo 003

**Branch**: `003-agrocampo-functional-refinement` | **Date**: 2026-09-10 | **Spec**: [spec.md](./spec.md)

**Input**: Constitución v2.1.0, especificación 003 aprobada, artefactos 001/002,
`master.md`, `jerarquía 01.md` y auditoría directa del monorepositorio actual.

## Summary

El Módulo 003 convierte los flujos agrícolas ya visibles en comportamiento real, persistente y
comprobable sin reconstruir AgroCampo. Se mantienen el Pub Workspace, `/frontend`, `/backend`, la
Feature-Based Architecture, Drift como fuente operativa y Supabase como respaldo. El incremento
extiende las APIs públicas de los módulos existentes, introduce una única política backend de
compatibilidad vegetal/apícola y completa los round-trips de geometría, contexto, Registrar,
rotaciones, riego, fertilización, apicultura e historial.

Durante 003, `Sector` es la única identidad territorial y productiva: `sectorId` identifica el
contexto y `sectors.kind = crop|apiary` conserva su categoría estable. No se crean
`productive_units`, `ProductiveUnitRef`, `unitId`, periodos de dominio ni una transición
vegetal↔apícola. Los eventos nuevos conservan la categoría dentro de su snapshot de contexto; las
rotaciones sólo cambian cultivo y temporada.

Los registros generales continúan usando `labors.detailsJson` versionado. Suelo y apicultura se
integran como especializaciones de una labor raíz para obtener contexto, un solo evento y outbox
atómico sin abandonar sus tablas actuales. Cosecha continúa como labor+producción y riego como
labor+registro+estimación opcional. La aritmética existente permite una estimación básica de
volumen por goteo a partir de caudal total y duración, verificable sin aprobación humana externa.
No existe una fórmula agronómica avanzada definida en el repositorio, por lo que ese resultado
continúa como `crop_rule_unavailable`; el registro manual de riego y fertilización permanece
disponible. Gemini/AgroIA no participa en cálculos.

## Technical Context

**Language/Version**: Flutter 3.47.0, Dart 3.13.0; Kotlin/Java 17 para el host Android; TypeScript
sobre Deno para las Edge Functions existentes.

**Primary Dependencies**: `flutter_riverpod` 3.4.2, `go_router` 18.0.0, Drift 2.34.x,
`supabase_flutter` 2.17.2, `flutter_map` 8.3.2, `latlong2` 0.10.1, `geolocator` 14.0.3,
`connectivity_plus` 7.3.1, `workmanager` 0.10.9, `flutter_local_notifications` 22.3.0 y las
dependencias vigentes de autenticación, medios y exportación. No se agrega un framework HTTP.

**Storage**: SQLite/Drift v10 como fuente operativa local; migración preservadora a v11 sólo para
enlaces de especialización e índices necesarios; PostgreSQL/Supabase,
Storage y outbox/sync v2 como respaldo. No se crea un almacén paralelo.

**Testing**: `flutter_test`, `integration_test`, `mocktail`, bases Drift en archivo con reapertura,
snapshots de migración, Supabase CLI + pgTAP, pruebas Deno de Edge Functions, widget/golden/
semántica y Android instrumentado donde intervienen GPS, ciclo de vida o background.

**Target Platform**: Android API 24+, `compileSdk`/`targetSdk` 36.

**Project Type**: aplicación móvil Flutter con paquete backend local dentro del mismo APK y
servicios administrados Supabase; no es una arquitectura cliente-servidor REST propia.

**Performance Goals**: confirmación local sin esperar red; percentil 95 bajo 2 segundos para las
consultas comunes nombradas en un perfil de carga representativo, versionado y reproducible;
interacción de mapa y formularios fluida; matriz de reintentos reconciliada sin pérdida ni
duplicación.

**Constraints**: offline-first; una cuenta agricultora; preservación total de datos v10; categoría
estable validada en backend; contexto ligado; geometría sólo mutable en edición explícita;
estimación básica determinista y recomendación avanzada sólo con fórmula definida/versionada;
integraciones degradables; sólo el import público
`package:agrocampo_backend/agrocampo_backend.dart`; UX según `master.md`.

**Scale/Scope**: 87 requisitos, 8 historias y 30 grupos técnicos de flujo; User Stories 1–7 forman
un único gate obligatorio. La Story 8 conserva prioridad P3, pero privacidad y aislamiento son
obligatorios cuando la integración está configurada. El esquema vigente contiene 26 tablas Drift
y 19 migraciones Supabase.

**Baseline caveat**: 002 sigue marcado `Implementation validation in progress`; T016, T096, T115
y T118 continúan perteneciendo a 002. Sólo bloquean 003 cuando una de sus verificaciones es
dependencia directa de código o comportamiento modificado por 003; cualquier evidencia coincidente
se registra sin cerrar automáticamente la tarea 002. En esta estación `supabase` no está en `PATH`,
por lo que los gates pgTAP propios de cambios 003 requieren instalar/configurar la CLI.

## Existing-State Audit and Disposition

Cada fila tiene una clasificación primaria vinculante. “Corregir” o “Extender” actúa detrás del
límite existente; no autoriza duplicar la feature.

| Capacidad | Evidencia actual | Clasificación 003 | Cambio delimitado |
|---|---|---|---|
| Pub Workspace y paquetes | `pubspec.yaml`, `frontend/pubspec.yaml`, `backend/pubspec.yaml` | **REUTILIZAR** | Mantener exactamente `/frontend` y `/backend`; ninguna app, servidor o paquete funcional adicional. |
| Frontera e inyección | `AgroCampoBackend.initialize`, `backend_providers.dart`, `agrocampo_backend.dart` | **EXTENDER** | Reexportar sólo nuevos DTOs/facades públicos; conservar `ProviderContainer` y ocultar Drift/Supabase/outbox. |
| Sector territorial | `sectors.kind`, `SectorRepository`, facades de territorio | **REUTILIZAR** | Mantener ID, parcela, polígono, número, nombre, versión y `kind`; “Cuadrante”/“platabanda” siguen siendo copy. |
| Categoría productiva del Sector | `kind = crop|apiary` existe, pero no hay validación funcional uniforme | **EXTENDER** | Tipar `kind`, mantenerlo estable y crear una política única de compatibilidad; no crear identidad paralela ni periodos. |
| Contexto ligado | `AgriculturalContext`, preferencias y `BoundAgriculturalContext` | **EXTENDER** | Incluir categoría, etiquetas y capacidades sobre `sectorId`; resolver asignación por fecha sin fallback de primer Sector. |
| Geometría y mapa | `PolygonGeometry`, `SectorGeometryDraft`, `TerritoryMapPage` | **CORREGIR** | Conservar borrador/confirmar/cancelar; exigir nombre/categoría al crear, cierre explícito y round-trip/contención. |
| Temporadas/asignaciones | tablas, repositorios, rotación y reconciler | **CORREGIR** | Impedir categoría incompatible, solapamientos y activación anticipada; no mover eventos. |
| Labor común | `labors`, `detailsJson`, `LaborRepository`, `LaborsFacade` | **EXTENDER** | DTOs tipados, errores por campo, `commandId`, contexto/categoría y schemas v2; no crear tablas por labor. |
| Suelo | valores nulos válidos, pero sin labor raíz, outbox ni contexto histórico | **CORREGIR** | Conservar tabla; enlazarla a labor raíz y guardar unidades/detalle en una transacción con outbox. |
| Fertilización | detalle con producto/cantidad/unidad/método libre | **EXTENDER** | Método tipado Manual/Foliar/Fertirriego, opcionales nulos y corrección trazable; sin cálculo inventado. |
| Fitosanitarios | ya contiene producto/objetivo/dosis/unidad/carencia | **EXTENDER** | Preservar observaciones/contexto, errores por campo y round-trip; ninguna recomendación química. |
| Cultivo y otras labores | existen `sowing`, `pruning`, `other`; falta Cultivo | **EXTENDER** | Añadir `cultivation` sin eliminar tipos heredados y persistir todos los campos aprobados. |
| Cosecha/producción | transacción labor+producción e índice único por `laborId` | **EXTENDER** | Añadir calidad/destino/jornada/observaciones al detalle y mantener un evento. |
| Riego manual | agregado compuesto; UI omite caudal en goteo y presión del evento | **CORREGIR** | Conservar método, duración, caudal/unidad y presión aplicable; invalidar preview al cambiar borrador. |
| Estimación y recomendación goteo | config/calculadora/estimación y release gate actual | **CORREGIR** | Separar estimación matemática básica de recomendación avanzada; eliminar firma/reviewer como gate funcional y mantener avanzada “no disponible” sin fórmula definida. |
| Apicultura | tabla/formulario; outbox usa agregado no registrado | **CORREGIR** | Labor raíz especializada, categoría, campos/fotos, detalle/historial y sync; nunca labor vegetal. |
| Historial | labor/asignación/suelo; detalle y filtros incompletos | **EXTENDER** | Incluir categoría/Sector/apiario/detalles/filtros/estado y deduplicar por root ID. |
| Drift/migraciones | v10 + snapshots v9/v10; `migration_policy` aún dice 9 | **EXTENDER** | Corregir la política y crear v11 mínima para enlaces suelo/apiario e índices, sin nueva tabla ni reset. |
| Outbox/sync v2 | registry de territorio/ciclos/labor/config/recordatorio | **EXTENDER** | Ampliar labor compound y payload v2; migrar operaciones apícolas pendientes sin perder IDs. |
| Supabase/RLS/RPC | migraciones 0001–0019 y handlers v2 | **EXTENDER** | Migraciones append-only y validación remota de categoría; no endpoint HTTP nuevo. |
| Fotos | almacenamiento privado y metadatos por agregado | **EXTENDER** | Vínculo validado a eventos/labores; no diagnóstico por imagen. |
| Mapa externo | `flutter_map` + OpenStreetMap por `MAP_TILE_URL` | **REUTILIZAR** | Mantener proveedor, atribución, GPS y geometría local sin tiles; no Google Maps. |
| Clima | `weather-proxy` → Open-Meteo, caché/vigencia/atribución | **REUTILIZAR** | Conservar degradación; sólo una fórmula avanzada definida puede consumirlo. |
| AgroIA | `agro-ai` → Gemini; sólo texto/locale/policy/ID | **REUTILIZAR** | Mantener privacidad/reintento; no contexto ni cálculos. |
| Pruebas | suites backend/frontend/integration/Supabase | **EXTENDER** | Añadir matrices representativas 003; ejecutar verificaciones 002 sólo por dependencia directa, sin cerrar tareas ajenas. |

La auditoría detallada y sus alternativas están en [research.md](./research.md).

## Constitution Check

### Gate previo a Phase 0

| Principio v2.1.0 | Estado | Evidencia del diseño |
|---|---|---|
| I. Funcionalidad antes que sobreingeniería | **PASS** | No hay reescritura, tabla de unidad ni módulo de código 003; cada cambio responde a una brecha observada. |
| II. Offline-First | **PASS** | Drift continúa como autoridad; toda mutación 003 válida confirma localmente antes del respaldo. |
| III. Flujos completos | **PASS** | Las fases son cortes UI→contrato→dominio→Drift→reapertura→sync/degradación. |
| IV. Integridad histórica y autoridad | **PASS** | IDs y snapshots se preservan; correcciones/rotaciones son explícitas y `Sector.kind` no cambia en 003. |
| V. Cálculos verificables | **PASS** | La estimación básica usa aritmética visible; sin fórmula avanzada definida no hay recomendación y Gemini queda excluido. |
| VI. Validez por dominio/categoría | **PASS** | Una política backend central valida antes de guardar y sincronizar; la UI sólo refleja el resultado. |
| VII. Integraciones degradables | **PASS** | OSM, Open-Meteo, Gemini y Supabase permanecen encapsulados y no bloquean flujos locales. |
| VIII. Seguridad proporcional | **PASS** | Se preservan sesión/propiedad/RLS; no se agregan roles, organizaciones ni secretos cliente. |
| IX. UX semitécnica | **PASS** | `master.md` gobierna presentación, contexto visible, errores comprensibles y alternativa textual del mapa. |
| X. Calidad suficiente | **PASS** | Gates basados en riesgo cubren migración, persistencia, dominio, exact-once, cálculo y Android. |
| Base técnica y límites | **PASS** | Se mantienen Flutter, Riverpod, go_router, Drift, Supabase y la frontera `/frontend`↔`/backend`. |

No se necesita excepción constitucional.

## Project Structure

### Documentation (this feature)

```text
specs/003-agrocampo-functional-refinement/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── checklists/
│   └── requirements.md
└── contracts/
    ├── frontend-backend-public-api.md
    ├── productive-domain-compatibility.md
    ├── sector-context-v2.md
    ├── territory-geometry-v2.md
    ├── labor-details-v2.md
    ├── irrigation-drip-v3.md
    ├── apiary-operations-v2.md
    └── sync-protocol-v2-003-delta.md
```

`tasks.md` corresponde a `$speckit-tasks` y no se genera durante este plan.

### Source Code (repository root)

```text
pubspec.yaml                         # Pub Workspace existente
frontend/
├── pubspec.yaml
├── android/                         # host Android/API 24+
├── lib/
│   ├── main.dart
│   └── src/
│       ├── app/                     # bootstrap, routing, shell, theme
│       ├── modules/                 # presentación y estado UI por feature
│       │   ├── agricultural_context/
│       │   ├── territory/
│       │   ├── crop_cycles/
│       │   ├── labors/
│       │   ├── soil/
│       │   ├── irrigation/
│       │   ├── production/
│       │   ├── apiary/
│       │   ├── history/
│       │   ├── weather/
│       │   └── agro_ai/
│       └── shared/design_system/
├── test/
└── integration_test/

backend/
├── pubspec.yaml
├── assets/data/
├── drift_schemas/
├── lib/
│   ├── agrocampo_backend.dart       # única allowlist pública
│   └── src/
│       ├── composition/             # providers/bootstrap/codecs
│       ├── modules/                 # contracts/application/domain/infrastructure
│       │   ├── agricultural_context/
│       │   ├── territory/
│       │   ├── crop_cycles/
│       │   ├── labors/              # incluye fertilización/fitosanitario/cultivo
│       │   ├── soil/
│       │   ├── irrigation/
│       │   ├── production/
│       │   ├── apiary/
│       │   ├── history/
│       │   ├── weather/
│       │   └── agro_ai/
│       ├── platform/database/       # composición Drift/migraciones
│       └── platform/sync/           # outbox/protocolo/coordinador
├── test/
└── supabase/
    ├── migrations/                  # append-only
    ├── functions/                   # weather-proxy/agro-ai existentes
    └── tests/database/
```

**Structure Decision**: conservar las rutas físicas actuales `lib/src/modules`. Fertilización y
fitosanitarios continúan como especializaciones de `labors`; 003 no se convierte en un módulo de
código. `backend/lib/agrocampo_backend.dart` sigue siendo la única entrada productiva del frontend.

## Architecture

### Frontera y flujo de escritura

```text
Frontend page + UI draft
        ↓ DTO/comando público
Backend facade del módulo
        ↓ contexto ligado + DomainCompatibilityPolicy
Dominio tipado / regla determinista
        ↓ una transacción
Drift root/especialización + SyncOutbox
        ↓ stream/proyección pública
Frontend muestra guardado local confirmado + BackupState real
        ↓ trigger oportunista
SyncCoordinator → Supabase RPC v2 → RLS/handler de agregado
```

- El frontend conserva exclusivamente estado de presentación y borradores no confirmados.
- El backend revalida contexto, categoría, campos y versión aunque la pantalla haya ocultado la
  acción incompatible.
- Un éxito local nunca significa `synced`; el estado remoto proviene del outbox/ACK real.
- Los DTOs públicos no exponen filas Drift, DAOs, payloads de sync, gateways ni clientes externos.
- Los repositorios simples pueden permanecer directos detrás de facades; no se crean capas vacías.

### Política única de compatibilidad

`DomainCompatibilityPolicy` vivirá en el dominio de `agricultural_context` y resolverá la categoría
desde `sectors.kind` del Sector propiedad del agricultor. Publicará capacidades para guiar la UI y
un `validate(operation, context, occurredAt)` obligatorio para cada facade mutante. Las mutaciones
de un Sector existente rechazan cualquier intento de cambiar `kind` durante 003.

| Categoría persistida | Operaciones admitidas en 003 | Rechazos obligatorios |
|---|---|---|
| `crop` | suelo, riego manual, estimación básica de goteo, recomendación avanzada cuando exista fórmula, fertilización, fitosanitario, cultivo, cosecha, otras labores vegetales | operaciones apícolas salvo una futura regla expresa |
| `apiary` | inspección, alimentación, sanidad, cosecha/alza/otra apícola y adjuntos | riego vegetal, recomendación de riego, suelo, fertilización vegetal y fitosanitario agrícola |

No se infiere categoría desde cultivo, icono, ruta ni copy. Supabase usa una función SQL equivalente
`operation_allowed(category, operation)` y tests de paridad con la matriz contractual; no se crean
reglas independientes por pantalla ni se confía sólo en RLS.

### Sector como contexto productivo

- `sectorId` es la única identidad territorial y productiva expuesta en 003.
- `sectors.kind` usa `crop|apiary`, se exige al crear y permanece inmutable después.
- El contexto público añade categoría, etiquetas y capacidades al `BoundAgriculturalContext`
  existente; no introduce `unitId` ni `ProductiveUnitRef`.
- Cada labor nueva guarda `domain_category` como snapshot; una fila legada ambigua permanece
  `legacyUnknown` y visible, sin recibir una categoría inventada.
- Una futura conversión de dominio o relación N:1 exigirá otra especificación y migración.

### Persistencia y migración v11

La migración es preservadora sobre v10 y se detalla en [data-model.md](./data-model.md). Conserva
todas las tablas actuales y realiza únicamente estos cambios físicos justificados:

1. agregar a `labors` `domain_category` como snapshot obligatorio para escrituras nuevas;
2. agregar `labor_id` nullable/único a `soil_measurements` y `apiary_inspections`, manteniendo sus
   IDs y campos existentes;
3. guardar las extensiones por tipo en `labors.detailsJson` e `irrigation_records.performedDetailsJson`
   ya existentes, sin tablas por subtipo;
4. actualizar constraints/handlers remotos para `cultivation`, categoría estable, payloads v2 e
   índices de historia.

El backfill sólo asigna `domain_category` cuando el tipo y las relaciones históricas la demuestran;
los casos ambiguos permanecen `legacyUnknown`. Suelo y apiario reciben una labor raíz determinista
cuando la relación puede probarse; temporada/asignación inciertas permanecen nulas/marcadas como
legadas. Las operaciones `apiary_inspection` pendientes se transforman idempotentemente a labor
compuesta usando la fila local completa, sin descartar IDs. Conteos, polígonos, fechas, relaciones,
outbox y estados se comparan antes/después. No se usa reset ni se recrea la base del usuario.

### Diseño por módulo existente

| Módulo | Resultado vertical 003 |
|---|---|
| `territory` + `agricultural_context` | Crear/editar geometría con nombre/categoría, persistir selección y exponer Sector/capacidades; rechazo backend de dominio. |
| `crop_cycles` | Asignar y rotar por fecha efectiva, sin solapamiento ni reescritura de eventos. |
| `labors` | Schemas tipados completos para fertilización, fitosanitario, cultivo y otra; corrección explícita y errores por campo. |
| `soil` | Valores+unidades+omisiones como especialización de labor, detalle e historial tras reapertura. |
| `irrigation` | Registro manual completo; estimación básica de goteo; avanzada no disponible sin fórmula; snapshot de caudal/duración/presión. |
| `production` | Cosecha completa y una única proyección histórica por labor root. |
| `apiary` | Eventos especializados, validación de categoría, fotos, detalle/historial y respaldo. |
| `history` | Proyección única con filtros requeridos y estados honestos. |
| `platform/sync` + Supabase | Payloads/handlers compatibles, idempotencia, pull transaccional y conflictos bajo autoridad del agricultor. |
| `weather`/`agro_ai`/mapa | Regresión del proveedor real, privacidad, vigencia y degradación; ninguna ampliación. |

### Contratos y trabajo paralelo

Los documentos de [contracts](./contracts/) fijan el límite antes de implementar. Después de ese
freeze, el trabajo puede avanzar en tres carriles independientes:

1. **Backend**: política, facades/DTOs, repositorios, migración, codecs, RPC/RLS y pruebas con
   fixtures, sin importar frontend.
2. **Frontend**: páginas/controladores consumiendo sólo interfaces públicas y dobles de facade,
   incluyendo borradores, navegación y estados según `master.md`.
3. **Integración**: pruebas verticales contra el backend real, base en archivo, Supabase local y
   Android. Ningún carril redefine el contrato unilateralmente.

## Prototype Flow Technical Traceability

Esta matriz operacionaliza la tabla del spec y desambigua los controles de Perfil nombrados en
`jerarquía 01.md`. Cada flujo queda en exactamente una categoría.

| ID | Flujo visible | Clasificación de producto | Propietario técnico / evidencia |
|---|---|---|---|
| PF-01 | Carga/Inicio/resumen/accesos | Preservado 001/002 | `home`, contexto y regresión offline/clima |
| PF-02 | Barra Inicio/Sectores/Registrar/AgroIA/Más | Preservado 001/002 | routing/shell contra `master.md` |
| PF-03 | Volver y retorno guardar/cancelar | Preservado 001/002 | router + pruebas de contexto/borrador |
| PF-04 | Lista/tarjetas/selección de Sectores | Completado por 003 | territory/context + reapertura |
| PF-05 | Preview mapa y resumen historial | Preservado 001/002 | proyecciones reales, sin CTA nuevo |
| PF-06 | Dibujar/seleccionar/abrir Sector | Completado por 003 | geometry v2 + lista alternativa |
| PF-07 | Mover vértices/límites | Completado por 003 | edición explícita, confirmar/cancelar |
| PF-08 | Detalle y acciones de Sector | Completado por 003 | capacidades desde backend |
| PF-09 | Registrar y selector de contexto | Completado por 003 | bound context v2 |
| PF-10 | Medición de Suelo | Completado por 003 | soil round-trip/sync |
| PF-11 | Riego | Completado por 003 | manual + goteo condicionado |
| PF-12 | Fertilización | Completado por 003 | labor details v2 |
| PF-13 | Control enfermedades/plagas | Completado por 003 | labor details v2, sin recomendación |
| PF-14 | Cultivo como labor | Completado por 003 | discriminator `cultivation` |
| PF-15 | Cosecha/producción | Completado por 003 | agregado compuesto, un evento |
| PF-16 | Apicultura | Completado por 003 | agregado especializado |
| PF-17 | Otra labor | Completado por 003 | nombre/detalle tipados |
| PF-18 | Cambiar cultivo/rotación | Completado por 003 | crop_cycles por fecha efectiva |
| PF-19 | Historial desde sus tres entradas | Completado por 003 | history query/detail/filter |
| PF-20 | AgroIA desde barra/Sector | Preservado desde 002 | sólo texto elegido por el agricultor |
| PF-21 | Clima/alertas informativas | Preservado 001/002 | Open-Meteo vigente/degradable |
| PF-22 | Respaldo Excel | Preservado desde 001 | exportación real, regresión |
| PF-23 | Conexión/sincronización | Preservado desde 002 | estado/outbox real, no interruptor simulado |
| PF-24 | Perfil y edición vigente | Preservado 001/002 | profile contract |
| PF-25 | Perfil → Notificaciones | Preservado 001/002 | reminders/permisos; sin alcance nuevo |
| PF-26 | Perfil → Seguridad | Preservado 001/002 | sesión/biometría; sin alcance nuevo |
| PF-27 | Tema/idioma/ayuda/contacto/privacidad/animaciones no exigidos | Fuera de alcance | sin implementación nueva |
| PF-28 | Edición aislada de icono | Fuera de alcance | categoría/cultivo sólo por flujo aprobado |
| PF-29 | Rutas desconocidas/fallback silencioso | Fuera de alcance | no son flujo aprobado |
| PF-30 | Calculadora predictiva costos/rendimiento/margen | Fuera de alcance | diferida íntegramente a otro módulo |

## Implementation Phases

Las fases expresan dependencias y gates; las tareas se generarán posteriormente. P1/P2 ordenan el
trabajo y no reducen alcance.

### Phase A — Baseline y contratos congelados

- Reproducir la baseline afectada por 003 y registrar qué verificaciones pendientes de 002 son
  dependencias directas; las demás permanecen bajo 002 y no bloquean este incremento.
- Congelar contratos públicos, matriz de compatibilidad y versiones de payload antes de dividir
  frontend/backend.
- Añadir fixtures v10 ricos en geometría, historia, riego, producción, apiario y outbox.

### Phase B — Contexto, dominio y geometría (US1, P1)

- Extender el contexto de Sector con categoría estable y política única de compatibilidad.
- Extender contexto ligado y todos los puntos de entrada directos.
- Cerrar creación/edición/cierre/confirmación/cancelación/validación/reapertura de geometría.
- Gate: matrices representativas de incompatibilidad y geometría cubren todas las particiones
  declaradas, con cero cambios parciales y round-trip real.

### Phase C — Registros y ciclos completos (US2–US3, P1)

- Versionar detalles y completar suelo, fitosanitario, cultivo, cosecha y otra labor.
- Mantener tipos heredados `sowing`/`pruning`; agregar `cultivation` sin reinterpretarlos.
- Cerrar asignaciones/rotaciones por fecha y contexto histórico.
- Gate: un caso mínimo y completo por subtipo, más nulos, límites, corrección y rollback, conserva
  exactamente datos/contexto tras reapertura; la matriz de rotación cubre estados vigentes,
  futuros, solapados, cancelados y archivados.

### Phase D — Riego verificable (US4, P1)

- Completar el registro manual para los métodos heredados.
- Capturar caudal, duración y presión aplicable y congelar snapshots.
- Implementar la estimación matemática básica con la aritmética existente de caudal total ×
  duración; no presentarla como recomendación agronómica.
- No exponer etapa, textura ni clima como entradas de cálculo en 003. Una fórmula avanzada futura
  podrá declararlas; con el conocimiento actual, esa recomendación permanece no disponible.
- Gate: métodos manuales, cancelación, invalidación del borrador y matriz automatizada de valores,
  unidades, límites y redondeos de la estimación básica; sin firmas ni aprobación externa.

### Phase E — Fertilización y apicultura (US5–US6, P2)

- Completar Manual/Foliar/Fertirriego, correcciones y vínculo opcional inmutable con riego.
- Completar inspección/alimentación/sanidad/cosecha apícola, fotos y rechazo vegetal.
- Gate: matrices por método de fertilización y tarea apícola cubren requeridos, opcionales,
  inválidos, corrección, adjuntos y separación de dominio con round-trip.

### Phase F — Historial y respaldo (US7, P2)

- Completar proyección, detalles, filtros y estados sin duplicar agregados compuestos.
- Activar schema/payloads/codecs/handlers 003 sólo cuando tests local+remoto pasen.
- Gate: matriz reproducible con tiempo virtual, reaperturas en puntos críticos, ACK perdido,
  conflicto y reanudación exact-once.

### Phase G — Integraciones y cierre (US8, P3)

- Regresión aislada de OSM/GPS, Open-Meteo, Gemini, exportación, notificaciones y sesión.
- Capturar request AgroIA para demostrar ausencia de contexto privado.
- Ejecutar PF-01..PF-30, revisión visual `master.md` y los flujos automatizados SC-004/SC-014 desde
  sus puntos de entrada públicos.
- Declarar 003 completo sólo si US1–US7 y todos sus criterios aplicables están en PASS.

## Test Strategy and Release Gates

- **Dominio/unidad**: tests puros de matriz, rutas/facades directas y reintento; UI no cuenta como
  única protección.
- **Persistencia**: DB en archivo, cierre/reapertura real y fallas inyectadas dentro de transacción.
- **Migración**: fixture v10, conteos/IDs/hashes/relaciones antes y después, sin downgrade destructivo.
- **Contratos**: frontend compila sólo contra allowlist pública; arquitectura rechaza imports
  internos.
- **Sync**: codec unitario, pgTAP/RLS/RPC, ACK perdido, duplicate, conflict, tombstone y pull
  transaccional; nunca enviar un lote vacío tras filtrar agregados no soportados.
- **UI/Android**: widget/semántica/golden donde aporta; dispositivo/emulador para mapa/GPS y ciclo
  de vida modificado por 003. Evidencia de WorkManager, biometría o notificaciones sólo se exige si
  el código afectado por 003 depende directamente de ella.
- **Flujo automatizado**: navegación pública, contexto visible y confirmación/reapertura de cada
  familia representativa. Una sesión de usabilidad posterior es opcional y no bloqueante.

El procedimiento ejecutable está en [quickstart.md](./quickstart.md).

## Risks and Controls

| Riesgo | Control del plan |
|---|---|
| Tratar `kind` como decoración o inferir por nombre de cultivo | Política backend tipada y tests en cada facade/RPC. |
| Inventar contexto legado | Backfill sólo de relaciones demostrables; desconocidos quedan nulos/marcados. |
| Romper payloads pendientes | Decodificación por schema version y migración idempotente de outbox con fixtures v1. |
| Duplicar cosecha/riego/suelo/apiario | `groupingKey` por labor raíz y enlaces únicos de especialización. |
| Perder presión/caudal o usar preview obsoleto | Snapshot canónico + invalidación ante cualquier cambio de borrador. |
| Presentar ciencia no definida | Estimación básica rotulada como matemática; fórmula avanzada ausente queda explícitamente no disponible. |
| Reintroducir proveedores antiguos | Tests/configuración basados en código actual: OSM, Open-Meteo y Gemini. |
| Baseline 002 incompleta | Sólo una dependencia directa se ejecuta como gate 003; el resto continúa visible y bajo 002. |

## Definition of Architectural Done

003 está arquitectónicamente listo para aceptación sólo cuando:

1. no existe import privado frontend→backend ni dependencia backend→frontend;
2. todas las mutaciones 003 pasan por contexto y política de categoría backend;
3. cada éxito observable corresponde a commit Drift y estado de respaldo honesto;
4. la migración v11 mínima preserva íntegramente fixture v10 y outbox sin crear periodos de dominio;
5. los payloads nuevos tienen codec local, handler remoto, RLS y pruebas antes de activarse;
6. historia proyecta una sola vez cada evento y recupera detalles/contexto;
7. estimación básica reproduce la fórmula declarada y la recomendación avanzada permanece
   deshabilitada sin fórmula versionada verificable;
8. PF-01..PF-30 están verificados y US1–US7 superan todos sus gates.

## Constitution Check — Post Phase 1 Design

**PASS**. `research.md`, `data-model.md`, los contratos y `quickstart.md` conservan la arquitectura
vigente, usan cambio de datos mínimo, sitúan dominio/persistencia/sync en backend, dejan presentación
en frontend, preservan historia y offline-first, centralizan validez por categoría y excluyen toda
recomendación avanzada sin fórmula definida. La eliminación de identidad/periodos paralelos reduce
complejidad sin debilitar los flujos. No se detectan excepciones ni violaciones que requieran
Complexity Tracking.

## Complexity Tracking

No aplica: el diseño no introduce excepciones constitucionales.
