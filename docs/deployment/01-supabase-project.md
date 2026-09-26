# 1. Crear el proyecto Supabase remoto

**Por qué es un paso humano:** requiere una cuenta en supabase.com y la creación de
un proyecto facturable (tiene capa gratuita). Nadie más que el dueño del producto
debería decidir la organización/región/plan.

Hoy `backend/supabase/config.toml` sólo define `project_id = "agrocampo-local"`, sin
ningún `project_id` remoto vinculado — todo lo probado hasta ahora corrió contra el
stack Docker local (ver `docs/verification/003-host-execution-2026-09-11.md`).

## Pasos

1. Crear cuenta/organización en https://supabase.com si no existe.
2. Crear un proyecto nuevo. Anotar:
   - **Project Reference ID** (ej. `abcdefghijklmno`)
   - **Región** (elegir la más cercana a los usuarios reales, ej. `sa-east-1`)
   - **Database password** (guardarla en un gestor de contraseñas, no en el repo)
3. Vincular el CLI local al proyecto (requiere haber iniciado sesión con
   `supabase login`, que abre el navegador — también humano):

   ```bash
   supabase login
   supabase --workdir backend link --project-ref <PROJECT_REF>
   ```

4. Aplicar las migraciones 0001–0020 ya existentes en `backend/supabase/migrations/`
   contra el proyecto remoto:

   ```bash
   supabase --workdir backend db push
   ```

   Esto es **append-only** y reproduce exactamente lo ya validado localmente (ver
   `docs/architecture/migration-manifest.json` y `verify-migration.cjs`). No genera
   SQL nuevo ni cambia el esquema documentado.

5. En el dashboard del proyecto (**Project Settings → API**), copiar:
   - `Project URL` → variable `SUPABASE_URL`
   - `anon` / `publishable` key (empieza con `sb_publishable_`) → variable
     `SUPABASE_PUBLISHABLE_KEY`
   - `service_role` key → sólo para Edge Functions, nunca para el cliente Flutter

6. Completar `frontend/.env` (copiado desde `frontend/.env.example`) con
   `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY`, y `AGROCAMPO_ENV=production` cuando
   se quiera compilar el release real.

7. Cargar los mismos dos valores como **secretos de GitHub Actions**
   (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`) para que
   `.github/workflows/android-release.yml` pueda construir un release real — ver
   [`06-ci-cd-pipeline.md`](06-ci-cd-pipeline.md).

8. Configurar los secretos de las Edge Functions contra el proyecto remoto (una vez
   completados `03-gemini-ai-agroia.md` y `02-firebase-fcm.md`):

   ```bash
   cp backend/supabase/.env.example backend/supabase/.env   # completar valores reales
   supabase --workdir backend secrets set --env-file backend/supabase/.env
   ```

## Verificación

```bash
supabase --workdir backend db remote commit   # confirma que no hay drift de schema
./scripts/check_deployment_readiness.sh       # confirma que frontend/.env quedó completo
```

`RuntimeConfig.fromCompileTime()` (`backend/lib/src/platform/network/runtime_config.dart`)
ya rechaza cualquier build `AGROCAMPO_ENV=production` sin estas dos variables —
verificado en cada push por `backend/tool/verify_runtime_config_guard.dart` en CI.
