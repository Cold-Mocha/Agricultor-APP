# AgroCampo 003 — investigación para liberar bloqueos de integración local

**Fecha:** 2026-09-11  
**Alcance:** backend, Supabase local, Edge Functions con Deno, frontend y plan de API 24+.  
**Fuera de alcance:** Pixel 8/`emulator-5554`, despliegues remotos, cambios de producto y cierre automático de tareas.

## Fuentes y reglas

Se revisaron `003-post-integration-gap-analysis.md`, `003-integration-pixel8-report.md`,
`003-remaining-plan.md` y los seis artefactos de `specs/003-agrocampo-functional-refinement/`:
`spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md` y `tasks.md`. También se
aplicaron `AGENTS.md` y `AGENTES.md`.

No existe un archivo `constitution.md` con ese nombre en el checkout. La Constitución v2.1.0 es
referenciada por `spec.md`, `plan.md` y `tasks.md`; sus reglas operativas están en el Constitution
Check de `plan.md`, el Scope Guard de `tasks.md` y la separación frontend/backend del repositorio.
Esto debe recuperarse o adjuntarse antes del gate documental T124; no se inventó una regla para
suplirlo.

La documentación oficial confirma que Supabase local necesita el CLI y un runtime compatible con
Docker, y lista Podman como alternativa compatible con la API Docker
([Local Development & CLI](https://supabase.com/docs/guides/local-development)). La CLI usa
`init`/`start` para levantar la pila local y puede instalarse como dependencia npm fijada
([Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started)).

## Conclusión ejecutiva

- Supabase CLI y Deno quedaron disponibles temporalmente en `/tmp`, sin modificar el checkout:
  Supabase CLI **2.117.0** y Deno **2.9.6**.
- Docker Engine **29.8.0** y Compose **5.5.1** sí están instalados. El contexto normal no puede
  abrir `/var/run/docker.sock`, que aparece como `660 nobody:nobody`; con el contexto autorizado
  Docker sí ejecuta la pila Supabase.
- Podman rootless falla con el runtime predeterminado porque `/run/user/1000/libpod` es no escribible
  en esta sesión. Con runtime, root y runroot en `/tmp`, Podman pasa `info`, ejecuta Alpine y expone
  una API Docker compatible.
- Supabase local, migraciones, pgTAP, RLS y RPC pasan después de esperar a que termine la
  inicialización: **16 archivos, 148 pruebas, PASS**.
- La primera ejecución FAIL de pgTAP fue una carrera de observación: el reset seguía aplicando
  migraciones cuando comenzó `test db`. El runbook exige un sentinel del esquema antes de pgTAP.
- API 24+ permanece pendiente porque el Pixel 8 se descarta y no hay otro AVD/dispositivo disponible.

## Evidencia ejecutada

| Área | Prueba | Resultado |
|---|---|---:|
| CLI | npm temporal + `supabase --version` | PASS — 2.117.0 |
| Deno | weather-proxy + AgroIA | PASS — 5/5 |
| Docker/Supabase | pila local y contenedores | PASS — 11 contenedores; DB/Kong/Auth/Realtime saludables |
| PostgreSQL | `supabase test db --local` tras esquema completo | PASS — 16 archivos/148 tests |
| Edge integrado | Auth local efímero → `weather-proxy` inválido | PASS — HTTP 400 `Invalid locality` |
| Edge runtime | log del contenedor | PASS — Edge Runtime 1.74.3 / Deno compatible 2.1.4 |
| Backend Flutter | `flutter test --no-pub` | PASS — 154 tests |
| Frontend Flutter | `flutter test --no-pub` | PASS — 64 tests |
| Podman | rootless `info`, Alpine efímero y Docker API | PASS |

No se imprimieron claves, tokens ni secretos en la evidencia.

## Diagnóstico y solución

### Supabase CLI

El checkout no tiene `package.json` raíz y `supabase` no estaba en `PATH`. Para el equipo se puede
fijar como herramienta npm; para CI restringido se puede instalar fuera del checkout:

    npm install --save-dev supabase@2.117.0
    npx supabase --version

    TOOL_ROOT=/tmp/agrocampo-supabase-cli
    npm install --prefix "$TOOL_ROOT" supabase@2.117.0
    "$TOOL_ROOT/node_modules/.bin/supabase" --version

La CLI intentó escribir `~/.supabase/telemetry.json`, pero la sesión gestionada es no escribible.
Usar `SUPABASE_TELEMETRY_DISABLED=1` y, si se requiere, `SUPABASE_HOME` en un directorio temporal.
La CLI documenta también `DO_NOT_TRACK=1` para desactivar telemetría
([Telemetry](https://supabase.com/docs/guides/local-development/cli/getting-started)).

### Deno y Edge Functions

Deno es necesario para las pruebas TypeScript; el runtime de Edge lo suministra la pila Supabase.
La instalación oficial es un binario único y admite directorio de usuario
([Deno Installation](https://docs.deno.com/runtime/getting_started/installation/)). La prueba
reproducible es:

    deno test --allow-env backend/supabase/functions/weather-proxy/tests
    deno test --allow-env backend/supabase/functions/agro-ai/tests

Supabase documenta `deno test` para pruebas unitarias y de integración con mocks de red
([Testing Edge Functions](https://supabase.com/docs/guides/functions/unit-test)). Deno unitario no
prueba por sí solo Kong, Auth ni el runtime; por eso se hizo además una petición HTTP local con un
usuario efímero y una entrada inválida, sin llamar a Gemini ni Open-Meteo.

### Docker

La causa observada es de acceso al socket, no de ausencia del cliente ni del daemon: el usuario
pertenece al grupo `docker`, pero el socket expuesto por la sesión es `nobody:nobody` y el contexto
normal da `permission denied`. Una instalación rootful normal crea un socket accesible al grupo
`docker`; Docker advierte que ese grupo concede privilegios equivalentes a root
([Linux post-installation](https://docs.docker.com/engine/install/linux-postinstall)).

En una terminal real del host, diagnosticar y reparar así:

    stat -c '%A %a %U %G %n' /var/run/docker.sock
    getent group docker
    id -nG
    sudo systemctl status docker docker.socket
    sudo journalctl -xu docker.service --no-pager -n 200
    sudo systemctl start docker
    newgrp docker
    docker run --rm hello-world

Si persiste `nobody:nobody`, debe corregirse la proyección del socket, el servicio o la sandbox del
host; no hacer `chmod 666`, no exponer Docker por TCP sin TLS y no sustituir el servicio con un
`chown` manual. Docker recomienda revisar servicio y logs en
([Troubleshooting](https://docs.docker.com/engine/daemon/troubleshoot/)) y
([daemon logs](https://docs.docker.com/engine/daemon/logs/)).

### Podman

Podman exige rangos `/etc/subuid` y `/etc/subgid`; la estación los tiene, además de `newuidmap`,
`newgidmap`, `fuse-overlayfs` y `pasta`. El fallo es el runtime no escribible. El fallback temporal
que pasó fue:

    PODMAN_RUNTIME=/tmp/agrocampo-podman-runtime
    PODMAN_ROOT=/tmp/agrocampo-podman-root
    PODMAN_RUNROOT=/tmp/agrocampo-podman-runroot
    mkdir -p "$PODMAN_RUNTIME/podman" "$PODMAN_ROOT" "$PODMAN_RUNROOT"
    chmod 700 "$PODMAN_RUNTIME"
    XDG_RUNTIME_DIR="$PODMAN_RUNTIME" podman --root "$PODMAN_ROOT" --runroot "$PODMAN_RUNROOT" info --debug
    XDG_RUNTIME_DIR="$PODMAN_RUNTIME" podman --root "$PODMAN_ROOT" --runroot "$PODMAN_RUNROOT" run --rm docker.io/library/alpine:3.22 cat /etc/os-release

En un host normal, activar `podman.socket` y apuntar clientes Docker a
`unix://$XDG_RUNTIME_DIR/podman/podman.sock`, según
([Podman system service](https://docs.podman.io/en/latest/markdown/podman-system-service.1.html)).
`podman info` no basta: el fallback sólo libera T105/T121 si también pasa `supabase start`, `db reset`
y `test db` completo. No se mezclan contenedores Docker y Podman con el mismo proyecto/puertos.

## Flujo de pruebas bloqueadas

1. **Baseline:** conservar el checkout, registrar versiones y ejecutar las suites locales backend y
   frontend. No usar Android.
2. **Runtime:** probar Docker en una terminal de host; corregir servicio/grupo/socket. Si no se
   puede, usar Podman rootless en un runtime escribible y verificar su socket Docker API.
3. **CLI:** ejecutar `start` y `status`; ocultar secretos y aceptar sólo avisos no bloqueantes como
   la deprecación de `[inbucket]`.
4. **Reset:** ejecutar `db reset --local` sólo en la instancia desechable y esperar el fin real del
   proceso.
5. **Sentinel:** antes de pgTAP comprobar que existen `supabase_migrations.schema_migrations` con
   20 filas, `public.parcels` y `public.sync_push(jsonb)`. Si falta algo, esperar/diagnosticar.
6. **SQL:** ejecutar `test db --local`; exigir los 16 archivos/148 tests y la matriz de categoría,
   anonymous, owner A, owner B, bypass directo, duplicate/hash y rollback.
7. **Edge:** ejecutar Deno 5/5; después probar gateway, Auth, handler inválido y proveedor
   simulado/ausente, verificando timeout, caché, payload mínimo y cero mutaciones críticas.
8. **Frontend/backend:** ejecutar format, analyze, tests unitarios/widgets/goldens e integraciones
   que no requieran dispositivo. La suite local no cierra las verticales Android.
9. **API 24+:** usar en CI o en otra estación un AVD API 24 genérico o dispositivo físico. Android
   documenta que el API del AVD debe ser compatible con `minSdk` y que el AVD puede gestionarse por
   CLI ([AVD](https://developer.android.com/studio/run/managing-avds),
   [emulator CLI](https://developer.android.com/studio/run/emulator-commandline)).
10. **Cierre:** actualizar `003-release-matrix.md`; ejecutar T118 con PF-01..PF-30 y T124 sólo
    después de que las tareas verticales y T120/T121 tengan evidencia completa.

El test SQL `backend/supabase/tests/database/productive_domain_compatibility_test.sql` referenciado
por T026 no existe actualmente. Debe restaurarse o justificarse su reubicación antes de cerrar T026;
no se debe sustituir por una suite representativa.

## Estado posterior

`tasks.md` permanece en **107/124 completadas y 17 abiertas**. T116 y T123 aparecen `[X]` en el
estado actual; no se reabren por este bloqueo de infraestructura. La investigación libera la
infraestructura local, pero no declara 003 listo.

Siguen legítimamente pendientes API 24+, T026, T030, T050, T058, T068, T080, T094, T105, T110,
T111, T113, T115, T117, T118, T120, T121 y T124 según sus criterios completos. El release sigue en
`NO LISTO` hasta que la matriz final y T124 sean verdes.
