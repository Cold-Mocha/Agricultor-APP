# Propuesta 01 — Arquitectura modular por funcionalidades para AgroCampo

- **Estado:** propuesta de reordenamiento; no implementada.
- **Fecha:** 7 de septiembre de 2026.
- **Alcance:** aplicación Flutter Android, paquete Backend local y proyecto Supabase del mismo repositorio.
- **Autoridades preservadas:** [`specs/001-agrocampo-android-mvp/`](./specs/001-agrocampo-android-mvp/), [`specs/002-agrocampo-functional-core/`](./specs/002-agrocampo-functional-core/), [`master.md`](./master.md) y [`docs/architecture/frontend-backend-boundary.md`](./docs/architecture/frontend-backend-boundary.md).

## 1. Decisión propuesta

AgroCampo debería adoptar una **arquitectura modular por funcionalidades dentro de un monorepositorio Dart/Flutter nativo**, con estas decisiones:

1. Mantener `frontend/` como la única aplicación ejecutable y `backend/` como el único paquete Flutter local sin UI.
2. Convertir la raíz en un **Pub Workspace** con dos miembros: `frontend` y `backend`.
3. Mover las implementaciones de ambos paquetes bajo `lib/src/`, dejando públicas sólo las entradas deliberadas.
4. Organizar el código por **capacidades de negocio**, no por pantallas aisladas ni por tecnologías.
5. Conservar un único Drift, una única outbox y un único proyecto Supabase; la modularidad será de código y ownership, no una fragmentación de datos ni la creación de microservicios.
6. Mantener la regla existente: producción Frontend importa Backend únicamente mediante `package:agrocampo_backend/agrocampo_backend.dart`.
7. No crear por ahora un paquete Dart por cada feature. La opción recomendada es un **monolito modular de dos paquetes**, con límites internos verificados automáticamente.

En forma resumida:

```text
Monorepositorio Pub Workspace
│
├── frontend/  aplicación, rutas, shell, páginas y widgets
│       │
│       └── importa sólo el contrato público de backend/
│
└── backend/   aplicación lógica, dominio, repositorios e infraestructura local
        │
        ├── Drift + outbox, fuente operativa offline
        └── Supabase, respaldo remoto y Edge Functions
```

Esta decisión amplía y ordena la separación ya implementada; no reemplaza la arquitectura aprobada ni agrega alcance funcional.

## 2. Respuesta directa a la estructura de referencia

La estructura web propuesta como inspiración es útil por su orientación a módulos, pero no debe copiarse literalmente:

- En Dart y Flutter, el código va en `lib/`; la implementación interna de un paquete debe quedar en `lib/src/`, no en un `src/` paralelo. Dart documenta `lib/src` como la ubicación convencional de implementaciones que otros paquetes no deben importar directamente ([Dart: Package layout conventions](https://dart.dev/tools/pub/package-layout)).
- Flutter usa `pubspec.yaml`, no `package.json`.
- `hooks/` es una convención habitual de React. AgroCampo no usa `flutter_hooks`; no se debe crear una carpeta vacía ni introducir otra tecnología.
- `services/`, `types/` y `utils/` no deben convertirse en cajones genéricos. En esta propuesta, cada nombre describe una responsabilidad concreta.
- `.env` no debe versionarse. La aplicación mantiene configuración pública mediante el mecanismo aprobado y los secretos permanecen en el entorno de Edge Functions; sólo tendría sentido versionar un `.env.example` sin valores sensibles.
- Supabase conserva su estructura CLI dentro de `backend/supabase/`; no es un tercer backend ni un paquete Node.

## 3. Alcance, supuestos y exclusiones

### 3.1 Incluye

- Taxonomía de módulos funcionales.
- Estructura objetivo de `frontend/`, `backend/`, Drift, Supabase y tests.
- Reglas de imports y APIs públicas.
- Adopción propuesta de Pub Workspaces.
- Plan incremental de migración, validación y reversión.
- Criterios para una eventual extracción futura de módulos a paquetes Dart.

### 3.2 No incluye

- Implementar ahora los movimientos.
- Cambiar comportamiento, datos, copy, rutas observables o diseño.
- Crear aplicación web, panel administrativo, API propia, microservicios o un servidor adicional.
- Reemplazar Riverpod, go_router, Drift, Supabase o las integraciones aprobadas.
- Rediseñar el esquema Drift/Supabase o editar migraciones históricas.
- Cambiar el prototipo `index.html` o `agrocampo-highfi.html`.
- Incorporar roles, empresas, trabajadores, ERP, IoT, sensores automáticos o nuevas funciones no aprobadas.

Toda tarea futura que toque UI debe citar y cumplir [`master.md`](./master.md), en particular sus secciones **Navigation**, **Screens**, **Offline UX**, **Flutter Implementation Guidelines** y **Development Rules**.

## 4. Método de investigación

Se contrastaron cuatro familias de evidencia:

1. **Estado real del repositorio:** árboles de `frontend/lib`, `backend/lib`, tests, `pubspec.yaml`, exports, imports, composición Riverpod, router, Drift y Supabase.
2. **Requisitos canónicos:** specs 001/002, planes, tareas, modelos de datos y contratos de contexto agrícola, guardado local, sincronización, navegación e integraciones.
3. **Autoridad visual:** inventario de pantallas, navegación, estados y reglas Flutter de [`master.md`](./master.md).
4. **Fuentes técnicas primarias:** documentación oficial de Flutter, Dart/Pub, Drift, Riverpod, go_router y Supabase.

La propuesta distingue hechos observados de inferencias. La selección de módulos es una inferencia arquitectónica basada en las capacidades e invariantes del dominio; no existe una lista universal de carpetas que sea correcta para todos los proyectos.

## 5. Auditoría de la arquitectura actual

El repositorio ya es físicamente un monorepositorio y ya tiene una primera organización feature-first. La migración del 6 de septiembre de 2026 dejó la división `frontend/` / `backend/` verificada en [`docs/architecture/migration-report.md`](./docs/architecture/migration-report.md).

### 5.1 Inventario observado

| Indicador | Estado actual |
|---|---:|
| Directorios de feature en Frontend | 20 |
| Archivos Dart dentro de features Frontend | 30 |
| Directorios de feature en Backend | 19 |
| Archivos Dart dentro de features Backend | 106 |
| Archivos Dart en `backend/lib/core` | 65 |
| Exports directos del barrel `agrocampo_backend.dart` | 30 |
| Tablas registradas por `AppDatabase` | 26 |
| Líneas del router central | 321 |

### 5.2 Fortalezas que deben preservarse

- Frontera física clara entre UI y lógica/datos.
- Frontend consume una única entrada pública de Backend.
- Backend no importa widgets, tema ni go_router.
- Drift continúa como fuente operativa offline; Supabase es respaldo remoto.
- El flujo `Frontend → Backend local → Drift → Outbox → Supabase` está documentado y probado.
- Ya existen APIs de varias features, tests de frontera, pruebas unitarias, de widgets, goldens, integración, migraciones y RLS.
- La navegación y la presentación ya se apoyan en `master.md`.

### 5.3 Problemas encontrados

#### a. “Feature” significa cosas diferentes según la carpeta

Actualmente conviven:

- capacidades de negocio: `crops`, `irrigation`, `labors`;
- pantallas o superficies: `home`, `more`, `map`;
- infraestructura presentada al usuario: `sync_status`;
- coordinación transversal: `context`.

Esto dificulta saber quién es dueño de una regla o de un dato.

#### b. Las convenciones internas no son uniformes

`sectors` usa `pages/` y `widgets/`; la mayoría usa `presentation/`. Algunas features tienen `<feature>_api.dart`; `auth`, `context`, `parcels` y `sectors` se exportan parcialmente archivo por archivo desde el barrel raíz.

#### c. Hay dependencias concretas entre features

Se observaron, entre otras:

- `map → sectors`;
- `irrigation → labors`;
- `production → labors`;
- `parcels → context`;
- `profile → weather`;
- `sectors → auth + context + crops + history`;
- `history → labors`.

No todas son incorrectas, pero hoy alcanzan repositorios, controllers o modelos concretos de otra feature. Flutter recomienda que los repositorios no se conozcan entre sí y que la coordinación de múltiples repositorios se realice en la capa de presentación lógica o en una capa de dominio/casos de uso cuando la interacción es compleja ([Flutter: Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)). En AgroCampo, los controllers Riverpod y casos de uso de aplicación son el lugar apropiado para esa coordinación, sin mover lógica a widgets.

#### d. `core/` concentra infraestructura y piezas de negocio

`backend/lib/core` tiene 65 archivos. Allí viven la base de datos, sincronización y red, pero también:

- tablas de apicultura, riego, producción y parcelas;
- exportación;
- autenticación;
- geometría territorial;
- programación de recordatorios.

Además, archivos como `external_service_tables.dart`, `media_reminder_tables.dart`, `labor_tables.dart`, `territory_tables.dart` y `technical_tables.dart` agrupan tablas con owners funcionales distintos.

#### e. La implementación Backend es públicamente direccionable

Aunque el test actual restringe a Frontend al barrel raíz, `backend/lib/core/**` y `backend/lib/features/**` están directamente bajo `lib/`. Dart reserva `lib/src/` para implementación interna y provee el lint recomendado `implementation_imports` para impedir que otro paquete la consuma ([Dart: implementation_imports](https://dart.dev/tools/linter-rules/implementation_imports)). La estructura actual depende más de un test propio que de la convención natural del ecosistema.

#### f. Falta un workspace Dart nativo

`frontend` y `backend` poseen resoluciones y lockfiles separados. Ambos repiten el override de `path_provider_android`. Pub Workspaces ofrece una resolución, un `pubspec.lock` y un `package_config.json` compartidos; también obliga a resolver incompatibilidades entre paquetes que se ejecutan juntos ([Dart: Pub workspaces](https://dart.dev/tools/pub/workspaces)). La documentación oficial indica además que un override sólo puede declararse una vez en el workspace y recomienda centralizarlo en la raíz.

#### g. Los tests verifican la frontera entre paquetes, pero no entre módulos

`frontend/test/architecture/frontend_backend_boundary_test.dart` protege UI ↔ Backend e infraestructura pública. No impide que una feature Backend importe la implementación interna de otra ni que `shared/` crezca sin criterio.

## 6. Opciones evaluadas

| Opción | Ventajas | Costos/riesgos | Decisión |
|---|---|---|---|
| A. Sólo renombrar carpetas actuales | Cambio pequeño | No corrige visibilidad pública, acoplamiento concreto, `core/` ni resolución duplicada | Insuficiente |
| B. Dos paquetes en Pub Workspace + módulos internos | Preserva arquitectura aprobada; unifica dependencias; limita churn; permite migración incremental; mantiene una transacción Drift | Requiere guardas propias para límites dentro del mismo paquete | **Recomendada** |
| C. Un paquete Dart por feature | Fronteras de compilación fuertes y tests muy aislados | Explosión de paquetes/APIs; dependencias cíclicas probables alrededor de contexto, labor, historial, Drift y sync; migración extensa | Posponer |
| D. Separar Backend como servidor/microservicios | Despliegue independiente | Rompe el modelo local-first aprobado, agrega arquitectura y alcance no autorizados | Descartada |

La opción B es proporcional al tamaño y a la forma real del producto. Flutter enfatiza responsabilidades, interfaces y dependencias claras, pero advierte que capas y casos de uso innecesarios agregan complejidad ([Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)). La modularidad debe reducir acoplamiento observable, no maximizar la cantidad de carpetas.

## 7. Modelo arquitectónico objetivo

### 7.1 Tipo de arquitectura

**Monolito modular local-first en un Pub Workspace.**

- **Monolito:** se entrega un APK y el Backend local se compila dentro de él.
- **Modular:** cada capacidad posee contratos, aplicación, dominio e infraestructura identificables.
- **Local-first:** una escritura válida se confirma en Drift y su outbox antes de mostrar éxito; la red no es fuente paralela para la UI.
- **Monorepositorio:** código, Supabase, specs, diseño, pruebas y CI evolucionan en una sola unidad Git.

La documentación de Flutter sobre offline-first respalda separar repositorio y fuentes local/remota, manteniendo explícita la estrategia de lectura y escritura ([Flutter: Offline-first support](https://docs.flutter.dev/app-architecture/design-patterns/offline-first)). En AgroCampo prevalecen los contratos más estrictos ya aprobados de guardado local y sincronización v2.

### 7.2 Flujo de dependencias

```text
frontend/lib/src/app
        │ compone rutas, shell y módulos visuales
        ▼
frontend/lib/src/modules/<módulo>/presentation
        │ importa sólo agrocampo_backend.dart
        ▼
backend/lib/agrocampo_backend.dart
        │ exporta contratos/facades allowlisted
        ▼
backend/lib/src/modules/<módulo>/application
        │ usa dominio y puertos
        ▼
backend/lib/src/modules/<módulo>/domain
        ▲
        │ implementa puertos
backend/lib/src/modules/<módulo>/infrastructure
        │
        ▼
backend/lib/src/platform/{database,sync,network,files,notifications}
        │
        ├── Drift + outbox
        └── Supabase y plugins Android
```

La composición concreta ocurre sólo en `frontend/lib/src/app/` y `backend/lib/src/composition/`. El dominio no conoce Flutter UI, Riverpod, Drift, Supabase ni plugins.

## 8. Catálogo recomendado de módulos

Los nombres de directorio se mantienen en inglés y `snake_case`, como el código existente; la interfaz y documentación funcional siguen en español. “Autenticación” se representa como `auth`.

| Módulo objetivo | Origen actual principal | Responsabilidad propia | No debe poseer | Trazabilidad |
|---|---|---|---|---|
| `auth` | `features/auth`, `core/auth` | Login remoto inicial, sesión local protegida, logout, biometría, material seguro de sesión | Perfil visible, datos agrícolas, navegación UI | 002 FR-006–FR-013 |
| `profile` | `features/profile`, parte de `LocalProfiles`/preferencias | Nombre visible y preferencias personales aprobadas | Sesión, clima, roles, empresas o trabajadores | `master.md` Perfil/Configuración y restricciones 001/002 |
| `territory` | `features/parcels`, `features/sectors`, `features/map`, `core/geometry` | Parcelas, sectores, geometría, GPS/places como puertos, edición/validación territorial y proyecciones de sector | Temporadas, historial, clima o sync engine | 002 FR-014–FR-028 |
| `agricultural_context` | `features/context`, selector y tarjeta de contexto | Selección y binding validados de owner/parcela/sector/temporada/asignación; revisión persistida | CRUD de las entidades seleccionadas | Contrato Agricultural Context; FR-015–FR-016, FR-028, FR-094 |
| `crop_cycles` | `features/crops`, tablas de cultivos/temporadas | Catálogo, cultivos personalizados, temporadas, asignaciones, rotación e intercambio | Parcelas, labores o cálculos de riego | 002 FR-029–FR-039 |
| `labors` | `features/labors`, raíz `Labors` | Evento agrícola raíz, tipos estructurados, corrección/anulación y contrato común de labor | Especializaciones completas de riego/producción | 002 FR-040–FR-045 |
| `soil` | `features/soil`, `SoilMeasurements` | Medición de suelo y su validación/registro local | Inferencias de fertilidad no aprobadas | 001 US2 y restricciones de 001/002 |
| `irrigation` | `features/irrigation`, tablas/reglas de riego | Configuración por goteo, cálculo determinista, estimación y riego realizado | Chatbot, clima como requisito duro o automatización física | 002 FR-049–FR-059 |
| `production` | `features/production`, `ProductionRecords` | Especialización 1:1 de cosecha y valores de producción | Un segundo evento de historial o dashboards no requeridos | 002 FR-046–FR-047 |
| `apiary` | `features/apiary`, `ApiaryInspections` | Revisión apícola y datos propios del registro | Cuenta/rol “apicultor” | 001 US7 y `master.md` Revisión apícola |
| `media` | `features/photos`, `PhotoAttachments`, file store | Captura/selección, archivo privado, metadata, subida y estado de adjunto | Análisis de fotografías | 001 US6 y restricciones 002 |
| `reminders` | `features/reminders`, parte de notifications | Recordatorios, programación local y reconciliación | Convertir permiso denegado en error del registro | 002 FR-080–FR-083 |
| `history` | `features/history` | Proyección cronológica de temporadas, cultivos, labores, riego y producción | Mutar agregados o depender de repositorios concretos de otras features | 002 FR-060–FR-065 |
| `weather` | `features/weather`, `WeatherCache`, FCM meteorológico | Clima normalizado, cache/frescura, alertas opt-in y atribución | Bloquear flujos locales o proveer alertas oficiales inexistentes | 002 FR-084–FR-087 |
| `agro_ai` | `features/agro_ai`, `AiMessages` | Conversación general, privacidad, reintento idempotente y disclaimer | Contexto privado automático, acciones o cálculo de riego | 002 FR-088–FR-092 |
| `export` | `features/export`, `core/export`, `ExportSnapshots` | Snapshot y exportación XLSX mediante selector Android | Confirmar éxito antes de escritura completa | 001 US8 y contrato XLSX |
| `sync_status` | `features/sync_status` | Estado visible, pendientes, errores y resolución de conflictos | Implementar transporte, outbox o codecs | 002 FR-066–FR-079 y `master.md` Sincronización |
| `home` | `features/home` | Composición visual de inicio y accesos rápidos | Reglas, repositorios o un “dashboard” analítico nuevo | `master.md` Inicio |

### 8.1 Elementos que no son módulos de negocio

- `more` es un menú del shell, por lo que debe vivir en `frontend/lib/src/app/shell/`.
- `map` es una forma de trabajar con territorio, por lo que se integra en `territory`.
- `sync` técnico es plataforma; sólo `sync_status` y conflictos son feature visible.
- `database`, `network`, `files`, `notifications`, `observability` y `config` son capacidades de plataforma.
- `dashboard` no se crea como módulo adicional: el MVP tiene `home`; agregar analítica ampliaría alcance.

### 8.2 Dependencias funcionales permitidas

1. `auth` no depende de módulos agrícolas.
2. `territory` recibe `ownerId`; no importa el controller de sesión.
3. `agricultural_context` consume contratos de consulta de `auth`, `territory` y `crop_cycles`.
4. `labors`, `soil`, `irrigation`, `production`, `apiary`, `media` y `reminders` consumen un `BoundAgriculturalContext`, no buscan “el primer sector”.
5. `irrigation` y `production` coordinan con el contrato público de `labors` mediante casos de uso transaccionales; sus repositorios no construyen otro repositorio concreto.
6. `history` consulta una proyección propia; no importa `HistoryRepository` desde `sectors` ni enums internos de `labors`.
7. `profile` no construye `WeatherAlertService`; la preferencia meteorológica la administra `weather` y la UI la compone donde corresponda.
8. `home` puede componer facades visuales de `weather`, `territory` y `sync_status`, pero no sus archivos internos.
9. El registro de codecs de sync se arma en composición; cada agregado aporta su codec por una interfaz estable.

## 9. Estructura objetivo del repositorio

```text
Agricultor-APP/
├── pubspec.yaml                         # Workspace, sin lib/ productivo
├── pubspec.lock                         # Resolución única del workspace
├── analysis_options.yaml                # Base común opcional
├── tool/
│   └── check_architecture.dart          # Reglas de fronteras y ciclos
│
├── frontend/                            # Aplicación Flutter/Android ejecutable
│   ├── pubspec.yaml                     # resolution: workspace
│   ├── analysis_options.yaml
│   ├── android/
│   ├── assets/
│   ├── lib/
│   │   ├── main.dart                    # Único entrypoint
│   │   └── src/
│   │       ├── app/
│   │       │   ├── bootstrap/
│   │       │   ├── routing/
│   │       │   ├── shell/               # Incluye pantalla/menú Más
│   │       │   └── theme/               # Composición ThemeData
│   │       ├── modules/
│   │       │   ├── auth/
│   │       │   ├── profile/
│   │       │   ├── territory/
│   │       │   ├── agricultural_context/
│   │       │   ├── crop_cycles/
│   │       │   ├── labors/
│   │       │   ├── soil/
│   │       │   ├── irrigation/
│   │       │   ├── production/
│   │       │   ├── apiary/
│   │       │   ├── media/
│   │       │   ├── reminders/
│   │       │   ├── history/
│   │       │   ├── weather/
│   │       │   ├── agro_ai/
│   │       │   ├── export/
│   │       │   ├── sync_status/
│   │       │   └── home/
│   │       └── shared/
│   │           ├── design_system/
│   │           │   ├── components/
│   │           │   ├── semantics/
│   │           │   └── tokens/
│   │           └── presentation/
│   ├── test/
│   │   ├── app/
│   │   ├── architecture/
│   │   ├── modules/                     # Refleja lib/src/modules
│   │   ├── shared/
│   │   └── golden/
│   └── integration_test/
│       ├── flows/
│       └── platform/
│
├── backend/                             # Paquete Flutter local sin UI
│   ├── pubspec.yaml                     # resolution: workspace
│   ├── analysis_options.yaml
│   ├── build.yaml
│   ├── assets/data/
│   ├── lib/
│   │   ├── agrocampo_backend.dart       # Única API importable por Frontend
│   │   └── src/
│   │       ├── composition/
│   │       │   ├── backend_bootstrap.dart
│   │       │   └── backend_providers.dart
│   │       ├── modules/                 # Mismos owners funcionales
│   │       │   ├── auth/
│   │       │   ├── profile/
│   │       │   ├── territory/
│   │       │   ├── agricultural_context/
│   │       │   ├── crop_cycles/
│   │       │   ├── labors/
│   │       │   ├── soil/
│   │       │   ├── irrigation/
│   │       │   ├── production/
│   │       │   ├── apiary/
│   │       │   ├── media/
│   │       │   ├── reminders/
│   │       │   ├── history/
│   │       │   ├── weather/
│   │       │   ├── agro_ai/
│   │       │   ├── export/
│   │       │   └── sync_status/
│   │       ├── platform/
│   │       │   ├── database/            # AppDatabase y migraciones Drift
│   │       │   ├── sync/                # Engine, outbox, gateway y registry
│   │       │   ├── network/
│   │       │   ├── files/
│   │       │   ├── notifications/
│   │       │   └── observability/
│   │       └── shared/
│   │           ├── contracts/           # AppDestination y contratos realmente globales
│   │           └── kernel/              # Clock, EntityId, AppFailure
│   ├── test/
│   │   ├── architecture/
│   │   ├── composition/
│   │   ├── modules/
│   │   ├── platform/
│   │   ├── integration/
│   │   ├── performance/
│   │   └── fixtures/
│   ├── drift_schemas/
│   └── supabase/
│       ├── config.toml
│       ├── migrations/                  # Historial global, ordenado e inmutable
│       ├── functions/
│       │   ├── _shared/
│       │   ├── agro-ai/
│       │   ├── weather-proxy/
│       │   ├── notification-dispatch/
│       │   └── tests/
│       │       ├── agro-ai-test.ts
│       │       └── weather-proxy-test.ts
│       ├── tests/database/
│       └── seed.sql
│
├── specs/
├── docs/
├── master.md
├── index.html
└── agrocampo-highfi.html
```

`frontend/` y `backend/` no se renombran como `apps/` y `packages/`: esa mudanza no crea una frontera nueva y sí invalidaría documentación, scripts y evidencia histórica. Pub Workspaces acepta miembros en rutas explícitas, por lo que la organización actual puede convertirse en workspace sin ese churn ([Dart: Pub workspaces](https://dart.dev/tools/pub/workspaces)).

## 10. Plantilla interna de cada módulo

Sólo se crean carpetas que tengan archivos y una responsabilidad real.

### 10.1 Frontend

```text
frontend/lib/src/modules/territory/
├── territory_ui.dart                    # Facade interna para app/otros módulos UI
├── routes/
│   └── territory_routes.dart
└── presentation/
    ├── pages/
    │   ├── parcel_list_page.dart
    │   ├── parcel_form_page.dart
    │   ├── sector_list_page.dart
    │   ├── sector_detail_page.dart
    │   └── territory_map_page.dart
    ├── widgets/
    │   ├── quadrant_map_preview.dart
    │   └── sector_summary_card.dart
    ├── controllers/                      # Notifier/ViewModel y coordinación de UI
    ├── state/                            # Loading, formulario y errores visuales
    └── formatters/                       # Transformación específica para mostrar
```

Reglas:

- Las páginas/widgets contienen composición, layout, animación y lógica visual simple; no reglas de datos.
- El estado efímero puramente visual puede permanecer en un widget.
- Controllers/ViewModels/Notifiers, loading, formulario, selección y errores visuales pertenecen a Frontend.
- Validación de negocio, repositorios y DTOs de comandos permanecen en Backend. Un plugin de interacción puramente visual, como el selector de archivos/fotos, puede quedar en Frontend; integraciones de negocio y persistencia quedan en infraestructura Backend.
- Un módulo Frontend importa otro sólo mediante su `<module>_ui.dart`.
- Las rutas de módulo son fragmentos `RouteBase`; `app/routing` conserva la composición global, redirects de sesión, shell y orden de navegación.
- `go_router` soporta subrutas, redirección y `ShellRoute`, por lo que el router puede componerse sin entregar el ownership del shell a una feature ([go_router](https://pub.dev/packages/go_router)).
- Todo componente visual se implementa según [`master.md`](./master.md); no se crean tokens, variantes ni navegación nuevos durante la mudanza.

### 10.2 Backend

```text
backend/lib/src/modules/irrigation/
├── irrigation_api.dart                  # Contratos allowlisted para el barrel raíz
├── application/
│   ├── facades/                         # Frontera de aplicación sin estado de pantalla
│   └── use_cases/                       # Sólo coordinaciones complejas/reutilizadas
├── contracts/
│   ├── dto/
│   └── inputs/
├── domain/
│   ├── entities/
│   ├── value_objects/
│   ├── policies/                        # Cálculo/validación pura
│   └── repositories/                    # Interfaces/ports, no implementaciones
└── infrastructure/
    ├── persistence/
    │   ├── tables/
    │   ├── daos/
    │   └── repositories/
    ├── remote/
    ├── sync/
    └── mappers/
```

Reglas:

- `application` coordina comandos y devuelve contratos neutrales; Frontend transforma esos resultados en estado visual.
- `domain` es Dart puro sin excepciones.
- `domain/repositories` contiene interfaces; implementaciones Drift/Supabase viven en `infrastructure`.
- No se crea un caso de uso para un passthrough trivial. Se usa cuando coordina varios repositorios, una transacción compuesta o una regla compleja/reutilizada.
- Un repositorio no instancia otro repositorio.
- Los facades/casos de uso no reciben `AppDatabase` si pueden recibir un repositorio/puerto específico.
- Sólo `composition` conecta implementaciones concretas con providers.
- Riverpod permanece como contenedor de estado e inyección. Sus providers son reemplazables en pruebas; Riverpod 3 provee utilidades como `ProviderContainer.test` y overrides ([Riverpod 3](https://riverpod.dev/docs/whats_new)). La persistencia experimental de providers no reemplaza Drift.

## 11. Matriz de movimientos principales

| Ruta actual | Ruta objetivo |
|---|---|
| `frontend/lib/app/**` | `frontend/lib/src/app/**` |
| `frontend/lib/features/auth/**` | `frontend/lib/src/modules/auth/presentation/**` |
| `frontend/lib/features/parcels/**` | `frontend/lib/src/modules/territory/presentation/**` |
| `frontend/lib/features/sectors/**` | `frontend/lib/src/modules/territory/presentation/**` |
| `frontend/lib/features/map/**` | `frontend/lib/src/modules/territory/presentation/**` |
| Selector/tarjeta de contexto en `frontend/lib/shared/**` | `frontend/lib/src/modules/agricultural_context/presentation/widgets/**` |
| `frontend/lib/features/crops/**` | `frontend/lib/src/modules/crop_cycles/presentation/**` |
| `frontend/lib/features/photos/**` | `frontend/lib/src/modules/media/presentation/**` |
| `frontend/lib/features/more/**` | `frontend/lib/src/app/shell/**` |
| Resto de `frontend/lib/features/<x>/**` | `frontend/lib/src/modules/<x>/presentation/**` |
| `frontend/lib/shared/presentation/components/**` | `frontend/lib/src/shared/design_system/components/**` o módulo owner |
| `backend/lib/core/config/**` | `backend/lib/src/composition/**` y `platform/network/**` según responsabilidad |
| `backend/lib/core/auth/**`, `features/auth/**` | `backend/lib/src/modules/auth/**` |
| `backend/lib/features/parcels`, `sectors`, `map`; `core/geometry` | `backend/lib/src/modules/territory/**` |
| `backend/lib/features/context/**` | `backend/lib/src/modules/agricultural_context/**` |
| `backend/lib/features/crops/**` | `backend/lib/src/modules/crop_cycles/**` |
| `backend/lib/features/photos/**`, file store asociado | `backend/lib/src/modules/media/**` |
| `backend/lib/core/export/**`, `features/export/**` | `backend/lib/src/modules/export/**` |
| `backend/lib/core/sync/**` | `backend/lib/src/platform/sync/**`; codecs concretos en cada módulo |
| `backend/lib/core/database/app_database.dart` | `backend/lib/src/platform/database/app_database.dart` |
| Tablas Drift de negocio en `core/database/tables` | `backend/lib/src/modules/<owner>/infrastructure/persistence/tables/**` |
| DAOs técnicos de outbox/cursor/conflicto | `backend/lib/src/platform/sync/persistence/**` |
| `backend/lib/shared/domain/{clock,entity_id}.dart` | `backend/lib/src/shared/kernel/**` |
| `backend/lib/shared/contracts/app_routes.dart` | `frontend/lib/src/app/routing/app_routes.dart`; Backend recibe el payload de notificación por inyección y no conoce navegación |

Mover archivos no autoriza renombrar tablas, columnas, IDs, aggregate types, rutas visibles o payloads.

## 12. API pública y reglas de imports

### 12.1 API Frontend → Backend

La regla vigente se conserva:

```dart
import 'package:agrocampo_backend/agrocampo_backend.dart';
```

El archivo `backend/lib/agrocampo_backend.dart` exportará los APIs de módulo internos:

```dart
library;

export 'src/composition/backend_bootstrap.dart';
export 'src/modules/auth/auth_api.dart';
export 'src/modules/territory/territory_api.dart';
export 'src/modules/agricultural_context/agricultural_context_api.dart';
// ...sólo contratos, inputs, entidades y facades aprobados.
```

Cada `<module>_api.dart` debe usar exports explícitos y `show` cuando aporte claridad. Nunca exporta:

- repositorios concretos;
- tablas/filas/companions Drift;
- `AppDatabase` o DAOs;
- `SupabaseClient`, RPC o payloads internos;
- file stores, plugins o gateways concretos;
- codecs/outbox/cursor;
- secretos o configuración privada.

### 12.2 Imports dentro de Backend

Permitidos:

```text
module/application      → mismo módulo domain/contracts + APIs de otros módulos
module/infrastructure   → mismo módulo domain/contracts + platform
module/domain           → mismo módulo domain + shared/kernel
composition             → todos los module APIs + platform
platform                → shared/kernel; no presentación
```

Prohibidos:

```text
module A → module B/infrastructure/**
module A → module B/application/controllers/**
domain   → Drift/Supabase/Riverpod/Flutter/plugins
platform → páginas/widgets/tema/go_router
shared   → una feature concreta
```

La única excepción `platform → modules` es
`platform/database/app_database.dart → modules/*/infrastructure/persistence/tables/**` para
registrar el schema Drift único. Ningún otro archivo de plataforma puede depender de módulos.

### 12.3 Criterio para `shared`

Algo entra a `shared` sólo si:

1. tiene semántica estable;
2. es utilizado por al menos tres módulos o es un contrato verdaderamente global;
3. no contiene lógica específica de un owner funcional;
4. no depende de infraestructura.

`utils/` genérico queda prohibido. Una función usada por un módulo vive en ese módulo; si luego cumple el criterio anterior, se extrae con pruebas.

## 13. Pub Workspace propuesto

Pub Workspaces está disponible desde Dart 3.6; el repositorio exige Dart 3.13, por lo que satisface la precondición. Un workspace crea resolución, lockfile y `package_config.json` compartidos y permite listar sus miembros con `dart pub workspace list` ([Dart: Pub workspaces](https://dart.dev/tools/pub/workspaces)).

### 13.1 `pubspec.yaml` de la raíz

```yaml
name: agrocampo_workspace
publish_to: none

environment:
  sdk: ^3.13.0

workspace:
  - frontend
  - backend

dependency_overrides:
  path_provider_android: 2.2.23
```

### 13.2 Miembros

En `frontend/pubspec.yaml` y `backend/pubspec.yaml`:

```yaml
resolution: workspace
```

Durante la primera migración se conserva:

```yaml
agrocampo_backend:
  path: ../backend
```

Esto mantiene explícita la relación aprobada y permite un rollback simple. Los dos `dependency_overrides` actuales se eliminan de los miembros y se declaran una sola vez en la raíz.

### 13.3 Consecuencias operativas

- `dart pub get` genera `pubspec.lock` y `.dart_tool/package_config.json` en la raíz.
- Los lockfiles y `.dart_tool` de los miembros dejan de ser canónicos; Pub documenta que los elimina al migrar al workspace.
- Flutter, build_runner y tests siguen ejecutándose en su paquete propietario, según la frontera actual.
- No se necesita Melos inicialmente. Con sólo dos miembros, Pub Workspace más scripts en `tool/` cubre resolución y verificación sin otra dependencia.

## 14. Estrategia Drift

### 14.1 Una base física, ownership modular

Se mantiene un único `AppDatabase` para preservar:

- transacciones atómicas de agregado + outbox;
- consultas históricas coherentes;
- un schema version y una cadena de migración;
- aislamiento por owner;
- reinicio y operación offline.

Las declaraciones de tablas y DAOs se ubican con el módulo que posee su significado. `AppDatabase` sigue siendo el composition root de Drift y registra todas las tablas.

Ejemplos:

```text
modules/territory/infrastructure/persistence/tables/{parcels,sectors}.dart
modules/crop_cycles/infrastructure/persistence/tables/{crops,seasons,assignments}.dart
modules/labors/infrastructure/persistence/tables/labors.dart
modules/soil/infrastructure/persistence/tables/soil_measurements.dart
modules/irrigation/infrastructure/persistence/tables/{configs,rules,estimates,records}.dart
modules/production/infrastructure/persistence/tables/production_records.dart
modules/media/infrastructure/persistence/tables/photo_attachments.dart
modules/reminders/infrastructure/persistence/tables/reminders.dart
platform/sync/persistence/tables/{outbox,cursors,conflicts}.dart
```

Drift recomienda DAOs para modularizar consultas de una base grande ([Drift: DAOs](https://drift.simonbinder.eu/dart_api/daos/)). Los repositorios deberían recibir el DAO o puerto mínimo que necesitan, evitando propagar `AppDatabase` a controllers y dominio.

### 14.2 Generación modular Drift

Drift ofrece un modo de generación modular que produce varias bibliotecas y reduce el tamaño del archivo generado en proyectos grandes ([Drift: Modular code generation](https://drift.simonbinder.eu/generation_options/modular/)). **No debe activarse en la misma PR que el reordenamiento.**

Primero se mueve ownership sin cambiar el modo de generación. Después se mide:

- tiempo de `build_runner` limpio e incremental;
- tiempo/memoria del analyzer;
- tamaño y frecuencia de cambio de `app_database.g.dart`;
- complejidad adicional de imports y código generado.

Sólo si hay una mejora material se aprueba un ADR separado para generación modular.

### 14.3 Migraciones

- No editar migraciones Drift ejecutadas ni snapshots históricos.
- Un movimiento de archivo sin cambio de schema no incrementa `schemaVersion`.
- Comparar el schema generado antes/después.
- Ejecutar fixtures v9→v10 y pruebas de reinicio/owner/outbox.
- Los agregados compuestos de cosecha y riego conservan una única transacción contractual.

## 15. Estrategia Supabase

Supabase documenta `supabase/` como unidad versionable de configuración, migraciones, seed, funciones y pruebas; `--workdir backend` permite conservar exactamente la ubicación actual ([Supabase: Local development workflow](https://supabase.com/docs/guides/local-development/cli-workflows)).

Decisiones:

- Mantener `backend/supabase/config.toml`, `migrations/`, `tests/database/` y `seed.sql`.
- No mover ni reescribir `0001`–`0019`; son historial global ordenado.
- Las migraciones futuras usan nombres que identifiquen la capacidad, pero siguen siendo una secuencia única.
- Mantener Edge Functions como endpoints desplegables, no crear una función por módulo móvil.
- Añadir `functions/_shared/` sólo para código realmente compartido.
- Conservar nombres con guiones: `agro-ai`, `weather-proxy`, `notification-dispatch`.
- Separar tests de funciones siguiendo la convención oficial cuando se compruebe el comando CI resultante. Supabase recomienda pocas funciones cohesivas, `_shared`, nombres con guiones y tests separados ([Supabase: Edge Functions development environment](https://supabase.com/docs/guides/functions/development-environment)).
- Mantener RLS, ownership derivado del JWT y RPC transaccional; el reordenamiento no cambia contratos remotos.

## 16. Navegación, estado y composición

### 16.1 Navegación

- `app/routing` conserva el router raíz, la redirección de sesión y el `StatefulShellRoute`.
- Cada módulo visual aporta sus rutas secundarias mediante una facade.
- `app/shell` conserva los cinco destinos y la posición central de Registrar.
- Backend expone un contrato neutral de destino para notificaciones; no importa go_router ni páginas.
- Los paths, back de Android, deep links y restauración no cambian durante la mudanza.
- Cada movimiento visual y prueba de rutas debe citar [`master.md`](./master.md).

### 16.2 Riverpod

- Providers de infraestructura y ensamblaje: `backend/lib/src/composition` o `platform`.
- Providers de facades/reglas funcionales sin estado de pantalla: `backend/lib/src/modules/<módulo>/application`.
- Controllers/Notifiers y providers de pantalla `autoDispose`: `frontend/lib/src/modules/<módulo>/presentation`.
- Sesión y contexto activo tienen facade/reglas Backend, pero su estado observable de presentación pertenece a Frontend.
- Overrides de pruebas sustituyen puertos/repositorios, no `AppDatabase` desde widgets.
- El `ProviderScope`/container se compone una vez en bootstrap.

### 16.3 Proyecciones entre módulos

Para Inicio, Sectores, Historial o Exportación, evitar encadenar repositorios concretos. Crear queries/proyecciones específicas de lectura, por ejemplo:

- `SectorOverviewQuery` para cards de sectores;
- `HistoryTimelineQuery` para el historial;
- `HomeSummaryQuery` sólo si el contenido exigido no puede componerse desde estados existentes;
- `ExportSnapshotQuery` para XLSX.

Una proyección puede leer varias tablas en infraestructura, pero devuelve un contrato propio y no muta sus owners.

## 17. Guardas automáticas de arquitectura

Crear `tool/check_architecture.dart` y ampliar los tests existentes para fallar cuando:

1. Frontend importe algo de Backend distinto de `agrocampo_backend.dart`.
2. Backend importe Frontend, widgets, material/cupertino o go_router.
3. Un módulo importe `infrastructure/` o controllers internos de otro módulo.
4. Un archivo `domain/` importe Flutter, Riverpod, Drift, Supabase o plugins.
5. El barrel público alcance infraestructura, repositorios concretos o tipos Drift.
6. Exista un ciclo entre módulos, salvo una excepción documentada y aprobada.
7. `shared/` importe un módulo.
8. Aparezcan nuevas carpetas genéricas `utils/`, `services/` o `types/` sin una regla específica.
9. Un módulo Frontend importe archivos internos de otro en vez de `<module>_ui.dart`.
10. Se cree código productivo en `lib/` de la raíz.

Activar además `implementation_imports` en el análisis. El test propio sigue siendo necesario porque los módulos comparten paquete y el lint de Dart protege principalmente imports entre paquetes.

### 17.1 Contrato documental por módulo

Cada módulo debe tener un `README.md` corto o una entrada equivalente en `docs/architecture/modules/` con:

- propósito y owner;
- requisitos/specs cubiertos;
- entidades/tablas propias;
- API pública;
- módulos permitidos como dependencia;
- eventos/proyecciones compartidos;
- tests obligatorios;
- exclusiones explícitas.

## 18. Estrategia de pruebas

### 18.1 Por módulo

- Dominio: reglas puras, invariantes y value objects.
- Aplicación: facade/use case con repositorios/puertos falsos.
- Infraestructura: DAO/repositorio con Drift en memoria y archivo.
- Contrato: API pública, inputs, estados, atomicidad y errores estables.
- UI: widget tests de carga, vacío, contenido, error, guardado local, pendiente, sync y conflicto según corresponda.

### 18.2 Integración

- Los escenarios sin dispositivo siguen al owner probado: presentación en Frontend; dominio, persistencia y sync en Backend.
- Los flujos Android, rutas, permisos y plugins siguen en `frontend/integration_test`.
- Supabase conserva pgTAP/RLS/RPC y pruebas Deno.
- Los goldens no se regeneran por un movimiento de carpetas; deben ser idénticos.
- Toda prueba visual o ajuste de UI se valida según [`master.md`](./master.md).

### 18.3 Gates de cada lote de migración

```bash
dart pub get
dart pub workspace list

# Dentro de backend/
dart run build_runner build
flutter analyze
flutter test

# Dentro de frontend/
flutter analyze
flutter test
flutter build apk --debug

# Desde la raíz
node docs/architecture/verify-migration.cjs
node agrocampo-acceptance.test.js
```

Cuando exista entorno disponible:

```bash
supabase --workdir backend db reset
supabase --workdir backend test db
deno test --allow-env backend/supabase/functions/weather-proxy/tests
deno test --allow-env backend/supabase/functions/agro-ai/tests
```

Después de migrar los tests de Edge Functions a la carpeta objetivo separada, el gate equivalente
se actualiza a `deno test --allow-env backend/supabase/functions/tests`; durante la transición se
mantienen los comandos actuales para no perder cobertura.

Además se ejecuta la comprobación de sintaxis del JavaScript embebido definida en `AGENTS.md`.

## 19. Plan incremental de implementación

Cada fase debe ser una PR/lote revisable y dejar el repositorio verde. No se mezcla reordenamiento con cambios de comportamiento o actualización de dependencias.

### Fase 0 — ADR, baseline y mapa de dependencias

- Aprobar esta propuesta o convertirla en ADR.
- Registrar inventario de archivos, imports, exports, tests, hashes Drift y rutas.
- Ejecutar baseline completo de Backend, Frontend, APK, prototipos y Supabase cuando esté disponible.
- Congelar cambios de schema/rutas durante los movimientos mecánicos.

**Salida:** baseline reproducible y grafo de dependencias actual.

### Fase 1 — Activar Pub Workspace

- Crear `pubspec.yaml` raíz.
- Agregar `resolution: workspace` a ambos miembros.
- Centralizar `path_provider_android` override.
- Generar lockfile raíz y actualizar `.gitignore`, README, quickstarts y CI.
- Confirmar builds desde los directorios propietarios.

**Rollback:** restaurar lockfiles y overrides de cada miembro; no hay movimiento de código.

### Fase 2 — Introducir `lib/src` y guardas

- Mover Backend a `backend/lib/src/{composition,modules,platform,shared}` sin cambiar aún owners complejos.
- Conservar `backend/lib/agrocampo_backend.dart` como API estable.
- Mover Frontend a `frontend/lib/src/{app,modules,shared}` conservando `main.dart`.
- Corregir imports mecánicamente.
- Activar `implementation_imports` y el checker modular.

**Criterio:** los 30 exports públicos representan la misma API observable o una reducción explícitamente compatible.

### Fase 3 — Normalizar módulos aislados

Migrar primero `auth`, `profile`, `weather`, `agro_ai`, `export`, `media` y `reminders` porque permiten validar la plantilla con menor acoplamiento mutuo.

- Separar contrato/aplicación/dominio/infraestructura.
- Mover preferencias meteorológicas desde Profile a Weather mediante contrato.
- Ubicar file/export/notification adapters bajo su owner o plataforma.
- Mantener los mismos providers públicos.

### Fase 4 — Territorio y contexto agrícola

- Consolidar `parcels + sectors + map + geometry` en `territory`.
- Extraer facades/proyecciones para lista/detalle/mapa.
- Mantener `agricultural_context` como coordinador explícito.
- Sustituir imports a controllers/repositorios concretos por query ports.
- Verificar múltiples parcelas, sectores, contexto ligado y cambios durante formularios.
- Validar toda pantalla afectada contra [`master.md`](./master.md).

### Fase 5 — Ciclos de cultivo

- Migrar catálogo, cultivos personalizados, temporadas, asignaciones, rotación e intercambio a `crop_cycles`.
- Definir contratos mínimos usados por contexto y operaciones.
- Preservar físicamente `crop_seasons` y sus IDs según el modelo v10.

### Fase 6 — Operaciones agrícolas

- Migrar `labors`, `soil`, `irrigation`, `production` y `apiary`.
- Introducir casos de uso transaccionales para riego+labor+estimación y cosecha+labor+producción.
- Eliminar construcción de `LaborRepository` desde repositorios de Irrigation/Production.
- Confirmar que Historial proyecta un evento por raíz.

### Fase 7 — Persistencia y sincronización por owner

- Mover tablas/DAOs a infraestructura de sus módulos sin cambiar schema.
- Mantener `AppDatabase` como composición única.
- Mover cada codec al módulo dueño del agregado.
- Mantener registry/coordinator/gateway/outbox/cursor/conflictos en `platform/sync`.
- Ejecutar comparación de schema, fixtures, restart, outbox, conflictos y tombstones.

### Fase 8 — Historia, sync visible, home y router

- Convertir Historial y resúmenes en proyecciones de lectura propias.
- Separar `sync_status` visible del sync engine.
- Convertir `home` en módulo de composición visual y `more` en parte del shell.
- Extraer fragmentos de rutas sin cambiar paths, back ni navegación inferior.
- Validar cada pantalla/ruta contra [`master.md`](./master.md), incluyendo goldens, semántica y estados offline.

### Fase 9 — Documentación y cierre

- Actualizar specs/planes/quickstarts sólo para rutas, sin alterar requisitos históricos.
- Actualizar frontera Frontend ↔ Backend, manifiesto de migración y reportes.
- Ejecutar la matriz completa.
- Eliminar carpetas vacías y compatibilidad temporal sólo después de verificar que no existen imports.

## 20. Criterios de aceptación del reordenamiento

La implementación futura se considera terminada sólo si:

- La raíz es un Pub Workspace válido con exactamente los miembros aprobados.
- Existe un lockfile canónico y no hay overrides duplicados.
- `frontend/lib/main.dart` y `backend/lib/agrocampo_backend.dart` son las únicas entradas públicas necesarias.
- La implementación de ambos paquetes vive bajo `lib/src`.
- Frontend sólo importa `package:agrocampo_backend/agrocampo_backend.dart`.
- No hay imports de infraestructura entre módulos ni ciclos no aprobados.
- `domain/` no importa frameworks o plugins.
- `shared/` no funciona como cajón genérico.
- Cada módulo tiene owner, API, dependencias y tests documentados.
- Drift conserva tablas, schema version, migraciones, hashes/estructura y datos válidos.
- Cada guardado mantiene transacción de dato + outbox y estados honestos.
- Supabase conserva migraciones, RLS, RPC, funciones y contratos.
- Rutas, copy, navegación, diseño, goldens y accesibilidad no cambian por la mudanza.
- Backend/Frontend analyze y tests pasan; APK debug compila.
- Tests de prototipo y sintaxis JavaScript pasan.

## 21. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| PR demasiado grande con miles de cambios de ruta | Migrar por fases y módulo, con movimientos mecánicos separados de refactors |
| Imports internos rotos o API pública accidentalmente ampliada | `lib/src`, barrel allowlisted, lint y checker de arquitectura |
| Cambiar schema Drift sin intención | Comparación de schema/snapshots, no subir versión por movimientos, tests v9→v10 |
| Romper transacciones compuestas | Casos de uso transaccionales y pruebas de rollback inyectado |
| Crear ciclos entre contexto, territorio y cultivos | Puertos de consulta mínimos y composición central |
| `shared/` se convierte en vertedero | Criterio de tres consumidores, owner explícito y guardas |
| Fragmentar router y perder jerarquía | App conserva composición/redirect/shell; módulos sólo aportan ramas |
| Divergencia visual durante movimientos | Cero cambios visuales; validar contra `master.md`; no regenerar goldens |
| Pub Workspace altera lockfiles y overrides | Fase aislada, diff de resolución, rollback documentado |
| Package-per-feature prematuro | Aplicar gates de extracción antes de crear paquetes nuevos |

## 22. Cuándo extraer un módulo a paquete Dart

No se crea un paquete por estética. Un módulo puede proponerse como tercer miembro del workspace sólo si cumple al menos dos señales y no introduce ciclos:

- lo consumen dos o más aplicaciones/paquetes reales;
- tiene API estable y pequeña;
- puede analizarse/probarse sin `AppDatabase` global ni imports internos de otros módulos;
- tiene ownership o ritmo de entrega independiente;
- una medición muestra beneficio relevante de build/análisis;
- necesita sustituir implementaciones por plataforma;
- el checker modular ya demuestra una frontera limpia.

Los primeros candidatos potenciales serían un `agrocampo_domain` Dart puro o un paquete de design system **sólo** si aparece otro consumidor. Hoy no existe esa necesidad aprobada.

## 23. Recomendación final

Implementar la **opción B**: Pub Workspace de dos paquetes + `lib/src/modules` + APIs y guardas estrictas. Es el mejor equilibrio entre claridad, aislamiento, compatibilidad y costo de migración.

El orden decisivo es:

1. workspace y guardas;
2. privacidad `lib/src`;
3. owners funcionales;
4. eliminación de dependencias concretas entre features;
5. ownership de tablas/DAOs/codecs sin dividir la base;
6. router/proyecciones/documentación;
7. considerar paquetes adicionales sólo con evidencia.

La meta no es que cada carpeta se vea igual, sino que cada cambio futuro tenga una respuesta inequívoca a cuatro preguntas: **qué módulo lo posee, qué contrato expone, de qué puede depender y cómo se verifica**.

## 24. Fuentes consultadas

### Fuentes internas canónicas

- [`AGENTS.md`](./AGENTS.md)
- [`docs/architecture/frontend-backend-boundary.md`](./docs/architecture/frontend-backend-boundary.md)
- [`docs/architecture/migration-report.md`](./docs/architecture/migration-report.md)
- [`specs/001-agrocampo-android-mvp/spec.md`](./specs/001-agrocampo-android-mvp/spec.md)
- [`specs/001-agrocampo-android-mvp/plan.md`](./specs/001-agrocampo-android-mvp/plan.md)
- [`specs/001-agrocampo-android-mvp/tasks.md`](./specs/001-agrocampo-android-mvp/tasks.md)
- [`specs/002-agrocampo-functional-core/spec.md`](./specs/002-agrocampo-functional-core/spec.md)
- [`specs/002-agrocampo-functional-core/plan.md`](./specs/002-agrocampo-functional-core/plan.md)
- [`specs/002-agrocampo-functional-core/tasks.md`](./specs/002-agrocampo-functional-core/tasks.md)
- [`specs/002-agrocampo-functional-core/data-model.md`](./specs/002-agrocampo-functional-core/data-model.md)
- [`specs/002-agrocampo-functional-core/contracts/agricultural-context.md`](./specs/002-agrocampo-functional-core/contracts/agricultural-context.md)
- [`specs/002-agrocampo-functional-core/contracts/integration-boundaries.md`](./specs/002-agrocampo-functional-core/contracts/integration-boundaries.md)
- [`specs/002-agrocampo-functional-core/contracts/local-write-contract.md`](./specs/002-agrocampo-functional-core/contracts/local-write-contract.md)
- [`specs/002-agrocampo-functional-core/contracts/sync-protocol-v2.md`](./specs/002-agrocampo-functional-core/contracts/sync-protocol-v2.md)
- [`master.md`](./master.md)

### Fuentes técnicas primarias

- Flutter, [Guide to app architecture](https://docs.flutter.dev/app-architecture/guide).
- Flutter, [Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations).
- Flutter, [Offline-first support](https://docs.flutter.dev/app-architecture/design-patterns/offline-first).
- Dart, [Pub workspaces](https://dart.dev/tools/pub/workspaces).
- Dart, [Package layout conventions](https://dart.dev/tools/pub/package-layout).
- Dart, [Lint `implementation_imports`](https://dart.dev/tools/linter-rules/implementation_imports).
- Drift, [DAOs](https://drift.simonbinder.eu/dart_api/daos/).
- Drift, [Modular code generation](https://drift.simonbinder.eu/generation_options/modular/).
- Flutter team, [go_router](https://pub.dev/packages/go_router).
- Riverpod, [What’s new in Riverpod 3.0](https://riverpod.dev/docs/whats_new).
- Supabase, [Local development workflow](https://supabase.com/docs/guides/local-development/cli-workflows).
- Supabase, [Edge Functions development environment](https://supabase.com/docs/guides/functions/development-environment).

**Fecha de consulta de fuentes web:** 7 de septiembre de 2026.
