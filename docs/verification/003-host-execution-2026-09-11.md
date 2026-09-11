# AgroCampo 003 — evidencia de ejecución host-only

Fecha: 2026-09-11  
Alcance: backend, Supabase local, Edge Functions con Deno, Flutter host, contratos,
páginas, persistencia file-backed, migraciones, sincronización y prototipos.  
Exclusión explícita: no se ejecutaron `flutter drive`, `flutter test integration_test`,
ADB, APK sobre dispositivo ni pruebas de permisos/GPS/ciclo de vida Android, porque
`emulator-5554` no está disponible.

Este documento aplica el ciclo exigido por
[`003-continuation-plan-without-android.md`](003-continuation-plan-without-android.md):
prueba inicial, cambio mínimo, repetición, diagnóstico/corrección y evidencia final.
Los artefactos de código y pruebas están en el repositorio; las salidas completas de las
suites se conservaron durante la ejecución y sus resultados resumidos se registran aquí.

## Entorno desbloqueado

| Componente | Preparación | Verificación |
|---|---|---|
| Flutter/Dart | SDK local `/tmp/flutter` | Flutter 3.47/Dart 3.13; `analyze` PASS |
| Supabase CLI | instalación temporal en `/tmp/agrocampo-supabase-cli` | `supabase --version` → 2.117.0 |
| Docker | daemon del host accesible con permiso elevado del sandbox | `docker info` → Engine 29.8.0 |
| Supabase local | `SUPABASE_HOME=/tmp/agrocampo-supabase-home supabase --workdir backend start` | servicios locales levantados |
| Deno | instalación temporal en `/tmp/agrocampo-deno` | `deno --version` → 2.9.6 |

El fallo inicial de Docker fue de acceso al socket desde el sandbox (`/var/run/docker.sock`),
no de daemon detenido. Como fallback independiente, Podman rootless funcionó con runtime y
runroot temporales bajo `/tmp` y compatibilidad `DOCKER_HOST`; no fue necesario usarlo para
la ejecución final porque Docker quedó disponible.

## Ciclos por tarea abierta

| Tarea | Prueba inicial / diagnóstico | Implementación mínima y repetición | Resultado host y criterio |
|---|---|---|---|
| T026 | Codec Dart inicial: 2/2 PASS; faltaba prueba SQL productiva independiente. | Se añadió `productive_domain_compatibility_test.sql` y dos casos codec; codec 4/4 y pgTAP completo PASS. | PASS — paridad de categoría explícita, inmutabilidad y rollback sin fila/outbox remoto. |
| T030 | Widget territorial 2/2 PASS; integración Android inicial falló por `No supported devices connected`. | Se mantuvo el widget host y no se simuló el dispositivo. | N/A-ANDROID/BLOQUEADO — falta GPS real, mapa remoto degradado y reapertura en Android. |
| T050 | Widgets suelo/producción 2/2 PASS; el escenario file-backed se ejecutó como backend local. | Se verificó persistencia/reapertura y sincronización con el escenario `labors_production_v2_local_e2e_test.dart`. | PASS HOST — labor, suelo y producción preservan detalle; el runner Android queda fuera de alcance de esta ejecución. |
| T058 | Rotación unitaria 4/4 PASS; faltaba confirmar contexto/reapertura integrada. | `seasons_crops_v2_local_e2e_test.dart` y `multi_context_scenario.dart`: 2/2 PASS. | PASS HOST — fecha efectiva, contextos y no alteración histórica. |
| T068 | Codec riego inicial sin cobertura completa SQL. | Codec `irrigation_sync_codec_test.dart`: 3/3 PASS; pgTAP local completo incluye `irrigation_sync_v2_test.sql`. | PASS — push/pull, duplicate/hash, fallo de especialización y caudal/duración/presión. |
| T080 | Formulario de fertilización 1/1 PASS; faltaba recorrer los tres métodos en flujo. | Se repitió el selector manual/foliar/fertirriego y el escenario file-backed; suite completa PASS. | PASS HOST — campos pertinentes, opcionales nulos y ausencia de dosis inventada. |
| T094 | Página apícola inicial PASS; faltaban familias y enlaces persistentes. | `apiary_functional_refinement_scenario.dart`: 7/7 PASS; página host PASS. | PASS HOST — seis familias, fotos, restart, evento único y gates cruzados. |
| T105 | Inicialmente no había pgTAP local ejecutable. | Supabase local reset aplicó 0001–0020; 17 archivos/164 tests pgTAP PASS. | PASS — compound handlers, RLS por propietario, bypass directo e idempotencia. |
| T110 | Contrato de sync PASS parcial; faltaba ACK perdido/conflicto/tombstone integrado. | Contratos + `sync_conflict_tombstone_scenario.dart`: 14/14 PASS. | PASS HOST — ACK perdido sin duplicados, conflictos, cursor y tombstones. |
| T111 | Edge Functions no ejecutables antes de instalar Deno. | Deno: 5/5 tests; escenarios weather/AgroIA: 3/3; endpoints locales sin auth: 401 controlado. | PASS HOST — timeout, caché, payload mínimo, privacidad y ausencia de mutaciones. |
| T113 | Widget clima PASS; flujo combinado y exportación faltaban. | Se añadió `weather_ai_export_flow_host_test.dart`; flujo host + golden export: 2/2 PASS. | PASS HOST — degradación/reintento/navegación y XLSX verificable. |
| T115 | La prueba Android inicial no pudo iniciar por falta de dispositivo. | Aislamiento de sesión host: 7/7 PASS; no se sustituyeron GPS/mapa/plugins reales. | N/A-ANDROID/BLOQUEADO — falta el criterio vertical Android completo. |
| T117 | E2E con binding de integración requería dispositivo y podía quedarse esperando timers. | Se aisló el diagnóstico y se añadió `functional_refinement_e2e_host_test.dart` con GoRouter y 12 rutas públicas; 1/1 PASS. | PASS HOST — navegación pública y resolución de rutas 003; sin afirmar lifecycle Android. |
| T118 | Matriz histórica estaba parcial y sin clasificación operativa por evidencia actual. | Se actualizó la matriz con PF-01..PF-30, clasificación única, enlaces y gates host/Android. | PASS HOST — trazabilidad documental y aceptación estática; Android permanece separado. |
| T120 | Suites parciales históricas tenían conteos desactualizados. | Format, analyze y suites completas repetidas: backend 156/156, frontend 66/66; goldens PASS. | N/A-ANDROID/BLOQUEADO — falta ejecutar los integration tests Android exigidos por quickstart. |
| T121 | Supabase CLI/Docker/Deno no disponibles en la prueba inicial histórica. | Stack Supabase local, migraciones, pgTAP y Deno quedaron reproducibles y PASS. | N/A-ANDROID/BLOQUEADO — API 24+ no se ejecutó por instrucción explícita. |
| T124 | Gates finales referenciaban bloqueos de infraestructura y matriz incompleta. | Arquitectura, migración, aceptación, sintaxis, format/analyze y scope guard se repitieron. | N/A-ANDROID/BLOQUEADO — no se puede confirmar US1–US7 globalmente sin los criterios Android. |

## Comandos y salidas finales

```text
backend: flutter test --no-pub --reporter compact       PASS — 156 tests
frontend: flutter test --no-pub --reporter compact      PASS — 66 tests
backend: dart format --output=none --set-exit-if-changed PASS — 301 files, 0 changed
frontend: dart format --output=none --set-exit-if-changed PASS — 166 files, 0 changed
backend: flutter analyze --no-pub                       PASS — No issues found
frontend: flutter analyze --no-pub                      PASS — No issues found
Supabase: db reset --local                              PASS — migrations 0001..0020
Supabase: pgTAP database suite                         PASS — 17 files, 164 tests
Deno: weather-proxy + agro-ai tests                     PASS — 5 tests
node agrocampo-acceptance.test.js                       PASS
embedded JavaScript syntax check                        PASS — 1 script
node docs/architecture/verify-migration.cjs             PASS — 426 entries
tool/check_architecture.dart                            PASS — Architecture check passed
git diff --check                                        PASS
```

## Decisión de cierre

Se pueden cerrar honestamente T026, T050, T058, T068, T080, T094, T105, T110, T111,
T113, T117 y T118 con evidencia host reproducible. T030, T115, T120, T121 y T124
conservan estado abierto/N/A-ANDROID porque sus criterios incluyen dispositivo, API 24+,
plugins, permisos o la confirmación global dependiente de ellos. El release global no está
listo; no se altera ese estado para convertir una prueba host en aprobación Android.
