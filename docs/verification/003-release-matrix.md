# AgroCampo 003 — matriz de evidencia de release

El plan detallado de cierre, distribución por carril y dependencias de las 23 tareas abiertas está
en [`003-remaining-plan.md`](003-remaining-plan.md).

La configuración y el procedimiento reproducible del AVD están en
[`android-pixel8-build-plan.md`](android-pixel8-build-plan.md).

La ejecución detallada de las 16 tareas de integración en el Pixel 8 está en
[`003-integration-pixel8-report.md`](003-integration-pixel8-report.md).

El análisis posterior y el paso a paso de cierre backend/frontend están en
[`003-post-integration-gap-analysis.md`](003-post-integration-gap-analysis.md).

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

## Bloqueos reproducibles (snapshot histórico 2026-09-10)

- Drift `build_runner` no termina; los artefactos generados permanecen sin regenerar y T013 no se marca.
- Supabase CLI, Docker y Deno no están disponibles; pgTAP/RLS/RPC/Edge Functions (T026, T068 SQL, T105, T111, T121) no tienen ejecución local.
- `flutter analyze` y `dart run tool/check_architecture.dart` no producen salida en este entorno.
- `node docs/architecture/verify-migration.cjs` detecta que el hash histórico de `backend/supabase/config.toml` ya no coincide con el manifiesto; T123 queda pendiente para una actualización append-only.

## Checkpoint de cierre backend/frontend 2026-09-11

| Evidencia | Resultado | Tareas relacionadas |
|---|---|---|
| Drift v11 | PASS — `build_runner` ejecutado desde el snapshot local; migración funcional v11: 2 tests PASS | T013 |
| Rotación frontend | PASS — contexto vegetal, fecha efectiva, planificación futura y ocultamiento para apiary; 4 tests PASS | T057 |
| Riego backend local | PASS parcial — codec local cubre rollback de especialización, payload de duración/caudal/presión y ACK duplicate/hash; 3 tests PASS; pgTAP remoto no ejecutado | T068 |
| Weather/AgroIA file-backed | PASS parcial — timeout explícito, caché fresh/stale, deduplicación de alertas, retry y request sin contexto privado; 3 tests PASS | T111 |
| Regresión mínima 002 dependiente | PASS histórico — `001_compatibility_regression_test.dart` 12/12 y `android_platform_flow_test.dart` 4/4 en la sesión Pixel 8 del 2026-09-10; no cierra tareas 002 | T114 |
| Frontend widgets/goldens | PASS — format sin cambios, analyze sin incidencias y suite `flutter test --no-pub` 64 tests PASS | T113, T120 |
| Backend calidad acumulada | PASS — format sin cambios, analyze sin incidencias y suite `flutter test --no-pub --reporter compact` 154 tests PASS | T119 |
| Arquitectura | PASS — `timeout 60s /tmp/flutter/bin/dart tool/check_architecture.dart` | T016, T116, T124 |
| Privacidad de integración | PASS — evidencia Pixel 8 histórica `agro_ai_privacy_flow_test.dart` 1/1 y checker actual PASS; no hay contexto privado, Google Maps, cálculos ni escrituras autoritativas | T116 |
| Integridad de migración | PASS — `node docs/architecture/verify-migration.cjs`; 426 entradas, 48 preservadas y 258 destinos intermedios reubicados | T123 |
| Prototipo | PASS — `node agrocampo-acceptance.test.js`; sintaxis embebida PASS, 1 script | G0, T118 |

### Clasificación PF-01..PF-30

La clasificación obligatoria queda confirmada contra `tasks.md`, sin convertir una clasificación en
evidencia de ejecución Android: PF-01..PF-03 y PF-05 son preservados desde 001/002; PF-04 y
PF-06..PF-19 son completados por 003; PF-20..PF-26 son preservados desde 001/002; PF-27..PF-30
están fuera de alcance. T118 permanece abierto porque requiere la ejecución y documentación
visible de todos los PF aplicables; el backend/frontend local no sustituye esa prueba.

### Estado de gates no ejecutables en esta estación

- T026, T068 (pgTAP), T105 y T121: bloqueados por Supabase CLI/Docker/Podman y PostgreSQL local no
  configurados; Deno tampoco está instalado para las Edge Functions.
- T030, T050, T058, T080, T094, T110, T115, T117, T118 y la parte Android de T120/T124:
  bloqueados porque `emulator-5554`/Pixel 8 no está disponible. No se ejecutaron comandos Android
  ni se simuló una aprobación.
- T111 y T113 tienen evidencia backend/widget local, pero sus pruebas Edge/Android siguen abiertas
  por esos mismos prerrequisitos.
- T124 no se cierra: arquitectura y alcance estático pasan, pero faltan los gates remotos, Android y
  la confirmación vertical completa de US1–US7.

Las filas PF-01..PF-30 conservan su clasificación en `tasks.md`; las rutas de implementación y
prueba están presentes para los flujos completados por 003. Las suites Android representativas
están verdes, pero T030/T050/T058/T080/T094/T110/T115/T117/T118 aún requieren sus criterios
completos y por ello no se declara 003 listo ni se marcan US1–US7 como completas.

## Checkpoint definitivo host-only 2026-09-11

Este checkpoint supersede los bloqueos de infraestructura del snapshot anterior. La evidencia
detallada, incluyendo el ciclo inicial → implementación → repetición → diagnóstico, está en
[`003-host-execution-2026-09-11.md`](003-host-execution-2026-09-11.md). No se ejecutó Android:
`emulator-5554` no está disponible y no se sustituyó el criterio de dispositivo por una prueba
host.

| Área | Evidencia reproducible | Resultado |
|---|---|---|
| Backend completo | `flutter test --no-pub --reporter compact` | PASS — 156/156 |
| Frontend completo | `flutter test --no-pub --reporter compact` | PASS — 66/66 |
| Calidad | `dart format --set-exit-if-changed` en ambos paquetes; `flutter analyze --no-pub` en ambos | PASS — 0 cambios, sin incidencias |
| Supabase local | CLI 2.117.0, Docker Engine 29.8.0, `db reset --local` | PASS — 0001–0020 |
| PostgreSQL/pgTAP | suite database local | PASS — 17 archivos, 164 tests |
| Edge Functions | Deno 2.9.6 para weather-proxy y agro-ai | PASS — 5 tests; HTTP sin auth devuelve 401 controlado |
| Migración/arquitectura | `verify-migration.cjs`, `tool/check_architecture.dart` | PASS — 426 entradas; arquitectura PASS |
| Prototipos | aceptación y sintaxis JavaScript embebida | PASS |
| Android API 24+ | dispositivo, GPS, permisos, plugins y lifecycle | N/A-ANDROID/BLOQUEADO |

### PF-01..PF-30 — clasificación y evidencia actual

Cada fila conserva exactamente una clasificación de `plan.md` y `tasks.md`. “Preservado” exige
regresión/no-impact; “completado por 003” exige implementación y prueba; “fuera de alcance” no
se implementa ni se usa como criterio de release.

| PF | Clasificación | Evidencia 2026-09-11 | Estado |
|---|---|---|---|
| PF-01 | Preservado 001/002 | suite frontend/backend + router público host | PASS host |
| PF-02 | Preservado 001/002 | rutas públicas y aceptación del prototipo | PASS host |
| PF-03 | Preservado 001/002 | navegación/router y regresión de borradores | PASS host |
| PF-04 | Completado por 003 | T026, widgets territoriales y persistencia de contexto | PASS host |
| PF-05 | Preservado 001/002 | historial, clima y aceptación sin cambios de alcance | PASS host |
| PF-06 | Completado por 003 | geometría, lista y router público | PASS host |
| PF-07 | Completado por 003 | edición explícita y confirmar/cancelar territorial | PASS host |
| PF-08 | Completado por 003 | capacidades/contexto desde contrato público | PASS host |
| PF-09 | Completado por 003 | bound context y 12 rutas públicas | PASS host |
| PF-10 | Completado por 003 | suelo: widget + file-backed labor/soil | PASS host |
| PF-11 | Completado por 003 | riego: codec, cálculo y pgTAP local | PASS host |
| PF-12 | Completado por 003 | fertilización manual/foliar/fertirriego | PASS host |
| PF-13 | Completado por 003 | detalle laboral v2 y ausencia de recomendación | PASS host |
| PF-14 | Completado por 003 | discriminador `cultivation` y suite backend | PASS host |
| PF-15 | Completado por 003 | producción compuesta y un evento por labor | PASS host |
| PF-16 | Completado por 003 | siete escenarios apícolas, fotos y persistencia | PASS host |
| PF-17 | Completado por 003 | otra labor y validaciones de detalle | PASS host |
| PF-18 | Completado por 003 | rotación por fecha efectiva, 2 escenarios locales | PASS host |
| PF-19 | Completado por 003 | historial, sync, tombstones y rutas públicas | PASS host |
| PF-20 | Preservado desde 002 | privacidad AgroIA y payload mínimo | PASS host |
| PF-21 | Preservado 001/002 | clima fresh/stale/timeout y widget | PASS host |
| PF-22 | Preservado desde 001 | golden XLSX/exportación sin pérdida | PASS host |
| PF-23 | Preservado desde 002 | sync contract, ACK perdido, conflicto y tombstone | PASS host |
| PF-24 | Preservado 001/002 | regresión de app/auth/profile en suite completa | PASS host |
| PF-25 | Preservado 001/002 | regresión de permisos/notificaciones contractuales | PASS host |
| PF-26 | Preservado 001/002 | secure session/biometría y aislamiento | PASS host |
| PF-27 | Fuera de alcance | scope guard; no se implementa | N/A |
| PF-28 | Fuera de alcance | scope guard; no se implementa | N/A |
| PF-29 | Fuera de alcance | scope guard; no se implementa | N/A |
| PF-30 | Fuera de alcance | scope guard; no se implementa | N/A |

### Estado de tareas y gates

Con esta ejecución quedan cerrables por evidencia host T026, T050, T058, T068, T080, T094,
T105, T110, T111, T113, T117 y T118. Se mantienen abiertas, sin falsificar aprobación,
T030 y T115 por mapa/GPS/plugins Android; T120 por la parte de integración Android; T121
por API 24+ aunque pgTAP/Deno ya pasen; y T124 porque su gate global exige confirmar US1–US7
incluyendo los criterios Android. Por tanto, el estado de release sigue `NO LISTO` hasta
ejecutar esa evidencia en un dispositivo API 24+.
