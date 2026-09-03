---

description: "Tareas simplificadas y ordenadas para implementar AgroCampo Functional Core - Módulo 002"
---

# Tasks: AgroCampo Functional Core - Módulo 002

**Fuentes**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/`, Constitución 2.0.0, `master.md` y código actual del repositorio.

**Criterio de simplificación**: cada tarea debe producir código funcional o una prueba crítica. Las variantes pequeñas que comparten flujo/archivo se agrupan; los resultados normales se informan en el chat de implementación y no generan reportes `evidence/*.md`.

**Formato**: `- [ ] T### [P?] [US?] Acción concreta en archivo(s); resultado verificable`.

- `[P]` se usa solo para trabajos sobre archivos distintos y sin dependencia pendiente.
- `[USn]` mantiene trazabilidad con las nueve historias de `spec.md`; la Fase 8 es transversal y no lleva etiqueta.
- Toda tarea de interfaz o navegación debe seguir `master.md`.
- La existencia de código parecido no completa ninguna tarea: todas comienzan pendientes.

---

## Fase 1 — Sesión, persistencia y sincronización (US1 P1 + US7 P2, bloqueante)

**Objetivo**: restaurar y bloquear sesiones correctamente, aislar al propietario, migrar Drift v9→v10 sin pérdida y demostrar Sync v2 con ACK real para `parcel` antes de habilitar otras entidades.

**Prueba independiente**: iniciar sesión, cerrar/reabrir offline, desbloquear opcionalmente con biometría, guardar una parcela en Drift persistente, perder el primer ACK, reintentar contra Supabase local y observar una sola fila remota; logout debe impedir acceso local sin borrar pendientes.

### Regresiones y Drift v10

- [X] T001 [P] [US1] Consolidar regresiones de restauración sin token válido, reapertura offline del mismo propietario, logout durable y aislamiento entre propietarios en `test/features/auth/session_controller_test.dart`; comprobar que los defectos actuales quedan reproducidos antes de corregirlos.
- [X] T002 [P] [US7] Consolidar regresiones de falso ACK, respuesta parcial, payload inválido, cursor adelantado y recuperación de `sending` estancado en `test/core/sync/sync_contract_test.dart`; exigir que ninguna operación se marque sincronizada sin resultado remoto individual.
- [X] T003 [P] [US7] Crear el helper Drift con archivo temporal y una fixture v9 poblada en `test/helpers/file_backed_database.dart` y `test/fixtures/database/functional_core_v9.dart`; demostrar cierre/reapertura con datos de las 24 tablas y outbox pendiente.
- [X] T004 [US7] Generar el snapshot real de esquema v9 bajo `drift_schemas/` y alinear `lib/core/database/migrations/migration_policy.dart` con la versión 9; verificar que las herramientas Drift cargan el snapshot sin manifest manual divergente.
- [X] T005 [US7] Extender las tablas Drift en `lib/core/database/tables/technical_tables.dart`, `territory_tables.dart`, `labor_tables.dart`, `irrigation_estimate_table.dart`, `production_table.dart`, `media_reminder_tables.dart` y `external_service_tables.dart` con Sync v2, temporadas y configuración de riego; conservar las 24 tablas y terminar con exactamente 26.
- [X] T006 [US7] Implementar la migración transaccional v9→v10, índices y backfill determinista en `lib/core/database/app_database.dart` y `lib/core/database/migrations/functional_core_v10.dart`; preservar IDs, geometrías, fechas, relaciones y operaciones outbox no finalizadas, con rollback completo ante error.
- [X] T007 [US7] Regenerar `lib/core/database/app_database.g.dart` y DAO generados, y completar pruebas de upgrade/rollback/reapertura desde la fixture v9 en `test/core/database/migrations/functional_core_v10_test.dart`; comparar conteos y valores críticos sin usar `NativeDatabase.memory()` como evidencia.

### Sesión, propietario y biometría

- [X] T008 [P] [US1] Añadir `local_auth: 3.0.2` en `pubspec.yaml` y adaptar `android/app/src/main/kotlin/cl/agrocampo/app/MainActivity.kt`, `android/app/src/main/AndroidManifest.xml` y temas Android para `FlutterFragmentActivity`/biometría sin romper el MethodChannel XLSX; verificar build Android.
- [X] T009 [US1] Exponer un único `SupabaseClient?` creado en bootstrap mediante `lib/app/bootstrap/app_bootstrap.dart` y `lib/app/providers.dart`, y eliminar accesos directos `Supabase.instance.client` de los flujos 002; verificar cliente compartido y estado explícito cuando falta environment.
- [X] T010 [US1] Extender `lib/core/auth/secure_session_store.dart` para guardar material de sesión válido, propietario y opt-in biométrico, limpiando credenciales/opt-in en logout; cubrir round-trip y borrado en `test/core/auth/secure_session_store_test.dart`.
- [X] T011 [US1] Corregir `lib/features/auth/domain/session_state.dart` y `lib/features/auth/presentation/session_controller.dart` con estados restoring/locked/signed-in/offline/signed-out, restauración basada en sesión recuperable y detención segura de sync en logout; hacer pasar T001.
- [X] T012 [US1] Aislar DB, providers, consultas y workers por propietario desbloqueado en `lib/app/providers.dart` y `lib/core/database/app_database.dart`; permitir reabrir pendientes del mismo propietario y negar cualquier lectura del anterior.
- [X] T013 [US1] Implementar el adaptador mínimo de `local_auth` en `lib/core/auth/biometric_unlock_gateway.dart` con resultados disponible/no configurado/cancelado/fallido/bloqueado; probar en `test/core/auth/biometric_unlock_gateway_test.dart` que solo desbloquea una sesión Supabase previa.
- [X] T014 [US1] Integrar habilitar/deshabilitar biometría, pantalla bloqueada, fallback y logout en `lib/features/auth/presentation/login_page.dart` y `lib/features/profile/presentation/profile_page.dart`, siguiendo `master.md`; cancelación biométrica debe mantener la app bloqueada.
- [X] T015 [US1] Ajustar redirects y refresh de rutas privadas en `lib/app/routing/app_router.dart`, siguiendo las ramas de `master.md`; ampliar `test/app/router_test.dart` para impedir render privado en estado locked/signed-out.
- [ ] T016 [US1] Completar `integration_test/session_persistence_flow_test.dart` con reapertura real, trabajo offline, logout, re-login del mismo propietario y cambio de propietario, y ejecutar biometría éxito/cancelación/no disponible en Android API 24+; informar resultados en el chat de implementación.

### Sync v2 y corte real de `parcel`

- [X] T017 [US7] Reemplazar el contrato de IDs reconocidos por DTOs Sync v2 y un registro de codecs allowlist en `lib/core/sync/protocol/sync_contract.dart`, `aggregate_sync_codec.dart`, `aggregate_sync_registry.dart` y `parcel_sync_codec.dart`; habilitar inicialmente solo `parcel` con payloads JSON versionados.
- [X] T018 [US7] Completar la máquina durable del outbox en `lib/core/database/daos/sync_outbox_dao.dart`: pending/sending/done/retry_wait/blocked/conflict, dependencias, recuperación de intentos, tombstones y cancelación create+delete nunca respaldada; cubrir transiciones en `test/core/database/sync_outbox_dao_test.dart`.
- [X] T019 [US7] Rehacer `lib/core/sync/protocol/supabase_sync_gateway.dart` para enviar JSON estructurado y exigir exactamente un resultado validado por operación, además de páginas pull ordenadas; hacer que respuestas faltantes o malformadas no reconozcan nada.
- [X] T020 [US7] Refactorizar `lib/core/sync/sync_coordinator.dart` para aplicar estados outbox, codecs y resultados individuales, y persistir cada página pull junto con su cursor en una sola transacción; abortar ante entidades/versiones desconocidas sin avanzar cursor.
- [X] T021 [P] [US7] Implementar clasificación de errores y backoff exponencial con jitter/server delay en `lib/core/sync/sync_retry_policy.dart`, con pruebas deterministas en `test/core/sync/sync_retry_policy_test.dart`; retry manual solo debe reactivar errores reintentables.
- [X] T022 [US7] Adaptar `lib/core/sync/conflicts/conflict_resolver.dart` y `lib/core/database/daos/conflict_dao.dart` a snapshots codecados y operaciones keep-local/keep-remote; mantener el conflicto abierto hasta recibir ACK real de la resolución.
- [X] T023 [US7] Crear la migración append-only `supabase/migrations/0012_functional_core_schema.sql` con cambios 002, dos tablas nuevas, backfill, índices, FKs, versiones/tombstones y RLS; verificar aplicación completa de 0001–0012 sin editar migraciones anteriores.
- [X] T024 [US7] Crear `supabase/migrations/0013_sync_protocol_v2.sql` con receipts idempotentes por owner/operation/hash, resultados por operación, versionado y handler exclusivo de `parcel`; entidades no soportadas deben responder rejected sin receipt exitoso.
- [X] T025 [US7] Implementar pgTAP de esquema/RLS y protocolo parcel en `supabase/tests/database/functional_core_schema_test.sql` y `sync_protocol_v2_test.sql`; cubrir applied/duplicate/conflict/rejected, ACK perdido, tombstone, pull ordenado y propietarios distintos.
- [X] T026 [US7] Corregir `lib/features/parcels/data/parcel_repository.dart` para que create/update/archive/delete escriban entidad y outbox completo en una transacción, con versiones/tombstone y rollback; hacer pasar `test/features/parcels/parcel_repository_test.dart`.
- [X] T027 [US7] Integrar un disparador coalescente en `lib/core/sync/sync_trigger_coordinator.dart`, `lib/core/sync/sync_scheduler.dart`, `lib/core/network/connectivity_service.dart` y bootstrap; coordinar save/resume/conectividad/manual/WorkManager sin ciclos concurrentes y cancelar trabajo al hacer logout.
- [X] T028 [US7] Exponer pendientes, retry, error, conflicto, progreso y último ACK en `lib/features/sync_status/presentation/sync_status_page.dart` y providers, siguiendo estados texto+icono de `master.md`; incluir retry manual y prueba widget en `test/features/sync_status/sync_status_page_test.dart`.
- [X] T029 [US7] Completar pruebas integradas de gateway/coordinator/outbox en `test/core/sync/supabase_sync_gateway_test.dart`, `test/core/sync/sync_contract_test.dart` e `integration_test/synchronization_test.dart`; cubrir respuesta parcial, dependencia, backoff, cursor rollback, tombstone y ambas resoluciones de conflicto.
- [X] T030 [US7] Implementar el corte E2E real en `integration_test/parcel_sync_v2_e2e_test.dart` usando Drift con archivo y Supabase local: guardar/reabrir, perder ACK, reintentar y descargar a una segunda DB; exigir una fila remota y estado local truthful antes de continuar.

**Checkpoint**: sesión, aislamiento, Drift v10 y Sync v2 `parcel` funcionan. Ningún codec adicional puede habilitarse antes de T030.

---

## Fase 2 — Territorio y contexto agrícola (US2 P1)

**Objetivo**: manejar múltiples parcelas/sectores, persistir una parcela activa y crear/ver/editar polígonos estables con GPS, mapa o fallback local.

**Prueba independiente**: crear tres parcelas y varios sectores offline, cambiar contexto, reiniciar, confirmar/cancelar edición geométrica y sincronizar sin mezclar propietarios, parcelas ni sectores; repetir con mapa/GPS no disponibles.

- [X] T031 [P] [US2] Consolidar pruebas críticas de contexto múltiple y geometría inválida en `test/features/context/agricultural_context_controller_test.dart` y `test/core/geometry/polygon_geometry_test.dart`; cubrir padres archivados, nombres repetidos, autocruce, área cero y coordenadas fuera de rango.
- [X] T032 [US2] Implementar `AgriculturalContext`, `AgriculturalContextController` y persistencia tipada de activeParcel/sector/season/assignment/revision en `lib/features/context/domain/agricultural_context.dart`, `lib/features/context/presentation/agricultural_context_controller.dart` y `lib/core/database/daos/app_preferences_dao.dart`; validar relaciones al restaurar.
- [X] T033 [US2] Conectar contexto e IDs ligados a ruta en `lib/app/providers.dart` y `lib/app/routing/app_router.dart`, siguiendo `master.md`; un formulario abierto debe conservar su contexto o pedir rebind explícito tras cambiar la parcela global.
- [X] T034 [US2] Crear el selector visible y accesible parcela/sector en `lib/shared/presentation/components/agricultural_context_selector.dart`, siguiendo `master.md`; añadir prueba semántica en `test/shared/agricultural_context_selector_test.dart` y nunca mostrar IDs como etiquetas.
- [X] T035 [US2] Completar CRUD/archivo/restauración, parcela activa y formularios con datos existentes en `lib/features/parcels/data/parcel_repository.dart`, `parcel_list_page.dart` y `parcel_form_page.dart`, siguiendo `master.md`; tras reinicio debe existir una sola parcela activa no archivada.
- [X] T036 [US2] Completar CRUD, consultas por parcela, geometría versionada y outbox atómico en `lib/features/sectors/data/sector_repository.dart`; ampliar `test/features/sectors/sector_repository_test.dart` con rollback, ownership y múltiples sectores.
- [X] T037 [US2] Sustituir supuestos owner-wide `getSingleOrNull()` por el contexto/selector explícito en `lib/features/labors/presentation/labor_form_page.dart`, `irrigation_record_page.dart`, `production_page.dart`, `soil_measurement_page.dart`, `photo_attachment_page.dart` y `apiary_inspection_page.dart`, manteniendo `master.md`; ningún flujo debe autoseleccionar ambiguamente.
- [X] T038 [US2] Extender `lib/core/geometry/polygon_geometry.dart` con normalización WGS84, duplicados, autocruce, contención y área estable; integrar las mismas reglas en `sector_repository.dart` y hacer pasar T031 sin mutar geometría fuera de edición explícita.
- [X] T039 [P] [US2] Normalizar permisos/servicio/precisión GPS en `lib/features/map/data/location_gateway.dart` y su configuración Android en `android/app/src/main/AndroidManifest.xml`; probar disponible/denegado/deshabilitado en `test/features/map/location_gateway_test.dart` y conservar dibujo manual.
- [X] T040 [US2] Completar `lib/features/map/presentation/territory_map_page.dart` y `lib/features/map/domain/sector_geometry_draft.dart` para renderizar polígonos Drift con `flutter_map`/OpenStreetMap, seleccionar sectores y editar un borrador con add/move/remove/undo/confirm/cancel, siguiendo `master.md`; mantener geometría local accesible si fallan las teselas.
- [X] T041 [US2] Cubrir 30 overlays persistidos, view-mode inmutable, confirm/cancel, fallback y cinco reaperturas en `test/features/map/territory_map_page_test.dart`, `test/features/map/territory_persistence_flow_test.dart` e `integration_test/territory_flow_test.dart`; fake renderer solo vale para UI, no para persistencia.
- [X] T042 [US2] Completar listas/detalle de sectores y navegación normal en `lib/features/sectors/presentation/sector_list_page.dart` y `sector_detail_page.dart`, siguiendo `master.md`; filtrar por parcela activa y mostrar contexto/cultivo/estado desde Drift.
- [X] T043 [US2] Añadir `sector` al registro Sync v2 mediante `lib/core/sync/protocol/sector_sync_codec.dart` y completar geometría/archive/delete en `parcel_sync_codec.dart`; probar dependencia parcel→sector y tombstones en `test/core/sync/territory_sync_codec_test.dart`.
- [X] T044 [US2] Crear `supabase/migrations/0014_sync_territory_handlers.sql` y pgTAP en `supabase/tests/database/territory_sync_v2_test.sql` para parcel/sector CRUD, PostGIS, RLS, dependencias, idempotencia y pull; habilitar codec solo al pasar el contrato.
- [X] T045 [US2] Cerrar `integration_test/territory_flow_test.dart` con Drift persistente y Supabase local para múltiples parcelas/sectores, reinicio, edición/cancelación, fallback y sync exact-once; ejecutar permisos/GPS en Android cuando corresponda.

**Checkpoint**: territorio múltiple es utilizable offline, alcanzable por navegación normal y sincronizable sin contaminar contextos.

---

## Fase 3 — Temporadas y cultivos (US3 P1)

**Objetivo**: gestionar temporadas, catálogo oficial/personalizado y asignaciones temporales, rotaciones e intercambios sin destruir historial.

**Prueba independiente**: crear dos temporadas y un cultivo personalizado offline, asignar/rotar/intercambiar dos sectores, reiniciar y sincronizar conservando IDs y rangos históricos.

- [X] T046 [US3] Consolidar pruebas de transiciones de temporada, catálogo combinado, solapamientos, rotación futura e intercambio atómico en `test/features/crops/agricultural_season_test.dart`, `crop_repository_test.dart` y `crop_rotation_test.dart`; incluir backfill de `crop_seasons` legado.
- [X] T047 [US3] Crear modelos y validadores `AgriculturalSeason`, `SectorCropAssignment` y `CropRef` en `lib/features/crops/domain/`, manteniendo `crop_seasons` como tabla física; impedir solapamientos y escrituras incompatibles con temporada cerrada.
- [X] T048 [US3] Implementar repositorio y UI de temporadas en `lib/features/crops/data/agricultural_season_repository.dart`, `presentation/agricultural_seasons_page.dart` y `agricultural_season_form_page.dart`, siguiendo `master.md`; exponer rutas desde sector y permitir planned/active/closed por parcela.
- [X] T049 [US3] Extender `lib/features/crops/data/crop_repository.dart` para combinar catálogo oficial inmutable con cultivos personalizados CRUD/archive y outbox; conservar personalizados ya referenciados y hacer pasar casos de unicidad normalizada.
- [X] T050 [US3] Completar búsqueda, detalle oficial y alta/edición/archivo personalizado en `lib/features/crops/presentation/crop_catalog_page.dart`, siguiendo `master.md`; probar catálogo mixto y estado offline en `test/features/crops/crop_catalog_page_test.dart`.
- [X] T051 [US3] Implementar consultas indexadas de asignación activa/planificada/por temporada en `lib/features/crops/data/sector_crop_assignment_repository.dart`; resolver etiqueta histórica y devolver como máximo una asignación por sector/fecha.
- [X] T052 [US3] Refactorizar planificar/activar/cancelar rotación en `lib/features/crops/data/crop_repository.dart` para cerrar/crear asignaciones en la fecha efectiva indicada y encolar payloads completos; nunca sustituirla por `DateTime.now()`.
- [X] T053 [US3] Implementar intercambio de cultivos all-or-nothing en `lib/features/crops/data/crop_exchange_repository.dart`; terminar ambas asignaciones previas e iniciar ambas nuevas en el mismo instante o no cambiar nada.
- [X] T054 [US3] Reconciliar asignaciones planificadas vencidas al unlock/resume en `lib/features/crops/data/crop_assignment_reconciler.dart` y `lib/app/bootstrap/app_bootstrap.dart`; una rotación futura nunca debe aparecer vigente antes de fecha.
- [X] T055 [US3] Completar UI de planificar/cancelar/activar/intercambiar en `lib/features/crops/presentation/rotation_page.dart`, siguiendo `master.md`; distinguir “Vigente” y “Planificado para…” y mantener contexto sector/temporada.
- [X] T056 [US3] Añadir codecs `agriculturalSeason`, `sectorCropAssignment` y `customCrop` en `lib/core/sync/protocol/aggregate_sync_registry.dart` y archivos dedicados bajo `lib/core/sync/protocol/`; probar dependencias, conflictos y tombstones en `test/core/sync/seasons_crops_sync_codec_test.dart`.
- [X] T057 [US3] Crear `supabase/migrations/0015_sync_seasons_crops_handlers.sql` y `supabase/tests/database/seasons_crops_sync_v2_test.sql` para CRUD/archive, no-overlap, intercambio, ownership, idempotencia y pull; habilitar codecs tras pgTAP.
- [X] T058 [US3] Implementar `integration_test/seasons_crops_flow_test.dart` con Drift persistente y Supabase local: temporadas, cultivo oficial/personalizado, una matriz de 20 rotaciones/intercambios, reinicio y segunda DB; verificar que labores/producción/riego previos conservan referencias históricas.

**Checkpoint**: cada sector puede cambiar de cultivo por temporada sin perder trazabilidad previa.

---

## Fase 4 — Labores estructuradas y producción (US4 P1)

**Objetivo**: registrar las siete labores con contexto estable y `detailsJson` versionado; cosecha y producción forman un agregado atómico y un solo evento histórico.

**Prueba independiente**: guardar offline riego, fertilización, fitosanitario, siembra, poda, cosecha y otra labor en sectores distintos, reiniciar y sincronizar; cosecha debe aparecer una sola vez con producción asociada.

- [X] T059 [US4] Consolidar pruebas de envelope versionado, campos obligatorios y unidades de los siete tipos en `test/features/labors/labor_details_test.dart` y `labor_repository_test.dart`; conservar versiones desconocidas de `detailsJson` sin perder el registro.
- [X] T060 [US4] Implementar `LaborDetails` versionado y modelos base de riego/cosecha en `lib/features/labors/domain/labor_details.dart`, `irrigation_labor_details.dart` y `harvest_details.dart`; mantener compatibilidad con `HarvestInput` y futura especialización de goteo.
- [X] T061 [P] [US4] Implementar validadores estructurados de fertilización y fitosanitarios en `lib/features/labors/domain/fertilization_details.dart` y `phytosanitary_details.dart`, con pruebas focales en `test/features/labors/agrochemical_details_test.dart`.
- [X] T062 [P] [US4] Implementar validadores de siembra, poda y otra labor en `lib/features/labors/domain/sowing_details.dart`, `pruning_details.dart` y `other_labor_details.dart`, con pruebas focales en `test/features/labors/cultural_labor_details_test.dart`.
- [X] T063 [US4] Extender `lib/features/labors/data/labor_repository.dart` para exigir parcel/sector/season/assignment, validar detalles, guardar estado/fecha/contexto y encolar payload completo en una transacción; cubrir rollback y doble submit.
- [X] T064 [US4] Añadir corrección/void mediante `supersedesLaborId` en `lib/features/labors/data/labor_repository.dart`; advertir si cambió la asignación desde la fecha original y no reasignar historial silenciosamente.
- [X] T065 [US4] Reorganizar el estado común de `lib/features/labors/presentation/labor_form_page.dart` alrededor del contexto ligado, fecha/hora, tipo, draft y feedback local/pending, siguiendo `master.md`; conservar valores ante navegación o error recuperable.
- [X] T066 [US4] Implementar en `labor_form_page.dart` los paneles específicos de fertilización, fitosanitarios, siembra, poda y otra labor usando T061/T062, siguiendo `master.md`; solicitar solo campos pertinentes con validación inline.
- [X] T067 [US4] Mantener el registro básico de riego alcanzable desde `labor_form_page.dart` y enlazar el mismo contexto a `lib/features/irrigation/presentation/irrigation_record_page.dart`, siguiendo `master.md`; no duplicar cálculo ni estado.
- [X] T068 [US4] Refactorizar `lib/features/production/data/production_repository.dart` para guardar labor cosecha + producción + un solo outbox agregado en una transacción; eliminar el evento/outbox duplicado y cubrir rollback en `test/features/production/production_repository_test.dart`.
- [X] T069 [US4] Vincular `lib/features/production/presentation/production_page.dart` a contexto parcel/sector/season/crop de solo lectura y unidades válidas, siguiendo `master.md`; eliminar cultivo libre y sector implícito.
- [X] T070 [US4] Completar una única suite widget/semántica para los siete tipos, preservación de campos y estados local/pending/error en `test/features/labors/labor_form_page_test.dart`, siguiendo `master.md`; evitar pruebas separadas redundantes por variante mínima.
- [X] T071 [US4] Implementar codec compuesto `labor` en `lib/core/sync/protocol/labor_sync_codec.dart` para raíz y especializaciones producción/riego, y registrarlo en `aggregate_sync_registry.dart`; probar conflicto, corrección, tombstone e idempotencia.
- [X] T072 [US4] Crear `supabase/migrations/0016_sync_labor_handlers.sql` y `supabase/tests/database/labor_sync_v2_test.sql` para aplicar/pullar agregados labor+producción atómicos con RLS y versiones; habilitar handler tras pgTAP.
- [X] T073 [US4] Implementar `integration_test/labors_production_flow_test.dart` con Drift persistente y Supabase local para los siete tipos, reinicio, corrección y sync; exigir una labor de cosecha, una producción relacionada y una sola tarjeta histórica.

**Checkpoint**: el agricultor puede registrar trabajo diario y producción offline con contexto y sincronización confiables.

---

## Fase 5 — Riego por goteo (US5 P2)

**Objetivo**: guardar configuración permanente por sector, calcular localmente con reglas aprobadas y registrar un snapshot histórico; ningún otro método recibe motor de recomendación.

**Prueba independiente**: guardar configuración offline, reiniciar, repetir un vector aprobado con iguales enteros —o mostrar `crop_rule_unavailable`—, registrar el riego, cambiar configuración y comprobar que el snapshot previo no cambia al sincronizar.

- [X] T074 [US5] Consolidar tests críticos de configuración, engine, redondeo y gate agronómico en `test/features/irrigation/sector_irrigation_config_test.dart`, `irrigation_calculator_test.dart` y `irrigation_rule_approval_test.dart`; exigir fuente/revisor/fecha/rangos y 20 vectores o estado unavailable.
- [X] T075 [US5] Implementar configuración por sector versionada/vigente y outbox en `lib/features/irrigation/domain/sector_irrigation_config.dart` y `data/sector_irrigation_config_repository.dart`; no sobrescribir versiones ya usadas por registros.
- [X] T076 [US5] Crear formulario/vista de configuración permanente en `lib/features/irrigation/presentation/drip_configuration_page.dart` y rutas desde sector/riego, siguiendo `master.md`; validar plantas, goteros/distribución, caudal y parámetros aprobados.
- [X] T077 [US5] Corregir `lib/features/irrigation/data/irrigation_estimate_repository.dart` para resolver asignación/cultivo/configuración/regla reales en la fecha del evento; eliminar `cropId: 'unassigned'` y devolver estado explícito sin regla aprobada.
- [X] T078 [US5] Adaptar el motor puro en `lib/features/irrigation/domain/irrigation_calculator.dart` y `irrigation_rule_set.dart` al contrato `contracts/irrigation-drip-v2.md`; usar enteros/unidades/ceil definidos, implementar solo `drip` y reproducir vectores exactamente.
- [X] T079 [P] [US5] Generar explicación y advertencias deterministas desde hechos del cálculo en `lib/features/irrigation/domain/irrigation_explanation.dart`, con pruebas en `test/features/irrigation/irrigation_explanation_test.dart`; Gemini y texto climático no participan.
- [X] T080 [US5] Refactorizar `lib/features/irrigation/data/irrigation_repository.dart` para guardar labor raíz + registro + estimación válida + snapshot de configuración/input/resultado + un outbox compuesto en una transacción; cubrir rollback y doble submit.
- [X] T081 [US5] Completar `lib/features/irrigation/presentation/irrigation_record_page.dart` con contexto, configuración vigente, inputs drip, volumen/tiempo/explicación y warnings de regla/clima, siguiendo `master.md`; no añadir recomendación para aspersión, surco o gravedad.
- [X] T082 [US5] Añadir pruebas file-backed de cálculo/reapertura/snapshot inmutable y estados UI disponibles/no disponibles en `test/features/irrigation/irrigation_snapshot_persistence_test.dart` y `test/features/irrigation/irrigation_record_page_test.dart`, siguiendo `master.md`.
- [X] T083 [US5] Implementar codecs `irrigationConfig` y riego compuesto en `lib/core/sync/protocol/irrigation_sync_codec.dart` y `aggregate_sync_registry.dart`; probar dependencias, snapshot, conflicto y tombstone en `test/core/sync/irrigation_sync_codec_test.dart`.
- [X] T084 [US5] Crear `supabase/migrations/0017_sync_irrigation_handlers.sql` y `supabase/tests/database/irrigation_sync_v2_test.sql` para versiones de configuración y agregado riego apply/duplicate/pull/conflict/RLS; habilitar después de pgTAP.
- [X] T085 [US5] Completar `integration_test/irrigation_calculation_flow_test.dart` con Drift persistente y Supabase local para configuración, reinicio, vector repetido, no-weather/unavailable, registro y snapshot histórico; afirmar que solo `drip` implementa recomendaciones.

**Checkpoint**: riego por goteo queda configurable, calculable cuando existe aprobación y registrable siempre sin depender de red o IA.

---

## Fase 6 — Historial sectorial (US6 P2)

**Objetivo**: ofrecer timeline local por sector/temporada con filtros, etiquetas históricas y estado sync, sin duplicar cosecha ni riego.

**Prueba independiente**: crear eventos en dos sectores/temporadas, reiniciar, filtrar offline y comprobar orden/etiquetas/estado; cosecha y riego deben producir una tarjeta cada uno.

- [X] T086 [US6] Extender `lib/features/history/domain/history_event.dart` y pruebas en `test/features/history/history_event_test.dart` con etiquetas de temporada/cultivo, detalle, grouping key, sync state y desempate estable; las especializaciones no crean un segundo evento.
- [X] T087 [US6] Implementar consultas Drift indexadas por owner/sector/temporada/tipo/fecha en `lib/features/history/data/sector_history_dao.dart` y ajustar índices en `lib/core/database/migrations/functional_core_v10.dart`; cubrir orden, aislamiento y estados con DB file-backed.
- [X] T088 [US6] Refactorizar `lib/features/history/data/history_repository.dart` para stream/paginación desde T087 y resolución por FK histórico, no escaneos completos en Dart; hacer pasar `test/features/history/history_repository_test.dart` sin duplicar producción/riego.
- [X] T089 [US6] Completar `lib/features/history/presentation/history_page.dart` con cabecera de sector, grupos por temporada, filtros, estados sync y vacíos diferenciados, siguiendo `master.md`; mantener legibilidad y acciones normales offline.
- [X] T090 [US6] Ligar rutas de historial desde sector y Más al contexto explícito en `lib/app/routing/app_router.dart`, `sector_detail_page.dart` y `more_page.dart`, siguiendo `master.md`; back debe volver al origen lógico.
- [X] T091 [US6] Consolidar widget/semántica para timeline poblado, vacío, filtrado, pending y conflict en `test/features/history/history_page_test.dart`, siguiendo `master.md`; evitar goldens repetidos si la prueba semántica cubre el estado.
- [X] T092 [US6] Completar `integration_test/history_production_flow_test.dart` con Drift persistente, dos temporadas, rotación, riego/cosecha, reinicio, filtros y cambio de estado tras sync; validar tiempos de consulta representativos sin convertir un benchmark grande en gate.

**Checkpoint**: historial es una proyección fiel, filtrable y rápida de los registros locales del sector.

---

## Fase 7 — Recordatorios, Open-Meteo y AgroIA (US8/US9 P3)

**Objetivo**: programar recordatorios offline, degradar clima/alertas con caché y ofrecer AgroIA general sin leer datos privados ni ejecutar cambios.

**Pruebas independientes**:

- US8: crear/editar/completar/cancelar recordatorio offline, reiniciar/reconciliar notificación y probar clima fresh/stale/unavailable sin bloquear trabajo local.
- US9: capturar request, fallar/reintentar tras reinicio y demostrar un mensaje/una respuesta sin parcela, sector, historial ni producción.

### Recordatorios y clima

- [X] T093 [P] [US8] Consolidar una matriz de 30 recordatorios para CRUD, ID Android estable, scheduling/reconcile y tres reaperturas file-backed en `test/features/reminders/reminder_repository_test.dart`, `test/core/notifications/local_notification_scheduler_test.dart` e `integration_test/reminder_restart_flow_test.dart`.
- [X] T094 [US8] Extender `lib/features/reminders/domain/reminder.dart` y `data/reminder_repository.dart` con contexto, status, binding estable, edit/complete/cancel y entidad+outbox transaccional; fallo o permiso denegado de notificación no debe perder el recordatorio.
- [X] T095 [US8] Implementar ID determinista y reconciliación al bootstrap/unlock/resume/timezone en `lib/core/notifications/local_notification_scheduler.dart`, `reminder_reconciler.dart` y `lib/app/bootstrap/app_bootstrap.dart`; reprogramar futuros y cancelar finalizados.
- [ ] T096 [US8] Completar configuración de reboot/notificaciones en `android/app/src/main/AndroidManifest.xml` sin solicitar exact alarms, y ejecutar permiso, programación, reboot y zona horaria en Android; registrar el resultado en el chat.
- [X] T097 [US8] Reemplazar el placeholder +1 hora por lista/formulario real en `lib/features/reminders/presentation/reminders_page.dart`, siguiendo `master.md`; permitir fecha/hora, editar/completar/cancelar, contexto y estados offline/permiso.
- [X] T098 [US8] Implementar codec y handler remoto de `reminder` en `lib/core/sync/protocol/reminder_sync_codec.dart`, `supabase/migrations/0018_sync_reminder_handler.sql` y `supabase/tests/database/reminder_sync_v2_test.sql`; excluir bindings locales y sincronizar status/tombstone idempotentemente.
- [X] T099 [US8] Completar `integration_test/reminder_restart_flow_test.dart` con 30 guardados offline, tres reinicios, reconciliación y sync Supabase; verificar que el dominio persiste aunque el plugin no pueda programar.
- [X] T100 [P] [US8] Consolidar contrato Open-Meteo normalizado en `test/features/weather/weather_gateway_contract_test.dart` y `supabase/functions/weather-proxy/tests/weather_contract_test.ts`; cubrir current/forecast, timestamps, attribution, malformed y fallo proveedor sin inventar alertas oficiales.
- [X] T101 [US8] Extender `supabase/functions/weather-proxy/index.ts` para leer coordenada de respaldo/endpoint desde environment y normalizar current/forecast sin exponer configuración ni payload; hacer pasar T100.
- [X] T102 [US8] Extender `lib/features/weather/domain/weather_snapshot.dart`, `data/weather_gateway.dart` y `weather_repository.dart` para cliente inyectado, caché normalizada y estados fresh/stale/unavailable; un fallo no borra el último snapshot.
- [X] T103 [US8] Implementar deduplicación/opt-in de alertas y UI de fecha/atribución/forecast/warning en `lib/features/weather/data/weather_alert_service.dart`, `presentation/weather_summary_card.dart` y `profile_page.dart`, siguiendo `master.md`; clima nunca oculta acciones locales.
- [X] T104 [US8] Completar `integration_test/weather_alert_flow_test.dart` con caché file-backed, respuesta contractual, transición fresh→stale→offline y deduplicación de alerta; no cerrar con mocks de repositorio solamente.

### AgroIA general

- [X] T105 [P] [US9] Consolidar pruebas de privacidad, estados y retry idempotente en `test/features/agro_ai/agro_ai_repository_test.dart` y `supabase/functions/agro-ai/tests/prompt_eval_test.ts`; el payload solo puede contener ID estable, texto del usuario, locale y metadata de política.
- [X] T106 [US9] Extender `lib/features/agro_ai/domain/agro_ai_message.dart` y `data/agro_ai_repository.dart` con draft/sending/sent/error, clientMessageId y reply relation; reintentar debe actualizar el mismo mensaje y almacenar como máximo una respuesta.
- [X] T107 [US9] Actualizar `lib/features/agro_ai/data/agro_ai_gateway.dart`, `supabase/functions/agro-ai/index.ts` y `prompt.ts` para cliente inyectado, credencial/modelo solo server-side, request mínimo y rechazo de acciones/cálculos/tools; nunca consultar tablas agrícolas.
- [X] T108 [US9] Completar `lib/features/agro_ai/presentation/agro_ai_page.dart` con estados offline/sending/error/retry y disclaimer consultivo, siguiendo `master.md`; eliminar contexto automático privado y cualquier ejecución de comandos.
- [X] T109 [US9] Implementar `integration_test/agro_ai_privacy_flow_test.dart` con mensajes file-backed y request capturado para fallo, reinicio y retry; exigir una pregunta/una respuesta y ausencia de datos privados.

**Checkpoint**: recordatorios funcionan offline; Open-Meteo y AgroIA son capacidades opcionales y degradables que no alteran datos agrícolas.

---

## Fase 8 — Validación final y compatibilidad

**Objetivo**: comprobar el módulo completo con escenarios reproducibles y proporcionales, sin crear documentación de evidencia repetida.

- [X] T110 [P] Ejecutar un escenario reproducible de 100 mutaciones 002 offline y múltiples cierres/reaperturas en `integration_test/functional_core_offline_restart_test.dart`; exigir cero pérdida y outbox durable, reemplazando cualquier espera literal de 24 horas.
- [X] T111 [P] Ejecutar conflictos simples, ACK perdido y create-delete/tombstone para agregados sincronizables en `integration_test/sync_conflict_tombstone_e2e_test.dart`; verificar que no haya falso synced, duplicados ni resurrecciones.
- [X] T112 [P] Reejecutar upgrade v9→v10 poblado, backfill y rollback inyectado en `test/core/database/migrations/functional_core_v10_test.dart` y `supabase/tests/database/functional_core_schema_test.sql`; comparar conteos/IDs/valores durante la implementación.
- [X] T113 [P] Ejecutar logout durante sync, reapertura del mismo propietario y cambio de propietario en `integration_test/session_sync_isolation_e2e_test.dart`; negar UI, query y worker privados tras logout sin borrar pendientes.
- [X] T114 [P] Ejecutar la matriz de tres parcelas y diez sectores por parcela a través de mapa, temporadas, labores, riego e historial en `integration_test/multi_context_e2e_test.dart`, siguiendo `master.md`; cada FK y etiqueta debe corresponder al contexto seleccionado.
- [ ] T115 [P] Ejecutar en Android API 24+ biometría, GPS denegado/deshabilitado, mapa, notificaciones/reboot/timezone y WorkManager usando `integration_test/android_platform_flow_test.dart`; los ensayos físicos de dos dispositivos quedan como validación opcional, no gate.
- [X] T116 [P] Ejecutar consultas e outbox con 20 parcelas, 200 sectores y 10.000 eventos en `test/performance/functional_core_performance_test.dart`; mantener p95 de consultas comunes bajo 2 s.
- [X] T117 [P] Ejecutar regresión de suelo, fotos, apicultura, XLSX y riego record-only en `integration_test/001_compatibility_regression_test.dart`, además de `agrocampo-acceptance.test.js`; corregir solo regresiones causadas por infraestructura compartida 002.
- [ ] T118 Ejecutar format/analyze/tests Flutter, integration tests seleccionados, Supabase pgTAP, Edge Function tests, auditoría de secretos/scope y revisión UI contra `master.md` según `specs/002-agrocampo-functional-core/quickstart.md`; entregar resultados finales en el chat y no crear una colección de reportes `evidence/*.md`.

**Checkpoint final**: el módulo 002 se considera completo solo si no hay pérdida silenciosa, falso ACK, contaminación de contexto, ruptura 001 ni funcionalidad excluida.

---

## Dependencias y orden de ejecución

```text
Fase 1: sesión + Drift v10 + Sync v2 parcel
    ↓ gate T030
Fase 2: territorio/contexto + sector sync
    ↓
Fase 3: temporadas/cultivos/asignaciones
    ↓
Fase 4: labores/producción
    ↓
Fase 5: riego por goteo
    ↓
Fase 6: historial
    ↓
Fase 7: recordatorios/clima/AgroIA
    ↓
Fase 8: validación transversal
```

- La Fase 1 bloquea todos los demás handlers de sync.
- La Fase 2 entrega el contexto explícito requerido por formularios posteriores.
- La Fase 3 entrega temporada/asignación histórica para labores, riego e historial.
- La Fase 4 entrega la raíz labor que especializan producción y riego.
- La Fase 5 completa riego drip; la Fase 6 proyecta todos los eventos anteriores.
- En Fase 7, recordatorios/clima (US8) y AgroIA (US9) pueden implementarse en paralelo una vez estabilizada la base.

### Trazabilidad por historia

| Historia | Tareas | Resultado demostrable |
|---|---:|---|
| US1 Sesión/biometría | T001, T008–T016 | Reapertura segura, unlock opcional y logout durable. |
| US2 Territorio/contexto | T031–T045 | Múltiples parcelas/sectores y polígonos estables offline. |
| US3 Temporadas/cultivos | T046–T058 | Catálogo mixto, rotación/intercambio e historial preservado. |
| US4 Labores/producción | T059–T073 | Siete labores y cosecha+producción atómica. |
| US5 Riego drip | T074–T085 | Configuración, cálculo aprobado/unavailable y snapshot. |
| US6 Historial | T086–T092 | Timeline filtrable sin eventos duplicados. |
| US7 Sync confiable | T002–T007, T017–T030 y codecs posteriores | Drift→outbox→Supabase→ACK real. |
| US8 Recordatorios/clima | T093–T104 | Scheduling offline y clima fresh/stale/unavailable. |
| US9 AgroIA | T105–T109 | Chat general, privado e idempotente. |

## Oportunidades paralelas

- Inicio de Fase 1: T001, T002, T003 y T008 modifican áreas distintas.
- Tras estabilizar Drift/contrato: T013 (biometría) y T021 (retry policy) pueden avanzar separados.
- Fase 2: pruebas T031 y gateway GPS T039 son independientes.
- Fase 4: T061 y T062 separan modelos de detalles sin tocar el mismo archivo.
- Fase 5: T079 puede avanzar cuando el contrato de resultado de T078 esté fijado.
- Fase 7: T093, T100 y T105 pertenecen a integraciones distintas.
- Fase 8: T110–T117 pueden ejecutarse en paralelo sobre una implementación estable; T118 consolida el cierre.

## Estrategia de implementación

### Primer hito técnico

Completar T001–T030 y detenerse para validar el corte `parcel`. Esta fase elimina el riesgo de construir pantallas sobre sesión insegura, migración no preservadora o falso ACK.

### Primer incremento agrícola utilizable

Completar Fases 1–4. El usuario ya puede entrar, administrar territorio, rotar cultivos y registrar labores/producción offline con backup confiable.

### Entrega incremental

1. Fase 5 añade riego por goteo determinista sin ampliar métodos.
2. Fase 6 vuelve consultables los registros por sector/temporada.
3. Fase 7 añade capacidades opcionales sin convertirlas en dependencias del núcleo.
4. Fase 8 valida el conjunto con escenarios reproducibles y resultados comunicados en el chat.

## Notas

- Reutilizar y corregir código existente; crear archivos solo para conceptos ausentes.
- No introducir web/admin, roles, organizaciones, MFA, IoT, fertilidad calculada, IA contextual ni riegos avanzados.
- No editar migraciones Supabase 0001–0011.
- Mocks/fakes sirven para límites unitarios, pero no cierran migración, persistencia/reinicio ni ACK remoto.
- Cada checkpoint debe dejar una app más funcional y demostrable antes de iniciar la fase siguiente.
