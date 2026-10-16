# Tasks: AgroCampo Functional Refinement - Módulo 003

**Input**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md` y Constitución v2.1.0.

**Tests**: Obligatorios. Cada capacidad se implementa y verifica antes de continuar; las pruebas finales son regresión acumulada, no el primer momento en que se prueba una función.

**Organization**: Las tareas están agrupadas por User Story y modifican únicamente los módulos Feature-Based existentes en `/frontend` y `/backend`. No se crea un módulo de código `003`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Puede ejecutarse en paralelo porque usa archivos independientes y sólo depende del contrato público ya congelado.
- **[Story]**: User Story de `spec.md`; Setup, Foundational y cierre no llevan etiqueta de historia.
- Cada descripción comienza con `Backend:`, `Frontend:` o `Integración:` para indicar su carril principal.

## Scope Guard

003 implementa registro manual de riego y la estimación matemática básica de goteo. No implementa recomendación agronómica avanzada, catálogos de etapa/textura, coeficientes, cálculo climático, calculadora económica, IoT, sensores, trabajadores, organizaciones, panel web, conversión histórica `crop ↔ apiary`, `ProductiveUnit`, Google Maps ni recomendaciones químicas automáticas.

T016, T096, T115 y T118 de `specs/002-agrocampo-functional-core/tasks.md` continúan bajo 002. Sólo la dependencia directa documentada en T001 puede provocar una verificación mínima en 003 y esa evidencia no cierra automáticamente la tarea de 002.

## Phase 1: Setup — Baseline y trazabilidad ejecutable

**Purpose**: Fijar la línea base afectada y preparar evidencia sin volver a investigar el producto.

- [X] T001 Integración: Ejecutar G0, identificar por diff y dependencias si 002/T016, 002/T096, 002/T115 o 002/T118 afectan código que 003 modificará y registrar únicamente las verificaciones mínimas aplicables sin cerrar tareas 002 en `docs/verification/003-baseline.md`
- [X] T002 [P] Integración: Crear la matriz de evidencia FR-001..FR-087, SC-001..SC-018, PF-01..PF-30 y G0..G12 con estado inicial pendiente y enlaces a suites concretas en `docs/verification/003-release-matrix.md`

**Checkpoint**: Baseline reproducible y alcance 002/003 separado.

---

## Phase 2: Foundational — Contratos, política y migración mínima

**Purpose**: Congelar tipos públicos y construir los prerrequisitos backend que bloquean todas las historias.

**⚠️ CRITICAL**: Ninguna implementación de User Story comienza antes de completar esta fase.

- [X] T003 Backend: Implementar `CommandId`, `FieldError`, `DomainFailure`, `StorageFailure`, `BackupState` y `SaveOutcome<T>` sin exponer infraestructura en `backend/lib/src/modules/agricultural_context/contracts/dto/save_outcome.dart`
- [X] T004 Backend: Añadir pruebas unitarias de igualdad, datos preservados y estados locales/remotos de los resultados públicos en `backend/test/shared/kernel/save_outcome_test.dart`
- [X] T005 [P] Backend: Implementar `ProductiveCategory`, `ProductiveOperation` y `CompatibilityDecision` con códigos públicos `crop|apiary|legacyUnknown` en `backend/lib/src/modules/agricultural_context/domain/entities/productive_domain.dart`
- [X] T006 Backend: Probar serialización, valores desconocidos legibles y rechazo de mutaciones para las categorías/operaciones públicas en `backend/test/modules/agricultural_context/productive_domain_test.dart`
- [X] T007 Backend: Implementar `DomainCompatibilityPolicy` como autoridad única sobre Sector propietario, categoría, operación y fecha en `backend/lib/src/modules/agricultural_context/domain/services/domain_compatibility_policy.dart`
- [X] T008 Backend: Cubrir la matriz completa operación×categoría, categoría legada, propietario incorrecto y cero cambios parciales en `backend/test/modules/agricultural_context/domain_compatibility_policy_test.dart`
- [X] T009 Backend: Extender el contexto ligado con categoría, etiquetas, capacidades, revisión y fecha de resolución sin fallback de primer Sector y reexportar todos los tipos comunes sólo mediante el API del módulo en `backend/lib/src/modules/agricultural_context/domain/entities/agricultural_context.dart`, `backend/lib/src/modules/agricultural_context/contracts/dto/context_options.dart`, `backend/lib/src/modules/agricultural_context/application/facades/context_options_queries.dart` y `backend/lib/src/modules/agricultural_context/agricultural_context_api.dart`
- [X] T010 Backend: Probar contexto vegetal, apícola y legado; selección ambigua; cambio global con formulario ligado y resolución temporal en `backend/test/modules/agricultural_context/bound_agricultural_context_test.dart`
- [X] T011 [P] Backend: Agregar sólo `labors.domain_category`, `soil_measurements.labor_id` único nullable y `apiary_inspections.labor_id` único nullable en `backend/lib/src/modules/labors/infrastructure/persistence/tables/labors.dart`, `backend/lib/src/modules/soil/infrastructure/persistence/tables/soil_measurements.dart` y `backend/lib/src/modules/apiary/infrastructure/persistence/tables/apiary_inspections.dart`
- [X] T012 Backend: Implementar la migración preservadora v10→v11, backfill sólo demostrable, índices mínimos y política de esquema 11 en `backend/lib/src/platform/database/migrations/functional_refinement_v11.dart`, `backend/lib/src/platform/database/app_database.dart` y `backend/lib/src/platform/database/migrations/migration_policy.dart`
- [X] T013 Backend: Regenerar Drift y los snapshots de esquema v11 en `backend/lib/src/platform/database/app_database.g.dart`, `backend/drift_schemas/drift_schema_v11.json`, `backend/test/generated/migrations/schema_v11.dart` y `backend/test/generated/migrations/schema.dart`
- [X] T014 Backend: Probar v10→v11 con IDs, conteos, geometrías, relaciones, JSON, outbox, cursores, conflictos y `legacyUnknown` preservados en `backend/test/platform/database/migrations/functional_refinement_v11_test.dart`
- [X] T015 Backend: Crear la base append-only de Supabase 0020 con columnas equivalentes, `operation_allowed`, inmutabilidad de `sectors.kind` y su prueba estructural inicial, sin editar 0001–0019, en `backend/supabase/migrations/0020_functional_refinement_v11.sql` y `backend/supabase/tests/database/functional_refinement_v11_test.sql`
- [X] T016 Integración: Reforzar el gate de imports públicos y ausencia de módulo/arquitectura `003` en `tool/check_architecture.dart` y `frontend/test/contracts/backend_public_api_contract_test.dart`

**Checkpoint**: Contratos comunes congelados, política probada y esquema v11 migrable sin pérdida.

---

## Phase 3: User Story 1 — Gestionar áreas según su dominio productivo (Priority: P1) 🎯 MVP

**Goal**: Crear, seleccionar y editar Sectores `crop|apiary` con contexto y geometría persistentes, rechazando operaciones incompatibles en backend.

**Independent Test**: Crear offline un Sector vegetal y otro apícola, confirmar/cancelar geometrías, reabrir y ejecutar solicitudes permitidas/prohibidas sin cambios parciales.

- [X] T017 [US1] Backend: Congelar comandos/resultados públicos de creación y edición territorial, `SectorSummary` tipado y capacidades en `backend/lib/src/modules/territory/contracts/dto/map_contracts.dart`, `backend/lib/src/modules/territory/contracts/dto/sector_summary.dart`, `backend/lib/src/modules/territory/territory_api.dart` y `backend/lib/src/modules/agricultural_context/agricultural_context_api.dart`
- [X] T018 [US1] Backend: Añadir contract tests para categoría obligatoria, categoría inmutable, `expectedVersion`, contexto ligado y outcomes preservadores en `backend/test/contracts/sector_context_territory_contract_test.dart`
- [X] T019 [US1] Backend: Completar validación de cierre explícito, puntos distintos, rango, autocruce, área y contención sin permitir mutar `kind` en `backend/lib/src/modules/territory/domain/entities/sector.dart`, `backend/lib/src/modules/territory/domain/entities/sector_geometry_draft.dart` y `backend/lib/src/modules/territory/domain/value_objects/polygon_geometry.dart`
- [X] T020 [US1] Backend: Ejecutar la matriz unitaria de geometría válida, limítrofe e inválida y estabilidad de categoría en `backend/test/shared/kernel/polygon_geometry_test.dart` y `backend/test/modules/territory/sector_domain_test.dart`
- [X] T021 [US1] Backend: Exigir nombre/categoría explícitos, quitar defaults silenciosos y persistir confirmación de geometría+superficie+versión+outbox atómicamente en `backend/lib/src/modules/territory/infrastructure/persistence/sector_repository.dart` y `backend/lib/src/modules/territory/application/facades/territory_map_facade.dart`
- [X] T022 [US1] Backend: Verificar create/edit/confirm/cancel/stale-version/rollback y round-trip file-backed de parcela y Sector en `backend/test/modules/territory/territory_persistence_flow_test.dart` y `backend/test/modules/territory/sector_repository_test.dart`
- [X] T023 [US1] Backend: Resolver/restaurar contexto y capacidades por Sector/fecha sin inferir categoría ni cambiar el formulario ligado en `backend/lib/src/modules/agricultural_context/application/facades/agricultural_context_facade.dart`, `backend/lib/src/modules/agricultural_context/application/facades/context_options_queries.dart` y `backend/lib/src/modules/territory/application/facades/sector_detail_facade.dart`
- [X] T024 [US1] Backend: Probar restauración tras reapertura, contexto obsoleto, nombres repetidos, owner distinto y acciones directas incompatibles en `backend/test/integration/productive_domain_compatibility_scenario.dart` y `backend/test/contracts/parcel_context_contract_test.dart`
- [X] T025 [US1] Backend: Hacer que codec y handler de Sector exijan `kind` al crear y rechacen update/pull que lo cambie en `backend/lib/src/modules/territory/infrastructure/sync/sector_sync_codec.dart` y `backend/supabase/migrations/0020_functional_refinement_v11.sql`
- [X] T026 [US1] Integración: Probar paridad Dart/PostgreSQL, creación explícita, inmutabilidad y rechazo sin filas/outbox remotos en `backend/test/modules/territory/territory_sync_codec_test.dart` y `backend/supabase/tests/database/productive_domain_compatibility_test.sql`
- [X] T027 [P] [US1] Frontend: Consumir categoría/capacidades públicas sin inferir por icono, cultivo o texto en `frontend/lib/src/modules/territory/presentation/controllers/territory_controllers.dart`, `frontend/lib/src/modules/territory/presentation/state/sector_ui_state.dart` y `frontend/lib/src/modules/agricultural_context/presentation/controllers/agricultural_context_controller.dart`
- [X] T028 [US1] Frontend: Probar lista, detalle, selector y tarjeta de contexto para crop/apiary/legacy y errores accionables en `frontend/test/modules/territory/sector_list_page_test.dart`, `frontend/test/modules/territory/sector_ui_state_test.dart` y `frontend/test/shared/agricultural_context_selector_test.dart`
- [X] T029 [US1] Frontend: Completar estados viewing/creating/editing/closedDraft/confirming, nombre+categoría al crear, mover vértices, cerrar, confirmar y cancelar conservando overlays sin tiles/GPS en `frontend/lib/src/modules/territory/presentation/pages/territory_map_page.dart`
- [ ] T030 [US1] Integración: Probar el flujo territorial visible y reapertura real, incluida denegación GPS y mapa remoto degradado, en `frontend/test/modules/territory/territory_map_page_test.dart`, `frontend/integration_test/territory_flow_test.dart` y `frontend/integration_test/android_map_device_test.dart`

**Checkpoint**: US1 funciona offline y es verificable sin depender del frontend para la validez de dominio.

---

## Phase 4: User Story 2 — Conservar registros agrícolas completos (Priority: P1)

**Goal**: Completar Registrar, Suelo, Fitosanitario, Cultivo, Cosecha/Producción, Otra y tipos heredados con campos, unidades, contexto y reapertura íntegros.

**Independent Test**: Guardar cada discriminador offline con opcionales presentes/ausentes, reiniciar y recuperar exactamente detalle, unidad, contexto y un único evento.

- [X] T031 [US2] Backend: Congelar comandos discriminados y detalles públicos v2 para labor, suelo y cosecha en `backend/lib/src/modules/labors/contracts/dto/labor_form_input.dart`, `backend/lib/src/modules/labors/labors_api.dart`, `backend/lib/src/modules/soil/soil_api.dart`, `backend/lib/src/modules/production/contracts/dto/production_form_input.dart` y `backend/lib/src/modules/production/production_api.dart`
- [X] T032 [US2] Backend: Añadir contract tests de campos requeridos/opcionales, null≠zero, unidades, errores por campo y datos preservados en `backend/test/contracts/complete_agricultural_records_contract_test.dart`
- [X] T033 [US2] Backend: Evolucionar `LaborDetailsEnvelope` a schema v2 conservando campos/versiones desconocidos byte a byte y sin convertir observaciones en detalle tipado en `backend/lib/src/modules/labors/domain/entities/labor_details.dart`
- [X] T034 [US2] Backend: Probar round-trip v1/v2, unknown schema/fields, omisiones y contexto `complete|legacyPartial` en `backend/test/modules/labors/labor_details_test.dart`
- [X] T035 [US2] Backend: Añadir `cultivation` sin reinterpretar `sowing|pruning` y completar detalles fitosanitarios, cultivo y otra labor en `backend/lib/src/modules/labors/domain/entities/labor_type.dart`, `backend/lib/src/modules/labors/domain/entities/phytosanitary_details.dart`, `backend/lib/src/modules/labors/domain/entities/cultivation_details.dart`, `backend/lib/src/modules/labors/domain/entities/other_labor_details.dart`, `backend/lib/src/modules/labors/domain/entities/sowing_details.dart` y `backend/lib/src/modules/labors/domain/entities/pruning_details.dart`
- [X] T036 [US2] Backend: Probar producto/objetivo/dosis/unidad/carencia/observaciones, campos de Cultivo/Otra y regresión Siembra/Poda sin recomendaciones químicas en `backend/test/modules/labors/agrochemical_details_test.dart`, `backend/test/modules/labors/cultural_labor_details_test.dart` y `backend/test/modules/labors/labor_details_test.dart`
- [X] T037 [US2] Backend: Parsear inputs sin `tryParse ?? 0`, validar contexto/categoría, devolver field errors y conservar el comando fallido en `backend/lib/src/modules/labors/application/facades/labors_facade.dart` y `backend/lib/src/modules/labors/contracts/labor_context.dart`
- [X] T038 [US2] Backend: Probar llamadas directas válidas/inválidas, contexto cambiado y storage failure sin limpiar el borrador en `backend/test/modules/labors/labors_facade_test.dart`
- [X] T039 [US2] Backend: Persistir `domain_category`, contexto snapshot, correcciones por supersesión y labor+outbox atómicos con deduplicación por `commandId` en `backend/lib/src/modules/labors/infrastructure/persistence/labor_repository.dart`
- [X] T040 [US2] Backend: Verificar rollback, corrección trazable, reapertura file-backed e idempotencia del repositorio en `backend/test/modules/labors/labor_repository_test.dart`
- [X] T041 [US2] Backend: Convertir Suelo en especialización de una labor root preservando indicadores, unidades, omisiones y contexto en `backend/lib/src/modules/soil/domain/entities/soil_measurement.dart`, `backend/lib/src/modules/soil/application/facades/soil_facade.dart` y `backend/lib/src/modules/soil/infrastructure/persistence/soil_repository.dart`
- [X] T042 [US2] Backend: Probar matriz de indicadores/unidades/null/invalid, enlace único, rollback y reapertura file-backed en `backend/test/modules/soil/soil_repository_test.dart`
- [X] T043 [P] [US2] Backend: Completar Cosecha/Producción con cantidad/unidad/calidad/destino/jornada/observaciones y grouping por labor root en `backend/lib/src/modules/labors/domain/entities/harvest_details.dart`, `backend/lib/src/modules/production/domain/entities/harvest_input.dart`, `backend/lib/src/modules/production/application/facades/production_facade.dart` y `backend/lib/src/modules/production/infrastructure/persistence/production_repository.dart`
- [X] T044 [US2] Backend: Probar transacción labor+producción, todos los opcionales, reapertura y un único evento por labor en `backend/test/modules/production/production_repository_test.dart`
- [X] T045 [US2] Backend: Extender codec y handler `labor` v2 con snapshot y especializaciones none/soil/production, conservando v1 y campos futuros, en `backend/lib/src/modules/labors/infrastructure/sync/labor_sync_codec.dart` y `backend/supabase/migrations/0020_functional_refinement_v11.sql`
- [X] T046 [US2] Backend: Probar codec, rollback compound, duplicate/hash, pull y E2E local para labor/suelo/producción en `backend/test/modules/labors/labor_sync_codec_test.dart` y `backend/test/integration/labors_production_v2_local_e2e_test.dart`
- [X] T047 [P] [US2] Frontend: Adaptar controller/formulario Registrar a outcomes tipados, contexto visible y campos completos de fitosanitario/cultivo/otra/siembra/poda, enrutando Suelo/Riego/Cosecha/Apicultura a sus flujos existentes en `frontend/lib/src/modules/labors/presentation/controllers/labors_controller.dart` y `frontend/lib/src/modules/labors/presentation/pages/labor_form_page.dart`
- [X] T048 [US2] Frontend: Probar preservación de borrador, cambio de contexto/tipo, errores por campo y campos específicos en `frontend/test/modules/labors/labor_form_page_test.dart`
- [X] T049 [P] [US2] Frontend: Completar captura/presentación de unidades y outcomes para Suelo y Cosecha/Producción en `frontend/lib/src/modules/soil/presentation/pages/soil_measurement_page.dart`, `frontend/lib/src/modules/soil/presentation/controllers/soil_controller.dart`, `frontend/lib/src/modules/production/presentation/pages/production_page.dart` y `frontend/lib/src/modules/production/presentation/controllers/production_controller.dart`
- [X] T050 [US2] Integración: Ejecutar widgets y flujo Registrar→detalle→historial→reapertura para labor general, suelo y cosecha única en `frontend/test/modules/soil/soil_measurement_page_test.dart`, `frontend/test/modules/production/production_page_test.dart` y `frontend/integration_test/labors_production_flow_test.dart`

**Checkpoint**: US2 conserva todo dato confirmado y ninguna validación o recomendación se inventa.

---

## Phase 5: User Story 3 — Cambiar cultivos sin alterar el pasado (Priority: P1)

**Goal**: Asignar y rotar cultivos por fecha efectiva en Sectores crop sin cambiar `kind` ni reinterpretar eventos anteriores.

**Independent Test**: Ejecutar asignaciones vigentes/futuras/solapadas/canceladas/archivadas y verificar snapshots antes y después de la fecha efectiva.

- [X] T051 [US3] Backend: Congelar outcomes públicos category-aware para planificar, activar, cancelar e intercambiar asignaciones en `backend/lib/src/modules/crop_cycles/crop_cycles_api.dart` y `backend/lib/src/modules/crop_cycles/domain/entities/crop_rotation.dart`
- [X] T052 [US3] Backend: Probar contrato de fechas límite, estados y rechazo de Sector apiary/legacy sin mutación en `backend/test/modules/crop_cycles/crop_rotation_test.dart`
- [X] T053 [US3] Backend: Aplicar `DomainCompatibilityPolicy`, resolver cultivo/temporada por fecha y conservar no-solapamiento sin tocar `sectors.kind` en `backend/lib/src/modules/crop_cycles/application/facades/crop_cycles_facade.dart`, `backend/lib/src/modules/crop_cycles/infrastructure/persistence/sector_crop_assignment_repository.dart` y `backend/lib/src/modules/crop_cycles/infrastructure/persistence/crop_assignment_reconciler.dart`
- [X] T054 [US3] Backend: Probar reloj controlado para vigente/futuro/borde/solapado/cancelado/archivado y snapshots históricos en `backend/test/modules/crop_cycles/crop_rotation_test.dart` y `backend/test/modules/crop_cycles/seasons_crops_v2_local_e2e_test.dart`
- [X] T055 [US3] Backend: Validar categoría y conservar fechas/contexto en codec y handler push/pull de asignaciones en `backend/lib/src/modules/crop_cycles/infrastructure/sync/sector_crop_assignment_sync_codec.dart` y `backend/supabase/migrations/0020_functional_refinement_v11.sql`
- [X] T056 [US3] Backend: Probar codec, dependencia Sector→asignación, retries y rechazo remoto de apiary en `backend/test/modules/crop_cycles/seasons_crops_sync_codec_test.dart` y `backend/supabase/tests/database/seasons_crops_sync_v2_test.sql`
- [X] T057 [P] [US3] Frontend: Mostrar contexto, fecha efectiva y estados reales sin activar anticipadamente ni ofrecer rotación en apiary en `frontend/lib/src/modules/crop_cycles/presentation/controllers/crop_cycles_controller.dart` y `frontend/lib/src/modules/crop_cycles/presentation/pages/rotation_page.dart`
- [X] T058 [US3] Integración: Probar navegación, planificación, cancelación, activación temporal y reapertura sin alterar historia/categoría en `frontend/integration_test/seasons_crops_flow_test.dart` y `backend/test/integration/multi_context_scenario.dart`

**Checkpoint**: US3 cambia sólo asignaciones futuras/vigentes y mantiene intacto el significado histórico.

---

## Phase 6: User Story 4 — Refinar y registrar el riego (Priority: P1)

**Goal**: Registrar riego manual completo y calcular únicamente el volumen básico de goteo con caudal total×duración, conservando snapshots y `crop_rule_unavailable` para la capacidad avanzada.

**Independent Test**: Repetir una matriz de unidades/límites/redondeo, cancelar previews y reabrir registros con caudal, duración, presión y resultado idénticos.

- [X] T059 [US4] Backend: Congelar DTOs públicos de `IrrigationDraft`, applicability, basic estimate, fingerprint, performed values y recommendation-unavailable en `backend/lib/src/modules/irrigation/contracts/dto/irrigation_form_input.dart` y `backend/lib/src/modules/irrigation/irrigation_api.dart`
- [X] T060 [US4] Backend: Añadir contract tests de métodos, unidades, scope/count, presión opcional, draft preservado y códigos `method_not_drip|crop_rule_unavailable|preview_stale` en `backend/test/contracts/irrigation_drip_v3_contract_test.dart`
- [X] T061 [US4] Backend: Separar la estimación básica `roundHalfUp(totalFlowMlPerMinute × durationSeconds / 60)` del motor avanzado sin usar clima, etapa, textura, coeficientes ni aprobación en `backend/lib/src/modules/irrigation/domain/entities/irrigation_calculator.dart` y `backend/lib/src/modules/irrigation/domain/entities/irrigation_record.dart`
- [X] T062 [US4] Backend: Probar valores normales, scopes total/emisor/planta, conversiones, límites y half-up determinista en `backend/test/modules/irrigation/irrigation_calculator_test.dart`
- [X] T063 [US4] Backend: Validar categoría, parsear valores/unidades sin fallback cero, calcular fingerprint e invalidarlo ante cualquier cambio en `backend/lib/src/modules/irrigation/application/facades/irrigation_facade.dart`
- [X] T064 [US4] Backend: Sustituir el gate heredado de approval y probar llamadas directas apiary, inputs inválidos, preview stale, cancelación y estado avanzado siempre `crop_rule_unavailable` en `backend/test/modules/irrigation/basic_record_test.dart`, `backend/test/modules/irrigation/irrigation_rule_approval_test.dart` y `backend/test/modules/irrigation/irrigation_advanced_unavailable_test.dart`
- [X] T065 [US4] Backend: Persistir labor+irrigation+outbox con submitted/canonical flow, scope/count, duración, presión, volumen, fórmula/rounding y contexto en `backend/lib/src/modules/irrigation/infrastructure/persistence/irrigation_repository.dart`
- [X] T066 [US4] Backend: Verificar rollback, idempotencia, snapshot inmutable y reapertura file-backed sin fila agronómica sintética en `backend/test/modules/irrigation/irrigation_snapshot_persistence_test.dart`
- [X] T067 [US4] Backend: Incorporar especialización irrigation en codec/handler compound labor v2 y conservar compatibilidad de config existente en `backend/lib/src/modules/irrigation/infrastructure/sync/irrigation_sync_codec.dart`, `backend/lib/src/modules/labors/infrastructure/sync/labor_sync_codec.dart` y `backend/supabase/migrations/0020_functional_refinement_v11.sql`
- [X] T068 [US4] Backend: Probar push/pull, duplicate/hash, fallo de especialización y payload de caudal/duración/presión en `backend/test/modules/irrigation/irrigation_sync_codec_test.dart` y `backend/supabase/tests/database/irrigation_sync_v2_test.sql`
- [X] T069 [P] [US4] Frontend: Consumir applicability/outcomes tipados y conservar/inactivar preview según fingerprint en `frontend/lib/src/modules/irrigation/presentation/controllers/irrigation_controller.dart`
- [X] T070 [US4] Frontend: Probar estado inicial, cálculo básico, unavailable avanzado, errores y draft preservado en `frontend/test/modules/irrigation/irrigation_controller_test.dart`
- [X] T071 [US4] Frontend: Mostrar métodos manuales, caudal, duración, scope/count, presión aplicable, volumen y explicación matemática sin campos avanzados en `frontend/lib/src/modules/irrigation/presentation/pages/irrigation_record_page.dart`
- [X] T072 [US4] Integración: Probar cálculo→confirmación→detalle/historial→reapertura y cancelación con etiquetas no agronómicas en `frontend/test/modules/irrigation/irrigation_record_page_test.dart` y `frontend/integration_test/irrigation_calculation_flow_test.dart`

**Checkpoint**: US4 queda completo sin inventar una recomendación agronómica avanzada.

---

## Phase 7: User Story 5 — Registrar fertilización según método (Priority: P2)

**Goal**: Registrar Manual/Foliar/Fertirriego con campos pertinentes, opcionales nulos y corrección trazable sin calcular dosis.

**Independent Test**: Guardar cada método offline, corregir opcionales y reabrir sin modificar el riego enlazado ni el contexto original.

- [X] T073 [US5] Backend: Tipar métodos y campos de fertilización en el contrato/detalle v2, incluido `irrigationLaborId?`, y exponerlos por el API existente en `backend/lib/src/modules/labors/domain/entities/fertilization_details.dart`, `backend/lib/src/modules/labors/contracts/dto/labor_form_input.dart` y `backend/lib/src/modules/labors/labors_api.dart`
- [X] T074 [US5] Backend: Probar matriz método×campo requerido/opcional/incompatible y ausencia de cálculo o dosis sugerida en `backend/test/modules/labors/fertilization_details_test.dart`
- [X] T075 [US5] Backend: Aplicar política crop, validar vínculo de riego propietario sin mutarlo y corregir por supersesión en `backend/lib/src/modules/labors/application/facades/labors_facade.dart` y `backend/lib/src/modules/labors/infrastructure/persistence/labor_repository.dart`
- [X] T076 [US5] Backend: Verificar guardado mínimo, opcionales posteriores, contexto inmutable, rollback y rechazo apiary file-backed en `backend/test/integration/fertilization_flow_scenario.dart`
- [X] T077 [US5] Backend: Serializar fertilización completa y su corrección en labor v2 sin campos calculados inventados en `backend/lib/src/modules/labors/infrastructure/sync/labor_sync_codec.dart`
- [X] T078 [US5] Backend: Probar round-trip sync, campos nulos y referencia de riego estable en `backend/test/modules/labors/labor_sync_codec_test.dart`
- [X] T079 [P] [US5] Frontend: Implementar selector Manual/Foliar/Fertirriego, campos dinámicos, advertencia al descartar incompatibles y corrección de opcionales en `frontend/lib/src/modules/labors/presentation/pages/labor_form_page.dart`
- [X] T080 [US5] Integración: Probar los tres métodos desde UI hasta detalle/reapertura, sin dosis inventada y con rechazo apiary en `frontend/test/modules/labors/fertilization_form_test.dart` y `frontend/integration_test/fertilization_flow_test.dart`

**Checkpoint**: US5 conserva el método real y permite completar opcionales sin alterar historia.

---

## Phase 8: User Story 6 — Apicultura especializada (Priority: P2)

**Goal**: Registrar inspección, alimentación, sanidad, cosecha, alza y otra tarea apícola como labor especializada, con fotos y sin campos vegetales.

**Independent Test**: Guardar cada familia de tarea offline, reabrir, ver un único evento y rechazar operaciones vegetales o apiary sobre crop sin escrituras parciales.

- [X] T081 [US6] Backend: Congelar comandos/detalles públicos `ApiaryTask` y `ApiaryDetailsV2` con outcomes tipados en `backend/lib/src/modules/apiary/domain/entities/apiary_inspection_input.dart`, `backend/lib/src/modules/apiary/apiary_api.dart` y `backend/lib/src/modules/media/media_api.dart`
- [X] T082 [US6] Backend: Añadir contract tests de tareas, hive count, responsable descriptivo, opcionales, fotos y category gate en `backend/test/contracts/apiary_operations_v2_contract_test.dart`
- [X] T083 [US6] Backend: Implementar reglas discriminadas para inspection/feeding/health/harvest/superPlacement/other sin defaults ni campos vegetales en `backend/lib/src/modules/apiary/domain/entities/apiary_operation_details.dart`
- [X] T084 [US6] Backend: Probar cada task type, null≠false, campos incompatibles y responsable sin identidad/rol en `backend/test/modules/apiary/apiary_operation_details_test.dart`
- [X] T085 [US6] Backend: Persistir una labor root apiary sin crop fabricado, especialización enlazada y un outbox compound en `backend/lib/src/modules/apiary/application/facades/apiary_inspection_facade.dart` y `backend/lib/src/modules/apiary/infrastructure/persistence/apiary_repository.dart`
- [X] T086 [US6] Backend: Probar category gate directo, transacción/rollback, enlace único, un evento y reapertura file-backed en `backend/test/modules/apiary/apiary_repository_test.dart`
- [X] T087 [US6] Backend: Completar backfill determinista de filas apícolas legadas sin inventar temporada/asignación en `backend/lib/src/platform/database/migrations/functional_refinement_v11.dart`
- [X] T088 [US6] Backend: Probar IDs/campos preservados, contexto parcial y labor link determinista del backfill apícola en `backend/test/platform/database/migrations/functional_refinement_v11_test.dart`
- [X] T089 [US6] Backend: Añadir apiary al codec/handler compound y migrar idempotentemente outbox `apiary_inspection` pendiente antes de su primer envío en `backend/lib/src/modules/labors/infrastructure/sync/labor_sync_codec.dart`, `backend/lib/src/composition/sync_codec_composition.dart` y `backend/supabase/migrations/0020_functional_refinement_v11.sql`
- [X] T090 [US6] Backend: Probar retry/duplicate, no reescritura tras receipt, pull/rollback y detalle completo en `backend/test/modules/apiary/apiary_sync_codec_test.dart`
- [X] T091 [US6] Backend: Validar e importar fotos privadas contra el `laborId` propietario confirmado con fallo retryable independiente en `backend/lib/src/modules/media/application/facades/media_facade.dart` y `backend/lib/src/modules/media/infrastructure/persistence/photo_repository.dart`
- [X] T092 [US6] Backend: Probar target permitido, owner isolation, fallo de attachment sin corrupción del evento y reapertura en `backend/test/modules/media/apiary_photo_attachment_test.dart`
- [X] T093 [P] [US6] Frontend: Adaptar controller/página a task types, campos propios, responsable descriptivo, fotos y rechazo tipado sin inputs vegetales en `frontend/lib/src/modules/apiary/presentation/controllers/apiary_inspection_controller.dart` y `frontend/lib/src/modules/apiary/presentation/pages/apiary_inspection_page.dart`
- [X] T094 [US6] Integración: Probar cada familia apícola, foto, restart, historia única y operaciones cruzadas rechazadas en `frontend/test/modules/apiary/apiary_inspection_page_test.dart`, `frontend/integration_test/apiary_flow_test.dart` y `backend/test/integration/apiary_functional_refinement_scenario.dart`

**Checkpoint**: US6 opera como dominio especializado sobre Sector, no como labor vegetal renombrada.

---

## Phase 9: User Story 7 — Historial, offline y respaldo exact-once (Priority: P2)

**Goal**: Recuperar todos los eventos 003 con detalle/contexto/estado veraz y respaldarlos sin pérdida, duplicados ni sobrescritura de conflictos.

**Independent Test**: Guardar una matriz mixta offline, reiniciar en estados críticos, filtrar historial y recuperar conexión con ACK perdido/conflicto hasta quedar respaldado una vez o en estado recuperable.

- [X] T095 [US7] Backend: Congelar `HistoryFilter`, summaries/details discriminados y `BackupState` públicos en `backend/lib/src/modules/history/domain/entities/history_event.dart` y `backend/lib/src/modules/history/history_api.dart`
- [X] T096 [US7] Backend: Añadir contract tests de filtros, ordering, grouping, detalle, corrección y separación local/backup en `backend/test/contracts/history_v2_contract_test.dart`
- [X] T097 [US7] Backend: Consultar el conjunto lógico antes de paginar y filtrar por parcela/Sector/categoría/temporada/cultivo/tipo/fechas en `backend/lib/src/modules/history/infrastructure/persistence/sector_history_dao.dart` y `backend/lib/src/modules/history/infrastructure/persistence/history_repository.dart`
- [X] T098 [US7] Backend: Probar filtros combinados, orden estable, pagination y deduplicación labor root para suelo/riego/producción/apiary en `backend/test/modules/history/history_repository_test.dart`
- [X] T099 [US7] Backend: Proyectar detalles tipados, contexto histórico/legacy, corrección y estado real desde facades sin exponer filas Drift en `backend/lib/src/modules/history/application/facades/history_facade.dart` y `backend/lib/src/modules/history/domain/entities/history_event.dart`
- [X] T100 [US7] Backend: Verificar detalle completo y reapertura file-backed para todas las especializaciones en `backend/test/modules/history/history_event_test.dart` y `backend/test/modules/history/history_repository_test.dart`
- [X] T101 [US7] Backend: Activar codecs 003 sólo con handlers disponibles, conservar orden Sector→asignación→labor y evitar `sync_push` con lote filtrado vacío en `backend/lib/src/composition/sync_codec_composition.dart` y `backend/lib/src/platform/sync/sync_coordinator.dart`
- [X] T102 [US7] Backend: Probar registry completo, lote vacío sin RPC, dependencias y estados pending/sending/done/error en `backend/test/platform/sync/sync_contract_test.dart`, `backend/test/platform/sync/sync_trigger_coordinator_test.dart` y `backend/test/platform/database/sync_outbox_dao_test.dart`
- [X] T103 [US7] Backend: Aplicar root+specialization+cursor en una transacción y preservar candidato local como conflicto en `backend/lib/src/platform/sync/protocol/aggregate_sync_registry.dart`, `backend/lib/src/platform/sync/sync_coordinator.dart` y `backend/lib/src/platform/sync/conflicts/conflict_resolver.dart`
- [X] T104 [US7] Backend: Probar ACK perdido, same ID/hash duplicate, hash distinto rechazado, pull rollback, tombstone, owner isolation y conflicto de dos dispositivos en `backend/test/integration/sync_functional_refinement_scenario.dart` y `backend/test/integration/sync_conflict_tombstone_scenario.dart`
- [X] T105 [US7] Integración: Ejecutar migraciones 0001–0020 y cubrir handlers compound, matriz de categoría, RLS anonymous/owner A/owner B y bypass directo en `backend/supabase/tests/database/functional_refinement_v11_test.sql`, `backend/supabase/tests/database/sync_protocol_v2_test.sql` y `backend/supabase/tests/database/rls_coverage_test.sql`
- [X] T106 [US7] Integración: Probar confirmaciones mixtas offline, cierre abrupto, reloj controlado y reapertura file-backed en cada estado crítico en `backend/test/integration/functional_refinement_offline_restart_scenario.dart`
- [X] T107 [P] [US7] Frontend: Consumir filtros, detalles, grouping y estados públicos en `frontend/lib/src/modules/history/presentation/controllers/history_controller.dart` y `frontend/lib/src/modules/history/presentation/pages/history_page.dart`
- [X] T108 [US7] Frontend: Probar filtros/contextos, detalle por discriminador, una sola fila por labor y estados accesibles en `frontend/test/modules/history/history_page_test.dart`
- [X] T109 [US7] Frontend: Mostrar guardado local separado de pendiente/sincronizando/respaldado/error/conflicto y resolución explícita en `frontend/lib/src/modules/sync_status/presentation/controllers/sync_status_controller.dart`, `frontend/lib/src/modules/sync_status/presentation/pages/sync_status_page.dart` y `frontend/lib/src/modules/sync_status/presentation/pages/conflict_resolution_page.dart`
- [X] T110 [US7] Integración: Probar historial desde sus tres entradas, restart, respaldo, ACK perdido y conflicto sin duplicados en `frontend/integration_test/history_production_flow_test.dart`, `frontend/integration_test/synchronization_test.dart` y `frontend/integration_test/sync_conflict_tombstone_e2e_test.dart`

**Checkpoint**: US7 demuestra durabilidad local e idempotencia remota con estado honesto.

---

## Phase 10: User Story 8 — Ayudas externas degradables (Priority: P3)

**Goal**: Mantener mapa, clima, AgroIA y exportación auxiliares, privados y aislados de los flujos locales refinados.

**Independent Test**: Inyectar offline/timeouts/configuración ausente y comprobar que sólo falla la capacidad dependiente; una request AgroIA contiene exclusivamente el texto autorizado.

- [X] T111 [P] [US8] Backend: Reforzar regresiones de weather-proxy/AgroIA para timeout, caché/vigencia, payload mínimo y ausencia de mutaciones/cálculos críticos en `backend/test/integration/weather_alert_scenario.dart`, `backend/test/integration/agro_ai_privacy_scenario.dart`, `backend/supabase/functions/weather-proxy/tests/weather_contract_test.ts` y `backend/supabase/functions/agro-ai/tests/prompt_eval_test.ts`
- [X] T112 [P] [US8] Backend: Verificar que la exportación vigente sigue leyendo eventos 003 sin inventar campos ni perder detalle en `backend/test/modules/export/xlsx_contract_test.dart`
- [X] T113 [P] [US8] Frontend: Probar estados degradados, reintento explícito y navegación preservada para clima/AgroIA/exportación en `frontend/test/modules/weather/weather_summary_card_test.dart`, `frontend/integration_test/agro_ai_privacy_flow_test.dart` y `frontend/integration_test/weather_ai_export_flow_test.dart`
- [X] T114 [P] [US8] Integración: Ejecutar sólo la regresión mínima de Perfil/Notificaciones/Seguridad que T001 haya demostrado como dependencia directa y registrar PASS/N/A sin cerrar 002/T016, 002/T096, 002/T115 ni 002/T118 en `docs/verification/003-release-matrix.md`
- [ ] T115 [US8] Integración: Inyectar fallas separadas de mapa/GPS/clima/AgroIA/Supabase y demostrar continuidad local y aislamiento de sesión en `frontend/integration_test/android_platform_flow_test.dart` y `frontend/integration_test/session_sync_isolation_e2e_test.dart`
- [X] T116 [US8] Integración: Verificar que no se adjunta contexto agrícola privado, no se cambia a Google Maps y ninguna integración produce cálculos o escrituras autoritativas en `frontend/integration_test/agro_ai_privacy_flow_test.dart` y `tool/check_architecture.dart`

**Checkpoint**: US8 conserva ayudas opcionales sin convertirlas en autoridad o dependencia local.

---

## Phase 11: Polish & Cross-Cutting Verification

**Purpose**: Ejecutar regresión acumulada, cerrar trazabilidad y decidir release sin agregar alcance.

- [X] T117 Integración: Implementar el E2E representativo SC-004/SC-014 desde navegación pública para labor general, suelo, riego, fertilización y apiary hasta detalle/historial/reapertura en `frontend/integration_test/functional_refinement_e2e_test.dart`
- [X] T118 Integración: Ejecutar y documentar PF-01..PF-30 contra `jerarquía 01.md`, `master.md`, `agrocampo-acceptance.test.js` y `agrocampo-highfi.html`, exigiendo implementación+prueba para cada PF “Completado por 003” y sólo regresión/no-impact para los preservados en `docs/verification/003-release-matrix.md`
- [X] T119 Backend: Ejecutar format, analyze y suite backend completa por los comandos de G0–G10/G12 y registrar resultados reproducibles en `docs/verification/003-release-matrix.md`
- [ ] T120 Frontend: Ejecutar format, analyze, widgets, goldens e integration tests completos y registrar resultados reproducibles en `docs/verification/003-release-matrix.md`
- [ ] T121 Integración: Ejecutar pgTAP/RLS/RPC local, Deno de Edge Functions y Android API 24+ sólo sobre stacks desechables/configurados según `specs/003-agrocampo-functional-refinement/quickstart.md`
- [X] T122 Backend: Implementar y ejecutar el perfil sembrado/versionado de consultas de contexto e historial con resultado correcto y p95 documentado bajo 2 segundos en `backend/test/performance/functional_core_performance_test.dart`
- [X] T123 Integración: Actualizar manifest/reporte append-only para Drift v11 y Supabase 0020 y ejecutar su verificador en `docs/architecture/migration-manifest.json`, `docs/architecture/migration-report.md` y `docs/architecture/verify-migration.cjs`
- [ ] T124 Integración: Ejecutar el Constitution Check, arquitectura, scope guard, FR/SC/PF gates y confirmar US1–US7 completos sin placeholders, módulo `003`, identidad paralela, cambio crop↔apiary ni recomendación avanzada en `docs/verification/003-release-matrix.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 → Phase 2**: La baseline y la matriz de evidencia preceden el freeze técnico.
- **Phase 2 → todas las User Stories**: Outcomes, política, contexto y migración v11 son bloqueantes.
- **US1 → US2, US3 y US4**: Registros, rotaciones y riego requieren Sector/categoría/contexto válidos.
- **US2 → US5 y US6**: Fertilización y apiary reutilizan el envelope/labor root v2.
- **US1 + US2 → US3**: Rotación necesita contexto estable y snapshots de eventos, pero no depende de US4–US6.
- **US1 → US4**: Riego puede avanzar en paralelo con US2/US3 después de congelar su contrato T059.
- **US2 → US5** y **US1 + US2 → US6**: Especializaciones usan la política y persistencia común.
- **US2–US6 → US7**: Historial/sync final necesita todos los discriminadores y payloads compound.
- **US7 → US8 y Phase 11**: Regresión externa y cierre se ejecutan sobre flujos locales completos.

### Backend-First Cycle Inside Every Story

1. Congelar contrato público y ejecutar su contract test.
2. Implementar una regla/DTO pequeño y ejecutar sus unit tests.
3. Implementar persistencia y ejecutar file-backed/integration tests.
4. Implementar codec/outbox/handler y ejecutar sync/pgTAP cuando aplique.
5. Adaptar frontend contra el contrato congelado y ejecutar widgets.
6. Ejecutar el flujo vertical antes de comenzar la siguiente capacidad.

### Parallel Opportunities

- T002 puede avanzar en paralelo con T001.
- T005 y T011 usan archivos independientes de T003; T012 espera T011 y T009.
- Tras T017, T027 puede desarrollar presentación con dobles mientras T019–T026 completan backend; T030 espera ambos carriles.
- Tras T031 y T039, T041/T043 y T047/T049 pueden repartirse por módulos independientes; T050 espera sus resultados.
- T057, T069, T079, T093 y T107 pueden avanzar con dobles después de congelar T051, T059, T073, T081 y T095 respectivamente; sus pruebas de integración esperan backend verde.
- T111, T112, T113 y T114 son regresiones independientes y paralelizables; T115/T116 consolidan la historia.
- Ninguna tarea marcada `[P]` comparte un archivo mutable con otra tarea paralela indicada en el mismo grupo.

---

## Prototype Flow Technical Coverage

| PF | Clasificación | Ruta de implementación/prueba |
|---|---|---|
| PF-01 | Preservado 001/002 | T023, T115, T118 |
| PF-02 | Preservado 001/002 | T047, T117, T118 |
| PF-03 | Preservado 001/002 | T029, T071, T117, T118 |
| PF-04 | Completado por 003 | T021–T024, T027–T030 |
| PF-05 | Preservado 001/002 | T097–T100, T118 |
| PF-06 | Completado por 003 | T019–T022, T029–T030 |
| PF-07 | Completado por 003 | T019–T022, T029–T030 |
| PF-08 | Completado por 003 | T017–T018, T023–T024, T027–T028 |
| PF-09 | Completado por 003 | T009–T010, T023–T024, T047–T048, T117 |
| PF-10 | Completado por 003 | T041–T042, T049–T050, T117 |
| PF-11 | Completado por 003 | T059–T072, T117 |
| PF-12 | Completado por 003 | T073–T080, T117 |
| PF-13 | Completado por 003 | T035–T040, T047–T050, T117 |
| PF-14 | Completado por 003 | T035–T040, T047–T050 |
| PF-15 | Completado por 003 | T043–T046, T049–T050, T098–T100 |
| PF-16 | Completado por 003 | T081–T094, T117 |
| PF-17 | Completado por 003 | T035–T040, T047–T050 |
| PF-18 | Completado por 003 | T051–T058 |
| PF-19 | Completado por 003 | T095–T110, T117 |
| PF-20 | Preservado desde 002 | T111, T113, T115–T116, T118 |
| PF-21 | Preservado 001/002 | T111, T113, T115, T118 |
| PF-22 | Preservado desde 001 | T112–T113, T118 |
| PF-23 | Preservado desde 002 | T101–T110, T115, T118 |
| PF-24 | Preservado 001/002 | T001, T114, T118 |
| PF-25 | Preservado 001/002 | T001, T114, T118 |
| PF-26 | Preservado 001/002 | T001, T114, T118 |
| PF-27 | Fuera de alcance | T116, T124 |
| PF-28 | Fuera de alcance | T020, T124 |
| PF-29 | Fuera de alcance | T016, T124 |
| PF-30 | Fuera de alcance | T061, T116, T124 |

Every PF classified **Completado por 003** has both an implementation route and an automated test route above. Preserved flows receive regression only where 003 can affect them; out-of-scope flows receive absence/scope checks only.

---

## Implementation Strategy

### MVP First

1. Complete Phase 1 and Phase 2.
2. Complete US1 (T017–T030).
3. Stop and validate US1 independently before proceeding.

### Incremental Delivery

1. US1 establishes Sector/category/context/geometry.
2. US2 and US3 complete records and historical crop assignment.
3. US4 completes deterministic irrigation.
4. US5 and US6 complete specialized P2 flows.
5. US7 closes history/offline/sync for every prior event.
6. US8 verifies auxiliary integrations; Phase 11 closes accumulated regression.

## Notes

- `[P]` never overrides an explicit dependency in this file.
- Backend tests must pass without importing or running frontend.
- Frontend may use only `package:agrocampo_backend/agrocampo_backend.dart` and public doubles.
- Every local success means `savedLocal`; only a real ACK may produce `backedUp`.
- Use representative partition matrices, not ceremonial case counts.
- Do not begin the next capability while the current capability's applicable unit/integration tests are red.
