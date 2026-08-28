# Tasks: AgroCampo MVP - Módulo 001

**Feature directory**: `specs/001-agrocampo-mvp/`

**Source of truth**: `.specify/memory/constitution.md`, `spec.md`, `plan.md`, `research.md`,
`data-model.md` and `contracts/`. No requirement is derived from `quickstart.md` or from future
ideas outside these artifacts.

**Execution format**: Every checklist line follows `[ID] [P?] [Story?] Description with file path`.
The nested fields are mandatory execution metadata for Codex.

**Test policy**: Tests are required by the request, specification and plan. A task is incomplete
until its listed tests pass and its evidence is recorded.

**Scope guard**: Do not create iOS, workers, roles, ERP, inventory, billing, physical irrigation
automation, Bluetooth/IoT sensors, web panel, advanced AI, photo analysis or lunar calendar features.

## Phase 1: Sprint 1 - Flutter Android setup

**Sprint goal**: Establish a reproducible Android-only Flutter project and the shared application
shell without implementing agricultural stories.

- [ ] T001 Crear el proyecto Flutter exclusivamente Android y fijar la matriz inicial de dependencias en `mobile/pubspec.yaml`, `mobile/android/` y `mobile/analysis_options.yaml`
  - **Sprint**: 1.
  - **Prioridad**: Crítica.
  - **Dependencias**: Ninguna.
  - **Objetivo**: Disponer de una base Flutter 3.44.7 reproducible, compilable para Android API 24-37 y sin estructura iOS.
  - **Archivos o módulos afectados**: `mobile/pubspec.yaml`, `mobile/pubspec.lock`, `mobile/android/`, `mobile/analysis_options.yaml`, `mobile/README.md`.
  - **Descripción técnica**: Inicializar solo la plataforma Android; configurar application ID y flavors `dev`, `staging`, `prod`; incorporar las dependencias aprobadas en `research.md`; fijar versiones compatibles después de resolverlas juntas; documentar SDK Flutter/Dart/Java/Android y no incluir secretos ni credenciales.
  - **Criterios de aceptación**: El proyecto resuelve dependencias, compila una aplicación vacía en API 24 y API actual, no contiene `ios/` y cada flavor usa identificador/configuración separados.
  - **Pruebas necesarias**: `flutter doctor -v`, `flutter pub get`, `flutter analyze`, compilación debug de los tres flavors y arranque en emuladores API 24 y actual.
  - **Terminado cuando**: El lockfile está versionado, la matriz de compatibilidad está documentada y un clon limpio puede compilar Android sin pasos manuales ocultos.

- [ ] T002 Configurar bootstrap, inyección, navegación y estados UI compartidos en `mobile/lib/app/`, `mobile/lib/core/ui/` y `mobile/lib/main.dart`
  - **Sprint**: 1.
  - **Prioridad**: Crítica.
  - **Dependencias**: T001.
  - **Objetivo**: Establecer MVVM pragmático, flujo unidireccional y el contrato de rutas/estados antes de añadir features.
  - **Archivos o módulos afectados**: `mobile/lib/main.dart`, `mobile/lib/app/bootstrap.dart`, `mobile/lib/app/agro_campo_app.dart`, `mobile/lib/app/router/`, `mobile/lib/app/theme/`, `mobile/lib/core/ui/`.
  - **Descripción técnica**: Configurar `provider` con inyección por constructor, `go_router`, rutas seguras descritas en `contracts/ui-navigation.md`, tema español latinoamericano, componentes de loading/empty/offline/saving/pending/syncing/error/conflict/permission y estado por texto+icono, sin lógica de persistencia en widgets.
  - **Criterios de aceptación**: Todas las rutas conocidas pueden representarse, las rutas protegidas redirigen a login, los estados estándar son accesibles y ningún ViewModel es singleton global mutable.
  - **Pruebas necesarias**: Widget tests de bootstrap, redirects, ruta inválida, estados estándar, semántica de iconos/controles y snapshot básico del tema.
  - **Terminado cuando**: La shell navega en Android, los tests de rutas/estados pasan y las responsabilidades coinciden con la tabla de arquitectura de `plan.md`.

- [ ] T003 [P] Implementar la infraestructura Drift, migraciones y acceso en background en `mobile/lib/core/database/`, `mobile/drift_schemas/` y `mobile/test/generated_migrations/`
  - **Sprint**: 1.
  - **Prioridad**: Crítica.
  - **Dependencias**: T001.
  - **Objetivo**: Crear la fuente de verdad local transaccional y una política de evolución sin pérdida de datos.
  - **Archivos o módulos afectados**: `mobile/lib/core/database/app_database.dart`, `mobile/lib/core/database/tables/`, `mobile/lib/core/database/daos/`, `mobile/lib/core/database/migrations/`, `mobile/drift_schemas/`, `mobile/test/core/database/`, `mobile/test/generated_migrations/`.
  - **Descripción técnica**: Abrir SQLite con Drift en background; habilitar claves foráneas; establecer convenciones UUID, UTC, unidades escaladas, campos de versión/sync/tombstone; crear tablas iniciales de perfil local, configuración y catálogo estable; versionar snapshots y preparar migraciones incrementales, transacciones y DAOs sin llamadas de red.
  - **Criterios de aceptación**: FK y checks están activos, las escrituras se confirman atómicamente, el catálogo conserva UUID estables, la base puede reabrirse tras reinicio y toda migración tiene snapshot.
  - **Pruebas necesarias**: Drift en memoria, rollback, FK/check, reapertura persistente, generación/verificación de migraciones y prueba de preservación de datos entre versiones.
  - **Terminado cuando**: Esquema, DAOs base y migraciones pasan pruebas en CI y no existe acceso SQLite desde presentación.

## Phase 2: Sprint 1 - Supabase, authentication and security foundation

**Sprint goal**: Complete the blocking backend, session and security foundation. No Sprint 2 task
may start before this phase passes.

- [ ] T004 [P] Inicializar Supabase local, migraciones, seeds y pruebas pgTAP base en `supabase/config.toml`, `supabase/migrations/`, `supabase/seed.sql` y `supabase/tests/`
  - **Sprint**: 1.
  - **Prioridad**: Crítica.
  - **Dependencias**: T001.
  - **Objetivo**: Disponer de un backend local reproducible con Auth, PostgreSQL/PostGIS, RLS y convenciones de propietario.
  - **Archivos o módulos afectados**: `supabase/config.toml`, `supabase/migrations/0001_foundation.sql`, `supabase/seed.sql`, `supabase/tests/rls/`, `supabase/tests/constraints/`.
  - **Descripción técnica**: Versionar extensiones y schema base; crear `profiles` y catálogo global; definir `owner_id`, versionado, timestamps y tombstones; activar RLS, revocar grants innecesarios y preparar helpers internos con `search_path` seguro; semillas deben coincidir con UUID locales y no crear roles/trabajadores.
  - **Criterios de aceptación**: `supabase db reset` reconstruye todo; `anon` no accede a datos privados; usuario A no accede a B; catálogo solo se lee; PostGIS queda disponible.
  - **Pruebas necesarias**: pgTAP de RLS/grants, constraints, UUID semilla, propietario inmutable, función interna no expuesta y reset completo desde cero.
  - **Terminado cuando**: La base se reproduce sin dashboard manual y todos los tests de seguridad base pasan.

- [ ] T005 Implementar autenticación, perfil y sesión offline segura en `mobile/lib/features/auth/`, `mobile/lib/features/profile/` y `mobile/lib/core/auth/`
  - **Sprint**: 1.
  - **Prioridad**: Crítica.
  - **Dependencias**: T002, T003, T004.
  - **Objetivo**: Permitir primer login conectado, perfil, retorno offline del último propietario validado y logout sin borrar pendientes.
  - **Archivos o módulos afectados**: `mobile/lib/core/auth/`, `mobile/lib/features/auth/data/`, `mobile/lib/features/auth/domain/`, `mobile/lib/features/auth/presentation/`, `mobile/lib/features/profile/`, `mobile/test/features/auth/`, `mobile/integration_test/auth_session_test.dart`.
  - **Descripción técnica**: Usar Supabase Auth con correo/contraseña de cuenta provisionada; persistir tokens solo en almacenamiento seguro; manejar `onAuthStateChange` y refresh offline; separar almacén local por `owner_id`; bloquear push hasta revalidar conexión; ocultar datos al cerrar sesión conservando Drift/outbox.
  - **Criterios de aceptación**: Primer acceso falla de forma comprensible offline; sesión validada reabre el mismo almacén sin red; logout bloquea datos; otro propietario no puede abrirlos; perfil muestra identidad y resumen sync sin secretos.
  - **Pruebas necesarias**: Unit tests de máquina de sesión, widget tests login/perfil/logout, integración conectado→offline→reinicio, refresh fallido, revocación al reconectar y cambio de propietario.
  - **Terminado cuando**: Todos los flujos CU-USR-01/02/03 y FR-001/004 pasan con credenciales ausentes de SQLite/logs.

- [ ] T006 [P] Configurar entornos, secretos, errores sanitizados y observabilidad mínima en `mobile/lib/core/security/`, `mobile/lib/core/errors/`, `mobile/config/` y `supabase/functions/.env.example`
  - **Sprint**: 1.
  - **Prioridad**: Crítica.
  - **Dependencias**: T001, T004.
  - **Objetivo**: Impedir que claves privilegiadas o datos sensibles entren al APK, repositorio, UI o logs.
  - **Archivos o módulos afectados**: `mobile/lib/core/security/`, `mobile/lib/core/errors/`, `mobile/lib/core/network/`, `mobile/config/README.md`, `.gitignore`, `supabase/functions/.env.example`, documentación de entornos.
  - **Descripción técnica**: Separar configuración dev/staging/prod; permitir en móvil solo publishable key y clave Android restringida; definir clasificación de errores, timeouts y logs con IDs/estado/latencia sin payload agrícola; documentar rotación, cuotas y secretos de Edge Functions; prohibir `service_role`, WeatherAPI, Gemini y credencial FCM en cliente.
  - **Criterios de aceptación**: Búsqueda estática no encuentra secretos; errores no revelan SQL/JWT; cada entorno usa endpoints/keys separados; logs excluyen prompt completo, fotos, credenciales y datos de otro propietario.
  - **Pruebas necesarias**: Tests de redacción de errores/logs, escaneo de artefacto Android y repo, pruebas de config faltante/incorrecta y revisión de permisos/keys por entorno.
  - **Terminado cuando**: CI bloquea secretos/configuración inválida y el contrato de seguridad externa queda aplicable a todas las integraciones.

- [ ] T007 Ejecutar y documentar el gate de Sprint 1 en `mobile/test/`, `mobile/integration_test/` y `supabase/tests/`
  - **Sprint**: 1.
  - **Prioridad**: Crítica.
  - **Dependencias**: T002, T003, T004, T005, T006.
  - **Objetivo**: Confirmar que la fundación bloqueante es reproducible antes de construir dominio agrícola.
  - **Archivos o módulos afectados**: `mobile/test/`, `mobile/integration_test/foundation_test.dart`, `supabase/tests/`, evidencia de CI asociada a Sprint 1.
  - **Descripción técnica**: Integrar análisis, unit/widget, migraciones Drift, reset/pgTAP Supabase y pruebas Android API 24/actual; validar login conectado, retorno offline, logout con datos preservados, aislamiento propietario y estados UI básicos.
  - **Criterios de aceptación**: Todos los comandos retornan éxito; ningún requisito de Sprint 1 depende de pasos manuales; no aparece código iOS ni módulo fuera de alcance.
  - **Pruebas necesarias**: Suite completa de T001-T006 en clon limpio y dos APIs Android, con reporte de fallos cero.
  - **Terminado cuando**: Evidencia aprobada confirma que Sprint 2 puede iniciar sin deuda bloqueante de persistencia, sesión o seguridad.

---

## Phase 3: Sprint 2 - Offline First, synchronization, conflicts and parcels

**Sprint goal**: Prove the complete local-write/outbox/RPC/pull/conflict path through the first
domain aggregate, Parcelas.

**Independent tests**:

- **US3**: Create 100 changes offline, restore network and prove each is acknowledged once or kept
  in an explicit error/conflict state, including lost ACK and restart.
- **US1 slice**: Create, edit, select and archive multiple parcels locally and recover them after
  restart; map/sector behavior is deferred to Sprint 3.

- [ ] T008 [US3] Implementar outbox, cursores, lease y estados sincronizables locales en `mobile/lib/core/database/tables/` y `mobile/lib/core/sync/`
  - **Sprint**: 2.
  - **Prioridad**: Crítica.
  - **Dependencias**: T003, T007.
  - **Objetivo**: Garantizar que cada escritura sincronizable tenga una operación durable y recuperable en la misma transacción.
  - **Archivos o módulos afectados**: `mobile/lib/core/database/tables/sync_*.dart`, `mobile/lib/core/sync/outbox_repository.dart`, `mobile/lib/core/sync/conflict_repository.dart`, `mobile/lib/core/sync/sync_lease.dart`, `mobile/test/core/sync/`.
  - **Descripción técnica**: Modelar `sync_outbox`, `sync_cursors`, `sync_lock` y `sync_conflicts` según `data-model.md`; usar UUID, base version, dependencias, retries, `next_attempt_at`, lease y errores sanitizados; exponer transacción de agregado+outbox y recuperar `sending` expirado a pending.
  - **Criterios de aceptación**: No puede confirmarse entidad sin outbox ni outbox sin entidad; un reinicio recupera operaciones; estados y contador se derivan de Drift; no hay cola en memoria como autoridad.
  - **Pruebas necesarias**: Rollback atómico, lease concurrente, restart sending→pending, causal dependency, backoff determinista con reloj inyectable y consultas indexadas.
  - **Terminado cuando**: Las transiciones locales del contrato sync pasan y Drift sigue siendo la única fuente de estado visible.

- [ ] T009 [P] [US3] Implementar ledger, feed y RPC de sincronización versionada en `supabase/migrations/`, `supabase/tests/sync/` y funciones PostgreSQL internas
  - **Sprint**: 2.
  - **Prioridad**: Crítica.
  - **Dependencias**: T004, T007.
  - **Objetivo**: Aplicar mutaciones remotas exactamente una vez por `operation_id` y ofrecer pull durable por `change_seq`.
  - **Archivos o módulos afectados**: `supabase/migrations/0002_sync_protocol.sql`, `supabase/tests/sync/`, `supabase/tests/rls/sync_policies.sql`.
  - **Descripción técnica**: Crear `sync_operations`, `sync_changes`, `sync_conflicts`; exponer RPC `SECURITY INVOKER` y función interna `SECURITY DEFINER` restringida; validar JWT/owner, whitelist de agregados, advisory lock, base version, recibo idempotente, evento/tombstone y paginación de pull; revocar DML directo.
  - **Criterios de aceptación**: Retry devuelve mismo recibo; versión conflictiva no altera canónico; feed ordena por owner/sequence; usuario no puede omitir versión/RLS ni invocar función interna.
  - **Pruebas necesarias**: pgTAP de duplicado, lost ACK simulado, base version, conflicto, tombstone, orden/paginación, grants y dos propietarios.
  - **Terminado cuando**: El contrato `contracts/sync-protocol.md` está cubierto por pruebas de base y un reset limpio.

- [ ] T010 [US3] Construir el coordinador push/pull, retry y estado global en `mobile/lib/core/sync/sync_coordinator.dart`, `mobile/lib/core/sync/sync_worker.dart` y `mobile/lib/core/ui/sync_status/`
  - **Sprint**: 2.
  - **Prioridad**: Crítica.
  - **Dependencias**: T008, T009.
  - **Objetivo**: Ejecutar ciclos idempotentes al iniciar, reanudar, recuperar conectividad y por reintento manual.
  - **Archivos o módulos afectados**: `mobile/lib/core/sync/`, `mobile/lib/core/network/`, `mobile/lib/core/ui/sync_status/`, `mobile/test/core/sync/sync_coordinator_test.dart`.
  - **Descripción técnica**: Adquirir lease; push causal antes de pull; clasificar auth/authorization/validation/429/5xx/timeout; aplicar ACK/conflict/páginas y cursor transaccionalmente; derivar Conectado/Offline/Sincronizando/Sincronizado/Error; tratar conectividad como señal, no prueba.
  - **Criterios de aceptación**: `Sincronizado` solo aparece sin pendientes/errores/conflictos; fallos no bloquean nuevas escrituras locales; pull replay es seguro; no hay dos coordinadores concurrentes.
  - **Pruebas necesarias**: Remoto falso con cortes antes/durante/después del commit, backoff+jitter, sesión expirada, pull interrumpido, múltiple trigger, cursor atómico y contador UI.
  - **Terminado cuando**: El ciclo completo cumple FR-047/051 y todas las ramas del contrato tienen estado visible y testeado.

- [ ] T011 [US3] Implementar persistencia y resolución explícita de conflictos en `mobile/lib/core/sync/` y `mobile/lib/features/sync/presentation/`
  - **Sprint**: 2.
  - **Prioridad**: Crítica.
  - **Dependencias**: T010.
  - **Objetivo**: Preservar snapshot local y remoto y permitir conservar remoto o reaplicar local sin last-write-wins.
  - **Archivos o módulos afectados**: `mobile/lib/core/sync/conflict_repository.dart`, `mobile/lib/features/sync/presentation/conflict_screen.dart`, `mobile/lib/features/sync/presentation/conflict_view_model.dart`, `mobile/test/core/sync/conflict_test.dart`.
  - **Descripción técnica**: Guardar conflicto antes de mostrarlo; comparar campos seguros; keep-remote reemplaza local tras confirmación; keep-local crea `resolve_conflict` contra última versión; retener auditoría y permitir un segundo conflicto sin descartar versiones.
  - **Criterios de aceptación**: Ninguna elección ocurre implícitamente; ambas versiones son legibles; la resolución actualiza estado/contador; otra cuenta no puede abrir el conflicto.
  - **Pruebas necesarias**: Widget tests de comparación/confirmación, unit tests de ambas resoluciones y segundo conflicto, integración con dos clientes y verificación de auditoría remota.
  - **Terminado cuando**: FR-050 y SC-006 están demostrados en ambos caminos de resolución.

- [ ] T012 [P] [US1] Crear el agregado Parcelas local/remoto y sus repositorios en `mobile/lib/features/parcels/`, `mobile/lib/core/database/tables/parcels.dart` y `supabase/migrations/0003_parcels.sql`
  - **Sprint**: 2.
  - **Prioridad**: Crítica.
  - **Dependencias**: T003, T004, T007.
  - **Objetivo**: Implementar la primera entidad agrícola sincronizable con datos, versión, archivo y tombstone coherentes.
  - **Archivos o módulos afectados**: `mobile/lib/features/parcels/data/`, `mobile/lib/features/parcels/domain/`, `mobile/lib/core/database/tables/parcels.dart`, `mobile/lib/core/database/daos/parcels_dao.dart`, `supabase/migrations/0003_parcels.sql`, tests asociados.
  - **Descripción técnica**: Modelar nombre, descripción, centro, geometría placeholder válida para el flujo previo a mapa, área, archived/tombstone y common sync fields; implementar repositorio Drift-only para UI, payload aggregate y políticas `RESTRICT`/RLS; el servidor recalcula área cuando exista geometría final.
  - **Criterios de aceptación**: Crear/editar/archivar restaura historial, UUID coincide local/remoto, owner no cambia y una parcela con dependencias no se borra físicamente.
  - **Pruebas necesarias**: DAO/repository, constraints/RLS, transacción parcela+outbox, archive/restore, tombstone y dos propietarios.
  - **Terminado cuando**: El agregado puede viajar por el protocolo T008-T010 sin acceso remoto directo desde UI.

- [ ] T013 [US1] Implementar lista, creación, edición, selección activa y archivado de parcelas en `mobile/lib/features/parcels/presentation/` y `mobile/lib/app/router/`
  - **Sprint**: 2.
  - **Prioridad**: Alta.
  - **Dependencias**: T012, T010.
  - **Objetivo**: Entregar el primer valor visible: múltiples parcelas y contexto activo persistente offline.
  - **Archivos o módulos afectados**: `mobile/lib/features/parcels/presentation/`, `mobile/lib/features/parcels/data/repositories/`, `mobile/lib/app/router/`, `mobile/lib/core/database/tables/app_settings.dart`, widget/integration tests.
  - **Descripción técnica**: Formularios españoles con validación y preservación de campos; lista activa/archivada; selección única en `app_settings`; confirmación de archivo/eliminación sin dependencias; propagación reactiva a rutas contextuales; geometría detallada se completa en Sprint 3.
  - **Criterios de aceptación**: Se crean Parcela 1/2/3 offline, una es activa, cambio persiste tras reinicio, archivar activa selecciona otra o estado vacío y toda escritura muestra pending/synced/error.
  - **Pruebas necesarias**: ViewModel/widget de formulario, lista, selección, confirmación, active parcel guard, restart offline e integración de sync simple.
  - **Terminado cuando**: CU-PAR-01/02/03/04 y FR-005/010 están cubiertos salvo edición gráfica reservada al Sprint 3.

- [ ] T014 [US3] Ejecutar fault injection y gate independiente de sincronización/parcelas en `mobile/integration_test/sync_parcels_test.dart` y `supabase/tests/sync/`
  - **Sprint**: 2.
  - **Prioridad**: Crítica.
  - **Dependencias**: T010, T011, T012, T013.
  - **Objetivo**: Probar el patrón vertical antes de replicarlo a sectores, labores, fotos y recordatorios.
  - **Archivos o módulos afectados**: `mobile/integration_test/sync_parcels_test.dart`, `mobile/test/fixtures/sync/`, `supabase/tests/sync/`, evidencia de CI Sprint 2.
  - **Descripción técnica**: Generar 100 operaciones, dependencias, red interrumpida en cuatro puntos, proceso terminado, ACK perdido, dos clientes, tombstone/archivo y pull paginado; medir duplicados y estados finales.
  - **Criterios de aceptación**: Cada operación termina acknowledged una vez o permanece explícitamente pending/failed/conflict; cero pérdida silenciosa, cero efectos duplicados y cursor nunca salta un evento.
  - **Pruebas necesarias**: Matriz Android conectado/offline/reinicio, pgTAP idempotencia, tests keep-local/remote y consulta final local/remota por UUID/version.
  - **Terminado cuando**: SC-003/004/005/006 pasan y el equipo autoriza reutilizar el patrón en Sprint 3.

---

## Phase 4: Sprint 3 - Maps, GPS, polygons, sectors and crops

**Sprint goal**: Complete User Story 1 by representing the real field spatially and assigning a
current crop without making the map provider the owner of geometry.

**Independent test (US1)**: Create a parcel polygon, one rectangular and one irregular sector,
assign/change crops, disable map tiles, restart offline and verify geometry, areas and assignment
history remain usable.

- [ ] T015 [P] [US1] Implementar geometría determinista de polígonos, superficie y contención en `mobile/lib/core/geometry/` y `mobile/test/core/geometry/`
  - **Sprint**: 3.
  - **Prioridad**: Crítica.
  - **Dependencias**: T014.
  - **Objetivo**: Validar y calcular parcelas/sectores offline sin delegar reglas críticas al proveedor de mapas.
  - **Archivos o módulos afectados**: `mobile/lib/core/geometry/polygon.dart`, `mobile/lib/core/geometry/polygon_validator.dart`, `mobile/lib/core/geometry/area_calculator.dart`, `mobile/lib/core/geometry/containment_service.dart`, `mobile/test/core/geometry/fixtures/`.
  - **Descripción técnica**: Modelar vértices WGS84 y GeoJSON; cierre con mínimo tres puntos distintos; detectar duplicados, autocruces y área nula; calcular área aproximada con algoritmo/versionado/tolerancia; validar sector completamente dentro de parcela y advertir solapamientos sin prohibirlos automáticamente.
  - **Criterios de aceptación**: Los mismos vértices producen el mismo resultado offline; polígonos inválidos no guardan; m²/ha usan redondeo documentado; contención funciona para cuadrados, rectángulos e irregulares.
  - **Pruebas necesarias**: Unit/property tests de orden de vértices, cruces, bordes, concavidad, antimeridiano descartado/gestionado, fixtures de áreas conocidas y tolerancia local/servidor.
  - **Terminado cuando**: FR-014/018 y SC de geometría del plan pasan sin dependencia de Google Maps ni PostGIS en la lógica local.

- [ ] T016 [US1] Integrar Google Maps, GPS foreground y vista esquemática offline en `mobile/lib/features/map/` y `mobile/android/app/src/main/AndroidManifest.xml`
  - **Sprint**: 3.
  - **Prioridad**: Alta.
  - **Dependencias**: T015.
  - **Objetivo**: Renderizar y editar geometrías con mapa conectado manteniendo consulta/edición básica cuando no hay tiles.
  - **Archivos o módulos afectados**: `mobile/lib/features/map/data/`, `mobile/lib/features/map/domain/`, `mobile/lib/features/map/presentation/`, `mobile/android/app/src/main/AndroidManifest.xml`, `mobile/test/features/map/`.
  - **Descripción técnica**: Encapsular `google_maps_flutter` en `MapRenderer`; restringir clave por flavor/package/SHA-1; pedir ubicación aproximada/precisa solo al usar GPS; soportar taps, puntos, mover/agregar/eliminar/deshacer; renderizar polígonos locales en canvas esquemático cuando tiles fallen; incluir atribución/legal.
  - **Criterios de aceptación**: Abrir mapa no exige GPS; permiso denegado permite posición manual; sin red se ven geometrías guardadas y coordenadas; el SDK no calcula área ni decide validez.
  - **Pruebas necesarias**: Fakes del renderer/location, widget tests permiso/tiles/offline, integración GPS en dispositivo, edición/persistencia y verificación de restricciones de clave/legal.
  - **Terminado cuando**: CU-MAP-01/03/04/05/07 y CU-PAR-05 funcionan en estados conectado/offline/permiso denegado.

- [ ] T017 [P] [US1] Implementar búsqueda protegida de ubicaciones en `supabase/functions/place-search/` y `mobile/lib/features/map/data/place_search_gateway.dart`
  - **Sprint**: 3.
  - **Prioridad**: Media.
  - **Dependencias**: T006, T014.
  - **Objetivo**: Buscar ubicaciones conectadas sin exponer una clave de web service ni persistir contenido prohibido del proveedor.
  - **Archivos o módulos afectados**: `supabase/functions/place-search/`, `mobile/lib/features/map/data/place_search_gateway.dart`, `mobile/lib/features/map/presentation/place_search_view_model.dart`, pruebas de función/gateway.
  - **Descripción técnica**: Edge Function con JWT, coordenadas/query validadas, debounce/session token, rate limit, timeout y DTO mínimo; persistir solo place ID y coordenadas confirmadas; degradar a GPS/manual sin red; secretos por entorno.
  - **Criterios de aceptación**: Query corta/no válida no sale; resultados se seleccionan sin filtrar claves; offline indica no disponible y no bloquea el mapa; logs no contienen clave ni URL completa.
  - **Pruebas necesarias**: Unit gateway con 200/429/timeout/empty, pruebas de función auth/rate limit, widget búsqueda y escaneo de secreto.
  - **Terminado cuando**: CU-MAP-02 cumple el contrato `PlaceSearchGateway` y el fallback local permanece intacto.

- [ ] T018 [P] [US1] Crear entidades, relaciones e índices de Sectores en Drift y Supabase en `mobile/lib/features/sectors/`, `mobile/lib/core/database/tables/sectors.dart` y `supabase/migrations/0004_sectors.sql`
  - **Sprint**: 3.
  - **Prioridad**: Crítica.
  - **Dependencias**: T012, T015.
  - **Objetivo**: Persistir sectores agrícolas/apícolas dentro de una parcela con número único y sincronización segura.
  - **Archivos o módulos afectados**: `mobile/lib/features/sectors/data/`, `mobile/lib/features/sectors/domain/`, `mobile/lib/core/database/tables/sectors.dart`, `supabase/migrations/0004_sectors.sql`, pgTAP/Drift tests.
  - **Descripción técnica**: Modelar parcel FK compuesta con owner, número positivo único parcial, nombre, tipo, GeoJSON/PostGIS, área y common sync fields; índices por parcela; validación local y PostGIS transaccional de contención; payload agregado compatible con outbox/RPC.
  - **Criterios de aceptación**: Número solo es único dentro de parcela; sector fuera no guarda; tipo apícola existe sin implementar aún la revisión; tombstone no borra historia; owner cruzado falla.
  - **Pruebas necesarias**: Drift/Postgres constraints e índices, PostGIS contención, RLS, duplicate number, sync create/update/delete y relación con parcela archivada.
  - **Terminado cuando**: FR-017/020 y el modelo `sectors` de `data-model.md` están implementados local/remoto.

- [ ] T019 [US1] Implementar creación, edición y consulta visual de sectores en `mobile/lib/features/sectors/presentation/` y `mobile/lib/features/map/presentation/`
  - **Sprint**: 3.
  - **Prioridad**: Alta.
  - **Dependencias**: T016, T018.
  - **Objetivo**: Permitir delimitar sectores cuadrados, rectangulares o irregulares dentro de la parcela activa.
  - **Archivos o módulos afectados**: `mobile/lib/features/sectors/presentation/`, `mobile/lib/features/map/presentation/sector_editor/`, `mobile/lib/app/router/`, widget/integration tests.
  - **Descripción técnica**: Flujo desde parcela activa; herramientas de forma y vértices; formulario de número/nombre/tipo; previsualización área; error/advertencia de contención/solape; ficha con geometría y datos; guardado local+outbox y estados estándar.
  - **Criterios de aceptación**: Cada forma válida se guarda offline, aparece en mapa/lista/ficha y conserva datos tras reinicio; cruce de límite impide confirmar sin borrar dibujo; número duplicado identifica conflicto.
  - **Pruebas necesarias**: ViewModel/widget de cada forma, invalid geometry, duplicate, active parcel propagation, restart offline y integración de sincronización.
  - **Terminado cuando**: CU-MAP-08 y CU-SEC-01/02/05 pasan de manera independiente.

- [ ] T020 [P] [US1] Implementar catálogo y asignaciones temporales de cultivos en `mobile/lib/features/crops/`, `mobile/lib/core/database/tables/crop_assignments.dart` y `supabase/migrations/0005_crops.sql`
  - **Sprint**: 3.
  - **Prioridad**: Alta.
  - **Dependencias**: T018.
  - **Objetivo**: Consultar los nueve cultivos obligatorios y cambiar cultivo sin reescribir rotaciones históricas.
  - **Archivos o módulos afectados**: `mobile/lib/features/crops/`, `mobile/lib/core/database/tables/crops.dart`, `mobile/lib/core/database/tables/crop_assignments.dart`, `supabase/migrations/0005_crops.sql`, `supabase/seed.sql`, tests.
  - **Descripción técnica**: Sembrar fichas con siembra/suelo/agua/enfermedades; modelar asignación con sector, crop, season opcional, valid_from/to y único parcial activo; cerrar+crear en una transacción/outbox aggregate; mostrar offline última versión local; apicultura activa tipo especializado sin añadir IA o inventario.
  - **Criterios de aceptación**: Los nueve nombres y campos aparecen en español; una asignación activa por sector; fecha inválida se rechaza; cambio preserva la anterior; catálogo no es editable por propietario.
  - **Pruebas necesarias**: Seed parity local/remoto, unique partial, atomic change, date boundaries, offline catalog, UI assign/change y history relationship.
  - **Terminado cuando**: CU-SEC-03/04 y CU-CUL-01, FR-021/023 están cubiertos con trazabilidad.

- [ ] T021 [US1] Ejecutar gate independiente de organización del campo en `mobile/integration_test/field_structure_test.dart` y suites de geometría/Supabase
  - **Sprint**: 3.
  - **Prioridad**: Crítica.
  - **Dependencias**: T016, T017, T019, T020.
  - **Objetivo**: Cerrar User Story 1 como incremento demostrable antes de comenzar `LABORES`.
  - **Archivos o módulos afectados**: `mobile/integration_test/field_structure_test.dart`, `mobile/test/fixtures/geometry/`, `supabase/tests/constraints/geometry.sql`, evidencia CI Sprint 3.
  - **Descripción técnica**: Recorrer parcela→mapa→sector rectangular/irregular→asignación/cambio de cultivo conectado y offline; cortar tiles/Places/GPS; reiniciar y sincronizar; medir consistencia de IDs, áreas y estado activo.
  - **Criterios de aceptación**: El agricultor completa la estructura en menos de 10 minutos en prueba; geometrías y cultivos persisten; fallas externas no bloquean datos locales; historial de asignación queda intacto.
  - **Pruebas necesarias**: E2E Android, tests de tolerancia área/contención, RLS owner, sync dependencies y usabilidad/semántica en mapa.
  - **Terminado cuando**: US1, SC-001 y todos sus CU/FR quedan con evidencia aprobada.

---

## Phase 5: Sprint 4 - LABORES, soil, irrigation, hybrid calculation and initial history

**Sprint goal**: Deliver the primary field-recording value offline, deterministic irrigation
support and the first queryable history.

**Independent tests**:

- **US2**: Disable network, record a generic labor and soil measurement, restart and find both as
  pending with preserved values.
- **US4**: Run 20 approved irrigation fixtures twice offline and obtain identical liters/time and
  an auditable saved irrigation.
- **US5 slice**: Filter current labor/soil/irrigation records by parcel, sector, crop, type and date.

- [ ] T022 [US2] Implementar el agregado base y flujo general del módulo `LABORES` en `mobile/lib/features/labors/`, Drift y Supabase
  - **Sprint**: 4.
  - **Prioridad**: Crítica.
  - **Dependencias**: T021.
  - **Objetivo**: Registrar offline actividades con contexto parcela→sector→tipo→datos→guardar y nombre UI exacto `LABORES`.
  - **Archivos o módulos afectados**: `mobile/lib/features/labors/`, `mobile/lib/core/database/tables/labors.dart`, `supabase/migrations/0006_labors.sql`, `mobile/lib/app/router/`, tests.
  - **Descripción técnica**: Modelar parcel/sector/crop assignment/season/type/occurred_at/notes/general details; tipos obligatorios; FK owner compuestas; agregado+outbox; formularios genéricos para fertilización, enfermedad/plaga, siembra y poda sin inventario/productos; estados estándar y preservación de input.
  - **Criterios de aceptación**: Módulo nunca dice “acciones”; labor se vincula al contexto correcto; formulario inválido conserva datos; offline/restart mantiene pending; genéricos no crean campos fuera de spec.
  - **Pruebas necesarias**: DAO/RLS/aggregate sync, widget selector/validación, active parcel change guard, offline restart y cada tipo enum.
  - **Terminado cuando**: CU-LAB-01 y FR-024/026 pasan y la base admite detalles especializados atómicos.

- [ ] T023 [P] [US2] Implementar mediciones manuales de suelo en `mobile/lib/features/soil/`, `mobile/lib/core/database/tables/soil_measurements.dart` y `supabase/migrations/0007_soil.sql`
  - **Sprint**: 4.
  - **Prioridad**: Alta.
  - **Dependencias**: T022.
  - **Objetivo**: Guardar humedad, pH, temperatura, EC, N, P y K con unidades/validaciones deterministas y sin sensor automático.
  - **Archivos o módulos afectados**: `mobile/lib/features/soil/`, `mobile/lib/core/database/tables/soil_measurements.dart`, `supabase/migrations/0007_soil.sql`, tests de dominio/UI/DB.
  - **Descripción técnica**: Detalle 1:1 de labor soil; almacenar unidades escaladas; al menos un indicador; rangos 0-100 y 0-14, no negativos; formularios métricos; transacción labor+detalle+outbox; server repite checks.
  - **Criterios de aceptación**: Valores límite válidos guardan; fuera de rango identifican campo; campos opcionales permiten registro parcial válido; UI dice ingreso manual y muestra unidades correctas.
  - **Pruebas necesarias**: Boundary/unit conversion, DB checks, rollback agregado, widget preserving inputs, sync offline/restart y export mapping preparado.
  - **Terminado cuando**: CU-SUE-01, FR-027/029 y criterios de unidades pasan local/remoto.

- [ ] T024 [P] [US2] Implementar registro de riego en `mobile/lib/features/irrigation/records/`, Drift y Supabase
  - **Sprint**: 4.
  - **Prioridad**: Alta.
  - **Dependencias**: T022.
  - **Objetivo**: Registrar fecha, sector, cultivo, tipo, caudal, duración y volumen estimado offline.
  - **Archivos o módulos afectados**: `mobile/lib/features/irrigation/records/`, `mobile/lib/core/database/tables/irrigation_records.dart`, `supabase/migrations/0008_irrigation_records.sql`, tests.
  - **Descripción técnica**: Detalle 1:1 de labor; enums goteo/aspersión/surco/gravedad; flow ml/min, duration seconds, volume ml; cálculo directo flow×time con redondeo único y advertencia si manual difiere; link opcional futuro a recommendation; transacción atómica.
  - **Criterios de aceptación**: Solo tipos/rangos válidos guardan; litros se muestran métricos; inputs y resultado permanecen trazables; offline/restart/sync no alteran el valor.
  - **Pruebas necesarias**: Unit conversion/rounding/zero, DB enum/check, widget form, rollback labor+detail+outbox y sync idempotente.
  - **Terminado cuando**: CU-RIE-01 y FR-030/032 pasan sin depender de clima o calculadora.

- [ ] T025 [P] [US4] Implementar reglas versionadas y calculadora híbrida determinista en `mobile/lib/features/irrigation/calculator/` y tablas de reglas/recomendaciones
  - **Sprint**: 4.
  - **Prioridad**: Crítica.
  - **Dependencias**: T020, T022.
  - **Objetivo**: Calcular localmente litros y tiempo con plantas, caudal, cultivo, humedad y temperatura, sin evapotranspiración avanzada.
  - **Archivos o módulos afectados**: `mobile/lib/features/irrigation/calculator/domain/`, `mobile/lib/core/database/tables/crop_irrigation_rules.dart`, `mobile/lib/core/database/tables/irrigation_recommendations.dart`, `supabase/migrations/0009_irrigation_rules.sql`, fixtures/tests.
  - **Descripción técnica**: Enteros escalados; base ml/planta por crop; ajustes simples y acotados de humedad/temperatura/clima; max weather cap; duration=volume/flow; rule ID/version/source; inputs/results/warnings persistidos; semillas solo con fuente y aprobación explícita; IA no participa.
  - **Criterios de aceptación**: Mismo input/regla produce exacto mismo output offline; cero plantas/caudal falla; resultado muestra variables, versión, advertencias y carácter estimativo; no existe ET avanzada.
  - **Pruebas necesarias**: 20 fixtures aprobados, property/boundary/rounding, replay histórico por versión, regla retirada, seed no aprobado bloquea release y tests de ausencia de dependencia IA/red.
  - **Terminado cuando**: FR-033/036 y SC-007/008 pasan y la fuente agronómica queda documentada.

- [ ] T026 [P] [US4] Implementar WeatherAPI mediante proxy seguro y cache local en `supabase/functions/weather-proxy/` y `mobile/lib/features/weather/`
  - **Sprint**: 4.
  - **Prioridad**: Alta.
  - **Dependencias**: T006, T021.
  - **Objetivo**: Proveer ajuste climático opcional sin exponer clave ni bloquear cálculo local.
  - **Archivos o módulos afectados**: `supabase/functions/weather-proxy/`, `mobile/lib/features/weather/data/`, `mobile/lib/features/weather/domain/`, `mobile/lib/core/database/tables/weather_cache.dart`, tests.
  - **Descripción técnica**: JWT, WGS84/range, rate limit, timeout, cache actual/forecast según términos, DTO temperatura/humedad/lluvia/pronóstico/attribution; `WeatherProvider` abstraído; cache con expiry; datos stale visibles pero sin influir recomendación nueva; no conservar respuesta completa.
  - **Criterios de aceptación**: Clave ausente del APK; cuota/timeout produce unavailable; cálculo usa weather adjustment solo fresco y acotado; UI muestra fecha/atribución; offline sin cache funciona.
  - **Pruebas necesarias**: Function auth/rate/cache, gateway fresh/stale/429/timeout, unit mapping metric, calculator no-weather y escaneo de secreto/log.
  - **Terminado cuando**: Contrato Weather proxy y FR de clima se cumplen sin convertir proveedor en cálculo crítico.

- [ ] T027 [US4] Integrar recomendación con creación de riego y presentación explicable en `mobile/lib/features/irrigation/presentation/`
  - **Sprint**: 4.
  - **Prioridad**: Crítica.
  - **Dependencias**: T024, T025, T026.
  - **Objetivo**: Permitir revisar una estimación, recalcular y usarla en un registro de riego sin automatizar la acción física.
  - **Archivos o módulos afectados**: `mobile/lib/features/irrigation/presentation/calculator_screen.dart`, `mobile/lib/features/irrigation/presentation/calculator_view_model.dart`, `mobile/lib/features/irrigation/presentation/irrigation_form.dart`, integration tests.
  - **Descripción técnica**: Mostrar inputs/unidades/rule/warnings/weather freshness, permitir edición/recalculo, crear riego con recommendation ID y valores aplicados, guardar ambos aggregates coherentemente según sus outbox operations, disclaimer de estimación y jamás activar equipos.
  - **Criterios de aceptación**: Handoff conserva inputs/resultados; usuario confirma antes de guardar; clima ausente se ve; cambios posteriores de regla no reescriben recomendación histórica.
  - **Pruebas necesarias**: ViewModel/widget, offline calculate→save→restart, sync dependency/retry, expired weather y prueba textual de no automatización.
  - **Terminado cuando**: CU-CAL-01 y aceptación de US4 se completan de extremo a extremo.

- [ ] T028 [US5] Implementar historial inicial consultado exclusivamente desde Drift en `mobile/lib/features/history/` y DAOs de labores
  - **Sprint**: 4.
  - **Prioridad**: Alta.
  - **Dependencias**: T020, T022, T023, T024.
  - **Objetivo**: Recuperar labores, suelo, riegos y cambios de cultivo por contexto sin depender de red.
  - **Archivos o módulos afectados**: `mobile/lib/features/history/data/`, `mobile/lib/features/history/domain/`, `mobile/lib/features/history/presentation/`, `mobile/lib/core/database/daos/history_dao.dart`, tests.
  - **Descripción técnica**: Queries paginadas/stream por parcel, sector, crop assignment, type y date; orden cronológico estable; filas especializadas resumidas; estados empty/offline/error; índices definidos en data model; producción se incorpora Sprint 5.
  - **Criterios de aceptación**: Cada filtro devuelve solo relaciones correctas, crop change muestra ambas asignaciones, historial funciona offline y no consulta Supabase desde UI.
  - **Pruebas necesarias**: DAO con datos cruzados, combinations/date boundaries/order, widget filtros/empty y performance preliminar con fixture.
  - **Terminado cuando**: FR-037/038 están cubiertos para entidades existentes y el diseño admite producción sin cambiar contrato público.

- [ ] T029 [US2] Ejecutar gate de registro offline de LABORES y suelo en `mobile/integration_test/labors_soil_offline_test.dart`
  - **Sprint**: 4.
  - **Prioridad**: Crítica.
  - **Dependencias**: T022, T023.
  - **Objetivo**: Validar de forma independiente el valor P1 de registrar trabajo en terreno sin internet.
  - **Archivos o módulos afectados**: `mobile/integration_test/labors_soil_offline_test.dart`, fixtures suelo/labores, evidencia CI US2.
  - **Descripción técnica**: Desactivar red, registrar genérico y suelo, forzar validaciones, reiniciar tres veces, consultar historial, restablecer red y confirmar outbox/ACK.
  - **Criterios de aceptación**: 100 % de registros válidos reaparece pending tras reinicio, inválidos preservan input y cada aggregate sincroniza una vez.
  - **Pruebas necesarias**: E2E Android, persistencia/restart, pérdida ACK y medición de tiempo de registro bajo 2 minutos.
  - **Terminado cuando**: US2, SC-002/003 y sus CU/FR tienen evidencia aprobada.

- [ ] T030 [US4] Ejecutar gate determinista de cálculo y registro de riego en `mobile/integration_test/irrigation_calculator_test.dart`
  - **Sprint**: 4.
  - **Prioridad**: Crítica.
  - **Dependencias**: T025, T026, T027.
  - **Objetivo**: Probar que el resultado crítico es local, reproducible, explicable y degradable sin clima.
  - **Archivos o módulos afectados**: `mobile/integration_test/irrigation_calculator_test.dart`, `mobile/test/fixtures/irrigation/`, evidencia CI US4.
  - **Descripción técnica**: Ejecutar dos veces 20 casos, comparar enteros/rule version, cero/faltantes, clima fresh/stale/unavailable, handoff a riego, restart y sync.
  - **Criterios de aceptación**: Resultados exactos e idénticos; warnings correctos; ninguna llamada Gemini; riego conserva auditoría y no existe ET avanzada.
  - **Pruebas necesarias**: Unit+integration+snapshot UI, bloqueo de regla no aprobada y matriz offline/provider failure.
  - **Terminado cuando**: US4, SC-007/008 y FR-033/036 están completamente probados.

- [ ] T031 [US5] Ejecutar gate del historial inicial en `mobile/integration_test/history_filters_test.dart`
  - **Sprint**: 4.
  - **Prioridad**: Alta.
  - **Dependencias**: T028, T029, T030.
  - **Objetivo**: Verificar filtros y trazabilidad antes de añadir producción y apicultura.
  - **Archivos o módulos afectados**: `mobile/integration_test/history_filters_test.dart`, `mobile/test/fixtures/history/`, evidencia CI US5 Sprint 4.
  - **Descripción técnica**: Cargar dos parcelas, sectores/cultivos cruzados y registros de cada tipo; aplicar filtros individuales/combinados offline; validar orden, assignment histórico, paginación e índices.
  - **Criterios de aceptación**: Cero filas de otro contexto, resultados estables y respuesta bajo objetivo preliminar con fixture de Sprint 4.
  - **Pruebas necesarias**: DAO/integration, `EXPLAIN QUERY PLAN`, UI filter reset/empty/offline y cross-owner isolation.
  - **Terminado cuando**: El slice de US5 puede demostrarse independientemente y Sprint 5 puede extenderlo sin reescritura.

---

## Phase 6: Sprint 5 - Production, harvest, apiary and photos

**Sprint goal**: Complete production/history, the apiary specialization and durable visual evidence
without introducing image analysis.

**Independent tests**:

- **US5**: Record harvests for two sectors/seasons and prove every history filter and aggregation
  returns only related rows.
- **US7**: Create an apiary sector and inspection offline, including explicit health fields, then
  retrieve and sync it.
- **US6 photo slice**: Attach camera/gallery photos offline, kill/restart during intake/upload and
  prove associations and private access remain correct.

- [ ] T032 [P] [US5] Implementar temporadas y registros de producción/cosecha en `mobile/lib/features/production/` y migraciones Drift/Supabase
  - **Sprint**: 5.
  - **Prioridad**: Alta.
  - **Dependencias**: T031.
  - **Objetivo**: Guardar cultivo, fecha, cantidad, unidad, calidad y observaciones con contexto para comparaciones futuras.
  - **Archivos o módulos afectados**: `mobile/lib/features/production/`, `mobile/lib/core/database/tables/seasons.dart`, `mobile/lib/core/database/tables/production_records.dart`, `supabase/migrations/0010_production.sql`, tests.
  - **Descripción técnica**: Modelar season open/closed y detalle 1:1 de labor harvest; cantidad interna en gramos, UI kg u otra unidad métrica permitida; quality/unclassified y notes; relación parcel/sector/crop/season; aggregate labor+production+outbox; sin generar aún dashboards/estadísticas nuevas.
  - **Criterios de aceptación**: Cantidad positiva y métrica; temporada/relaciones preservadas; offline/restart/sync idempotente; datos aptos para consultas anuales/sector sin añadir panel comparativo fuera de MVP.
  - **Pruebas necesarias**: Conversions/boundaries, season dates/status, DB/RLS, rollback aggregate, widget form, offline sync y owner isolation.
  - **Terminado cuando**: CU-PRO-01 y FR-039/040 están implementados con trazabilidad completa.

- [ ] T033 [US5] Completar historial con producción, temporadas y consultas de rendimiento base en `mobile/lib/features/history/` y `mobile/lib/core/database/daos/history_dao.dart`
  - **Sprint**: 5.
  - **Prioridad**: Alta.
  - **Dependencias**: T032.
  - **Objetivo**: Incorporar cosechas y temporadas al historial y dejar consultas preparadas para comparaciones futuras sin crear un panel futuro.
  - **Archivos o módulos afectados**: `mobile/lib/features/history/`, `mobile/lib/core/database/daos/history_dao.dart`, `mobile/lib/features/production/data/`, tests.
  - **Descripción técnica**: Extender queries y modelos de fila con producción/season; totales base por sector/cultivo/temporada solo cuando formen parte de consulta actual; mantener paginación/orden/índices; no implementar gráficos, predicciones ni panel web.
  - **Criterios de aceptación**: Filtros incluyen/excluyen producción correctamente; crop/sector/season relations son auditables; historial anterior no cambia; todo funciona offline.
  - **Pruebas necesarias**: Datos cruzados multitemporada, totals/units, date boundaries, query plans, widget filter/result y restart.
  - **Terminado cuando**: US5 funcional cubre labores, suelo, riego, crop changes, temporadas y producción.

- [ ] T034 [P] [US7] Implementar sector/revisión apícola y formulario especializado en `mobile/lib/features/beekeeping/` y migraciones Drift/Supabase
  - **Sprint**: 5.
  - **Prioridad**: Alta.
  - **Dependencias**: T022, T031.
  - **Objetivo**: Registrar la revisión apícola intermedia definida por el MVP sin añadir gestión avanzada de colmenas.
  - **Archivos o módulos afectados**: `mobile/lib/features/beekeeping/`, `mobile/lib/core/database/tables/apiary_inspections.dart`, `supabase/migrations/0011_apiary.sql`, tests.
  - **Descripción técnica**: Detalle 1:1 de labor apiary; exigir sector_type apiary; hive count, date vía labor, beekeeper, queen, laying, feeding, disease/pest booleans+notes, super added; transacción y sync aggregate; fotos se integran mediante target labor en T037.
  - **Criterios de aceptación**: Valores obligatorios/rangos aplican; ausencia/presencia sanitaria es explícita; sector agrícola no admite revisión apícola; no aparece inventario ni análisis de imagen.
  - **Pruebas necesarias**: Domain/DB checks, wrong sector type, conditional notes, widget form, offline restart, sync/RLS y history row.
  - **Terminado cuando**: CU-API-01 y FR-044 están cubiertos antes de integrar fotos.

- [ ] T035 [P] [US6] Implementar ingreso y persistencia local de fotografías en `mobile/lib/features/photos/` y almacenamiento privado Android
  - **Sprint**: 5.
  - **Prioridad**: Alta.
  - **Dependencias**: T022, T031.
  - **Objetivo**: Capturar/seleccionar evidencia y conservarla offline de forma durable, privada y asociable.
  - **Archivos o módulos afectados**: `mobile/lib/features/photos/data/local/`, `mobile/lib/features/photos/domain/`, `mobile/lib/core/files/`, tabla Drift `photos`, Android permissions, tests.
  - **Descripción técnica**: `image_picker`, cámara/galería y Photo Picker; copiar XFile temporal a app-private con UUID; `retrieveLostData` al bootstrap; MIME/size/SHA-256/source/time; compresión y remoción EXIF innecesario; exactly-one target sector/labor; no BLOB/base64 ni análisis.
  - **Criterios de aceptación**: Foto permanece tras restart/force-stop; permiso denegado y espacio insuficiente no crean fila rota; local path no se exporta/sincroniza; imagen puede verse offline.
  - **Pruebas necesarias**: Fakes picker/filesystem, lost data, camera/gallery cancel, MIME/size/hash, low space, target check, EXIF policy y Android device flow.
  - **Terminado cuando**: FR-041/043 local y el contrato Local intake están probados.

- [ ] T036 [US6] Implementar bucket privado y sincronización idempotente de fotos en `supabase/migrations/0012_photo_storage.sql`, `supabase/tests/rls/storage.sql` y gateway Flutter
  - **Sprint**: 5.
  - **Prioridad**: Crítica.
  - **Dependencias**: T009, T010, T035.
  - **Objetivo**: Respaldar archivo y metadata sin duplicar, sobrescribir ni exponer evidencia agrícola.
  - **Archivos o módulos afectados**: `supabase/migrations/0012_photo_storage.sql`, `supabase/tests/rls/storage.sql`, `mobile/lib/features/photos/data/remote/`, `mobile/lib/features/photos/data/repositories/`, sync photo worker/tests.
  - **Descripción técnica**: Bucket `agricultural-photos` privado; path immutable owner/photo/hash; MIME/size; RLS folder owner insert/select, sin update/delete móvil; standard upload <=6MB, upsert false; considerar existing success solo si hash/path coincide; subir objeto antes de metadata; conservar copia local y clasificar retries.
  - **Criterios de aceptación**: Retry/ACK perdido no duplica; owner B no lista/lee A; metadata nunca confirma sin objeto; fallo de archivo deja estado visible/reintentable; no se usa bucket público.
  - **Pruebas necesarias**: pgTAP Storage policies, interrupted/existing/mismatch upload, auth expiry, network loss, metadata rollback y scan de rutas/keys.
  - **Terminado cuando**: El contrato Remote storage y la parte remota de FR-043 pasan con evidencia de privacidad.

- [ ] T037 [US6] Integrar fotografías con sectores, labores, cosecha y apicultura en `mobile/lib/features/photos/presentation/` y rutas de destino
  - **Sprint**: 5.
  - **Prioridad**: Alta.
  - **Dependencias**: T034, T036.
  - **Objetivo**: Completar el flujo usuario de evidencia visual sin análisis automático.
  - **Archivos o módulos afectados**: `mobile/lib/features/photos/presentation/`, `mobile/lib/features/sectors/presentation/`, `mobile/lib/features/labors/presentation/`, `mobile/lib/features/production/presentation/`, `mobile/lib/features/beekeeping/presentation/`, router/tests.
  - **Descripción técnica**: Selector target explícito, preview/description, galería por sector/labor, badges upload/sync/error, delete-before-sync que no reaparece, navegación segura y lazy thumbnails; no inferir enfermedad/calidad desde foto.
  - **Criterios de aceptación**: Enfermedad/evolución/cosecha/apicultura se documentan como asociaciones manuales; fotos cargan offline; borrar pendiente cancela cola; conflictos no cambian target.
  - **Pruebas necesarias**: Widget/navigation, target owner, delete/retry/restart, integration apiary+photo y performance de metadata/thumbnails.
  - **Terminado cuando**: CU-FOT-01 y escenarios foto de US6/US7 son ejecutables de extremo a extremo.

- [ ] T038 [US5] Ejecutar gate completo de producción e historial en `mobile/integration_test/production_history_test.dart`
  - **Sprint**: 5.
  - **Prioridad**: Crítica.
  - **Dependencias**: T032, T033.
  - **Objetivo**: Cerrar User Story 5 con datos multisection/multitemporada y filtros exactos.
  - **Archivos o módulos afectados**: `mobile/integration_test/production_history_test.dart`, fixtures producción/temporadas, evidencia CI US5.
  - **Descripción técnica**: Crear cosechas de dos sectores/cultivos/temporadas offline; sincronizar; filtrar/ordenar; cambiar cultivo; comprobar cantidades métricas, relaciones e historial intacto.
  - **Criterios de aceptación**: 100 % de consultas contiene solo filas pertinentes; cambio de cultivo no reescribe cosecha; producción queda apta para comparación futura sin panel nuevo.
  - **Pruebas necesarias**: E2E, cross-owner, query plans, restart, sync and SC-009 dataset.
  - **Terminado cuando**: US5, CU-PRO-01 y SC-009 tienen evidencia aprobada.

- [ ] T039 [US7] Ejecutar gate independiente de apicultura en `mobile/integration_test/apiary_inspection_test.dart`
  - **Sprint**: 5.
  - **Prioridad**: Alta.
  - **Dependencias**: T034, T037.
  - **Objetivo**: Demostrar un sector apícola y revisión completa offline con fotos opcionales.
  - **Archivos o módulos afectados**: `mobile/integration_test/apiary_inspection_test.dart`, fixtures apicultura, evidencia CI US7.
  - **Descripción técnica**: Crear sector apiary, inspección con cada campo, ausencia/presencia sanitaria, foto, restart, historia y sync; probar sector agrícola inválido.
  - **Criterios de aceptación**: Registro aparece cronológico, foto mantiene vínculo, validaciones funcionan y no existen colmenas como inventario separado.
  - **Pruebas necesarias**: E2E offline/sync/photo, DB/RLS, validation and history filter.
  - **Terminado cuando**: US7 y sus dos escenarios de aceptación pasan independientemente.

- [ ] T040 [US6] Ejecutar gate de fotografías resilientes y privadas en `mobile/integration_test/photos_offline_sync_test.dart` y `supabase/tests/rls/storage.sql`
  - **Sprint**: 5.
  - **Prioridad**: Crítica.
  - **Dependencias**: T035, T036, T037.
  - **Objetivo**: Probar intake, recuperación, asociación, upload y aislamiento antes de recordatorios/exportación.
  - **Archivos o módulos afectados**: `mobile/integration_test/photos_offline_sync_test.dart`, fixtures imagen, Storage tests, evidencia CI US6 photo slice.
  - **Descripción técnica**: Cámara/galería, kill durante picker/upload, retry same hash, delete pending, storage full, owner B access y restart offline con visualización.
  - **Criterios de aceptación**: Cero foto perdida/duplicada/reasociada; errores visibles y recuperables; bucket/rutas privadas; no análisis fotográfico.
  - **Pruebas necesarias**: Android físico/emulador, fault injection, pgTAP policies y scan de metadata/local paths.
  - **Terminado cuando**: El slice fotográfico de US6 pasa y no deja deuda bloqueante de archivos.

---

## Phase 7: Sprint 6 - Reminders, FCM, consultative Gemini and XLSX

**Sprint goal**: Complete User Story 6 and the remaining mandatory external integrations while
keeping offline reminders/export authoritative and AI non-critical.

**Independent test (US6)**: Attach a photo, create an offline reminder that alerts locally, receive
a deduplicated remote event, obtain/refuse advisory answers according to policy, and export all
required sheets offline.

- [ ] T041 [P] [US6] Implementar recordatorios y alarmas locales offline en `mobile/lib/features/reminders/` y `mobile/lib/core/notifications/`
  - **Sprint**: 6.
  - **Prioridad**: Alta.
  - **Dependencias**: T040.
  - **Objetivo**: Crear título, fecha/hora, sector y descripción con aviso local independiente de internet.
  - **Archivos o módulos afectados**: `mobile/lib/features/reminders/`, tabla Drift/Supabase `reminders`, `mobile/lib/core/notifications/local_scheduler.dart`, Android notification config, tests.
  - **Descripción técnica**: Persistir primero; timezone e ID Android estable; `flutter_local_notifications` inexacta por defecto; permisos contextual Android 13+; reconcile al start/edit/cancel/complete/timezone; fecha pasada histórica explícita; aggregate+outbox; no exact alarm salvo requisito posterior.
  - **Criterios de aceptación**: Offline programa/avisa; permiso denegado preserva registro; edit/cancel no duplica alarma; restart/timezone reconciliado; sync no determina entrega local.
  - **Pruebas necesarias**: Clock/timezone/DST, scheduler fake, permission denied, restart, edit/cancel/complete, Android device local alert y sync.
  - **Terminado cuando**: CU-REC-01 y FR-045/046 local están implementados.

- [ ] T042 [US6] Implementar registro de dispositivo y FCM HTTP v1 remoto en `mobile/lib/core/notifications/fcm/`, `supabase/functions/send-reminder/` y migraciones
  - **Sprint**: 6.
  - **Prioridad**: Alta.
  - **Dependencias**: T006, T041.
  - **Objetivo**: Complementar recordatorios sincronizados con notificación remota segura y deduplicada.
  - **Archivos o módulos afectados**: `mobile/lib/core/notifications/fcm/`, `supabase/functions/send-reminder/`, `supabase/migrations/0013_device_registrations.sql`, tests función/cliente.
  - **Descripción técnica**: Token lifecycle por owner/device, refresh/disable invalid, Edge Function con credencial server-only y HTTP v1, payload event/reminder/route sin datos agrícolas, dedupe local event_id, estados foreground/background/terminated; FCM nunca completa ni sustituye alarma local.
  - **Criterios de aceptación**: Credencial ausente de APK; token de otro owner no sirve; duplicate event no duplica aviso; force-stop/Doze/delay se documentan sin prometer exactitud.
  - **Pruebas necesarias**: Token refresh/invalid, function auth/payload/rate, foreground/background tap route, double delivery, permission denied y real-device FCM.
  - **Terminado cuando**: Contrato FCM y requisito constitucional de notificación remota pasan.

- [ ] T043 [P] [US6] Implementar Gemini consultivo mediante proxy y pantalla aislada en `supabase/functions/gemini-advisory/` y `mobile/lib/features/advisory_ai/`
  - **Sprint**: 6.
  - **Prioridad**: Alta.
  - **Dependencias**: T006, T040.
  - **Objetivo**: Ofrecer orientación textual general sin cálculos críticos, fotos, diagnósticos, escrituras ni decisiones automáticas.
  - **Archivos o módulos afectados**: `supabase/functions/gemini-advisory/`, `mobile/lib/features/advisory_ai/data/`, `domain/`, `presentation/`, policy/config/tests.
  - **Descripción técnica**: JWT, pregunta/contexto mínimo seleccionado, límites char/token/timeout/rate/spend, modelo GA fijado por config y deprecation check, safety settings, logs metadata-only, disclaimer/uncertainty; rechazar foto, ubicación exacta, historia completa, dosis, diagnosis, area/volume/time y commands; offline unavailable no queued.
  - **Criterios de aceptación**: Toda respuesta permitida está en español y rotulada consultiva; solicitudes prohibidas no ejecutan cálculo/escritura; no hay clave/prompt completo en cliente/log; falla externa no afecta otros módulos.
  - **Pruebas necesarias**: Contract/function allow/refuse matrix, injection/oversize/rate/timeout, privacy log, offline UI, adversarial prompts y model/key release check.
  - **Terminado cuando**: FR-054 y límites constitucionales IA pasan sin análisis fotográfico ni IA avanzada.

- [ ] T044 [P] [US6] Implementar exportación XLSX offline conforme al contrato en `mobile/lib/features/export/` y pruebas de workbook
  - **Sprint**: 6.
  - **Prioridad**: Alta.
  - **Dependencias**: T033, T040.
  - **Objetivo**: Generar un `.xlsx` coherente desde Drift con siete hojas, métricas, relaciones y estado sync.
  - **Archivos o módulos afectados**: `mobile/lib/features/export/`, `mobile/lib/core/files/document_writer.dart`, `mobile/test/features/export/`, fixtures XLSX.
  - **Descripción técnica**: `excel_community` fijado; snapshot transaccional; isolate; hojas/columnas/orden exactos de `contracts/export-xlsx.md`; fechas ISO, IDs texto, scaled→metric, tombstone excluded/archive included, formula injection safe; Android SAF sin permiso storage amplio; cancel/failure no éxito parcial.
  - **Criterios de aceptación**: Excel y LibreOffice abren sin repair; counts/IDs/units/statuses/accent match Drift; pending/conflict incluidos; funciona offline y UI no se bloquea.
  - **Pruebas necesarias**: Contract parser/row count, malicious cell text, 10k fixture memory/time, SAF cancel/error, Excel+LibreOffice manual y no secrets/local paths.
  - **Terminado cuando**: CU-EXP-01, FR-052/053 y SC-010 pasan.

- [ ] T045 [US6] Endurecer adaptadores externos, cuotas y secretos en `mobile/lib/core/network/`, `supabase/functions/` y configuración por entorno
  - **Sprint**: 6.
  - **Prioridad**: Crítica.
  - **Dependencias**: T017, T026, T036, T042, T043.
  - **Objetivo**: Aplicar de forma uniforme autenticación, timeout, retry/circuit, rate limits, atribución y límites de costo.
  - **Archivos o módulos afectados**: `mobile/lib/core/network/`, `supabase/functions/_shared/`, `mobile/config/README.md`, documentación de quotas/terms, tests transversales.
  - **Descripción técnica**: Contratos tipados y fakes; secrets por entorno; JWT verify; classification; quota/spend alerts; key rotation; restricted Maps key; Weather attribution/cache; Gemini authorization-key/deprecation review; FCM service identity; no full upstream URL/payload logs.
  - **Criterios de aceptación**: Cada integración se puede apagar/fallar sin bloquear registros; no hay secreto privilegiado móvil; attribution/legal visible; staging y prod aislados.
  - **Pruebas necesarias**: Static secret scan APK/repo, integration 401/403/429/5xx/timeout, circuit recovery, quota alarm dry-run y review checklist provider terms.
  - **Terminado cuando**: El contrato `external-services.md` completo está cubierto y aprobado por seguridad.

- [ ] T046 [US6] Ejecutar gate de recordatorios, FCM, Gemini y XLSX en `mobile/integration_test/complementary_features_test.dart` y pruebas de funciones
  - **Sprint**: 6.
  - **Prioridad**: Crítica.
  - **Dependencias**: T041, T042, T043, T044, T045.
  - **Objetivo**: Cerrar US6 y todas las integraciones obligatorias antes del hardening final.
  - **Archivos o módulos afectados**: `mobile/integration_test/complementary_features_test.dart`, `supabase/functions/*/tests/`, XLSX fixtures, evidencia CI Sprint 6.
  - **Descripción técnica**: Recordatorio offline→alert→sync→FCM duplicate; permiso negado; Gemini allow/refuse/offline; export con data pending/conflict y fórmula hostil; providers down; scan secrets.
  - **Criterios de aceptación**: Cada capacidad entrega valor independiente; fallas externas degradan con mensaje; FCM no duplica; IA no cruza límites; workbook cumple contrato.
  - **Pruebas necesarias**: E2E Android físico, function/contract tests, Excel/LibreOffice, security scan y acceptance scenarios US6.
  - **Terminado cuando**: US6, SC-010/011 y requisitos de fotos/recordatorios/export/IA quedan aprobados.

---

## Phase 8: Sprint 7 - Final tests, performance, security and Android release

**Sprint goal**: Harden cross-cutting behavior and produce a release candidate only after every
functional sprint passes.

- [ ] T047 Implementar sincronización best-effort con WorkManager y exclusión foreground/background en `mobile/lib/core/sync/background/` y configuración Android
  - **Sprint**: 7.
  - **Prioridad**: Alta.
  - **Dependencias**: T010, T046.
  - **Objetivo**: Reintentar con red en segundo plano sin crear una segunda implementación de sync ni prometer inmediatez.
  - **Archivos o módulos afectados**: `mobile/lib/core/sync/background/`, `mobile/android/`, `mobile/test/core/sync/background/`, integration tests.
  - **Descripción técnica**: Trabajo único con constraint network; inicialización corta de DB/Auth/Supabase en isolate; mismo coordinator/lease; cierre de recursos; refresh/invalidation al resume; fallback foreground si concurrencia no supera gate; documentar Doze/force-stop.
  - **Criterios de aceptación**: Foreground y worker nunca procesan misma lease; retry/restart es idempotente; UI refresca cambios; deshabilitar worker no rompe sync al abrir/reanudar.
  - **Pruebas necesarias**: Forced WorkManager, overlapping triggers, process kill, Doze, network constraint, lease expiry, DB lock and resume refresh on real device.
  - **Terminado cuando**: Background best-effort pasa sin pérdida/duplicado y no cambia garantías del protocolo v1.

- [ ] T048 [P] Rehearsar migraciones, seeds y recuperación de datos/Storage en `mobile/drift_schemas/`, `supabase/migrations/`, `supabase/tests/` y runbook operativo
  - **Sprint**: 7.
  - **Prioridad**: Crítica.
  - **Dependencias**: T003, T004, T036, T046.
  - **Objetivo**: Probar actualización sin pérdida y documentar que backup PostgreSQL no sustituye backup de objetos Storage.
  - **Archivos o módulos afectados**: `mobile/drift_schemas/`, `mobile/test/generated_migrations/`, `supabase/migrations/`, `supabase/seed.sql`, `supabase/tests/`, `docs/storage-backup-runbook.md`.
  - **Descripción técnica**: Rebuild remoto; upgrade cada Drift snapshot; data preservation/FK check; seed stable IDs; rehearsal staging; inventario de bucket/metadata y restore verificable; no purga tombstones/feed en MVP; rollback/migración destructiva por fases.
  - **Criterios de aceptación**: Cada versión actualiza al latest sin pérdida; reset reproduce schema; restore recupera metadata+objetos+relaciones; runbook no contiene secretos.
  - **Pruebas necesarias**: Generated migration tests, `supabase db reset/test`, staging backup/restore drill, hash/link photo validation y schema diff.
  - **Terminado cuando**: Gate de migración/recuperación es verde y bloquea release ante cualquier pérdida.

- [ ] T049 [P] Optimizar consultas, inicio, memoria y exportación con fixture objetivo en `mobile/test/fixtures/performance/` y módulos perfilados
  - **Sprint**: 7.
  - **Prioridad**: Crítica.
  - **Dependencias**: T046.
  - **Objetivo**: Cumplir P95 local <2 s, inicio <5 s y escala 20/200/10.000 sin bloquear UI.
  - **Archivos o módulos afectados**: `mobile/test/fixtures/performance/`, DAOs/índices identificados por profiling, sync batch config, exporter isolate, benchmark/integration tests.
  - **Descripción técnica**: Generar fixture determinista; medir profile mode P50/P95 startup/query/save/filter/export; `EXPLAIN QUERY PLAN`/Postgres `EXPLAIN`; ajustar solo índices/queries/lotes demostrados; revisar fotos fuera del benchmark textual y jank isolate.
  - **Criterios de aceptación**: Métricas NFR-001/002/009/SC-012; no regression funcional; índice añadido tiene query justificante; memory/export dentro del presupuesto observado del target device.
  - **Pruebas necesarias**: Automated benchmarks repeated, Flutter performance traces, DB plans, 10k XLSX and 100-op sync load.
  - **Terminado cuando**: Resultados versionados muestran metas cumplidas en dispositivo objetivo API 24 y actual.

- [ ] T050 [P] Ejecutar auditoría final de Auth, RLS, grants, Storage, funciones, claves y privacidad en `supabase/tests/`, configuración y APK staging
  - **Sprint**: 7.
  - **Prioridad**: Crítica.
  - **Dependencias**: T045, T046.
  - **Objetivo**: Impedir acceso cross-owner, DML fuera del RPC, exposición de archivos o secretos y uso indebido de IA.
  - **Archivos o módulos afectados**: `supabase/tests/rls/`, `supabase/tests/sync/`, `supabase/tests/functions/`, `mobile/test/security/`, configuración cloud/staging y reporte auditoría.
  - **Descripción técnica**: Dos owners+anon; owner immutable; DML denied/RPC allowed; search_path/function execute; Storage paths; JWT expiry/revocation; APK/repo/log/export secret scan; Maps restrictions; provider keys/terms; Gemini privacy/paid production/deprecation; minimal Android permissions.
  - **Criterios de aceptación**: Ningún actor cruza owner ni obtiene secret; funciones privadas no expuestas; findings críticos/altos corregidos; excepciones no implícitas.
  - **Pruebas necesarias**: pgTAP adversarial, function auth fuzz, mobile static/dynamic scan, session/logout/revocation and manual cloud policy review.
  - **Terminado cuando**: Seguridad aprueba release y cualquier fallo crítico bloquea T053.

- [ ] T051 [P] Completar accesibilidad, español, unidades y usabilidad en terreno en `mobile/lib/app/theme/`, `mobile/lib/core/ui/` y todas las features
  - **Sprint**: 7.
  - **Prioridad**: Alta.
  - **Dependencias**: T046.
  - **Objetivo**: Asegurar flujos táctiles comprensibles, métricos y visibles sin depender de color o conectividad.
  - **Archivos o módulos afectados**: `mobile/lib/app/theme/`, `mobile/lib/core/ui/`, `mobile/lib/features/*/presentation/`, widget/accessibility tests y reporte de prueba de campo.
  - **Descripción técnica**: Revisar copy español latinoamericano, prohibir imperial/Fahrenheit, semantic labels, target táctil, contraste, texto+icono+count sync, keyboard/focus/errors, bright-light/one-hand, map textual alternatives y no-clear-input; no rediseñar ni añadir pantallas fuera de contrato.
  - **Criterios de aceptación**: Usuario prueba identifica estados <5 s; 90 % completa flujos SC-001/002/011 sin ayuda; ningún control esencial solo color/icono sin label; todas las unidades correctas.
  - **Pruebas necesarias**: Semantics/widget, text/unit scan, contrast/touch review, user task sessions and Android font scaling.
  - **Terminado cuando**: NFR-006/007/008/010 y métricas de comprensión/usabilidad tienen evidencia.

- [ ] T052 Ejecutar matriz final de 54 FR, 11 NFR, 12 SC y gates constitucionales en `mobile/integration_test/`, `supabase/tests/` y reporte de aceptación
  - **Sprint**: 7.
  - **Prioridad**: Crítica.
  - **Dependencias**: T047, T048, T049, T050, T051.
  - **Objetivo**: Demostrar el MVP completo y detectar cualquier contradicción o pendiente antes de release.
  - **Archivos o módulos afectados**: `mobile/integration_test/`, `supabase/tests/`, `specs/001-agrocampo-mvp/evidence/acceptance-report.md`, scripts/fixtures de prueba.
  - **Descripción técnica**: Matriz requisito→task→test→resultado; 24h offline/3 restarts; 100 sync ops; conflicts; mapa tiles outage; soil/riego; history/production/apiary/photos; reminders/FCM/Gemini/XLSX; API24/current; low storage/permissions/providers down; revisar exclusiones.
  - **Criterios de aceptación**: Cada requisito tiene evidencia pass o blocker; cero placeholder/waiver implícito; ninguna función fuera de scope; constitución/spec/model/contracts concuerdan con comportamiento.
  - **Pruebas necesarias**: Suites unit/widget/integration/pgTAP/function/performance/manual-device y acceptance report reproducible.
  - **Terminado cuando**: Todos los blockers están resueltos y el propietario aprueba la matriz, incluida regla agronómica.

- [ ] T053 Preparar, firmar y validar el release candidate Android en `mobile/android/`, configuración CI/CD y documentación de entrega
  - **Sprint**: 7.
  - **Prioridad**: Crítica.
  - **Dependencias**: T052.
  - **Objetivo**: Producir un APK/AAB staging/prod verificable sin secretos y con configuración/avisos legales correctos.
  - **Archivos o módulos afectados**: `mobile/android/`, pipeline CI/CD, `mobile/config/`, notas/release checklist, artefactos de firma fuera del repo.
  - **Descripción técnica**: Build release Android-only; signing seguro; min/target API; shrink/obfuscation si compatible; Maps/Firebase/Supabase environments; legal attribution/weather/Gemini disclaimer; versioning; install/upgrade from prior RC; checksum; rollback and distribution record.
  - **Criterios de aceptación**: APK/AAB instala/actualiza en API24/current, usa prod endpoints, no contiene secret/debug config, pasa smoke offline/online y cumple checklist constitucional.
  - **Pruebas necesarias**: `flutter analyze/test/integration`, release build, install/upgrade, APK secret scan, startup/auth/sync/map/notification/export smoke and signature verification.
  - **Terminado cuando**: Artefacto firmado y evidencia T052 están aprobados; no se genera ni publica iOS.

---

## Dependencies & Execution Order

### Sprint/phase dependencies

```text
Sprint 1 Setup (T001-T003)
  -> Sprint 1 Foundation (T004-T007)
  -> Sprint 2 Sync vertical + Parcelas (T008-T014)
  -> Sprint 3 Campo/Mapa/Sectores/Cultivos (T015-T021)
  -> Sprint 4 LABORES/Suelo/Riego/Historial inicial (T022-T031)
  -> Sprint 5 Producción/Apicultura/Fotos (T032-T040)
  -> Sprint 6 Recordatorios/FCM/Gemini/XLSX (T041-T046)
  -> Sprint 7 Hardening/Release (T047-T053)
```

No sprint may start while the prior sprint's critical gate task is incomplete: T007, T014, T021,
T029/T030/T031, T038/T039/T040, T046 and T052 respectively.

### User story dependency graph

```text
Foundation
  -> US3 Sync/backup (P1) enables every synchronized story
  -> US1 Organize field (P1)
       -> US2 Register labors offline (P1)
            -> US4 Plan/document irrigation (P2)
            -> US5 History/production (P2)
            -> US7 Apiary (P3)
            -> US6 Photos/reminders/export/advisory (P2)
  -> Sprint 7 cross-cutting validation
```

The dependencies reflect domain prerequisites, not scope expansion. Each story retains the
independent test stated in its sprint and can be demonstrated without future modules.

### Task counts by story

| Story | Tasks | IDs |
|---|---:|---|
| US1 - Organizar el campo | 9 | T012-T013, T015-T021 |
| US2 - Registrar labores sin conexión | 4 | T022-T024, T029 |
| US3 - Respaldar y recuperar información | 5 | T008-T011, T014 |
| US4 - Planificar y documentar riego | 4 | T025-T027, T030 |
| US5 - Consultar producción e historial | 5 | T028, T031-T033, T038 |
| US6 - Complementar y compartir registros | 10 | T035-T037, T040-T046 |
| US7 - Gestionar sector apícola | 2 | T034, T039 |
| Setup/foundation/polish | 14 | T001-T007, T047-T053 |
| **Total** | **53** | T001-T053 |

## Parallel Opportunities

- **Sprint 1**: After T001, T003, T004 and T006 can proceed in parallel; T002 is independent of
  database/backend work after scaffold.
- **US3/Sprint 2**: T008 local protocol and T009 remote protocol run in parallel; T012 parcel schema
  can run beside them, then converge in T010-T014.
- **US1/Sprint 3**: T015 geometry and T017 search proxy can run in parallel; after T015, T016 map and
  T018 sector persistence can run in parallel; T020 crop work can overlap T019 UI after T018.
- **US2/US4/Sprint 4**: After T022, T023 soil and T024 riego run in parallel; T025 calculator and
  T026 weather adapter also run in parallel before T027.
- **Sprint 5**: T032 production, T034 apiary and T035 photo intake use different files and can start
  together after Sprint 4 gate; their test gates remain separate.
- **US6/Sprint 6**: T041 reminders, T043 Gemini and T044 XLSX can run in parallel after their listed
  dependencies; FCM follows reminder persistence.
- **Sprint 7**: T048 migrations, T049 performance, T050 security and T051 accessibility can run in
  parallel after Sprint 6, then converge at T052.

## Parallel Execution Examples

### User Story 1

```text
Parallel batch A: T015 geometry | T017 place-search proxy
Parallel batch B after T015: T016 map/GPS | T018 sector persistence
Parallel batch C after T018: T019 sector UI | T020 crop assignments
Converge: T021 independent US1 gate
```

### User Story 2

```text
Sequential base: T022 LABORES aggregate
Parallel after T022: T023 soil | T024 irrigation record
Converge: T029 independent US2 gate
```

### User Story 3

```text
Parallel: T008 local outbox/lease | T009 remote RPC/feed
Sequential converge: T010 coordinator -> T011 conflicts -> T014 fault gate
```

### User Story 4

```text
Parallel: T025 deterministic rules/calculator | T026 weather proxy/cache
Converge with T024: T027 recommendation handoff -> T030 independent gate
```

### User Story 5

```text
Sprint 4 slice: T028 initial history -> T031 filter gate
Sprint 5 completion: T032 production -> T033 complete history -> T038 independent gate
```

### User Story 6

```text
Photo slice: T035 local intake -> T036 private upload -> T037 UI -> T040 gate
Parallel Sprint 6: T041 local reminders | T043 Gemini proxy | T044 XLSX
Then T042 FCM after T041; converge at T045-T046
```

### User Story 7

```text
T034 apiary aggregate can run beside production/photo intake.
T039 validates apiary after T037 makes optional photo association available.
```

## Implementation Strategy

### First demonstrable MVP slice

1. Complete Sprint 1 setup/foundation.
2. Complete Sprint 2 sync vertical and parcel slice.
3. Complete Sprint 3 and validate US1 independently at T021.
4. Stop and demo: authenticated farmer creates multiple parcels/sectors/crops offline and later
   backs them up without loss.

This is the earliest useful architecture/product slice. It is not the complete AgroCampo MVP;
product release still requires Sprints 4-7.

### Incremental delivery

1. **Sprints 1-3**: Reliable farm structure and synchronization.
2. **Sprint 4**: Primary field recording and irrigation value.
3. **Sprint 5**: Productive history, apiary and photographic evidence.
4. **Sprint 6**: Reminders, remote delivery, consultative assistance and data portability.
5. **Sprint 7**: Release-quality evidence and Android artifact.

At each checkpoint, demonstrate only completed stories and preserve all prior tests. A failed
migration, RLS, sync-integrity or irrigation-rule test blocks subsequent feature work.

## Backlog execution rules

- Work task IDs in dependency order; `[P]` only authorizes parallel work after its listed
  dependencies are complete.
- A story label maps directly to the numbered user story in `spec.md`; setup and final polish have
  no story label by design.
- Do not reinterpret a task to introduce excluded functionality. If an artifact conflicts with the
  constitution, stop and amend/specify before coding.
- Each task must leave its tests and migration evidence in the named paths; verbal confirmation is
  insufficient.
- Critical writes must always remain local-first and transactional with outbox.
- Critical calculations remain deterministic Dart; Gemini stays isolated and consultative.
- Commit after a complete task or coherent task pair, never with a failing critical gate.
