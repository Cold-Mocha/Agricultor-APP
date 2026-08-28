# Tasks: AgroCampo Android MVP - Módulo 001

**Feature**: `002-agrocampo-android-mvp`  
**Input**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md` y constitución 1.0.0.  
**Autoridad visual**: `master.md`. Ninguna tarea autoriza decisiones visuales propias.

## Formato y reglas de ejecución

- Cada checkbox es una unidad ejecutable y conserva el formato `[ID] [P?] [Story?]`.
- `[P]` significa que puede ejecutarse en paralelo una vez cumplidas sus dependencias explícitas y siempre que no haya edición simultánea de los mismos archivos.
- Las tareas de historia incluyen `[US1]` a `[US8]`; Setup, Foundation y Polish no llevan etiqueta de historia.
- Toda tarea de UI contiene una referencia concreta `master.md → ...`. Si la sección no cubre una necesidad, la tarea se bloquea hasta actualizar y aprobar `master.md`; no se crea una variante local.
- “Referencia visual: No aplica” sólo se usa en tareas sin capa visual y prohíbe introducir widgets, copy visual o valores de estilo.
- Las pruebas indicadas son obligatorias porque `spec.md`, `plan.md`, los contratos y la constitución exigen evidencia para dominio, persistencia, sincronización, accesibilidad y flujos críticos.

---

## Phase 1: Setup — Proyecto Flutter Android

**Purpose**: Fijar toolchain, dependencias, estructura y controles antes de implementar comportamiento.

- [ ] T001 Fijar toolchain, dependencias compatibles e identidad Android en `pubspec.yaml`, `pubspec.lock`, `android/app/build.gradle.kts` y `android/app/src/main/AndroidManifest.xml`
  - **Prioridad**: P0.
  - **Dependencias**: Ninguna.
  - **Objetivo y detalle**: Adoptar Flutter/Dart/Android del plan y las dependencias estables de `research.md`; establecer `applicationId`, API mínima 24, compile/target 36, Java/desugaring exigido y excluir cualquier configuración iOS.
  - **Criterio de aceptación**: `flutter pub get`, análisis y build Android debug resuelven un único conjunto bloqueado, sin prereleases ni sistemas alternativos de estado, router o base de datos.
  - **Pruebas**: Verificar árbol de dependencias, manifest merge y APK debug en API 24 y API 36.
  - **Terminada cuando**: El lockfile es reproducible y el APK no contiene claves server-side.
  - **Referencia visual**: No aplica — configuración de build sin capa UI.

- [ ] T002 Crear la estructura feature-first y bootstrap mínimo en `lib/main.dart`, `lib/app/bootstrap/`, `lib/core/`, `lib/features/`, `lib/shared/`, `test/`, `integration_test/` y `drift_schemas/`
  - **Prioridad**: P0.
  - **Dependencias**: T001.
  - **Objetivo y detalle**: Materializar la estructura de `plan.md`, dirección `presentation -> domain <- data`, punto de composición único y convenciones de nombres; eliminar la aplicación contador sin crear pantallas funcionales todavía.
  - **Criterio de aceptación**: El proyecto compila con un bootstrap vacío controlado, ninguna feature accede a plugins directamente y no existen directorios/módulos fuera del MVP.
  - **Pruebas**: Test de humo de inicialización con providers sustituidos.
  - **Terminada cuando**: Las carpetas y archivos de entrada reflejan exactamente el plan y no contienen funciones simuladas o incompletas.
  - **Referencia visual**: No aplica — estructura y composición sin decisiones de interfaz.

- [ ] T003 [P] Implementar configuración tipada por ambiente y política de secretos en `lib/app/bootstrap/app_environment.dart`, `lib/core/network/runtime_config.dart`, `supabase/config.toml` y `.gitignore`
  - **Prioridad**: P0.
  - **Dependencias**: T001.
  - **Objetivo y detalle**: Separar dev/staging/prod; permitir sólo URL/clave publicable Supabase, configuración Firebase y clave Android restringida; rechazar Weather, Gemini, `service_role` y credenciales FCM server-side en el APK.
  - **Criterio de aceptación**: Falta o formato inválido de configuración detiene el bootstrap con error tipado; un escaneo del artefacto no encuentra secretos prohibidos.
  - **Pruebas**: Unitarias de carga/validación y prueba de escaneo de archivos/artefacto.
  - **Terminada cuando**: Cada ambiente puede configurarse sin editar código y los secretos remotos sólo están declarados como requisitos de Functions.
  - **Referencia visual**: No aplica — configuración sin capa UI.

- [ ] T004 [P] Registrar Inter y activos agrícolas locales aprobados en `pubspec.yaml`, `assets/fonts/inter/`, `assets/icons/crops/` y `lib/app/theme/asset_catalog.dart`
  - **Prioridad**: P0.
  - **Dependencias**: T001.
  - **Objetivo y detalle**: Empaquetar los pesos Inter y SVG de cultivos definidos por la autoridad visual, con claves estables y semántica de asset; no descargar fuentes o pictogramas en runtime.
  - **Criterio de aceptación**: Todos los assets cargan offline, conservan proporciones y no existen emojis, fuentes remotas ni pictogramas alternativos.
  - **Pruebas**: Test de resolución de cada asset y render de SVG en modo offline.
  - **Terminada cuando**: El catálogo cubre los nueve elementos iniciales y falla explícitamente ante una clave desconocida.
  - **Referencia visual**: `master.md → Typography → Familia y pesos extraídos`; `master.md → Flutter Implementation Guidelines → Iconografía Flutter`.

- [ ] T005 [P] Configurar generación, análisis y convenciones de prueba en `analysis_options.yaml`, `build.yaml`, `test/helpers/`, `integration_test/` y scripts documentados en `quickstart.md`
  - **Prioridad**: P0.
  - **Dependencias**: T001.
  - **Objetivo y detalle**: Unificar `build_runner` para Drift/Riverpod, lints estrictos, formato, helpers de reloj/UUID/owner y comandos reproducibles; no añadir un framework de estado o test redundante.
  - **Criterio de aceptación**: Generación limpia e idempotente, análisis sin warnings y un test vacío ejecutable en unit/widget/integration.
  - **Pruebas**: Ejecutar generación dos veces, análisis, formato y suite de humo.
  - **Terminada cuando**: CI local detecta archivos generados obsoletos y errores de arquitectura básicos.
  - **Referencia visual**: `master.md → Development Rules`; sólo para configurar la futura comprobación de política, sin crear estilos.

**Checkpoint**: Proyecto Android reproducible, estructura creada y herramientas listas.

---

## Phase 2: Foundational — Bloqueos compartidos

**Purpose**: Entregar la infraestructura obligatoria que bloquea todas las historias.

**⚠️ CRITICAL**: No comenzar tareas de US1–US8 antes de completar T006–T014.

- [ ] T006 Implementar ThemeData Material 3 y Design Tokens en `lib/app/theme/agro_theme.dart`, `color_scheme.dart`, `semantic_colors.dart`, `typography.dart`, `spacing.dart`, `radii.dart`, `elevation.dart`, `iconography.dart`, `layout.dart` y `motion.dart`
  - **Prioridad**: P0.
  - **Dependencias**: T002, T004.
  - **Objetivo y detalle**: Transcribir exclusivamente roles aprobados de `master.md` a un tema claro, `ColorScheme`, `TextTheme` y `ThemeExtension`; prohibir `fromSeed`, color dinámico y un segundo tema.
  - **Criterio de aceptación**: Cada token tiene trazabilidad a `master.md`, existe una sola vez y puede obtenerse desde `BuildContext`; no hay valores visuales en features.
  - **Pruebas**: Unitarias del esquema/extensiones y snapshot de ThemeData/component roles.
  - **Terminada cuando**: El test detecta cualquier rol ausente, duplicado o no normado.
  - **Referencia visual**: `master.md → Color System`; `master.md → Typography`; `master.md → Layout Rules`; `master.md → Flutter Implementation Guidelines → Arquitectura visual del tema`.

- [ ] T007 Implementar componentes compartidos básicos en `lib/shared/presentation/components/` y semántica común en `lib/shared/presentation/semantics/`
  - **Prioridad**: P0.
  - **Dependencias**: T006.
  - **Objetivo y detalle**: Crear page scaffold/header, cards base, botones, icon action, chips, campos/unidades, form section/error summary, banner/snackbar, loading/empty/error y estado de registro; exponer variantes semánticas, nunca parámetros de estilo arbitrarios.
  - **Criterio de aceptación**: Cada componente soporta estados aplicables, texto ampliado, nombres accesibles y consume sólo tema/tokens; ningún componente redefine valores visuales.
  - **Pruebas**: Widget/semantics para normal, focused, pressed, disabled, loading, error y escalado de texto.
  - **Terminada cuando**: Las features pueden construir sus pantallas sin repetir primitivas visuales.
  - **Referencia visual**: `master.md → Components`; `master.md → Flutter Implementation Guidelines → Accesibilidad y semántica`; `master.md → Development Rules`.

- [ ] T008 Implementar el shell y router restaurable de cinco ramas en `lib/app/routing/app_router.dart`, `route_names.dart`, `route_guards.dart` y `lib/app/shell/agro_app_shell.dart`
  - **Prioridad**: P0.
  - **Dependencias**: T006, T007.
  - **Objetivo y detalle**: Configurar `StatefulShellRoute.indexedStack`, rutas de `contracts/navigation.md`, IDs de restauración, guard base de sesión y `PopScope`; preservar pilas y evitar duplicados de destinos superiores.
  - **Criterio de aceptación**: Inicio, Sectores, Registrar, AgroIA y Más aparecen en orden normativo; back/predictive back y cambio de rama conservan estado.
  - **Pruebas**: Widget/router para orden, stack independiente, re-tap, deep link seguro, restauración y abandono cancelable.
  - **Terminada cuando**: Todas las rutas contractuales resuelven a destinos técnicos mínimos sin estilos propios y los guards son sustituibles.
  - **Referencia visual**: `master.md → Navigation → Navegación primaria`; `master.md → Navigation → Jerarquía de rutas`; `master.md → Navigation → Comportamiento Android`.

- [ ] T009 [P] Implementar bootstrap, errores tipados, conectividad y observabilidad segura en `lib/app/bootstrap/app_bootstrap.dart`, `lib/core/errors/`, `lib/core/network/` y `lib/core/observability/`
  - **Prioridad**: P0.
  - **Dependencias**: T002, T003.
  - **Objetivo y detalle**: Inicialización ordenada, clasificación auth/network/storage/validation, timeouts/cancelación, señal de conectividad no autoritativa y logs con redacción de secretos/coordenadas/payloads.
  - **Criterio de aceptación**: Un fallo de servicio queda aislado, no bloquea una capacidad local ajena y nunca registra datos sensibles.
  - **Pruebas**: Unitarias de clasificación, timeout, cancelación, redacción y conectividad falsa positiva.
  - **Terminada cuando**: Cada adaptador puede devolver un fallo estable sin filtrar excepciones del proveedor a la UI.
  - **Referencia visual**: No aplica — entrega estados semánticos, pero no implementa presentación.

- [ ] T010 Implementar AppDatabase, migraciones y tablas técnicas locales en `lib/core/database/app_database.dart`, `lib/core/database/tables/`, `lib/core/database/migrations/` y `drift_schemas/`
  - **Prioridad**: P0.
  - **Dependencias**: T001, T002, T005.
  - **Objetivo y detalle**: Abrir Drift nativo en background con FKs; crear metadata común, `sync_outbox`, `sync_cursors`, `local_conflicts`, `form_drafts`, `local_preferences`, `local_session_state`, `weather_cache`, `notification_bindings`, `ai_threads` y `ai_messages`.
  - **Criterio de aceptación**: Schema inicial coincide con `data-model.md`, distingue nulo/cero y migra desde snapshot sin pérdida; no usa BLOB para fotos.
  - **Pruebas**: Creación, constraints, rollback, archivo/reapertura, streams y migración step-by-step.
  - **Terminada cuando**: Snapshots están versionados y toda tabla técnica tiene índices justificados.
  - **Referencia visual**: No aplica — persistencia sin capa UI.

- [ ] T011 Implementar sesión segura, espacio local por propietario y base Supabase en `lib/core/auth/`, `lib/features/auth/data/`, `lib/features/auth/domain/`, `supabase/migrations/0001_auth_profile_rls.sql` y `supabase/tests/database/auth_rls_test.sql`
  - **Prioridad**: P0.
  - **Dependencias**: T003, T009, T010.
  - **Objetivo y detalle**: Email/contraseña, sesión en Android Keystore, primer acceso online, reapertura offline, perfil 1:1, DB owner-scoped, refresh antes de push y logout que bloquea sin borrar pendientes.
  - **Criterio de aceptación**: Owner A/B no comparten datos; sesión ausente no abre DB; contraseña nunca se persiste; RLS rechaza anon y otro propietario.
  - **Pruebas**: Unitarias de ciclo de sesión, base por propietario y pgTAP anon/A/B.
  - **Terminada cuando**: Auth/session puede sustituirse por fakes y no introduce roles, trabajadores o biometría.
  - **Referencia visual**: No aplica — autenticación y autorización sin widgets.

- [ ] T012 Implementar acceso, perfil y estados de sesión en `lib/features/auth/presentation/`, `lib/features/profile/presentation/` y rutas correspondientes en `lib/app/routing/app_router.dart`
  - **Prioridad**: P0.
  - **Dependencias**: T007, T008, T011.
  - **Objetivo y detalle**: Conectar controllers Riverpod a sesión/perfil, primer acceso conectado, reapertura offline, error recuperable y logout seguro; usar componentes aprobados sin crear una pantalla visual alternativa.
  - **Criterio de aceptación**: Formularios conservan valores válidos, anuncian primer error, perfil sólo muestra datos del propietario y logout no borra cambios locales.
  - **Pruebas**: Widget/semantics para carga, inválido, offline sin sesión, sesión recuperada, error y logout con pendientes.
  - **Terminada cuando**: Guard de T008 navega correctamente y toda presentación consume tokens.
  - **Referencia visual**: `master.md → Components → Inputs y formularios`; `master.md → Screens → Perfil`; `master.md → Screens → Configuración`; `master.md → Development Rules`.

- [ ] T013 Implementar primitivas local-first y transacción agregado+outbox en `lib/core/sync/outbox/`, `lib/core/sync/sync_state.dart`, `lib/shared/domain/` y `lib/core/database/daos/sync_outbox_dao.dart`
  - **Prioridad**: P0.
  - **Dependencias**: T010, T011.
  - **Objetivo y detalle**: UUID/reloj inyectables, metadata común, acciones/versiones/dependencias, recuperación de `sending`, backoff state y helper transaccional que confirma dominio+outbox juntos.
  - **Criterio de aceptación**: Ningún repositorio puede confirmar escritura sincronizable sin outbox; fallo inyectado revierte ambos; estado remoto no se infiere por conectividad.
  - **Pruebas**: Unitarias/Drift de commit, rollback, causalidad, recuperación y nulo `baseVersion` sólo en create.
  - **Terminada cuando**: Las features pueden implementar repositorios sin duplicar protocolo.
  - **Referencia visual**: No aplica — protocolo local sin UI.

- [ ] T014 Crear el gate fundacional de pruebas y política visual en `test/app/`, `test/core/`, `test/shared/design_policy_test.dart`, `test/shared/component_semantics_test.dart` y `test/helpers/`
  - **Prioridad**: P0.
  - **Dependencias**: T006–T013.
  - **Objetivo y detalle**: Añadir Provider overrides/fakes, DB temporal, reloj/UUID, harness de dispositivo/text scale, escaneo de literales y pruebas de theme/components/router/auth/outbox.
  - **Criterio de aceptación**: Falla ante color/medida/fuente/segundo tema fuera de `app/theme`, navegación alterada, control sin label o escritura sin outbox.
  - **Pruebas**: Ejecutar suite fundacional completa en API mínima simulada.
  - **Terminada cuando**: El checkpoint Foundation pasa repetidamente y no depende de red real.
  - **Referencia visual**: `master.md → Flutter Implementation Guidelines → Calidad visual y pruebas`; `master.md → Development Rules`.

**Checkpoint**: Tema y componentes normativos, router, Drift, sesión segura y outbox disponibles; las historias pueden comenzar.

---

## Phase 3: User Story 1 — Organizar parcelas y sectores (Priority: P1) 🎯 MVP

**Goal**: Crear parcelas, sectores, cultivos y temporadas con geometría válida y contexto activo, utilizable offline.

**Independent Test**: Crear una parcela con polígono válido, añadir dos sectores de formas distintas, asignar/cambiar cultivos y cambiar parcela activa; toda la estructura se consulta offline sin mezclar contextos.

- [ ] T015 [P] [US1] Escribir pruebas de entidades, restricciones y repositorios territoriales en `test/features/parcels/`, `test/features/sectors/`, `test/features/crops/` y `test/core/geometry/`
  - **Prioridad**: P1.
  - **Dependencias**: T014.
  - **Objetivo y detalle**: Cubrir UUID/owner, número único por parcela, asignación vigente única, cambio histórico, archivo/restauración, polígono inválido, autocruce, área nula y contención sector-parcela.
  - **Criterio de aceptación**: Las pruebas fallan antes de los modelos y expresan AC-CAP003/004/005 sin depender de UI.
  - **Pruebas**: Unitarias y Drift con fixtures de geometría/propietario.
  - **Terminada cuando**: Cada regla tiene caso positivo, borde y rechazo con código estable.
  - **Referencia visual**: No aplica — pruebas de dominio/datos sin UI.

- [ ] T016 [P] [US1] Implementar tablas y DAOs Drift de parcelas, sectores, catálogo, temporadas y asignaciones en `lib/core/database/tables/territory_tables.dart`, `lib/features/parcels/data/`, `lib/features/sectors/data/` y `lib/features/crops/data/`
  - **Prioridad**: P1.
  - **Dependencias**: T010, T015.
  - **Objetivo y detalle**: Modelar columnas, escalas, FKs, índices, streams, parcela activa y proyección `active_crop_by_sector` según `data-model.md`.
  - **Criterio de aceptación**: Reinicio conserva estructura; consultas por owner/parcela no mezclan datos; unicidades e historia se cumplen localmente.
  - **Pruebas**: Ejecutar T015, migración y consultas reactivas.
  - **Terminada cuando**: DAOs exponen contratos suficientes sin SQL desde presentación.
  - **Referencia visual**: No aplica — persistencia sin UI.

- [ ] T017 [P] [US1] Crear migraciones Supabase, PostGIS, índices y RLS territoriales en `supabase/migrations/0002_territory.sql` y `supabase/tests/database/territory_rls_test.sql`
  - **Prioridad**: P1.
  - **Dependencias**: T011, T015.
  - **Objetivo y detalle**: Implementar `parcels`, `sectors`, `crop_catalog`, `seasons`, `sector_crop_assignments`, FKs owner-scoped, índices parciales y GiST; denegar DML ajeno/directo no permitido.
  - **Criterio de aceptación**: Owner A/B aislados, geometrías válidas/contención revalidadas y asignación vigente única.
  - **Pruebas**: pgTAP de constraints, RLS, archivo y referencias cruzadas.
  - **Terminada cuando**: `supabase db reset` y `supabase test db` pasan desde cero.
  - **Referencia visual**: No aplica — backend sin UI.

- [ ] T018 [P] [US1] Sembrar catálogo aprobado y enlazar pictogramas en `assets/data/crop_catalog_v1.json`, `supabase/seed.sql` y `lib/features/crops/data/crop_seed_loader.dart`
  - **Prioridad**: P1.
  - **Dependencias**: T004, T016, T017.
  - **Objetivo y detalle**: IDs/códigos estables para frambuesa, arándanos, papas, sandía, melones, maíz, physalis, frutilla y apicultura, con los campos informativos exigidos y asset local.
  - **Criterio de aceptación**: Seed local/remoto coincide por ID/versión y el catálogo completo abre offline; no se añaden cultivos.
  - **Pruebas**: Integridad de seed, asset existente, duplicados y carga sin red.
  - **Terminada cuando**: Catálogo es sólo lectura y una actualización no rompe asignaciones históricas.
  - **Referencia visual**: `master.md → Components → Tarjeta de sector o cultivo`; `master.md → Flutter Implementation Guidelines → Iconografía Flutter`.

- [ ] T019 [P] [US1] Implementar geometría determinista y adapters Google Maps/GPS/Places en `lib/core/geometry/`, `lib/features/map/data/`, `android/app/src/main/kotlin/` y configuración Android de Maps
  - **Prioridad**: P1.
  - **Dependencias**: T001, T015.
  - **Objetivo y detalle**: Vértices WGS84, cierre/deshacer/edición, área versionada, autocruce/contención, permiso GPS foreground, búsqueda Places normalizada y prohibición de caché de teselas.
  - **Criterio de aceptación**: Misma geometría reproduce área dentro de tolerancia aprobada; GPS denegado permite dibujo manual; ausencia de mapa preserva geometría/lista.
  - **Pruebas**: Fixtures geométricos, fakes de permiso/search/tiles y smoke en dispositivo físico.
  - **Terminada cuando**: Dominio no importa tipos Google y la clave está restringida por app/firma.
  - **Referencia visual**: No aplica — motor/adapters sin widgets; la futura representación queda en T022.

- [ ] T020 [US1] Implementar repositorios y casos de uso territoriales en `lib/features/parcels/domain/`, `lib/features/parcels/data/`, `lib/features/sectors/domain/`, `lib/features/sectors/data/` y `lib/features/crops/domain/`
  - **Prioridad**: P1.
  - **Dependencias**: T013, T016, T018, T019.
  - **Objetivo y detalle**: Crear/editar/archivar/restaurar parcela, seleccionar activa, crear sector contenido, advertir superposición y cambiar cultivo/temporada atómicamente con outbox.
  - **Criterio de aceptación**: Cada comando confirma localmente antes de red, conserva contexto/historia y produce operación causal válida.
  - **Pruebas**: T015 más rollback entidad+outbox, propietario equivocado y parcela archivada.
  - **Terminada cuando**: Controllers sólo consumen contratos y streams locales.
  - **Referencia visual**: No aplica — dominio/repositorios sin UI.

- [ ] T021 [US1] Implementar Inicio y selección/edición de parcela en `lib/features/home/presentation/`, `lib/features/parcels/presentation/` y providers de contexto activo
  - **Prioridad**: P1.
  - **Dependencias**: T007, T008, T020.
  - **Objetivo y detalle**: Estados sin parcela, contenido, carga local, error, archivo/restauración y selector activo; conservar contexto entre rutas y mostrar guardado local/sync como estados distintos.
  - **Criterio de aceptación**: Crear una parcela selecciona el contexto; cambiarla actualiza todas las vistas sin mezcla; formularios conservan borrador/error.
  - **Pruebas**: Widget/semantics para vacío, activo, dos parcelas, archivo y offline; golden autorizado.
  - **Terminada cuando**: No existen literales visuales y las acciones navegan según contrato.
  - **Referencia visual**: `master.md → Screens → Inicio`; `master.md → Components → Estados vacíos`; `master.md → Components → Tarjetas de acción rápida y acción de cuadrante`.

- [ ] T022 [US1] Implementar Sectores, Mapa, detalle y cambio de cultivo en `lib/features/sectors/presentation/`, `lib/features/map/presentation/` y `lib/features/crops/presentation/`
  - **Prioridad**: P1.
  - **Dependencias**: T019, T020, T021.
  - **Objetivo y detalle**: Lista/mapa equivalentes, dibujo/edición con alternativa al arrastre, sector cards, detalle, selección de cultivo y temporada; estados de mapa offline/error no ocultan geometrías.
  - **Criterio de aceptación**: Sector válido aparece en lista/mapa/ficha; polígono inválido conserva puntos; cambio de cultivo no reescribe historia.
  - **Pruebas**: Widget, semantics/TalkBack, gestos y alternativa textual, narrow/landscape y mapa sin tiles.
  - **Terminada cuando**: Toda UI reutiliza tokens/componentes y cumple AC-CAP004/005.
  - **Referencia visual**: `master.md → Screens → Sectores`; `master.md → Screens → Mapa`; `master.md → Screens → Detalle sector`; `master.md → Screens → Cambiar cultivo`; `master.md → Components → Mapa de parcela`; `master.md → Components → Cuadrantes y vértices editables`.

- [ ] T023 [US1] Completar pruebas independientes y golden de US1 en `integration_test/territory_flow_test.dart` y `test/golden/us1/`
  - **Prioridad**: P1.
  - **Dependencias**: T015–T022.
  - **Objetivo y detalle**: Automatizar la historia completa con dos parcelas/dos sectores, cambio activo, reinicio offline, permisos GPS denegados y mapa indisponible.
  - **Criterio de aceptación**: Pasa el Independent Test de US1 y AC-CAP003/004/005; capturas coinciden con identidad aprobada.
  - **Pruebas**: Integración emulator/device, golden, semántica y restauración de stack/scroll.
  - **Terminada cuando**: US1 se demuestra sin datos de otras historias y sin red después del guardado.
  - **Referencia visual**: `master.md → Flutter Implementation Guidelines → Calidad visual y pruebas`; `master.md → Screens → Inicio, Sectores, Mapa, Detalle sector y Cambiar cultivo`.

**Checkpoint**: US1 funciona y es demostrable de forma independiente.

---

## Phase 4: User Story 2 — Registrar LABORES sin conexión (Priority: P1)

**Goal**: Guardar una labor, medición de suelo y riego básico completamente offline, conservar borradores y recuperar todo tras reinicio.

**Independent Test**: Con parcela/sector existentes, desactivar red, guardar los tres registros, reiniciar y comprobar datos, historial reciente y estado pendiente.

- [ ] T024 [P] [US2] Escribir pruebas de dominio y persistencia de LABORES, suelo y riego básico en `test/features/labors/`, `test/features/soil/` y `test/features/irrigation/basic_record_test.dart`
  - **Prioridad**: P1.
  - **Dependencias**: T014, US1.
  - **Objetivo y detalle**: Tipos permitidos, contexto obligatorio, revisión trazable, al menos un indicador, humedad/pH/rangos, nulo vs cero, riego positivo y especialización compatible.
  - **Criterio de aceptación**: Las pruebas fallan antes de implementación y cubren AC-CAP006/007 y la porción de registro de CAP-008.
  - **Pruebas**: Unitarias, Drift, rollback y reinicio en archivo temporal.
  - **Terminada cuando**: Cada validación tiene código de error estable y conserva valores válidos.
  - **Referencia visual**: No aplica — pruebas de dominio/datos.

- [ ] T025 [P] [US2] Implementar tablas/DAOs/migraciones local y remota de LABORES, suelo y riego en `lib/core/database/tables/labor_tables.dart`, `lib/features/labors/data/`, `lib/features/soil/data/`, `lib/features/irrigation/data/` y `supabase/migrations/0003_labors_soil_irrigation.sql`
  - **Prioridad**: P1.
  - **Dependencias**: T024.
  - **Objetivo y detalle**: `labors`, `soil_measurements`, `irrigation_records`, relaciones históricas, escalas fijas, índices y RLS; mantener especializaciones 1:1 del agregado.
  - **Criterio de aceptación**: Constraints local/remoto coinciden y una labor no admite especialización ajena; filtros básicos usan índices.
  - **Pruebas**: T024 más pgTAP owner A/B, FKs, rangos y tipo/especialización.
  - **Terminada cuando**: Migraciones y DAOs no sobrescriben revisiones históricas.
  - **Referencia visual**: No aplica — persistencia/backend.

- [ ] T026 [US2] Implementar repositorios, comandos atómicos y borradores de LABORES en `lib/features/labors/domain/`, `lib/features/labors/data/`, `lib/features/soil/domain/`, `lib/features/irrigation/domain/` y `lib/core/database/daos/form_draft_dao.dart`
  - **Prioridad**: P1.
  - **Dependencias**: T013, T020, T025.
  - **Objetivo y detalle**: Guardar labor+especialización+outbox en una transacción, crear revisión en vez de overwrite, draft por owner/ruta/contexto y proyección local de eventos recientes.
  - **Criterio de aceptación**: Guardado aparece inmediatamente offline; fallo revierte agregado completo; draft sobrevive proceso y se limpia sólo al guardar/cancelar.
  - **Pruebas**: Repositorio con DB real temporal, fallo inyectado, propietario/sector inválido y recuperación.
  - **Terminada cuando**: Ningún comando necesita Supabase para finalizar localmente.
  - **Referencia visual**: No aplica — dominio/repositorio.

- [ ] T027 [US2] Implementar selector y formulario común de LABORES en `lib/features/labors/presentation/` y ruta `/registrar` en `lib/app/routing/app_router.dart`
  - **Prioridad**: P1.
  - **Dependencias**: T007, T008, T026.
  - **Objetivo y detalle**: Mostrar sólo campos del tipo elegido, contexto visible, validación al terminar campo, resumen/foco del primer error, borrador recuperable y feedback local/pendiente.
  - **Criterio de aceptación**: Usa el término de dominio `LABORES`; cambiar tipo no guarda campos ajenos; una sola acción primaria rellena.
  - **Pruebas**: Widget/semantics para tipos, inválido, error recuperable, back con draft y texto ampliado.
  - **Terminada cuando**: Guardar navega al sector sin esperar red y no hay hardcodes visuales.
  - **Referencia visual**: `master.md → Screens → Registrar actividad`; `master.md → Components → Inputs y formularios`; `master.md → Components → Botones`; `master.md → Navigation → Jerarquía de rutas`.

- [ ] T028 [P] [US2] Implementar formulario manual de suelo en `lib/features/soil/presentation/`
  - **Prioridad**: P1.
  - **Dependencias**: T026, T027.
  - **Objetivo y detalle**: Humedad, pH, temperatura, EC, N, P, K, unidades/observaciones, parcial válido, nulo vs cero, validación cercana y estados local/pending/error.
  - **Criterio de aceptación**: Fuera de rango no guarda y conserva campos válidos; al menos un indicador válido crea labor+medición atómica.
  - **Pruebas**: Widget con límites, campos omitidos/cero, teclado/unidades, offline y semántica.
  - **Terminada cuando**: Registro aparece en sector/eventos recientes tras commit local.
  - **Referencia visual**: `master.md → Screens → Medición de suelo`; `master.md → Components → Inputs y formularios`; `master.md → Offline UX`.

- [ ] T029 [P] [US2] Implementar formulario de registro de riego básico en `lib/features/irrigation/presentation/irrigation_record_page.dart` y controller asociado
  - **Prioridad**: P1.
  - **Dependencias**: T026, T027.
  - **Objetivo y detalle**: Capturar tipo aprobado, caudal, duración y cantidad estimada informada/calculable básica, contexto, observaciones y estados locales; reservar el motor recomendado para US4 sin simular un cálculo todavía no implementado.
  - **Criterio de aceptación**: Valores no positivos impiden guardar; los cuatro tipos permitidos se persisten; no aparece modelo avanzado ni IA.
  - **Pruebas**: Widget para tipos, unidades, inválido, draft/reinicio y guardado offline.
  - **Terminada cuando**: Riego básico válido se guarda como agregado pendiente y aparece localmente.
  - **Referencia visual**: `master.md → Screens → Riego`; `master.md → Components → Inputs y formularios`; `master.md → Offline UX`.

- [ ] T030 [US2] Completar prueba independiente offline/reinicio de US2 en `integration_test/critical_offline_flows_test.dart` y golden de Registrar/Suelo/Riego en `test/golden/us2/`
  - **Prioridad**: P1.
  - **Dependencias**: T024–T029.
  - **Objetivo y detalle**: Desactivar red, registrar labor genérica, suelo y riego, matar/reabrir proceso y verificar historial reciente, borrador, estados y ausencia de duplicados.
  - **Criterio de aceptación**: Independent Test US2, AC-CAP006/007 y AC-003 pasan; los tres registros permanecen pendientes después del reinicio.
  - **Pruebas**: Integración en archivo DB, widget/golden/semantics y tiempo de registro SC-002.
  - **Terminada cuando**: US2 funciona sin backend disponible.
  - **Referencia visual**: `master.md → Screens → Registrar actividad, Medición de suelo y Riego`; `master.md → Offline UX`; `master.md → Flutter Implementation Guidelines → Calidad visual y pruebas`.

**Checkpoint**: US2 funciona offline de forma independiente sobre el contexto de US1.

---

## Phase 5: User Story 3 — Respaldar y resolver cambios (Priority: P1)

**Goal**: Sincronizar automáticamente sin pérdida/duplicado y resolver conflictos conservando ambas versiones.

**Independent Test**: Crear cien cambios offline, reconectar, interrumpir/reanudar, simular edición concurrente y resolver conservando local y remoto en casos separados.

- [ ] T031 [P] [US3] Escribir pruebas contractuales/pgTAP del protocolo sync en `supabase/tests/database/sync_protocol_test.sql` y `test/core/sync/sync_contract_test.dart`
  - **Prioridad**: P1.
  - **Dependencias**: T014, T017, T025.
  - **Objetivo y detalle**: Recibo idempotente, mismo ID/hash distinto, `baseVersion`, lock/owner, página/cursor, tombstone, errores y RLS anon/A/B/direct DML/RPC.
  - **Criterio de aceptación**: Las pruebas fallan sin RPC y representan `contracts/sync-protocol.md` completo.
  - **Pruebas**: pgTAP y cliente con fixtures aplicados/duplicados/conflicto/rechazo/retry.
  - **Terminada cuando**: Cada status de push/pull tiene aserción y no depende de timestamps del cliente.
  - **Referencia visual**: No aplica — contrato backend/cliente sin UI.

- [ ] T032 [US3] Implementar tablas server-only y RPC transaccional push/pull en `supabase/migrations/0004_sync_protocol.sql`
  - **Prioridad**: P1.
  - **Dependencias**: T031.
  - **Objetivo y detalle**: `sync_operations`, `sync_changes`, `sync_conflicts`, recibos idempotentes, versionado, locks por owner, aplicación atómica de agregados, cursor monotónico y tombstones.
  - **Criterio de aceptación**: `applied|duplicate|conflict|rejected|retryableError` son deterministas; un conflicto no altera canónico; ACK perdido reenvía sin duplicar.
  - **Pruebas**: Ejecutar T031 y fallos inyectados antes/después del commit.
  - **Terminada cuando**: Toda mutación remota de entidades sincronizables usa el protocolo, no upsert directo.
  - **Referencia visual**: No aplica — backend sin UI.

- [ ] T033 [US3] Implementar DTOs, gateway y coordinador push/pull en `lib/core/sync/protocol/`, `lib/core/sync/sync_gateway.dart`, `lib/core/sync/sync_coordinator.dart` y `lib/core/database/daos/sync_cursor_dao.dart`
  - **Prioridad**: P1.
  - **Dependencias**: T013, T032.
  - **Objetivo y detalle**: Lotes causales, ACK idempotente, aplicación página+cursor transaccional, backoff/jitter, clasificación auth/403/validation/5xx y mutex por owner.
  - **Criterio de aceptación**: UI sigue leyendo Drift; interrupción conserva pendientes; sólo applied/duplicate marca synced; cursor nunca adelanta una página fallida.
  - **Pruebas**: Unitarias con servidor fake, DB real, process recovery y payload malformado.
  - **Terminada cuando**: El ciclo completo produce resumen observable sin bloquear guardados locales.
  - **Referencia visual**: No aplica — coordinación sin widgets.

- [ ] T034 [P] [US3] Integrar triggers de sincronización, WorkManager y sesión renovada en `lib/core/sync/sync_scheduler.dart`, `lib/core/sync/worker/`, `android/app/src/main/AndroidManifest.xml` y bootstrap
  - **Prioridad**: P1.
  - **Dependencias**: T009, T011, T033.
  - **Objetivo y detalle**: Disparar en inicio/resume/save/reconexión/manual/background oportunista, coalescer ciclos, refresh antes de push y cancelar por logout; no prometer ejecución exacta.
  - **Criterio de aceptación**: Falsa conectividad no marca online; background/reboot conserva outbox; fallo de refresh pide acceso sin perder pendientes.
  - **Pruebas**: Lifecycle, WorkManager fake, timeout, logout y dispositivo Android.
  - **Terminada cuando**: Existe un único ciclo por owner y triggers repetidos no duplican trabajo.
  - **Referencia visual**: No aplica — scheduler sin UI.

- [ ] T035 [US3] Implementar repositorio y casos de uso de conflictos en `lib/core/sync/conflicts/` y `lib/core/database/daos/conflict_dao.dart`
  - **Prioridad**: P1.
  - **Dependencias**: T033.
  - **Objetivo y detalle**: Conservar snapshots/base/canónico, impedir overwrite en pull, resolver keep-local/keep-remote, reabrir si cambia remoto y conservar auditoría.
  - **Criterio de aceptación**: Ambas versiones existen hasta resolución confirmada; no hay merge automático ni last-write-wins.
  - **Pruebas**: Dos dispositivos, ambas elecciones, segunda divergencia y fallo de resolución.
  - **Terminada cuando**: Estado de dominio/outbox/conflicto transiciona según contrato.
  - **Referencia visual**: No aplica — lógica de conflicto sin UI.

- [ ] T036 [US3] Implementar estado global/per-record y pantalla de sincronización en `lib/features/sync_status/presentation/` y `lib/shared/presentation/components/agro_sync_status.dart`
  - **Prioridad**: P1.
  - **Dependencias**: T007, T008, T033.
  - **Objetivo y detalle**: Conectado/offline/ciclo, pendientes/errores/conflictos, progreso, último respaldo, reintento y confirmaciones separadas de guardado local/remoto.
  - **Criterio de aceptación**: Agricultor distingue estados en menos de cinco segundos en prueba; nunca se usa sólo color ni se muestra synced por tener red.
  - **Pruebas**: Widget/semantics para todos los estados, progreso y error recuperable; golden.
  - **Terminada cuando**: Todas las pantallas escritoras pueden reutilizar el estado por registro.
  - **Referencia visual**: `master.md → Offline UX → Representación por nivel`; `master.md → Offline UX → Máquina visual de estados`; `master.md → Components → Banners, alertas y feedback`; `master.md → Screens → Más`.

- [ ] T037 [US3] Implementar comparación y resolución visual de conflictos en `lib/features/sync_status/presentation/conflict_resolution_page.dart`
  - **Prioridad**: P1.
  - **Dependencias**: T035, T036.
  - **Objetivo y detalle**: Presentar diferencias autorizadas y acciones conservar local/remota con confirmación cancelable, loading/error/reintento y retorno lógico.
  - **Criterio de aceptación**: Ninguna versión desaparece antes de confirmación; botón único primario por paso; resolución fallida conserva elección y snapshots.
  - **Pruebas**: Widget/semantics para ambas resoluciones, cambio remoto intermedio, error y back.
  - **Terminada cuando**: UI consume modelo de conflicto y no decide merge ni estilo propio.
  - **Referencia visual**: `master.md → Offline UX`; `master.md → Components → Banners, alertas y feedback`; `master.md → Components → Inputs y formularios`; `master.md → Development Rules`.

- [ ] T038 [US3] Ejecutar pruebas de resiliencia e independencia de US3 en `integration_test/synchronization_test.dart` y fixtures Supabase locales
  - **Prioridad**: P1.
  - **Dependencias**: T031–T037.
  - **Objetivo y detalle**: 100 cambios, cadena parcela→sector→labor, ACK perdido, interrupción en cada frontera, cursor, tombstone, 24 h offline/reinicios, dos dispositivos y sesión expirada.
  - **Criterio de aceptación**: SC-003/004/005/006 y AC-CAP016 pasan: cada operación queda una vez, pendiente explícita o conflicto conservado.
  - **Pruebas**: Integración Flutter+Supabase local, prueba física de background y captura de métricas.
  - **Terminada cuando**: Cero pérdida silenciosa/duplicados y UI nunca bloquea uso local.
  - **Referencia visual**: `master.md → Offline UX`; `master.md → Flutter Implementation Guidelines → Calidad visual y pruebas`.

**Checkpoint**: Núcleo P1 completo: estructura agrícola, registro offline y respaldo observable/confiable.

---

## Phase 6: User Story 4 — Calcular y registrar riego (Priority: P2)

**Goal**: Producir y guardar una estimación determinista de litros/tiempo con o sin clima actual.

**Independent Test**: Ejecutar el mismo conjunto de entradas offline varias veces, obtener el mismo resultado/limitaciones y guardarlo con todas sus entradas y versión.

- [ ] T039 [US4] Cerrar y aprobar el contrato agronómico v1 en `specs/002-agrocampo-android-mvp/contracts/irrigation-calculation.md`
  - **Prioridad**: P1 bloqueante de US4.
  - **Dependencias**: T030, `spec.md` FR-038–FR-042.
  - **Objetivo y detalle**: Documentar fórmula exacta, coeficientes de los cultivos aprobados, entradas/rangos, unidades, redondeo, tolerancia, rama sin clima, limitaciones y al menos veinte vectores input/output; no inventar valores sin aprobación agronómica.
  - **Criterio de aceptación**: El contrato no contiene campos abiertos y cuenta con aprobación del propietario/revisión agronómica; excluye evapotranspiración avanzada e IA.
  - **Pruebas**: Revisión reproducible manual de los veinte vectores y consistencia dimensional.
  - **Terminada cuando**: T040–T044 pueden implementarse sin interpretar coeficientes o umbrales.
  - **Referencia visual**: No aplica — contrato de cálculo sin UI.

- [ ] T040 [P] [US4] Escribir pruebas de cálculo determinista y persistencia en `test/features/irrigation/irrigation_calculator_test.dart` y `test/features/irrigation/irrigation_estimate_repository_test.dart`
  - **Prioridad**: P2.
  - **Dependencias**: T039.
  - **Objetivo y detalle**: Codificar todos los vectores aprobados, límites/no positivos, unidades, redondeo, snapshot climático, rama limitada y reproducción tras serializar.
  - **Criterio de aceptación**: Pruebas fallan antes del motor y cada resultado tiene tolerancia/versión explícita.
  - **Pruebas**: Unitarias parametrizadas y Drift temporal.
  - **Terminada cuando**: No existe llamada a Gemini/red en el test de cálculo.
  - **Referencia visual**: No aplica — pruebas de dominio/datos.

- [ ] T041 [US4] Implementar motor de riego v1 en `lib/features/irrigation/domain/irrigation_calculator.dart`, `irrigation_rule_set.dart` y tipos de unidades
  - **Prioridad**: P2.
  - **Dependencias**: T040.
  - **Objetivo y detalle**: Aplicar exclusivamente contrato T039 con aritmética/escala fija, variables usadas, limitaciones, algoritmo versionado y snapshot Weather opcional.
  - **Criterio de aceptación**: Los veinte vectores pasan bit a bit/tolerancia; entradas insuficientes no producen recomendación utilizable.
  - **Pruebas**: T040, propiedades de determinismo y conversiones métricas.
  - **Terminada cuando**: Motor es Dart puro, explicable y no depende de plugins/IA.
  - **Referencia visual**: No aplica — lógica determinista.

- [ ] T042 [US4] Persistir estimación y riego como agregado en `lib/core/database/tables/irrigation_estimate_table.dart`, `lib/features/irrigation/data/` y `supabase/migrations/0005_irrigation_estimates.sql`
  - **Prioridad**: P2.
  - **Dependencias**: T025, T041.
  - **Objetivo y detalle**: Guardar entradas/resultados/variables/proveniencia/limitaciones/version, vincular a labor/sector/cultivo y sincronizar atómicamente sin JSON crudo de clima.
  - **Criterio de aceptación**: Reabrir el registro reproduce el resultado; remoto/local preservan escalas y owner; fallo revierte todo el agregado.
  - **Pruebas**: Repositorio, migración, pgTAP y round-trip de veinte fixtures.
  - **Terminada cuando**: Historial puede explicar cálculo sin ejecutar fórmula nueva.
  - **Referencia visual**: No aplica — persistencia/backend.

- [ ] T043 [US4] Integrar calculadora y estados en la pantalla Riego en `lib/features/irrigation/presentation/`
  - **Prioridad**: P2.
  - **Dependencias**: T029, T041, T042.
  - **Objetivo y detalle**: Capturar plantas/caudal/tiempo/cultivo/humedad/temperatura, calcular, mostrar variables y limitación sin clima, guardar una única acción primaria y distinguir local/sync.
  - **Criterio de aceptación**: Inválido no calcula; estimación limitada se identifica; mismas entradas muestran mismo resultado; AgroIA no interviene.
  - **Pruebas**: Widget/semantics para insuficiente, inválido, limitada, completa, guardando, pending y error.
  - **Terminada cuando**: UI consume tokens/componentes y no contiene constantes agronómicas ni visuales.
  - **Referencia visual**: `master.md → Screens → Riego`; `master.md → Components → Inputs y formularios`; `master.md → Components → Tarjetas de métricas`; `master.md → Offline UX`.

- [ ] T044 [US4] Completar prueba independiente de US4 en `integration_test/irrigation_calculation_flow_test.dart` y `test/golden/us4/`
  - **Prioridad**: P2.
  - **Dependencias**: T039–T043.
  - **Objetivo y detalle**: Ejecutar vectores offline, guardar/reabrir/sincronizar una estimación con y sin clima, y comprobar trazabilidad/explicación.
  - **Criterio de aceptación**: AC-CAP008 y SC-007 pasan; indisponibilidad Weather no bloquea cálculo local válido.
  - **Pruebas**: Integración, golden/semantics y comparación de snapshot persistido.
  - **Terminada cuando**: US4 se demuestra sin IA y sin red.
  - **Referencia visual**: `master.md → Screens → Riego`; `master.md → Flutter Implementation Guidelines → Calidad visual y pruebas`.

---

## Phase 7: User Story 5 — Consultar historial y producción (Priority: P2)

**Goal**: Consultar eventos cronológicos filtrados y registrar producción sin perder contexto histórico.

**Independent Test**: Crear datos en dos parcelas/temporadas, guardar una cosecha y comprobar filtros exclusivos y cambio de cultivo histórico.

- [ ] T045 [P] [US5] Escribir pruebas de historial, filtros y producción en `test/features/history/` y `test/features/production/`
  - **Prioridad**: P2.
  - **Dependencias**: T030, T044.
  - **Objetivo y detalle**: Orden estable, filtros parcela/sector/cultivo/tipo/fecha/temporada, vacío vs sin coincidencias, pending inmediato, cantidad positiva/unidad y asignación histórica.
  - **Criterio de aceptación**: Las pruebas fallan antes de implementación y cubren AC-CAP009/010.
  - **Pruebas**: Unitarias/Drift con dos owners, parcelas y temporadas.
  - **Terminada cuando**: Cada filtro prueba exclusión de datos ajenos además de inclusión.
  - **Referencia visual**: No aplica — pruebas de dominio/datos.

- [ ] T046 [P] [US5] Implementar producción local/remota e índices de historial en `lib/core/database/tables/production_table.dart`, `lib/features/production/data/` y `supabase/migrations/0006_production_history.sql`
  - **Prioridad**: P2.
  - **Dependencias**: T025, T045.
  - **Objetivo y detalle**: `production_records` 1:1 con labor harvest, cantidad/units/calidad, índices históricos por owner/contexto/fecha y RLS.
  - **Criterio de aceptación**: Cantidad no positiva/unidad ajena se rechaza; producción conserva assignment/season y sincroniza atómicamente.
  - **Pruebas**: T045 más pgTAP constraints/RLS y migración.
  - **Terminada cuando**: Datos son aptos para consulta/exportación sin implementar analítica futura.
  - **Referencia visual**: No aplica — persistencia/backend.

- [ ] T047 [US5] Implementar proyección y repositorio de historial en `lib/features/history/data/history_repository.dart`, `lib/features/history/domain/` y DAOs de consulta
  - **Prioridad**: P2.
  - **Dependencias**: T026, T042, T046.
  - **Objetivo y detalle**: Unir labores/especializaciones/cambios/temporadas sin duplicar, ordenar por fecha+ID, filtrar de forma indexada y emitir streams locales con estados pending/conflict.
  - **Criterio de aceptación**: Cambiar cultivo no altera etiquetas previas; 100% de filtros devuelven sólo coincidencias; registro offline entra en posición correcta.
  - **Pruebas**: T045, paginación/orden empates y carga de referencia.
  - **Terminada cuando**: Presentación no combina tablas ni reimplementa filtros.
  - **Referencia visual**: No aplica — consulta/repositorio.

- [ ] T048 [US5] Implementar repositorio/caso de uso de cosecha en `lib/features/production/domain/` y `lib/features/production/data/production_repository.dart`
  - **Prioridad**: P2.
  - **Dependencias**: T013, T046, T047.
  - **Objetivo y detalle**: Validar contexto, unidad/cantidad/calidad, crear labor+producción+outbox y revisión trazable.
  - **Criterio de aceptación**: Guardado offline aparece en historial correcto y conserva season/assignment aunque cambie cultivo.
  - **Pruebas**: Repositorio con rollback, archived parcel, owner/contexto inválido y corrección.
  - **Terminada cuando**: Export snapshot puede consumir la entidad sin transformación ambigua.
  - **Referencia visual**: No aplica — dominio/repositorio.

- [ ] T049 [US5] Implementar Historial y formulario de Producción en `lib/features/history/presentation/` y `lib/features/production/presentation/`
  - **Prioridad**: P2.
  - **Dependencias**: T007, T008, T047, T048.
  - **Objetivo y detalle**: Timeline, filtros, agrupación por temporada cuando aplique, vacío general vs filtro vacío, estados sync y formulario harvest contextual.
  - **Criterio de aceptación**: Filtros conservan estado/back; producción válida aparece de inmediato; no se crean comparativas/analítica no especificadas.
  - **Pruebas**: Widget/semantics para filtros, vacíos, pending/conflict, formulario inválido y texto ampliado.
  - **Terminada cuando**: Rutas desde sector/Más regresan al origen lógico y todo consume tokens.
  - **Referencia visual**: `master.md → Screens → Historial`; `master.md → Components → Timeline e historial`; `master.md → Screens → Registrar actividad`; `master.md → Components → Inputs y formularios`.

- [ ] T050 [US5] Completar prueba independiente de US5 en `integration_test/history_production_flow_test.dart` y `test/golden/us5/`
  - **Prioridad**: P2.
  - **Dependencias**: T045–T049.
  - **Objetivo y detalle**: Dos parcelas/sectores/temporadas, cambios de cultivo, suelo/riego/cosecha, todos los filtros y navegación desde sector/Más.
  - **Criterio de aceptación**: AC-CAP009/010, SC-009 y parte de AC-004 pasan sin contaminación de filtros.
  - **Pruebas**: Integración, golden/semantics y consulta con fechas empatadas.
  - **Terminada cuando**: US5 funciona offline y preserva trazabilidad histórica.
  - **Referencia visual**: `master.md → Screens → Historial`; `master.md → Flutter Implementation Guidelines → Calidad visual y pruebas`.

---

## Phase 8: User Story 6 — Documentar y recordar trabajo (Priority: P2)

**Goal**: Asociar fotos estables offline y crear/modificar/completar/cancelar recordatorios con aviso local y FCM secundario.

**Independent Test**: Adjuntar foto offline, crear recordatorio, reiniciar y verificar archivo/asociación/aviso; denegar permiso sin perder el recordatorio.

- [ ] T051 [P] [US6] Escribir pruebas de ciclo de vida fotográfico en `test/features/photos/` y `supabase/tests/database/photo_storage_rls_test.sql`
  - **Prioridad**: P2.
  - **Dependencias**: T014, T030.
  - **Objetivo y detalle**: Cancelar, lost data, falta espacio, copia atómica, MIME/hash/EXIF, asociación sector/labor, retry, delete antes/durante upload y RLS A/B.
  - **Criterio de aceptación**: Pruebas fallan sin pipeline; nunca queda fila/archivo parcial ni foto resucitada.
  - **Pruebas**: Unitarias filesystem temporal, Drift, pgTAP/Storage y picker fake.
  - **Terminada cuando**: Cada frontera de archivo/upload tiene rollback o reintento idempotente.
  - **Referencia visual**: No aplica — pruebas de datos/plataforma.

- [ ] T052 [US6] Implementar metadata, archivo privado y upload Storage en `lib/core/files/`, `lib/features/photos/data/`, `lib/features/photos/domain/` y `supabase/migrations/0007_photos_storage.sql`
  - **Prioridad**: P2.
  - **Dependencias**: T013, T051.
  - **Objetivo y detalle**: Copia/validación/compresión aprobada/hash/rename, tabla `photos`, ruta inmutable owner/photo/hash, bucket privado/upsert false, signed URL temporal y tombstone.
  - **Criterio de aceptación**: Foto confirmada abre offline tras reinicio; retry no duplica; owner B no accede; bytes no están en SQLite.
  - **Pruebas**: T051, process death/retrieveLostData, upload interrumpido y URL expirada.
  - **Terminada cuando**: Asociación local se confirma antes de cualquier upload.
  - **Referencia visual**: No aplica — archivo/repositorio/backend.

- [ ] T053 [US6] Implementar selección, preview y adjuntos fotográficos en `lib/features/photos/presentation/` e integración en sector/LABORES
  - **Prioridad**: P2.
  - **Dependencias**: T007, T052.
  - **Objetivo y detalle**: Cámara/galería, preview/cancelar, descripción, permiso, guardado local, pending/upload/error/delete y asociación visible en detalle/labor.
  - **Criterio de aceptación**: Cancelar no crea adjunto; error conserva datos recuperables; imagen local sigue visible offline; iconos/feedback accesibles.
  - **Pruebas**: Widget/semantics y dispositivo real para picker/permisos/process death.
  - **Terminada cuando**: No hay análisis fotográfico ni estilo propio del picker dentro de la app.
  - **Referencia visual**: `master.md → Components → Inputs y formularios`; `master.md → Components → Banners, alertas y feedback`; `master.md → Screens → Detalle sector`; `master.md → Development Rules`.

- [ ] T054 [P] [US6] Escribir pruebas de recordatorios, scheduler y FCM en `test/features/reminders/`, `test/core/notifications/` y `supabase/tests/database/device_installations_rls_test.sql`
  - **Prioridad**: P2.
  - **Dependencias**: T014.
  - **Objetivo y detalle**: Fecha futura/pasada, permiso denied/revoked, zona/DST/reboot, editar/completar/cancelar, dedupe local+FCM, evento tardío y token rotado/inválido.
  - **Criterio de aceptación**: Pruebas fallan sin scheduler y demuestran que FCM no es fuente de verdad.
  - **Pruebas**: Reloj/timezone fake, plugin fake, pgTAP y payload contract.
  - **Terminada cuando**: Cada ocurrencia tiene ID estable y no revive tras completar/cancelar.
  - **Referencia visual**: No aplica — pruebas de dominio/plataforma.

- [ ] T055 [US6] Implementar recordatorios y notificación local en `lib/features/reminders/domain/`, `lib/features/reminders/data/`, `lib/core/notifications/local_notification_scheduler.dart`, `android/app/src/main/AndroidManifest.xml` y `supabase/migrations/0008_reminders.sql`
  - **Prioridad**: P2.
  - **Dependencias**: T010, T013, T054.
  - **Objetivo y detalle**: Tabla/repo/outbox, binding Android, timezone, reconciliación bootstrap/resume/reboot/cambio hora, permisos y degradación exact→inexacta sin borrar dato.
  - **Criterio de aceptación**: Recordatorio futuro offline agenda si hay permiso; denied permanece consultable; completado/cancelado no notifica.
  - **Pruebas**: T054 y dispositivo Android con reboot/Doze.
  - **Terminada cuando**: Persistencia manda y el scheduler es idempotente.
  - **Referencia visual**: No aplica — lógica/plataforma sin widgets.

- [ ] T056 [US6] Implementar UI de recordatorios y permiso en `lib/features/reminders/presentation/` y ruta `/mas/recordatorios`
  - **Prioridad**: P2.
  - **Dependencias**: T007, T008, T055.
  - **Objetivo y detalle**: Lista/crear/editar/completar/cancelar, fecha/hora/tipo/sector/descripcion, estados programado/vencido/permiso denegado/pending/error y confirmaciones.
  - **Criterio de aceptación**: Permiso denegado explica ausencia de aviso sin bloquear guardado; fecha pasada exige corrección/registro explícito permitido; back conserva borrador.
  - **Pruebas**: Widget/semantics para estados, permisos, confirmación, text scale y offline.
  - **Terminada cuando**: Una sola acción primaria y todos los valores visuales provienen del tema.
  - **Referencia visual**: `master.md → Screens → Más`; `master.md → Components → Inputs y formularios`; `master.md → Components → Banners, alertas y feedback`; `master.md → Offline UX`.

- [ ] T057 [US6] Implementar instalaciones FCM, envío confiable y deep links en `supabase/functions/notification-dispatch/`, `supabase/migrations/0009_device_installations.sql`, `lib/core/notifications/fcm_gateway.dart` y `lib/app/routing/notification_route_resolver.dart`
  - **Prioridad**: P2.
  - **Dependencias**: T011, T034, T054, T055.
  - **Objetivo y detalle**: Token por instalación/refresh/disable, HTTP v1 server-side, payload opaco con expiry/revision, dedupe con aviso local y navegación sólo tras validar sesión/entidad.
  - **Criterio de aceptación**: Credencial FCM no está en APK; evento expirado/completado/otro owner no navega ni notifica; token UNREGISTERED se deshabilita.
  - **Pruebas**: Contract tests payload, auth/RLS, foreground/background/terminated y deep links stale/offline.
  - **Terminada cuando**: FCM es secundario y no contiene copy agrícola privado.
  - **Referencia visual**: `master.md → Navigation → Comportamiento Android`; sólo para el destino/retorno tras tap, sin estilo nuevo.

- [ ] T058 [US6] Completar prueba independiente de US6 en `integration_test/photos_reminders_flow_test.dart` y `test/golden/us6/`
  - **Prioridad**: P2.
  - **Dependencias**: T051–T057.
  - **Objetivo y detalle**: Foto offline+reinicio+upload retry/delete, recordatorio offline+permiso granted/denied, aviso local, FCM tardío y rutas.
  - **Criterio de aceptación**: AC-CAP011/013 y user story 6 pasan sin pérdida, duplicado o borrado por permiso.
  - **Pruebas**: Integración emulador/dispositivo, golden/semantics y proceso destruido.
  - **Terminada cuando**: Foto y recordatorio siguen disponibles sin red y fallos externos quedan aislados.
  - **Referencia visual**: `master.md → Screens → Detalle sector y Más`; `master.md → Components → Banners, alertas y feedback`; `master.md → Flutter Implementation Guidelines → Calidad visual y pruebas`.

---

## Phase 9: User Story 7 — Gestionar apicultura (Priority: P3)

**Goal**: Registrar una revisión apícola completa, opcionalmente con fotos, y consultarla offline en su sector/historial.

**Independent Test**: Crear sector apícola, guardar revisión con todos los campos y foto, reiniciar y verificar historial/asociación; sector agrícola rechaza el formulario.

- [ ] T059 [P] [US7] Escribir pruebas de revisión apícola en `test/features/apiary/` y `supabase/tests/database/apiary_rls_test.sql`
  - **Prioridad**: P3.
  - **Dependencias**: T050, T058.
  - **Objetivo y detalle**: Sector apícola obligatorio, colmenas, responsable descriptivo, reina/postura/alimentación/sanidad/plagas/alza, especialización atómica, historia/foto y RLS.
  - **Criterio de aceptación**: Pruebas fallan sin implementación; responsable nunca crea usuario/rol; sector agrícola se rechaza.
  - **Pruebas**: Unitarias, Drift, pgTAP y owner/contexto inválido.
  - **Terminada cuando**: Todos los datos FR-057 tienen validación/round-trip.
  - **Referencia visual**: No aplica — pruebas de dominio/datos.

- [ ] T060 [P] [US7] Implementar tabla/migración apícola local/remota en `lib/core/database/tables/apiary_inspection_table.dart`, `lib/features/apiary/data/` y `supabase/migrations/0010_apiary.sql`
  - **Prioridad**: P3.
  - **Dependencias**: T025, T059.
  - **Objetivo y detalle**: Especialización 1:1 de labor, constraints por tipo/owner, campos definidos, índices de historial y RLS.
  - **Criterio de aceptación**: No existe tabla de trabajadores; responsible_name es texto; FK y tipo evitan inspección en sector agrícola.
  - **Pruebas**: T059, migración y constraints local/remoto.
  - **Terminada cuando**: Modelo sincronizable entra al agregado labor sin protocolo especial.
  - **Referencia visual**: No aplica — persistencia/backend.

- [ ] T061 [US7] Implementar caso de uso/repository de inspección apícola en `lib/features/apiary/domain/` y `lib/features/apiary/data/apiary_repository.dart`
  - **Prioridad**: P3.
  - **Dependencias**: T013, T020, T052, T060.
  - **Objetivo y detalle**: Validar sector/todos los campos, persistir labor+inspección+outbox y enlazar fotos locales existentes de forma causal.
  - **Criterio de aceptación**: Guardado offline aparece en historial; rollback evita agregado parcial; fotos conservan asociación al sincronizar.
  - **Pruebas**: Repositorio con sector agrícola, owner incorrecto, foto pendiente y fallo transaccional.
  - **Terminada cuando**: No se crea cuenta/permiso para responsable.
  - **Referencia visual**: No aplica — dominio/repositorio.

- [ ] T062 [US7] Implementar formulario y detalle apícola en `lib/features/apiary/presentation/` e integración con `lib/features/sectors/presentation/sector_detail_page.dart`
  - **Prioridad**: P3.
  - **Dependencias**: T007, T027, T049, T053, T061.
  - **Objetivo y detalle**: Mostrar campos sólo en sector apícola, validación, adjuntos, guardado local/pending/error y navegación al sector/historial.
  - **Criterio de aceptación**: Sector agrícola no muestra/exige campos; revisión válida queda visible cronológicamente y back conserva borrador.
  - **Pruebas**: Widget/semantics, text scale, sector type guard, foto y estados sync.
  - **Terminada cuando**: UI reutiliza formulario/LABORES/adjuntos sin una identidad apícola alternativa.
  - **Referencia visual**: `master.md → Screens → Registrar actividad`; `master.md → Screens → Detalle sector`; `master.md → Components → Inputs y formularios`; `master.md → Components → Timeline e historial`.

- [ ] T063 [US7] Completar prueba independiente de US7 en `integration_test/apiary_flow_test.dart` y `test/golden/us7/`
  - **Prioridad**: P3.
  - **Dependencias**: T059–T062.
  - **Objetivo y detalle**: Sector apícola, inspección completa, foto, reinicio offline, historial y respaldo; incluir intento en sector agrícola.
  - **Criterio de aceptación**: AC-CAP012 y user story 7 pasan; datos/foto sincronizan una vez y responsable sigue descriptivo.
  - **Pruebas**: Integración, golden/semantics y pgTAP asociado.
  - **Terminada cuando**: US7 es demostrable sin roles o módulos adicionales.
  - **Referencia visual**: `master.md → Screens → Detalle sector, Registrar actividad e Historial`; `master.md → Flutter Implementation Guidelines → Calidad visual y pruebas`.

---

## Phase 10: User Story 8 — Consultar clima, AgroIA y exportar (Priority: P3)

**Goal**: Mostrar clima degradable, ofrecer orientación Gemini consultiva y generar XLSX completo desde datos locales.

**Independent Test**: Consultar clima/antigüedad, enviar pregunta contextual sin modificar datos y exportar offline registros synced/pending con relaciones válidas.

- [ ] T064 [US8] Cerrar gate contractual de Weather y registrar cualquier atribución aprobada en `specs/002-agrocampo-android-mvp/research.md`, `contracts/external-services.md` y, sólo con aprobación, `master.md`
  - **Prioridad**: P2 bloqueante de clima release.
  - **Dependencias**: Contrato externo vigente.
  - **Objetivo y detalle**: Confirmar uso, cuota, cache/TTL, retención del snapshot de riego y atribución/disclaimer; si WeatherAPI no cumple, seleccionar el adapter permitido sin alterar dominio. No decidir tratamiento visual fuera de `master.md`.
  - **Criterio de aceptación**: Proveedor/condiciones quedan aprobados por escrito y toda obligación visual existe en `master.md` antes de T067.
  - **Pruebas**: Checklist legal/técnico y prueba de que el contrato normalizado sigue estable.
  - **Terminada cuando**: No queda decisión contractual o visual abierta para implementar clima.
  - **Referencia visual**: `master.md → Development Rules`; si falta atribución, se bloquea hasta una actualización aprobada, sin diseño propio.

- [ ] T065 [P] [US8] Escribir contract tests de clima en `test/features/weather/weather_gateway_contract_test.dart` y `supabase/functions/weather-proxy/tests/`
  - **Prioridad**: P3.
  - **Dependencias**: T064.
  - **Objetivo y detalle**: JWT/owner/parcel centroid, DTO temperatura/humedad/lluvia/pronóstico, unidades, TTL, stale/no-location, 401/429/timeout/invalid y cache dedupe.
  - **Criterio de aceptación**: Pruebas fallan sin Function/adapter y nunca usan JSON crudo en dominio.
  - **Pruebas**: Fixtures proveedor, Edge Function local y cache con reloj fake.
  - **Terminada cuando**: Cada fallo preserva las capacidades locales.
  - **Referencia visual**: No aplica — pruebas de contrato/datos.

- [ ] T066 [US8] Implementar weather-proxy, gateway, cache y repository en `supabase/functions/weather-proxy/`, `lib/features/weather/data/`, `lib/features/weather/domain/` y DAO de `weather_cache`
  - **Prioridad**: P3.
  - **Dependencias**: T009, T010, T065.
  - **Objetivo y detalle**: Function JWT/RLS por parcelId, normalización métrica, timeout/cuota, cache con expiración, última lectura y `WeatherInputSnapshot` explícito para riego.
  - **Criterio de aceptación**: Clave no está en APK; expirado no se presenta como actual; no-location/error no bloquea registros/cálculo local.
  - **Pruebas**: T065, secret scan y round-trip del snapshot aprobado.
  - **Terminada cuando**: UI sólo recibe estados/DTO de dominio.
  - **Referencia visual**: No aplica — server/repository sin UI.

- [ ] T067 [US8] Integrar hero de clima y estados en Inicio en `lib/features/weather/presentation/` y `lib/features/home/presentation/home_page.dart`
  - **Prioridad**: P3.
  - **Dependencias**: T021, T064, T066.
  - **Objetivo y detalle**: Mostrar variables/actualización y estados loading/current/stale/no-location/offline/error, con reintento y atribución sólo como fue aprobada en `master.md`.
  - **Criterio de aceptación**: Toda lectura muestra hora; stale no parece actual; error no oculta acciones agrícolas ni inventa cero.
  - **Pruebas**: Widget/golden/semantics para todos los estados y fallback offline.
  - **Terminada cuando**: No hay texto/estilo legal inventado ni valores visuales hardcodeados.
  - **Referencia visual**: `master.md → Screens → Inicio`; `master.md → Components → Tarjeta hero de clima`; `master.md → Components → Banners, alertas y feedback`.

- [ ] T068 [P] [US8] Escribir pruebas/evals de AgroIA en `test/features/agro_ai/` y `supabase/functions/agro-ai/tests/`
  - **Prioridad**: P3.
  - **Dependencias**: T014, T063.
  - **Objetivo y detalle**: Contexto RLS/whitelist, idempotencia, cálculo crítico, pedido de write/automatización/foto, prompt injection, safety, 429/timeout/model unavailable, offline y español consultivo.
  - **Criterio de aceptación**: Pruebas fallan sin implementación y ninguna respuesta puede modificar repositorios o sustituir cálculo.
  - **Pruebas**: Suite fija de prompts/resultados/policies con gateway fake y Function local.
  - **Terminada cuando**: Existe expectativa verificable para cada guardrail FR-068–FR-072.
  - **Referencia visual**: No aplica — pruebas de política/servicio.

- [ ] T069 [US8] Implementar Edge Function Gemini, gateway y conversación local en `supabase/functions/agro-ai/`, `lib/features/agro_ai/data/`, `lib/features/agro_ai/domain/` y DAOs AI
  - **Prioridad**: P3.
  - **Dependencias**: T003, T009, T010, T068.
  - **Objetivo y detalle**: JWT/RLS, modelo estable configurado, contexto mínimo, límites/safety, tools/imágenes deshabilitados, IDs idempotentes, mensajes/drafts locales y reintento manual.
  - **Criterio de aceptación**: Clave/model secret ausente del APK; offline conserva historial/draft; response no escribe ni genera cifra crítica alternativa.
  - **Pruebas**: T068, secret/log scan, duplicate request y owner/contexto ajeno.
  - **Terminada cuando**: Cambiar modelo/prompt exige pasar evals y versionar policy.
  - **Referencia visual**: No aplica — servicio/repositorio sin UI.

- [ ] T070 [US8] Implementar conversación AgroIA en `lib/features/agro_ai/presentation/` y rama `/agroia`
  - **Prioridad**: P3.
  - **Dependencias**: T008, T069.
  - **Objetivo y detalle**: Contexto activo verificable, empty suggestions dentro de alcance, bubbles/composer, enviar/responding/retry/offline, scroll preservado y disclaimer consultivo.
  - **Criterio de aceptación**: Enviar vacío está deshabilitado; offline no borra mensaje; respuesta no cambia datos y comunica verificación en terreno.
  - **Pruebas**: Widget/golden/semantics para vacío, contexto, loading, safety/error, retry, offline y teclado.
  - **Terminada cuando**: UI no incluye adjunto de imagen, tools o acciones autónomas.
  - **Referencia visual**: `master.md → Screens → AgroIA`; `master.md → Components → AgroIA chat`; `master.md → UX Improvements → AgroIA`.

- [ ] T071 [P] [US8] Escribir pruebas contractuales XLSX en `test/features/export/xlsx_contract_test.dart` y fixtures `test/fixtures/export/`
  - **Prioridad**: P3.
  - **Dependencias**: T046, T058, T063.
  - **Objetivo y detalle**: Hojas/headers v1, conteos/FKs, pending/synced/conflict/archive, fechas/unidades/nulo-cero/acentos, formula injection, no fotos/secret paths, falta espacio y 10.000 registros.
  - **Criterio de aceptación**: Pruebas fallan sin exporter y reabren OOXML sin reparación.
  - **Pruebas**: Parser independiente, Excel/LibreOffice manual de referencia y carga baja memoria.
  - **Terminada cuando**: Cada columna mínima de `contracts/xlsx-export.md` tiene aserción.
  - **Referencia visual**: No aplica — pruebas de archivo/datos.

- [ ] T072 [US8] Implementar snapshot/exporter XLSX y canal SAF Android en `lib/core/export/`, `lib/features/export/data/`, `android/app/src/main/kotlin/` y DAO `export_snapshot`
  - **Prioridad**: P3.
  - **Dependencias**: T005, T047, T071.
  - **Objetivo y detalle**: Adapter aislado de `excel_community`, snapshot Drift consistente, generación fuera de UI isolate, temp+reopen+validate, protección de fórmulas y `ACTION_CREATE_DOCUMENT` sin permiso amplio.
  - **Criterio de aceptación**: Offline genera workbook completo; cancel/fallo elimina temp y no presenta parcial; 100% IDs/FKs/estados coinciden.
  - **Pruebas**: T071, process interruption, destino cancelado y no-space.
  - **Terminada cuando**: Ninguna feature importa la librería XLSX directamente.
  - **Referencia visual**: No aplica — generación/plataforma sin UI.

- [ ] T073 [US8] Implementar UI de exportación y prueba integrada de US8 en `lib/features/export/presentation/`, `integration_test/weather_ai_export_flow_test.dart` y `test/golden/us8/`
  - **Prioridad**: P3.
  - **Dependencias**: T067, T070, T072.
  - **Objetivo y detalle**: Estado sin datos/preparing/completed/share/cancel/no-space/error, disparar SAF, y probar clima caído, consulta IA consultiva y export offline con pending.
  - **Criterio de aceptación**: AC-CAP014/015/017, SC-008/010/014 y user story 8 pasan; fallos son independientes y no entregan parcial.
  - **Pruebas**: Widget/golden/semantics, integración Function fakes/SAF y workbook validado.
  - **Terminada cuando**: UI no crea hoja/estilo visual propio ni afirma respaldo remoto por exportar.
  - **Referencia visual**: `master.md → Screens → Más`; `master.md → Components → Banners, alertas y feedback`; `master.md → Components → Estados vacíos`; `master.md → Flutter Implementation Guidelines → Calidad visual y pruebas`.

**Checkpoint**: Las ocho historias del MVP están funcionales y testeables.

---

## Phase 11: Polish & Cross-Cutting Concerns

**Purpose**: Validación integral, rendimiento, seguridad y release Android sin ampliar alcance.

- [ ] T074 Ejecutar auditoría visual/accesible integral y completar goldens en `test/golden/`, `test/shared/design_policy_test.dart` y `docs/verification/design-system-report.md`
  - **Prioridad**: P0 release.
  - **Dependencias**: T023, T030, T036–T037, T044, T050, T058, T063, T073.
  - **Objetivo y detalle**: Todas las pantallas/estados, teléfono estrecho/grande/tablet/landscape, text scale, TalkBack, contraste, alto contraste, reduced motion, safe areas/teclado y literales.
  - **Criterio de aceptación**: SC-013 y AC-002 pasan; cero valor visual fuera de `app/theme`; ninguna necesidad sin sección aprobada.
  - **Pruebas**: Golden, semantics, guidelines, revisión manual física y comparación con referencia autorizada.
  - **Terminada cuando**: Reporte enlaza evidencia por pantalla/estado y no registra desviaciones abiertas.
  - **Referencia visual**: `master.md → Flutter Implementation Guidelines → Calidad visual y pruebas`; `master.md → Development Rules`; todas las secciones `Screens` aplicables.

- [ ] T075 [P] Optimizar consultas, frames y trabajos pesados en `lib/core/database/`, `lib/core/geometry/`, `lib/core/export/`, `lib/features/history/` y `test/performance/`
  - **Prioridad**: P1 release.
  - **Dependencias**: T050, T072.
  - **Objetivo y detalle**: Fixture 20 parcelas/200 sectores/10.000 registros, P95 local <2 s, paginación/índices, rebuilds Riverpod, scroll/map y geometry/image/XLSX fuera del UI isolate.
  - **Criterio de aceptación**: SC-012 medido; no hay jank crítico ni regresión funcional; todo índice responde a una consulta real.
  - **Pruebas**: Benchmarks reproducibles en emulador de baja memoria y perfil de frames/memoria.
  - **Terminada cuando**: Resultados y dispositivo/toolchain quedan documentados.
  - **Referencia visual**: No aplica — optimización no puede alterar identidad/layout; cualquier cambio UI vuelve a T074.

- [ ] T076 [P] Ejecutar hardening de seguridad/RLS/Storage/Functions en `supabase/tests/database/`, `supabase/functions/`, `lib/core/auth/`, `lib/core/observability/` y `docs/verification/security-report.md`
  - **Prioridad**: P0 release.
  - **Dependencias**: T032, T052, T057, T066, T069.
  - **Objetivo y detalle**: Anon/A/B, direct DML/RPC/Storage, path traversal, JWT/refresh/logout, secret/log scan, rate limits/cuotas, signed URLs y claves restringidas.
  - **Criterio de aceptación**: Ningún propietario accede a otro; secretos server-only ausentes de APK/Git/logs; Functions requieren auth y mínimo contexto.
  - **Pruebas**: pgTAP, contract/security tests y análisis de artefacto release.
  - **Terminada cuando**: No hay hallazgo crítico/alto abierto.
  - **Referencia visual**: No aplica — seguridad sin cambios UI.

- [ ] T077 Validar migraciones, recuperación y resiliencia completa en `drift_schemas/`, `supabase/migrations/`, `integration_test/resilience_upgrade_test.dart` y `docs/verification/resilience-report.md`
  - **Prioridad**: P0 release.
  - **Dependencias**: T038, T052, T055, T072.
  - **Objetivo y detalle**: Upgrade desde cada schema, datos/outbox/fotos preservados, DB/Storage lleno, process kill, 24h offline, 100 pendientes, backup PostgreSQL y política separada de objetos Storage.
  - **Criterio de aceptación**: AC-003/007 y SC-003/004/006 pasan después de upgrade/interrupciones; ningún archivo parcial se confirma.
  - **Pruebas**: Matriz automatizada y pasos manuales de recuperación en dispositivo.
  - **Terminada cuando**: Reporte no contiene pérdida silenciosa ni ruta sin recuperación.
  - **Referencia visual**: `master.md → Offline UX`; sólo para verificar que estados/recuperación siguen siendo comprensibles.

- [ ] T078 Auditar dependencias, licencias, contratos externos y alcance en `pubspec.lock`, `android/`, `docs/verification/dependency-scope-report.md` y artefactos de especificación
  - **Prioridad**: P0 release.
  - **Dependencias**: T064, T069, T072, T076.
  - **Objetivo y detalle**: Licencias Lucide/XLSX/Google/Weather/Gemini, versiones bloqueadas, cuotas/atribución, claves, y búsqueda de iOS/roles/trabajadores/inventario/ERP/IoT/automatización/IA avanzada/análisis fotográfico/panel web/lunar.
  - **Criterio de aceptación**: Ninguna obligación o funcionalidad excluida queda abierta; upgrades incompatibles se rechazan o prueban separadamente.
  - **Pruebas**: SBOM/dependency audit, secret scan y assertions de alcance.
  - **Terminada cuando**: AC-009 y gates contractuales están cerrados.
  - **Referencia visual**: `master.md → Development Rules`; la auditoría confirma ausencia de identidad/variantes no autorizadas.

- [ ] T079 Completar matriz de trazabilidad y aceptación en `specs/002-agrocampo-android-mvp/checklists/acceptance-traceability.md` y `docs/verification/acceptance-report.md`
  - **Prioridad**: P0 release.
  - **Dependencias**: T074–T078.
  - **Objetivo y detalle**: Mapear CAP/FR/AC/SC a tarea, prueba y evidencia; ejecutar estudios cronometrados SC-001/002/005/008/011 con agricultores de prueba sin cambiar requisitos.
  - **Criterio de aceptación**: Cada requisito tiene evidencia passing o un bloqueo explícito; no se marca completo por ausencia de error.
  - **Pruebas**: Suite completa, sesiones de aceptación y revisión constitucional final PASS.
  - **Terminada cuando**: Cero requisito MVP sin dueño/prueba/evidencia y cero requisito externo agregado.
  - **Referencia visual**: `master.md → Flutter Implementation Guidelines → Calidad visual y pruebas`; `master.md → Development Rules`.

- [ ] T080 Generar release Android y cerrar verificaciones de repositorio en `android/`, `README.md`, `docs/verification/release-checklist.md` y artefactos AAB/APK no versionados
  - **Prioridad**: P0 release.
  - **Dependencias**: T079.
  - **Objetivo y detalle**: Analyze/test/integration, Supabase tests, firma/config release, minSdk devices, AAB/APK reproducible, smoke real, y comandos Node obligatorios de `AGENTS.md` para el prototipo sin modificarlo.
  - **Criterio de aceptación**: Build release instalable, todas las suites pasan, no contiene secretos y `node agrocampo-acceptance.test.js` más sintaxis embebida pasan.
  - **Pruebas**: Comandos de `quickstart.md`, instalación/upgrade/launch y smoke offline/reconexión.
  - **Terminada cuando**: Checklist firmado registra versiones, hashes, evidencias y riesgos residuales aceptados.
  - **Referencia visual**: `master.md → Development Rules`; release debe preservar todas las aprobaciones de T074.

---

## Dependencies & Execution Order

### Phase dependencies

```text
Setup T001–T005
        ↓
Foundation T006–T014
        ↓
US1 T015–T023
        ├──────────────→ US2 T024–T030 ──→ US3 T031–T038
        │                                      ↓
        │                               US4 T039–T044
        │                                      ↓
        └──────────────────────────────→ US5 T045–T050
                                               ↓
                                        US6 T051–T058
                                               ↓
                                        US7 T059–T063
                                               ↓
                                        US8 T064–T073
                                               ↓
                                        Polish T074–T080
```

### User story dependencies

| Story | Depends on | Independent completion boundary |
|---|---|---|
| US1 | Foundation | Territorial structure and context, no LABORES required. |
| US2 | US1 | Offline labor/soil/basic irrigation, no remote sync required. |
| US3 | US1 + US2 | Backup/conflicts for current aggregates; future aggregates plug into registry. |
| US4 | US2 + approved T039 | Deterministic calculator/estimate without Weather service. |
| US5 | US1 + US2; uses US4 data when present | History/production works even if no estimate exists. |
| US6 | US1 + US2; sync kernel for remote backup | Photos/reminders work locally even if FCM/Storage unavailable. |
| US7 | US1 + US2 + US5 + photo capability | Apiary inspection uses established labor/history/photo boundaries. |
| US8 | US1 + history/exportable data; uses completed feature set for full workbook | Weather and AI degrade independently; export remains offline. |

### Within each story

1. Write the listed tests/contract tests first and confirm they fail for the intended missing behavior.
2. Add schemas/models and migrations before repositories.
3. Implement domain/repositories before controllers/pages.
4. Add UI only after the required `master.md` reference exists.
5. Finish with the story's independent integration/golden checkpoint.

---

## Parallel Opportunities

### US1

- T016 local schema, T017 remote schema and T019 geometry/adapters can run in parallel after T015.
- T018 seed can run after T016/T017 while T019 continues.

### US2

- T028 Suelo and T029 Riego UI can run in parallel after T026/T027.
- Backend/local model work T025 can run while shared widget test fixtures are refined from T024.

### US3

- T034 scheduler and T035 conflict domain can run in parallel after T033.
- T036 sync summary UI can start with gateway fakes while T035 finishes; T037 waits for both.

### US4

- After T039, T040 fixtures and persistence migration design for T042 may proceed in parallel, but T041 must pass T040 before T043.

### US5

- T046 production schema and T047 history query can run in parallel after T045; T048 waits for T046.

### US6

- Photo track T051–T053 and reminder track T054–T057 can run in parallel after Foundation/US2, then converge at T058.

### US7

- T060 schema and widget test harness for T062 can proceed in parallel after T059; repository T061 gates functional UI.

### US8

- Weather T064–T067, AgroIA T068–T070 and XLSX T071–T072 are parallel workstreams; T073 integrates all three.

### Polish

- T075 performance and T076 security can run in parallel after feature completion; T074 may run per-screen incrementally and closes before T079.

---

## Implementation Strategy

### First demonstrable increment

1. Complete Setup and Foundation.
2. Complete US1 T015–T023.
3. Stop and validate its independent test: parcel, two sectors, crops and active context offline.

This is the smallest independently demonstrable slice. It is not the complete operational MVP because Offline First registration and reliable backup require US2 and US3.

### Core operational MVP

1. Foundation + US1: agricultural structure.
2. US2: offline recording.
3. US3: reliable backup/conflict resolution.
4. Stop and validate all P1 success criteria before adding P2/P3.

### Incremental completion

1. Add US4 calculation and validate its approved deterministic fixtures.
2. Add US5 history/production.
3. Add US6 photos/reminders.
4. Add US7 apiary.
5. Add US8 weather/AgroIA/export.
6. Complete Polish/release gates without adding scope.

## Backlog completion criteria

- Exactly 80 sequential tasks exist and every user-story task carries its `[USn]` label.
- Every checklist line includes an exact affected path.
- Every task declares dependencies, acceptance, tests, termination condition and visual reference.
- Every UI task cites one or more existing `master.md` sections and contains no visual design decision.
- No task creates iOS, workers, roles, inventory, ERP, physical irrigation automation, IoT, advanced AI, photo analysis, web panel or lunar calendar.
