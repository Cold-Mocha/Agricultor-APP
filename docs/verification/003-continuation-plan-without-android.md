# Plan de continuación AgroCampo 003 sin pruebas Android

Fecha: 2026-09-11  
Rama: `003-agrocampo-functional-refinement`  
Estado de partida: 107/124 tareas completadas; 17 abiertas.

## Objetivo y regla de cierre

Este documento complementa el `plan.md` canónico de 003 y no cambia el alcance aprobado por
`spec.md`, `research.md`, `data-model.md`, `quickstart.md`, `tasks.md` y
`.specify/memory/constitution.md`. El emulador Pixel 8 queda fuera de este ciclo. Por tanto, se
cerrarán únicamente los criterios que puedan demostrarse con backend, Supabase local, Deno,
pruebas Flutter en host y dobles de plataforma controlados. Los criterios que la especificación
exige ejecutar en Android, especialmente API 24+, no se convertirán artificialmente en PASS:
quedarán como `N/A-ANDROID/BLOQUEADO`, con su evidencia y la condición exacta para liberarlos.

Cada tarea seguirá obligatoriamente este ciclo: prueba inicial (preferiblemente roja o evidencia
del hueco), implementación mínima, nueva prueba, diagnóstico del fallo, corrección y repetición
hasta PASS. La tarea sólo se marcará `[X]` cuando todos sus criterios no Android tengan evidencia
reproducible. No se aceptarán suites representativas parciales, mocks que oculten errores de
contrato ni cambios de producto usados sólo para hacer pasar una prueba.

## Fase 0 — baseline y entorno reproducible

1. Congelar el inventario actual sin tocar cambios ajenos y confirmar las fuentes obligatorias,
   la frontera `frontend -> package:agrocampo_backend/agrocampo_backend.dart`, la ausencia de un
   módulo paralelo `003` y el estado 107/124.
2. Preparar un directorio temporal para `SUPABASE_HOME`, `XDG_RUNTIME_DIR`, `PUB_CACHE` y
   `GRADLE_USER_HOME`; no instalar herramientas dentro del repositorio ni depender de secretos
   remotos.
3. Preferir Docker. Diagnosticar con `docker info`, `docker compose version`, permisos del socket,
   grupo del usuario, contexto activo y servicio del daemon. Si el socket sigue inaccesible, no
   modificar permisos globales: iniciar un daemon Docker autorizado por el entorno o usar el
   fallback Podman rootless con runtime, root y runroot en `/tmp`.
4. Con Podman, validar primero `podman info`, una imagen mínima y, si se necesita compatibilidad,
   `podman system service` mediante un socket temporal expuesto como `DOCKER_HOST`. La prueba de
   contenedor debe ser un gate independiente antes de iniciar Supabase.
5. Instalar o localizar Supabase CLI y Deno en rutas temporales. Registrar versión, hash o fuente
   de instalación y repetir el flujo con `SUPABASE_TELEMETRY_DISABLED=1`.

## Fase 1 — T026, T068 y T105: contratos, migraciones y RLS

T026 es el primer gate porque referencia `backend/supabase/tests/database/productive_domain_compatibility_test.sql`,
que debe existir o quedar explicado por una corrección de ruta antes de ejecutar la tarea. Primero
ejecutar Dart y pgTAP por separado para capturar el fallo actual. Después implementar sólo la
prueba SQL faltante y cualquier ajuste mínimo de codec necesario para demostrar creación explícita,
inmutabilidad, paridad Dart/PostgreSQL y rechazo de filas/outbox remotos inválidos.

Con el stack local limpio, ejecutar `supabase db reset --local`, esperar el sentinel de migraciones
0001–0020 y consultar el esquema antes de probar. T105 debe producir una matriz explícita para
anonymous, owner A, owner B y bypass directo; comprobar handlers compound, categorías válidas,
RLS, RPC y ausencia de acceso cruzado. T068 debe cubrir push/pull, duplicate/hash, fallo de
especialización y payload de caudal, duración y presión, incluyendo idempotencia y no duplicación.
Cada fila de la matriz debe guardar comando, resultado, migración/commit y salida PASS.

Dependencia: T026 debe PASS antes de cerrar T068; T068 y T105 deben PASS antes de T110 y T121.

## Fase 2 — T111: Edge Functions y Deno local

Ejecutar primero las pruebas Deno existentes de `weather-proxy` y `agro-ai` para comprobar el
estado inicial. Reforzar sólo las regresiones descritas: timeout, caché y vigencia, payload mínimo,
localidad inválida, ausencia de mutaciones y exclusión de datos privados/cálculos críticos.

Levantar las funciones mediante el runtime local de Supabase con el stack ya validado; usar un
usuario efímero local y respuestas controladas para Open-Meteo/Gemini. Verificar 401 sin sesión,
rechazo de entrada inválida, aislamiento por usuario, degradación sin red y que una respuesta de
IA no persista recomendaciones ni altere la verdad agronómica. No usar claves reales. Un fallo de
resolución entre contenedores se diagnostica reiniciando el stack completo, comprobando health y
puertos, antes de tocar código. T111 sólo se cierra con Deno y endpoint local PASS.

## Fase 3 — integración Flutter en host: T030, T050, T058, T080 y T094

Separar los escenarios host de los Android-only sin cambiar producción. Para cada módulo ejecutar
la prueba inicial, completar el test de UI y el escenario de persistencia file-backed/Drift, y
reabrir la entidad desde su ruta pública: registrar → detalle → historial → reapertura. Usar fakes
de GPS, tiles, cámara y permisos únicamente en el arnés de prueba.

* T030: territorio, geometría y denegación GPS; probar mapa remoto degradado y reapertura local.
  `android_map_device_test.dart` y permisos reales quedan N/A Android.
* T050: labor general, medición de suelo y cosecha única, con detalle e historial.
* T058: planificación, cancelación, activación temporal y reapertura sin mutar historia ni
  categoría.
* T080: los tres métodos de fertilización, dosis declarada y rechazo de operación apícola.
* T094: cada familia apícola, foto mediante fake controlado, restart, una sola historia y rechazos
  de operaciones cruzadas.

No avanzar de una tarea al siguiente gate hasta tener implementación, prueba y evidencia PASS de
ese escenario host. Si el runner `integration_test` intenta exigir un dispositivo, crear un
runner host-only de pruebas, sin cambiar el comportamiento de la aplicación, y etiquetar el caso
Android que permanezca sin ejecutar.

## Fase 4 — T110, T113, T115 y T117: continuidad, degradación y E2E público

T110 debe probar las tres entradas al historial, restart, respaldo, ACK perdido, conflicto y
tombstone sin duplicados, usando Supabase local y base Drift temporal. T113 debe verificar en host
clima, AgroIA y exportación: loading, éxito, timeout, offline, error de formato, reintento explícito
y navegación preservada. T115 debe inyectar por separado fallas de mapa/GPS/clima/AgroIA/Supabase
y demostrar continuidad local e aislamiento de sesión; el bloque que dependa de plugins Android no
es PASS en este ciclo.

Para T117 no basta importar mains de widgets. Implementar o corregir un E2E host que arranque la
navegación pública real y recorra labor general, suelo, riego, fertilización y apiary hasta detalle,
historial y reapertura. Registrar una evidencia por ruta y por entidad, no una sola pantalla
representativa.

## Fase 5 — T120, T118, T121 y T124: gates finales

T120 consolida format, analyze, unit/widget, goldens e integración host de backend y frontend.
Además se ejecutan la aceptación de los prototipos y la validación JavaScript indicada por
`AGENTS.md`, sin confundirlas con pruebas de la aplicación Flutter.

T121 se divide explícitamente: pgTAP/RLS/RPC, migraciones locales y Deno pueden obtener PASS con
Docker o Podman; Android API 24+ queda BLOQUEADO hasta disponer de un dispositivo/AVD. T118 llena
`docs/verification/003-release-matrix.md` para PF-01..PF-30, usando `master.md` y `jerarquía 01.md`;
cada PF “Completado por 003” debe enlazar implementación y prueba, mientras los preservados o fuera
de alcance conservan su estado sin cerrar tareas de 002. T124 ejecuta Constitution Check,
arquitectura, scope guard, FR/SC/PF y confirma que no existan placeholders, identidad paralela,
cambio crop↔apiary ni recomendación avanzada.

## Criterio de salida

La salida esperada de este ciclo es: todas las partes host verificables de las 17 tareas en PASS,
matriz y logs reproducibles actualizados, y una lista separada de bloqueos Android. Si el criterio
formal de una tarea incluye Android, no se marcará `[X]` sólo por pasar Flutter host. El release gate
global queda `NO LISTO` mientras T121/API 24+ u otro criterio Android obligatorio siga bloqueado.
Cuando exista un AVD o dispositivo, se ejecutarán únicamente esos casos pendientes y se reutilizará
la misma matriz, sin repetir ni alterar los PASS host ya demostrados.
