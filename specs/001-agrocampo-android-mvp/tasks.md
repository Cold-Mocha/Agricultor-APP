# Tasks: AgroCampo Android MVP — Módulo funcional único

**Feature canónica**: `specs/001-agrocampo-android-mvp/`  
**Autoridad funcional**: [spec.md](./spec.md)  
**Autoridad técnica**: [plan.md](./plan.md), [research.md](./research.md), [data-model.md](./data-model.md) y [contracts/](./contracts/)  
**Autoridad visual exclusiva**: [master.md](../../master.md)

## Reglas de ejecución

- Ejecutar las tareas en orden salvo las marcadas `[P]`; ninguna dependencia implícita autoriza adelantar una fase.
- T001 y T002 son gates documentales bloqueantes; no generan código y deben cerrarse antes del componente afectado.
- Toda tarea UI/UX cita una sección exacta de `master.md`; si falta una regla visual, detener esa tarea y actualizar/aprobar el Design System.
- Pruebas listadas antes de una implementación deben fallar por la razón esperada antes de hacerlas pasar.
- Ninguna pantalla lee Supabase directamente: Drift es la única fuente operativa de la UI.
- No implementar iOS, trabajadores, roles, ERP, inventario avanzado, facturación, panel web inicial, IoT obligatorio, automatización física ni IA autónoma/fotográfica.

## Phase 1: Gates y setup

- [X] T001 Aprobar arquitectura de motor configurable sin coeficientes inventados en `specs/001-agrocampo-android-mvp/contracts/irrigation-calculation.md`; ninguna recomendación se activa hasta registrar clasificación de suelo, coeficientes, límites, fuentes y veinte vectores validados
- [X] T002 Cerrar proveedor Open-Meteo, política de endpoint server-side, retención, caché y atribución en `specs/001-agrocampo-android-mvp/research.md`, `contracts/external-services.md` y `master.md`
- [X] T003 Fijar Flutter 3.47.0/Dart 3.13.0, dependencias compatibles, identidad y SDK Android en `pubspec.yaml`, `pubspec.lock`, `android/app/build.gradle.kts` y `android/app/src/main/AndroidManifest.xml`
- [X] T004 Crear la estructura feature-first y bootstrap mínimo en `lib/main.dart`, `lib/app/`, `lib/core/`, `lib/features/`, `lib/shared/`, `test/`, `integration_test/` y `drift_schemas/`
- [X] T005 [P] Implementar configuración tipada por ambiente y política de secretos en `lib/app/bootstrap/app_environment.dart`, `lib/core/network/runtime_config.dart`, `supabase/config.toml` y `.gitignore`
- [X] T006 [P] Registrar Inter, pictogramas oficiales, Physalis, Apicultura y activo genérico de cultivo propio en `pubspec.yaml`, `assets/fonts/inter/`, `assets/icons/crops/` y `lib/app/theme/asset_catalog.dart` según `master.md` → **Color System / Colores de cultivo** e **Iconography**
- [X] T007 [P] Configurar generación, análisis y convenciones de prueba en `analysis_options.yaml`, `build.yaml`, `test/helpers/`, `integration_test/` y `quickstart.md`

## Phase 2: Foundational — bloqueos compartidos

- [X] T008 Implementar ThemeData Material 3 y tokens en `lib/app/theme/` según `master.md` → **Color System**, **Typography**, **Spacing**, **Shape**, **Elevation**, **Motion** y **Layout**
- [X] T009 Implementar componentes/semántica compartidos en `lib/shared/presentation/components/` y `lib/shared/presentation/semantics/` según `master.md` → **Component System**, **States** y **Accessibility**
- [X] T010 Implementar shell/router restaurable de cinco ramas en `lib/app/routing/` y `lib/app/shell/agro_app_shell.dart` según `master.md` → **Navigation**
- [X] T011 [P] Implementar bootstrap, errores tipados, conectividad y observabilidad segura en `lib/app/bootstrap/app_bootstrap.dart`, `lib/core/errors/`, `lib/core/network/` y `lib/core/observability/`
- [X] T012 Implementar AppDatabase, migraciones y tablas técnicas locales en `lib/core/database/`, `lib/core/database/migrations/` y `drift_schemas/`
- [X] T013 Implementar sesión segura, espacio local por propietario, perfil y RLS base en `lib/core/auth/`, `lib/features/auth/`, `lib/features/profile/`, `supabase/migrations/0001_auth_profile_rls.sql` y `supabase/tests/database/auth_rls_test.sql`
- [X] T014 Implementar Acceso y Perfil en `lib/features/auth/presentation/`, `lib/features/profile/presentation/` y router según `master.md` → **Screens / Acceso** y **Screens / Perfil**
- [X] T015 Implementar primitivas local-first y transacción agregado+outbox en `lib/core/sync/outbox/`, `lib/core/sync/sync_state.dart`, `lib/core/database/daos/sync_outbox_dao.dart` y `lib/shared/domain/`
- [X] T016 Crear el gate fundacional de pruebas en `test/app/`, `test/core/`, `test/shared/design_policy_test.dart`, `test/shared/component_semantics_test.dart` y `test/helpers/`

## Phase 3: User Story 3 — corte vertical de respaldo y conflictos (Priority: P1)

**Independent Test**: guardar cambios de una parcela offline, reiniciar, sincronizar cien operaciones con ACK perdido y resolver un conflicto sin pérdida ni duplicados.

- [X] T017 [P] [US3] Escribir pruebas contractuales y pgTAP del corte Parcel+sync en `test/core/sync/sync_contract_test.dart` y `supabase/tests/database/sync_protocol_test.sql`
- [X] T018 [US3] Implementar el mínimo agregado Parcel local/remoto con RLS, repositorio y outbox en `lib/features/parcels/`, `lib/core/database/tables/parcel_table.dart` y `supabase/migrations/0002_parcel_sync_slice.sql`
- [X] T019 [US3] Implementar tablas server-only y RPC idempotente push/pull en `supabase/migrations/0003_sync_protocol.sql`
- [X] T020 [US3] Implementar DTOs, gateway, cursor y coordinador push/pull en `lib/core/sync/protocol/`, `lib/core/sync/sync_gateway.dart`, `lib/core/sync/sync_coordinator.dart` y `lib/core/database/daos/sync_cursor_dao.dart`
- [X] T021 [P] [US3] Integrar triggers, backoff, WorkManager y renovación de sesión en `lib/core/sync/sync_scheduler.dart`, `lib/core/sync/worker/`, `android/app/src/main/AndroidManifest.xml` y bootstrap
- [X] T022 [US3] Implementar persistencia y casos de uso de conflictos en `lib/core/sync/conflicts/` y `lib/core/database/daos/conflict_dao.dart`
- [X] T023 [US3] Implementar estado global/por registro y pantalla de sincronización en `lib/features/sync_status/presentation/` según `master.md` → **Screens / Sincronización y conflictos**
- [X] T024 [US3] Implementar comparación/resolución visual de conflictos en `lib/features/sync_status/presentation/conflict_resolution_page.dart` según `master.md` → **Screens / Sincronización y conflictos**
- [X] T025 [US3] Ejecutar resiliencia e independencia de US3 en `integration_test/synchronization_test.dart`, fixtures Supabase y `test/golden/us3/` según `master.md` → **Offline UX** y **Screens / Sincronización y conflictos**

## Phase 4: User Story 1 — parcelas, sectores, cultivos y mapa (Priority: P1) 🎯 MVP territorial

**Independent Test**: crear/editar/eliminar o archivar parcelas, delimitar sectores, usar catálogo oficial/propio y planificar una rotación offline sin cambiar el cultivo vigente.

- [X] T026 [P] [US1] Escribir pruebas de entidades, restricciones, RLS, repositorios y geometría territorial en `test/features/parcels/`, `test/features/sectors/`, `test/features/crops/` y `test/core/geometry/`
- [X] T027 [P] [US1] Completar tablas/DAOs Drift de parcelas, sectores, catálogo oficial/propio, temporadas y asignaciones planificadas en `lib/core/database/tables/territory_tables.dart` y `lib/features/*/data/`
- [X] T028 [P] [US1] Crear migración Supabase/PostGIS, índices, RLS y transiciones territoriales en `supabase/migrations/0004_territory.sql` y `supabase/tests/database/territory_rls_test.sql`
- [X] T029 [P] [US1] Sembrar catálogo oficial y mapear pictogramas/activo genérico en `assets/data/crop_catalog_v1.json`, `supabase/seed.sql` y `lib/features/crops/data/crop_seed_loader.dart` según `master.md` → **Color System / Colores de cultivo** e **Iconography**
- [X] T030 [P] [US1] Implementar geometría determinista, renderizado `flutter_map`/OpenStreetMap y adapters GPS/Places en `lib/core/geometry/`, `lib/features/map/data/` y `android/app/src/main/kotlin/`
- [X] T031 [US1] Implementar casos de uso de parcela activa, CRUD, eliminación sin dependencias y archivo/restauración en `lib/features/parcels/domain/` y `lib/features/parcels/data/`
- [X] T032 [US1] Implementar sectores, contención, superficie y numeración única en `lib/features/sectors/domain/` y `lib/features/sectors/data/`
- [X] T033 [US1] Implementar catálogo propio, ficha agrícola y rotación `planned|active|ended|cancelled` en `lib/features/crops/domain/` y `lib/features/crops/data/`
- [X] T034 [US1] Implementar Inicio, lista/selección y formulario de parcelas en `lib/features/home/presentation/` y `lib/features/parcels/presentation/` según `master.md` → **Screens / Inicio** y **Screens / Parcelas**
- [X] T035 [US1] Implementar Sectores, Mapa y Detalle en `lib/features/sectors/presentation/` y `lib/features/map/presentation/` según `master.md` → **Screens / Sectores**, **Mapa** y **Detalle sector**
- [X] T036 [US1] Implementar Catálogo/ficha, Cambiar cultivo y Rotación futura en `lib/features/crops/presentation/` según `master.md` → **Screens / Catálogo y ficha de cultivo**, **Cambiar cultivo** y **Rotación futura**
- [X] T037 [US1] Completar flujo independiente y goldens US1 en `integration_test/territory_flow_test.dart` y `test/golden/us1/` según `master.md` → **Screens / Inicio**, **Parcelas**, **Sectores**, **Mapa**, **Detalle sector**, **Catálogo y ficha de cultivo**, **Cambiar cultivo** y **Rotación futura**

## Phase 5: User Story 2 — registrar LABORES offline (Priority: P1)

**Independent Test**: registrar/reiniciar offline una labor especializada, una “Otra labor”, una medición de suelo y un riego básico con tipo de suelo.

- [X] T038 [P] [US2] Escribir pruebas de dominio/persistencia para LABORES, Otra labor, suelo y riego básico en `test/features/labors/`, `test/features/soil/` y `test/features/irrigation/basic_record_test.dart`
- [X] T039 [P] [US2] Implementar tablas, DAOs y migración local/remota de LABORES, Otra labor, suelo y riego/tipo de suelo en `lib/core/database/tables/labor_tables.dart`, `lib/features/*/data/` y `supabase/migrations/0005_labors_soil_irrigation.sql`
- [X] T040 [US2] Implementar repositorios, comandos atómicos y borradores recuperables en `lib/features/labors/domain/`, `lib/features/labors/data/`, `lib/features/soil/domain/`, `lib/features/irrigation/domain/` y `lib/core/database/daos/form_draft_dao.dart`
- [X] T041 [US2] Implementar selector/formulario LABORES con todos los tipos y “Otra labor” en `lib/features/labors/presentation/` según `master.md` → **Screens / Registrar actividad**
- [X] T042 [P] [US2] Implementar formulario manual de suelo en `lib/features/soil/presentation/` según `master.md` → **Screens / Medición de suelo**
- [X] T043 [P] [US2] Implementar registro de riego básico con tipo de suelo en `lib/features/irrigation/presentation/irrigation_record_page.dart` según `master.md` → **Screens / Riego**
- [X] T044 [US2] Completar prueba offline/reinicio y goldens US2 en `integration_test/critical_offline_flows_test.dart` y `test/golden/us2/` contra `master.md` → **Registrar actividad**, **Medición de suelo** y **Riego**

## Phase 6: User Story 4 — cálculo y registro de riego (Priority: P2)

**Independent Test**: sin reglas aprobadas, obtener siempre `crop_rule_unavailable`; al incorporar
una regla validada, ejecutar dos veces sus veinte vectores offline y obtener mismos litros/tiempo,
regla, tipo de suelo y advertencias.

- [X] T045 [P] [US4] Convertir vectores T001 en pruebas de cálculo/persistencia en `test/fixtures/irrigation/`, `test/features/irrigation/irrigation_calculator_test.dart` y `irrigation_estimate_repository_test.dart`
- [X] T046 [US4] Implementar reglas versionadas y fuente aprobada en `lib/features/irrigation/domain/irrigation_rule_set.dart`, `lib/core/database/tables/crop_irrigation_rule_table.dart` y `supabase/migrations/0006_irrigation_rules.sql`
- [X] T047 [US4] Implementar motor v1 con enteros escalados, tipo de suelo, límites y redondeo contractual en `lib/features/irrigation/domain/irrigation_calculator.dart`
- [X] T048 [US4] Persistir estimación y riego con regla/inputs/resultados como agregado en `lib/core/database/tables/irrigation_estimate_table.dart` y `lib/features/irrigation/data/`
- [X] T049 [US4] Integrar calculadora, explicación, clima opcional y confirmación en `lib/features/irrigation/presentation/` según `master.md` → **Screens / Riego**
- [X] T050 [US4] Completar prueba independiente/golden US4 en `integration_test/irrigation_calculation_flow_test.dart` y `test/golden/us4/` contra `master.md` → **Screens / Riego**

## Phase 7: User Story 5 — historial y producción (Priority: P2)

**Independent Test**: filtrar registros de dos parcelas/temporadas y guardar una cosecha trazable apta para comparativas futuras.

- [X] T051 [P] [US5] Escribir pruebas de historial, filtros, rotaciones y producción en `test/features/history/` y `test/features/production/`
- [X] T052 [P] [US5] Implementar producción local/remota e índices de historial en `lib/core/database/tables/production_table.dart`, `lib/features/production/data/` y `supabase/migrations/0007_production_history.sql`
- [X] T053 [US5] Implementar proyección/repositorio de historial con cultivos vigentes/planificados/históricos en `lib/features/history/data/history_repository.dart`, `lib/features/history/domain/` y DAOs de consulta
- [X] T054 [US5] Implementar caso de uso/repository de cosecha y temporada en `lib/features/production/domain/` y `lib/features/production/data/production_repository.dart`
- [X] T055 [US5] Implementar Historial y Producción en `lib/features/history/presentation/` y `lib/features/production/presentation/` según `master.md` → **Screens / Historial** y **Producción**
- [X] T056 [US5] Completar prueba independiente/goldens US5 en `integration_test/history_production_flow_test.dart` y `test/golden/us5/` según `master.md` → **Screens / Historial** y **Producción**

## Phase 8: User Story 6 — fotografías y recordatorios (Priority: P2)

**Independent Test**: adjuntar foto y programar recordatorio offline; reiniciar, recibir aviso local y sincronizar sin duplicados.

- [X] T057 [P] [US6] Escribir pruebas del ciclo fotográfico y Storage RLS en `test/features/photos/` y `supabase/tests/database/photo_storage_rls_test.sql`
- [X] T058 [US6] Implementar metadata, archivo privado, hash y upload idempotente en `lib/core/files/`, `lib/features/photos/data/`, `lib/features/photos/domain/` y `supabase/migrations/0008_photos_storage.sql`
- [X] T059 [US6] Implementar cámara/galería, preview y adjuntos en `lib/features/photos/presentation/` según `master.md` → **Screens / Fotografías**
- [X] T060 [P] [US6] Escribir pruebas de recordatorios, scheduler y FCM en `test/features/reminders/`, `test/core/notifications/` y `supabase/tests/database/device_installations_rls_test.sql`
- [X] T061 [US6] Implementar recordatorios y aviso local en `lib/features/reminders/domain/`, `lib/features/reminders/data/`, `lib/core/notifications/local_notification_scheduler.dart` y `supabase/migrations/0009_reminders.sql`
- [X] T062 [US6] Implementar lista/formulario/permiso de recordatorios en `lib/features/reminders/presentation/` según `master.md` → **Screens / Recordatorios**
- [X] T063 [US6] Implementar instalaciones FCM, envío y deep links seguros en `supabase/functions/notification-dispatch/`, `supabase/migrations/0010_device_installations.sql`, `lib/core/notifications/fcm_gateway.dart` y router
- [X] T064 [US6] Completar prueba independiente/goldens US6 en `integration_test/photos_reminders_flow_test.dart` y `test/golden/us6/` contra `master.md` → **Fotografías** y **Recordatorios**

## Phase 9: User Story 7 — apicultura (Priority: P3)

**Independent Test**: guardar offline una revisión con tipo de tarea, apicultor descriptivo, colmenas, postura, sanidad, alimentación, reina, alza y fotografía.

- [X] T065 [P] [US7] Escribir pruebas de revisión apícola/tipo de tarea y RLS en `test/features/apiary/` y `supabase/tests/database/apiary_rls_test.sql`
- [X] T066 [P] [US7] Implementar tabla y migración apícola local/remota en `lib/core/database/tables/apiary_inspection_table.dart`, `lib/features/apiary/data/` y `supabase/migrations/0011_apiary.sql`
- [X] T067 [US7] Implementar caso de uso/repository de inspección apícola en `lib/features/apiary/domain/` y `lib/features/apiary/data/apiary_repository.dart`
- [X] T068 [US7] Implementar formulario/detalle apícola en `lib/features/apiary/presentation/` y sector detail según `master.md` → **Screens / Revisión apícola** y **Detalle sector**
- [X] T069 [US7] Completar prueba independiente/goldens US7 en `integration_test/apiary_flow_test.dart` y `test/golden/us7/` según `master.md` → **Screens / Revisión apícola** y **Detalle sector**

## Phase 10: User Story 8 — clima, AgroIA y XLSX (Priority: P3)

**Independent Test**: degradar clima/AgroIA por separado y generar offline un XLSX íntegro con datos pendientes y relaciones válidas.

- [X] T070 [P] [US8] Escribir contract tests de clima tras T002 en `test/features/weather/weather_gateway_contract_test.dart` y `supabase/functions/weather-proxy/tests/`
- [X] T071 [US8] Implementar weather-proxy, gateway, caché y repositorio en `supabase/functions/weather-proxy/`, `lib/features/weather/data/`, `lib/features/weather/domain/` y DAO `weather_cache`
- [X] T072 [US8] Integrar clima y estados en Inicio en `lib/features/weather/presentation/` y `lib/features/home/presentation/home_page.dart` según `master.md` → **Screens / Inicio**
- [X] T073 [P] [US8] Escribir pruebas/evals de AgroIA consultiva en `test/features/agro_ai/` y `supabase/functions/agro-ai/tests/`
- [X] T074 [US8] Implementar Edge Function Gemini, gateway y conversación local en `supabase/functions/agro-ai/`, `lib/features/agro_ai/data/`, `lib/features/agro_ai/domain/` y DAOs AI
- [X] T075 [US8] Implementar conversación AgroIA en `lib/features/agro_ai/presentation/` según `master.md` → **Screens / AgroIA**
- [X] T076 [P] [US8] Escribir pruebas contractuales XLSX v1 en `test/features/export/xlsx_contract_test.dart` y `test/fixtures/export/`
- [X] T077 [US8] Implementar snapshot/exporter XLSX y SAF Android en `lib/core/export/`, `lib/features/export/data/`, `android/app/src/main/kotlin/` y DAO `export_snapshot`
- [X] T078 [US8] Implementar Exportar y cerrar integración/goldens US8 en `lib/features/export/presentation/`, `integration_test/weather_ai_export_flow_test.dart` y `test/golden/us8/` según `master.md` → **Screens / Más**, **Exportar**, **Inicio** y **AgroIA**

## Phase 11: Polish y release

- [X] T079 Ejecutar auditoría visual/accesible integral en `test/golden/`, `test/shared/design_policy_test.dart` y `docs/verification/design-system-report.md` contra todas las pantallas de `master.md` → **Screens**, **Accessibility**, **Responsive Behavior** y **Implementation Checklist**
- [X] T080 [P] Optimizar consultas, frames y trabajos pesados en `lib/core/database/`, `lib/core/geometry/`, `lib/core/export/`, `lib/features/history/` y `test/performance/`
- [X] T081 [P] Ejecutar hardening de seguridad, RLS, Storage, Functions y logs en `supabase/tests/database/`, `supabase/functions/`, `lib/core/auth/`, `lib/core/observability/` y `docs/verification/security-report.md`
- [X] T082 Validar migraciones, upgrade, recuperación y resiliencia completa en `drift_schemas/`, `supabase/migrations/`, `integration_test/resilience_upgrade_test.dart` y `docs/verification/resilience-report.md`
- [X] T083 Auditar dependencias, licencias, contratos externos y exclusiones en `pubspec.lock`, `android/`, `docs/verification/dependency-scope-report.md` y artefactos canónicos
- [X] T084 Completar evidencia de esta matriz de trazabilidad y aceptación en `specs/001-agrocampo-android-mvp/checklists/acceptance-traceability.md` y `docs/verification/acceptance-report.md`
- [X] T085 Generar release Android y cerrar verificaciones en `android/`, `README.md`, `docs/verification/release-checklist.md` y artefactos AAB/APK no versionados

## Dependencies & Execution Order

```text
T001 agronomía ───────────────────────────────┐
T002 Weather ─────────────────────────────┐   │
Phase 1 setup -> Phase 2 foundation -> US3 Parcel+sync vertical -> US1 territory -> US2 LABORES
                                             │                         │
                                             ├-> US5 history/production│
                                             ├-> US6 photos/reminders  ├-> US4 irrigation (also T001)
                                             ├-> US7 apiary            └-> US8 context/export (Weather also T002)
                                             └-> US8 weather/AI/export
All completed stories -> Phase 11 hardening/release
```

- US3 precedes the full territorial UI because Offline First is constitutional and must be proven on a real aggregate.
- US1 extends the already-proven Parcel slice; it does not replace the sync protocol.
- US4 cannot start T045 until T001 is approved; Weather implementation T070 cannot start until T002.
- US5, US6 and US7 may run in parallel after their listed shared dependencies and US2 aggregate contracts exist.

## Parallel Opportunities

- Setup: T005, T006 and T007 after T003/T004.
- US1: T026-T030 use distinct test/schema/geometry/assets paths before converging on T031-T036.
- US2: T042 and T043 after T039/T040; T038 is test-first.
- US5/US6/US7 can use separate feature/schema files after US2 and sync contracts are stable.
- Within US8, Weather (T070-T072), AgroIA (T073-T075) and XLSX (T076-T077) converge at T078.
- Polish T080 and T081 are parallel after all story gates; T082-T085 remain sequential closure.

## Matriz de trazabilidad funcional (baseline 100 %)

| Requisito | Especificación | Tareas | Prueba/evidencia prevista |
|---|---|---|---|
| FR-001–FR-004 | CAP-001 Acceso y perfil | T013-T014 | `auth_rls_test.sql`, T016, T025 |
| FR-005–FR-008 | CAP-002 Inicio/contexto activo | T031, T034 | T026, `territory_flow_test.dart` |
| FR-009–FR-013 | CAP-003 Parcelas | T018, T027-T031, T034 | T017, T026, T025, T037 |
| FR-014–FR-019 | CAP-004 Mapa/GPS/geometrías | T026, T028, T030, T035 | `test/core/geometry/`, T037 |
| FR-020–FR-026, FR-086–FR-088 | CAP-005 Sectores/cultivos/temporadas | T027-T029, T032-T033, T035-T036 | T026, `territory_flow_test.dart`, T037 |
| FR-027–FR-031, FR-089 | CAP-006 LABORES | T038-T041 | T038, `critical_offline_flows_test.dart`, T044 |
| FR-032–FR-035 | CAP-007 Suelo | T038-T040, T042 | `test/features/soil/`, T044 |
| FR-036–FR-042, FR-090 | CAP-008 Riego/cálculo | T001, T038-T039, T043, T045-T050 | veinte vectores T001/T045, T050 |
| FR-043–FR-047 | CAP-009 Historial/temporadas | T051, T053, T055 | `test/features/history/`, T056 |
| FR-048–FR-051 | CAP-010 Producción | T051-T052, T054-T055 | `test/features/production/`, T056 |
| FR-052–FR-056 | CAP-011 Fotografías | T057-T059 | `test/features/photos/`, T064 |
| FR-057–FR-060, FR-091 | CAP-012 Apicultura | T065-T068 | `test/features/apiary/`, T069 |
| FR-061–FR-064 | CAP-013 Recordatorios | T060-T063 | `test/features/reminders/`, T064 |
| FR-065–FR-067 | CAP-014 Clima | T002, T070-T072 | weather contract tests, T078 |
| FR-068–FR-072 | CAP-015 AgroIA | T073-T075 | evals/contract tests, T078 |
| FR-073–FR-080 | CAP-016 Offline First/sync | T015, T017-T025 y repositorios de cada historia | T016-T017, T025, T082 |
| FR-081–FR-085 | CAP-017 XLSX | T076-T078 | `xlsx_contract_test.dart`, T078 |
| VR-001–VR-007 | Visual Requirements | T006, T008-T010 y toda tarea UI/golden | `design_policy_test.dart`, T079 |
| UXR-001–UXR-010 | UX Rules | T009-T010 y flujos UI/integración por historia | T025, T037, T044, T050, T056, T064, T069, T078-T079 |
| MR-001–MR-012 | Restricciones MVP | T003, T005, T013, T063, T074, T083 | auditoría alcance/dependencias T083-T084 |
| SC-001–SC-015 | Resultados medibles | Gates independientes de cada historia y T080-T084 | `acceptance-report.md` T084 |

La matriz se considera baseline: T084 no la crea al final, sino que adjunta resultados, versiones,
dispositivos y enlaces de evidencia a cada fila sin cambiar el requisito cubierto.

## Implementation Strategy

1. **Gates y base**: T001-T016.
2. **Primer incremento demostrable**: T017-T025, sincronización real de Parcel antes de ampliar UI.
3. **MVP operacional de terreno**: T026-T044, territorio + LABORES offline.
4. **Valor agrícola ampliado**: T045-T069, riego, historial, producción, fotos, recordatorios y apicultura.
5. **Servicios y portabilidad**: T070-T078.
6. **Calidad de release**: T079-T085.

Una fase no se cierra con pantallas aisladas: requiere su prueba independiente, persistencia local,
reanudación offline, sincronización aplicable y conformidad visual citada.
