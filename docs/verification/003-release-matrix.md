# AgroCampo 003 — matriz de evidencia de release

El plan detallado de cierre, distribución por carril y dependencias de las 23 tareas abiertas está
en [`003-remaining-plan.md`](003-remaining-plan.md).

La configuración y el procedimiento reproducible del AVD están en
[`android-pixel8-build-plan.md`](android-pixel8-build-plan.md).

La ejecución detallada de las 16 tareas de integración en el Pixel 8 está en
[`003-integration-pixel8-report.md`](003-integration-pixel8-report.md).

Estado de la ejecución: `parcial`, salvo G0 documentado en
[`003-baseline.md`](003-baseline.md). Cada fila debe enlazar una tarea y una suite concreta antes
de marcarse como completada.

| Grupo | Cobertura | Evidencia prevista | Estado inicial |
|---|---|---|---|
| FR | FR-001..FR-087 | tareas de US1–US8 y suites de contrato/integración | pendiente |
| SC | SC-001..SC-018 | criterios verificables de `spec.md` | pendiente |
| PF | PF-01..PF-30 | regresión visible y trazabilidad del prototipo | pendiente |
| Gates | G0..G12 | quickstart, análisis, migración, sync, APK y alcance | pendiente |

## Regla de clasificación de flujos

Cada flujo de `jerarquía 01.md` debe terminar con exactamente una clasificación:

1. completado por 003, con tarea de implementación y prueba;
2. preservado desde 001/002, con regresión si 003 puede afectarlo; o
3. fuera de alcance explícito, con referencia a `spec.md`/`plan.md`.

No se acepta una fila sin clasificación ni evidencia.

## Enlaces de suites

Los enlaces se completan durante cada checkpoint: unitarias y contract tests de backend,
file-backed/migration/sync tests, widget/integration/E2E de Flutter en `emulator-5554`, y los
gates estáticos finales. La calculadora económica predictiva y las recomendaciones agronómicas
avanzadas permanecen fuera de alcance.

## Checkpoint de ejecución 2026-09-10

| Evidencia | Resultado | Tareas relacionadas |
|---|---|---|
| Backend `flutter test --no-pub` | PASS — 151 tests | T037, T038, T067, T095–T106, T122 |
| Frontend `flutter test --no-pub` | PASS — 60 tests, incluidos goldens | T027–T029, T047–T049, T079, T107–T109 |
| Backend/frontend `dart format` | Ejecutado; el SDK vuelve a reportar cambios de formato/fin de línea en cada pasada (`--set-exit-if-changed` no converge) | T119, T120 |
| Contratos y especializaciones | PASS — dominio, sectores, labores, riego, apicultura, historial y media | T003–T012, T019–T025, T031–T036, T051–T056, T059–T066, T073–T078, T081–T092 |
| Reapertura/offline file-backed | PASS — 100 mutaciones y migración v9→v11 | T014, T106 (T013 codegen pendiente) |
| Prototipo y JavaScript | PASS — `node agrocampo-acceptance.test.js` y sintaxis embebida | G0 (PF regresión completa pendiente) |
| Pixel 8 API 37.1 (`emulator-5554`) | PASS — APK debug nuevo generado e instalado; `android_platform_flow_test.dart` 4/4; `functional_refinement_e2e_test.dart` 7/7; permisos y GPS preparados por ADB | T030, T110, T115, T117, T120, T121 |
| Integración 003 en Pixel 8 | PASS parcial — T030/T050/T058/T080/T094/T110/T114/T115/T117 ejecutan sus suites locales; T026/T068/T105/T121 dependen de Supabase/Docker; T116/T123 reportan fallos explícitos | 16 tareas de integración; detalle en `003-integration-pixel8-report.md` |

## Bloqueos reproducibles

- Drift `build_runner` no termina; los artefactos generados permanecen sin regenerar y T013 no se marca.
- Supabase CLI, Docker y Deno no están disponibles; pgTAP/RLS/RPC/Edge Functions (T026, T068 SQL, T105, T111, T121) no tienen ejecución local.
- `flutter analyze` y `dart run tool/check_architecture.dart` no producen salida en este entorno.
- `node docs/architecture/verify-migration.cjs` detecta que el hash histórico de `backend/supabase/config.toml` ya no coincide con el manifiesto; T123 queda pendiente para una actualización append-only.

Las filas PF-01..PF-30 conservan su clasificación en `tasks.md`; las rutas de implementación y
prueba están presentes para los flujos completados por 003. Las suites Android representativas
están verdes, pero T030/T050/T058/T080/T094/T110/T115/T117/T118 aún requieren sus criterios
completos y por ello no se declara 003 listo ni se marcan US1–US7 como completas.
