# AgroCampo 003 — ejecución de integración en Pixel 8

**Fecha:** 2026-09-10
**Dispositivo:** `Pixel_8` / `emulator-5554` / Android API 37.1
**APK:** `frontend/build/app/outputs/flutter-apk/app-debug.apk`

Este reporte cubre las 16 tareas con carril **Integración** que permanecían abiertas. Las suites
se ejecutaron con `flutter test ... -d emulator-5554`; las tareas que requieren Supabase, pgTAP,
RLS, Docker, Deno o API 24+ se separan explícitamente y no se consideran verdes por extrapolación.

## Preparación del dispositivo

- `adb devices -l`: `emulator-5554 device`.
- `location_mode=3` y coordenada de prueba `-72.5984 -38.7397`.
- Se concedieron `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` y
  `POST_NOTIFICATIONS` después de cada reinstalación del runner.
- `flutter build apk --debug --no-pub` e instalación ADB: PASS.

## Matriz de las 16 tareas

| Tarea | Evidencia ejecutada | Resultado de ejecución | Estado de la tarea |
|---|---|---|---|
| **T026** | `backend/test/modules/territory/territory_sync_codec_test.dart` (2/2); `supabase --workdir backend test db` | Dart PASS. SQL bloqueado: PostgreSQL local rechazó conexión (`ECONNREFUSED 127.0.0.1:54422`). | **Parcial** — falta paridad PostgreSQL. |
| **T030** | `territory_map_page_test.dart` (2/2); `territory_flow_test.dart` (1/1); `android_map_device_test.dart` (1/1) | PASS en widget y Pixel 8: OSM, GPS, geometría, cancelar/confirmar y reapertura. | **Parcial** — falta la matriz completa desde navegación pública, GPS denegado y degradación remota en el mismo flujo. |
| **T050** | Labor (2/2), Suelo (1/1), Producción (1/1); `labors_production_flow_test.dart` (1/1) | PASS en Pixel 8 y widgets; persistencia/reapertura del escenario local verde. | **Parcial** — el escenario sigue siendo harness local y no cubre toda la navegación pública. |
| **T058** | `seasons_crops_flow_test.dart` (1/1) en Pixel 8; `multi_context_scenario.dart` (1/1) | PASS: segunda base file-backed y contexto/categoría preservados. | **Parcial** — falta demostrar todas las transiciones desde UI pública. |
| **T068** | `irrigation_sync_codec_test.dart` (1/1); `supabase test db` | Codec Dart PASS, incluyendo snapshot de riego. SQL bloqueado por ausencia de PostgreSQL/Docker. | **Parcial** — falta push/pull remoto y duplicate/hash en Supabase. |
| **T080** | `fertilization_form_test.dart` (1/1); `fertilization_flow_test.dart` (1/1) en Pixel 8; escenario backend (1/1) | PASS: Manual/Foliar/Fertirriego y opcionales preservados. | **Parcial** — falta completar la matriz UI→detalle→reapertura y rechazo `apiary` contra backend remoto. |
| **T094** | `apiary_inspection_page_test.dart` (1/1); `apiary_flow_test.dart` (1/1) en Pixel 8; escenario backend (6/6) | PASS. El fixture de integración fue corregido para crear primero un Sector `kind: apiary`; el fallo previo era `owner_mismatch` por precondición incompleta. | **Parcial** — falta repetir todas las familias, foto y cruces inválidos en un flujo Android completo. |
| **T105** | `supabase --workdir backend start` / `test db` | Bloqueado: Docker y Podman no están instalados/en `PATH`; Supabase no puede levantar PostgreSQL. | **Bloqueada**. |
| **T110** | `history_production_flow_test.dart` (1/1), `synchronization_test.dart` (1/1), `sync_conflict_tombstone_e2e_test.dart` (7/7) en Pixel 8 | PASS: historial, restart, ACK perdido, tombstone, conflicto y ausencia de duplicados en harness local. | **Parcial** — falta respaldo remoto real y ACK contra Supabase. |
| **T114** | `001_compatibility_regression_test.dart` (12/12) y `android_platform_flow_test.dart` (4/4) en Pixel 8 | PASS para la regresión mínima de compatibilidad, biometría, GPS y notificaciones. No cierra tareas 002. | **Evidencia PASS** — registrar como regresión, sin cambiar propiedad de 002. |
| **T115** | `android_platform_flow_test.dart` (4/4), `session_sync_isolation_e2e_test.dart` (6/6), `agro_ai_privacy_flow_test.dart` (1/1), `weather_ai_export_flow_test.dart` (1/1), `weather_alert_flow_test.dart` (1/1) | PASS: degradación local, aislamiento de sesión, privacidad y exportación. | **Parcial** — falta inyección de fallo remoto Supabase y una matriz aislada por proveedor completa. |
| **T116** | `agro_ai_privacy_flow_test.dart` (1/1); `dart run tool/check_architecture.dart` | Privacidad PASS. Guard de arquitectura **FAIL (41 hallazgos)**: imports de implementación entre features, directorio `services` genérico y ciclo `agricultural_context → territory → history`. | **FAIL** — requiere corrección arquitectónica antes del gate. |
| **T117** | `functional_refinement_e2e_test.dart` (7/7) en Pixel 8 | PASS para los escenarios representativos de labor, Suelo, Producción, fertilización, apiary e historial. | **Parcial** — el archivo compone páginas/widget tests; aún falta entrada por navegación pública explícita. |
| **T118** | `node agrocampo-acceptance.test.js`; sintaxis embebida de `agrocampo-highfi.html` | Ambos PASS. | **Parcial** — falta cerrar la revisión PF-01..PF-30 con evidencia de cada flujo completado/preservado/fuera de alcance. |
| **T121** | `flutter devices`; intento de `supabase start` | Sólo hay AVD API 37; no existe dispositivo API 24+. Supabase bloqueado por Docker y las Edge Functions no tienen stack SQL local. | **Bloqueada**. |
| **T123** | `node docs/architecture/verify-migration.cjs` | **FAIL**: `backend/supabase/config.toml` tiene hash `8fc08e…`, pero el manifest espera `8a1d22…`. | **FAIL** — resolver append-only con evidencia histórica. |
| **T124** | scope guard (`rg`), arquitectura y estado de tareas | Scope sin funcionalidades prohibidas en código productivo; arquitectura FAIL y las dependencias anteriores permanecen abiertas. | **No listo** — no se puede declarar 003 completo. |

## Suites Android adicionales ejecutadas

Además de las suites ligadas directamente a cada fila, se ejecutaron en el mismo AVD:

- `functional_refinement_e2e_test.dart`: **7/7 PASS**.
- `android_platform_flow_test.dart`: **4/4 PASS**.
- `session_sync_isolation_e2e_test.dart`: **6/6 PASS**.
- `sync_conflict_tombstone_e2e_test.dart`: **7/7 PASS**.
- `weather_ai_export_flow_test.dart`, `weather_alert_flow_test.dart` y
  `agro_ai_privacy_flow_test.dart`: **1/1 PASS cada una**.

Los avisos de Gradle/Kotlin observados son warnings no bloqueantes. El bloqueo de SQL/RLS no se
puede resolver desde el Pixel 8: requiere Docker/Podman y un stack Supabase local desechable.

## Conclusión

El entorno Android quedó operativo y las rutas locales de integración están verdes. Las 16 tareas
no se marcan automáticamente como `[X]`: T026, T030, T050, T058, T068, T080, T094, T110, T115,
T117 y T118 conservan criterios remotos o de navegación pública; T105 y T121 están bloqueadas
por Docker/API24; T116 y T123 fallan por arquitectura y manifest; T124 depende de todas ellas.

La matriz general y el orden de cierre permanecen en [`003-release-matrix.md`](003-release-matrix.md)
y [`003-remaining-plan.md`](003-remaining-plan.md).
