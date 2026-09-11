# AgroCampo 003 — análisis posterior a la integración Android

**Fecha:** 2026-09-10
**Rama de trabajo:** `feature/backend`
**Dispositivo comprobado:** Pixel 8 API 37.1 (`emulator-5554`)

## Conclusión ejecutiva

Las suites representativas de Android están verdes, pero no es correcto afirmar que sólo falta
T116. El `tasks.md` conserva **101/124 tareas completadas y 23 abiertas**. La ejecución en el Pixel
8 aporta evidencia fuerte para los flujos locales, pero no sustituye los criterios de navegación
pública, PostgreSQL/Supabase, RLS, API 24+ ni los gates estáticos.

La diferencia es deliberada: una suite puede terminar en `PASS` y aun así dejar la tarea en `[ ]`
cuando prueba un harness local, una página directa o una sola partición de la matriz.

## Estado actual por carril

### Backend

| Tarea | Estado | Qué falta exactamente |
|---|---|---|
| T013 | Abierta | Regenerar Drift v11 y comparar `g.dart`, snapshots y schemas; `build_runner` debe terminar. |
| T026 | Parcial | El codec Dart pasa; falta paridad PostgreSQL y verificar que el rechazo no escriba filas/outbox remoto. |
| T068 | Parcial | El codec Dart pasa; falta push/pull remoto, duplicate/hash y fallo de especialización en Supabase. |
| T111 | Parcial | Las pruebas Deno de weather-proxy (4/4) y AgroIA (1/1) pasan; falta ejecutar la matriz completa contra el stack Edge configurado. |
| T119 | Abierta | Ejecutar format/analyze y la suite backend completa con salida reproducible. |

### Frontend

| Tarea | Estado | Qué falta exactamente |
|---|---|---|
| T057 | Abierta | Verificar contexto/fecha/estado de rotación y ocultamiento en `apiary` con pruebas propias. |
| T113 | Parcial | Las suites de clima/AgroIA/exportación pasan; falta consolidar widget, reintento y navegación preservada. |
| T120 | Abierta | Ejecutar el gate completo de format, analyze, widgets, goldens e integración. El APK ya compila. |

### Integración y gates

| Tarea | Estado | Qué falta exactamente |
|---|---|---|
| T026, T068 | Parcial | Repetir los mismos casos contra PostgreSQL/Supabase local. |
| T030, T050, T058, T080, T094 | Parcial | Las suites Android/harness pasan; falta la matriz completa desde navegación pública y las particiones de error/reapertura indicadas por cada tarea. |
| T105 | Bloqueada | Docker/Podman no están disponibles; no se pueden ejecutar migraciones, handlers compound y RLS. |
| T110 | Parcial | El historial, ACK, tombstone y conflicto pasan en harness local; falta respaldo remoto real. |
| T114 | Evidencia PASS | Regresión mínima de compatibilidad Android pasa; no cierra ninguna tarea de 002. |
| T115 | Parcial | Aislamiento, privacidad y degradación local pasan; falta inyección Supabase remota y matriz completa por proveedor. |
| T116 | FAIL | `agro_ai_privacy_flow_test` pasa, pero `tool/check_architecture.dart` reporta 41 hallazgos. |
| T117 | Parcial | El E2E representativo pasa 7/7, pero compone páginas/widget tests y aún no entra por navegación pública. |
| T118 | Parcial | Aceptación HTML y sintaxis JavaScript pasan; falta registrar cada PF-01..PF-30 con su evidencia final. |
| T121 | Bloqueada | Sólo existe API 37; falta API 24+ y el stack Supabase/Deno integrado. |
| T123 | FAIL | `verify-migration.cjs` detecta hash distinto en `backend/supabase/config.toml`. |
| T124 | No listo | Depende de T013, T026, T030, T050, T058, T068, T080, T094, T105, T110 y T116–T123. |

## Paso a paso recomendado

### Paso 1 — Congelar la evidencia Android

1. Mantener el AVD `Pixel_8` en `emulator-5554`.
2. Generar un APK nuevo con `flutter build apk --debug --no-pub`.
3. Instalarlo por ADB y repetir permisos/GPS después de cada reinstalación.
4. Conservar como smoke gate `android_platform_flow_test.dart` (4/4) y
   `functional_refinement_e2e_test.dart` (7/7).

Salida: el dispositivo queda disponible para las suites específicas; no cerrar tareas por el smoke
gate solamente.

### Paso 2 — Cerrar primero el backend local

1. Ejecutar T013 y regenerar Drift; comparar el generado con `drift_schema_v11.json` y
   `schema_v11.dart`.
2. Ejecutar T026 y T068 en Dart, incluyendo límites, `null` frente a cero, hash y rechazo de
   especialización.
3. Ejecutar T111 en Dart/Deno; comprobar timeout, caché, payload mínimo y ausencia de mutaciones.
4. Ejecutar T119 cuando `format` y `analyze` produzcan una salida reproducible.

Salida: contratos, persistencia y codecs backend verdes antes de repetir pruebas verticales.

### Paso 3 — Preparar las pruebas de frontend

1. Completar T057 con contexto visible, fecha efectiva, rotación futura y guard `apiary`.
2. Consolidar T113 con widget tests para degradación, reintento explícito y navegación preservada.
3. Mantener los fixtures de UI alineados con el contrato público; ningún test debe importar DAOs,
   Drift, outbox o payloads internos.
4. Ejecutar T120: `dart format`, `flutter analyze`, widgets, goldens e integración.

Salida: frontend comprobable contra contratos congelados sin mover reglas de dominio a la UI.

### Paso 4 — Repetir las verticales en el Pixel 8

Ejecutar una tarea por vez, en este orden:

1. T030: navegación pública → crear/editar/confirmar/cancelar → reapertura; después GPS denegado
   y mapa degradado.
2. T050: Registrar → detalle → historial → reapertura para labor, Suelo y Cosecha.
3. T058: rotación futura, cancelación, activación temporal y reapertura sin cambiar historia.
4. T080: Manual/Foliar/Fertirriego, datos opcionales, detalle/reapertura y rechazo `apiary`.
5. T094: seis familias apícolas, foto, restart, historia única y cruces inválidos.
6. T110: tres entradas de historial, restart, ACK perdido, conflicto y cero duplicados.
7. T115: mapa/GPS/clima/AgroIA/Supabase, una falla por vez, verificando continuidad local.
8. T117: repetir el E2E desde rutas públicas, no sólo importando páginas o tests widget.

Cada paso sigue el ciclo: prueba de la capacidad → corrección mínima si falla → prueba nuevamente →
registro inmediato de la evidencia.

### Paso 5 — Levantar el stack remoto desechable

1. Instalar/iniciar Docker Desktop o Podman.
2. Ejecutar `supabase --workdir backend start`, `db reset` y `test db`.
3. Repetir T026, T068 y T105 con pgTAP/RLS/RPC, anonymous, owner A, owner B y bypass directo.
4. Ejecutar T121 con Edge Functions y una matriz Android API 24+ además de API 37.

No se debe simular PASS mientras el stack no exista.

### Paso 6 — Resolver T116 y T123

Para T116, corregir sólo lo que exige el guard vigente: imports cross-feature mediante las APIs
públicas (`agricultural_context_api.dart`, `territory_api.dart`, `labors_api.dart`), eliminar el
directorio genérico `domain/services` y romper el ciclo
`agricultural_context → territory → history → agricultural_context` mediante contratos existentes.
Después repetir `dart run tool/check_architecture.dart` y la prueba de privacidad.

Para T123, investigar el origen del cambio de bytes de `backend/supabase/config.toml`, conservar la
historia append-only y actualizar el manifest/reporte sólo con el hash comprobado. Repetir
`node docs/architecture/verify-migration.cjs`.

### Paso 7 — Cierre y trazabilidad

1. Ejecutar T118 y asignar exactamente un resultado a PF-01..PF-30.
2. Ejecutar T124: Constitution Check, scope guard, arquitectura, FR, SC y PF.
3. Marcar `[X]` sólo tareas cuyo criterio completo tenga evidencia; mantener `[ ]` para parciales.
4. Declarar 003 completo únicamente cuando T124 sea verde y no queden dependencias abiertas.

## Paralelización segura

Después de congelar contratos, pueden avanzar en paralelo T057 (frontend), T111 (backend), T113
(frontend) y T114 (regresión de integración). T026/T068/T105/T121 deben esperar el stack Supabase;
T030/T050/T058/T080/T094/T110/T115/T117 dependen de sus respectivos backend y fixtures.

## Referencias

- [Reporte de las 16 integraciones en Pixel 8](003-integration-pixel8-report.md)
- [Plan restante de 003](003-remaining-plan.md)
- [Matriz de evidencia](003-release-matrix.md)
