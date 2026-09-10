# AgroCampo 003 — plan de cierre y estado de implementación

**Fecha del corte:** 2026-09-10

**Estado:** `parcial — no listo para release`
**Fuente de verdad:** `specs/003-agrocampo-functional-refinement/tasks.md`, `spec.md`, `plan.md`,
`quickstart.md`, `docs/verification/003-release-matrix.md` y la Constitución v2.1.0.

Este documento planifica únicamente el trabajo que falta para convertir los flujos clasificados
como **Completado por 003** en funcionalidad persistente y comprobable. No agrega funcionalidades,
no crea un módulo de código `003` y no sustituye los estados `[ ]` del `tasks.md`.

## Resumen ejecutivo

El `tasks.md` contiene **124 tareas**, de las cuales **101 están `[X]` y 23 permanecen `[ ]`**.
El número exacto pendiente es 23, no 20. La distribución de las 23 tareas abiertas es:

La ejecución de las 16 tareas del carril Integración sobre el Pixel 8 está documentada en
[`003-integration-pixel8-report.md`](003-integration-pixel8-report.md). Sus suites locales verdes
no sustituyen los criterios remotos, de navegación pública o de gates que cada tarea declara.

| Carril | Abiertas | Observación |
|---|---:|---|
| Backend | 4 | Generación Drift, sync de riego, regresiones auxiliares y gate backend |
| Frontend | 3 | Guard de rotaciones, regresiones auxiliares y gate Flutter |
| Integración | 16 | Flujos verticales, Supabase/RLS, Android, trazabilidad y gates finales |
| **Total** | **23** | **19 secuenciales por dependencia; 4 paralelizables `[P]`** |

Las 4 tareas marcadas `[P]` de forma segura son **T057, T111, T113 y T114**. El resto comparte
artefactos, necesita resultados de otra fase o debe ejecutarse como cierre; por eso no se marca como
paralelo aunque partes de su preparación puedan adelantarse.

## Qué ya está completado

| Fase | Hecho | Estado |
|---|---|---|
| Setup | Baseline G0, separación de dependencias 002 y matriz de evidencia | 2/2 |
| Foundational | Outcomes tipados, dominios `crop/apiary`, política de compatibilidad, contexto ligado, esquema v11, SQL 0020 y guardas de arquitectura | 13/14; sólo T013 abierta |
| US1 | Sector/categoría, geometría confirmada/cancelada, reapertura, contexto, codec y UI sin inferencia por icono | 12/14 |
| US2 | Registrar, Suelo, Cosecha/Producción, Fitosanitario, Cultivo, Otra, envelope v2, rollback y snapshots | 19/20 |
| US3 | Asignaciones por fecha, no solapamiento, snapshots históricos y codec category-aware | 6/8 |
| US4 | Riego manual, caudal/duración/presión, volumen básico, snapshot y `crop_rule_unavailable` | 13/14 |
| US5 | Manual/Foliar/Fertirriego, opcionales nulos, vínculo de riego y corrección por supersesión | 7/8 |
| US6 | Operaciones apícolas discriminadas, fotos privadas, labor root y sync compound | 13/14 |
| US7 | Historial, filtros, detalles, outbox, idempotencia, conflictos y reapertura offline | 14/16 |
| US8 | Exportación sin inventar campos | 1/6 |
| Cierre | Perfil de rendimiento documentado (T122) | 1/8; T117–T121, T123–T124 abiertas |

Evidencia disponible en el corte:

- Backend: `flutter test --no-pub` **PASS — 151 tests**, incluido el fallo de almacenamiento de
  T038 sin limpiar el borrador.
- Frontend: `flutter test --no-pub` **PASS — 60 tests**, incluidos goldens.
- Persistencia: escenario file-backed **PASS — 100 mutaciones y migración v9→v11**.
- Prototipo: `node agrocampo-acceptance.test.js` y sintaxis JavaScript embebida **PASS**.
- Alcance: no existe `modules/003` y la búsqueda de funcionalidades prohibidas no encontró hits.
- El emulador Pixel 8 API 37.1 (`emulator-5554`) está conectado por ADB y ya se generó/instaló un
  APK debug nuevo. El procedimiento reproducible, permisos y GPS están documentados en
  [`android-pixel8-build-plan.md`](android-pixel8-build-plan.md).

## Las 23 tareas que faltan

La siguiente tabla es el plan ejecutable. Cada fila conserva el ID y el carril de `tasks.md` y
define la evidencia que debe quedar en la matriz antes de marcar `[X]`.

| ID | Carril | Trabajo restante y criterio de salida | Dependencias / bloqueo actual |
|---|---|---|---|
| **T013** | Backend | Regenerar Drift y snapshots v11; ejecutar la migración generada y comparar `g.dart`, `drift_schema_v11.json` y schemas de test. | Requiere que `build_runner` termine; hoy se queda colgado. Bloquea T026, T068, T105 y T123. |
| **T026** | Integración | Ejecutar paridad Dart/PostgreSQL para creación explícita, `kind` inmutable y rechazo sin filas/outbox remotos. | T017–T025 y Supabase/SQL local disponible; CLI/Docker no están instalados. |
| **T030** | Integración | Ejecutar widget + integration + dispositivo del mapa: crear/editar/confirmar/cancelar, reapertura, GPS denegado y mapa remoto degradado. | T029 y APK compilable en Pixel 8; build y ADB ya están disponibles, falta la matriz completa. |
| **T050** | Integración | Ejecutar Registrar→detalle→historial→reapertura para labor general, Suelo y Cosecha, verificando una fila/evento y datos completos. | T047/T049 y flujo de historial T100; falta ejecutar el integration test. |
| **T057** `[P]` | Frontend | Mostrar contexto, fecha efectiva y estados reales de rotación; bloquear activación anticipada y ocultar rotación en `apiary`. | Contrato/backend US3 congelado (T051–T056). Puede hacerse en paralelo con T111/T113/T114. |
| **T058** | Integración | Probar navegación, planificación, cancelación, activación temporal y reapertura sin tocar historia ni categoría. | T057 + backend T054–T056; requiere integración Flutter estable. |
| **T068** | Backend | Probar push/pull de riego, duplicate/hash, fallo de especialización y preservación de caudal, duración y presión. | T067 y Supabase SQL; también depende de T013 para el esquema generado. |
| **T080** | Integración | Probar Manual/Foliar/Fertirriego desde UI hasta detalle/reapertura, sin dosis inventada y rechazando `apiary`. | T079 y backend T076–T078; APK/harness ya disponible, falta la ejecución completa. |
| **T094** | Integración | Probar todas las familias apícolas, foto, restart, historia única y cruces inválidos crop↔apiary. | T093 y T086–T092; APK/harness ya disponible, falta la matriz Android/file-backed. |
| **T105** | Integración | Ejecutar 0001–0020, handlers compound, matriz de categoría, RLS anonymous/owner A/owner B y bypass directo. | Supabase CLI + Docker + pgTAP; no disponibles actualmente. T013 también es prerrequisito. |
| **T110** | Integración | Probar historial por sus tres entradas, restart, respaldo, ACK perdido y conflicto sin duplicados. | T106/T109 y APK compilable; build disponible, falta el ciclo Android completo. |
| **T111** `[P]` | Backend | Reforzar regresiones de weather-proxy/AgroIA: timeout, caché/vigencia, payload mínimo y cero mutaciones/cálculos críticos. | Suites Dart/TypeScript; Edge Functions necesitan Deno/Supabase. Paralela e independiente de T057. |
| **T113** `[P]` | Frontend | Probar estados degradados, reintento explícito y navegación preservada para clima, AgroIA y exportación. | Contratos existentes; puede ejecutarse en paralelo con T057/T111/T114 si Flutter compila. |
| **T114** `[P]` | Integración | Ejecutar sólo la regresión mínima de Perfil/Notificaciones/Seguridad demostrada por T001 y registrar PASS/N/A. | No cierra T016/T096/T115/T118 de 002. Paralela si la evidencia de T001 sigue aplicable. |
| **T115** | Integración | Inyectar fallas independientes de mapa/GPS/clima/AgroIA/Supabase y demostrar continuidad local e aislamiento de sesión. | Pixel 8 + APK actual disponibles; falta ejecutar la matriz de fallas. |
| **T116** | Integración | Verificar privacidad, ausencia de Google Maps, ausencia de cálculos/escrituras autoritativas externas y arquitectura. | Requiere que `flutter analyze` y `check_architecture.dart` produzcan resultado; ambos cuelgan. |
| **T117** | Integración | Completar E2E representativo SC-004/SC-014 desde navegación pública hasta detalle/historial/reapertura para labor, Suelo, riego, fertilización y apiary. | US1–US7 y APK instalable disponibles; la suite representativa 7/7 pasa, pero falta verificar navegación pública y criterios completos. |
| **T118** | Integración | Ejecutar PF-01..PF-30 contra `jerarquía 01.md`, `master.md` y ambos prototipos; exigir implementación+prueba para cada PF “Completado por 003”. | T117 y suites previas. Los 30 PF ya están clasificados, pero falta la ejecución final. |
| **T119** | Backend | Ejecutar format, analyze y suite backend completa de G0–G10/G12 y registrar comandos/salidas reproducibles. | `dart format --set-exit-if-changed` no converge por fin de línea/SDK; `flutter analyze` no entrega salida. |
| **T120** | Frontend | Ejecutar format, analyze, widgets, goldens e integration completos y registrar resultados. | APK ya compilable; format/analyze siguen sin salida reproducible y falta la suite completa. |
| **T121** | Integración | Ejecutar pgTAP/RLS/RPC, Deno de Edge Functions y Android API 24+ en stacks desechables configurados por `quickstart.md`. | Faltan Supabase, Docker y Deno; API 24+ todavía no se ha ejecutado. |
| **T123** | Integración | Actualizar de forma append-only el manifest/reporte de Drift v11 y Supabase 0020 y ejecutar `verify-migration.cjs`. | El verificador detecta mismatch histórico en `backend/supabase/config.toml` (hash esperado ≠ bytes actuales). Resolver con evidencia, no sobrescribir historia a ciegas. |
| **T124** | Integración | Ejecutar Constitution Check, arquitectura, scope guard y gates FR/SC/PF; confirmar US1–US7 completos sin placeholders ni alcance prohibido. | Último paso: depende de T013, T026, T030, T050, T058, T068, T080, T094, T105, T110 y T117–T123. |

## Orden recomendado de ejecución

1. **Desbloqueo de herramientas (sin cambiar alcance):** hacer disponible `build_runner` de
   Drift, Supabase CLI/Docker, Deno y una compilación Gradle reproducible para el AVD Pixel 8.
   Mantener el mismo checkout y registrar versiones en la matriz.
2. **Fundación de datos:** ejecutar T013 y volver a correr la prueba de migración. Con el esquema
   generado verde se habilitan las comprobaciones de paridad y sync.
3. **Ola backend/SQL:** ejecutar T026 y T068; ejecutar T105 cuando el stack Supabase esté listo.
   Cada una sigue el ciclo de contract/unit → persistencia → codec/outbox → SQL.
4. **Ola frontend paralela:** T057, T111, T113 y T114 son la única ola marcada `[P]`; sus
   archivos son independientes y sólo consumen contratos congelados.
5. **Flujos verticales:** T030, T050, T058, T080 y T094, cada uno después de su backend verde;
   ejecutar widget primero, luego integration/device y registrar la evidencia inmediatamente.
6. **Durabilidad y resiliencia:** T110 y T115, incluyendo restart, ACK perdido, conflicto y
   aislamiento de fallas. Usar el APK recién generado y el procedimiento de
   [`android-pixel8-build-plan.md`](android-pixel8-build-plan.md), no el artefacto fechado 2026-09-06.
7. **Cierre de calidad:** T116, T119, T120, T121 y T123 pueden correr en paralelo sólo cuando
   sus herramientas estén disponibles y no compartan un artefacto mutable; T123 debe conservar
   el historial del manifest.
8. **Decisión final:** T117 → T118 → T124. Si una prueba falla, corregir y repetir el ciclo
   antes de avanzar; si una herramienta no está disponible, dejar la tarea `[ ]` y documentar el
   bloqueo.

## Plan de pruebas por carril

### Backend

- **Reglas/contratos:** T013 (schemas), T026 (paridad sector), T068 (sync riego) y T111
  (weather/AgroIA). Deben probar valores válidos, límites, errores, `null` frente a cero,
  duplicate/hash y ausencia de mutaciones críticas.
- **Persistencia y migraciones:** repetir migración v10→v11 y los escenarios file-backed antes de
  cualquier push/pull remoto. La evidencia debe incluir IDs, conteos, JSON, outbox, snapshots y
  `legacyUnknown` preservados.
- **Gate final:** T119 no es una prueba nueva de negocio: consolida format/analyze y los 151 tests
  ya verdes, pero sólo puede marcarse cuando los comandos terminen con salida reproducible.

### Frontend

- **Widget/golden:** T057, T080, T113 y las partes widget de T030/T050/T094 deben comprobar
  contexto visible, errores accionables, borrador preservado, estados degradados y campos reales.
- **Integration/device:** T030, T050, T058, T080, T094, T110, T115 y T117 deben ejecutarse en el
  AVD Pixel 8 con APK recién generado; el build/instalación ya está resuelto. Verificar reapertura,
  historial y confirmación/cancelación en cada suite.
- **Gate final:** T120 consolida `flutter test`, goldens, format y analyze. Una ejecución atascada
  no cuenta como PASS.

### Integración y remoto

- **Supabase/RLS/pgTAP:** T026, T068, T105 y T121 deben correr contra migraciones 0001–0020 en
  un stack desechable, cubriendo anonymous, owner A, owner B, bypass directo y rollback.
- **Sync/offline:** T050, T058, T080, T094 y T110 deben demostrar exactamente-once, ACK perdido,
  conflicto recuperable y cero duplicados después de cerrar/reabrir.
- **Trazabilidad/gates:** T114, T116, T118, T123 y T124 sólo registran evidencia existente; no
  habilitan funcionalidades nuevas ni sustituyen pruebas de flujo.

## Bloqueos reproducibles que deben resolverse

1. **Drift:** `dart run build_runner build --delete-conflicting-outputs` no termina; T013 queda
   abierta y no se debe editar manualmente el generado para simular la salida.
2. **Supabase/Edge:** CLI, Docker y Deno no están disponibles; por ello pgTAP/RLS/RPC/Edge
   Functions no tienen PASS local (T026, T068, T105, T111, T121).
3. **Android (resuelto parcialmente):** el SDK Flutter escribible/elevado permite generar e
   instalar un APK nuevo y las suites representativas del Pixel 8 pasan. Permanecen pendientes
   las matrices específicas T030/T050/T058/T080/T094/T110/T115/T117 y los gates T120/T121; no se
   debe declarar PASS por extrapolación.
4. **Análisis:** `flutter analyze` y `dart run tool/check_architecture.dart` quedan sin salida;
   T116/T119/T120/T124 deben permanecer abiertas.
5. **Formato:** el SDK vuelve a reportar cambios de formato/fin de línea en cada pasada de
   `dart format --set-exit-if-changed`; documentar la no convergencia hasta disponer de un SDK
   estable, sin marcar el gate verde por fuerza.
6. **Manifest de migración:** `verify-migration.cjs` informa mismatch para
   `backend/supabase/config.toml` (hash actual `8fc08e…` frente al esperado `8a1d22…`). Resolver
   el origen de los bytes y actualizar el reporte sólo de forma append-only (T123).

## Trazabilidad PF-01..PF-30

Los 30 flujos tienen clasificación y ruta en `tasks.md`: PF-01–03, PF-05 y PF-20–26 son
preservados; PF-04 y PF-06–19 son **Completados por 003**; PF-27–30 están fuera de alcance. No
queda ningún PF sin clasificar. Sin embargo, **T118 sigue abierta**, por lo que esta cobertura
documental no equivale todavía a una regresión PASS en Android.

## Criterio de finalización

003 sólo puede declararse funcionalmente completo cuando T013, T026, T030, T050, T057, T058,
T068, T080, T094, T105, T110, T111, T113, T114, T115, T116, T117, T118, T119, T120, T121,
T123 y T124 tengan evidencia PASS o N/A explícitamente justificado donde el propio `tasks.md` lo
permite. Hasta entonces, conservar `[ ]`, mantener el estado `parcial` de la matriz y dejar el
checkout listo para continuar, no para publicar como release.
