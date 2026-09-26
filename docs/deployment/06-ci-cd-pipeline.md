# 6. Pipeline de CI/CD

Este documento explica lo que ya quedó automatizado en este cambio y qué secretos
de GitHub Actions hay que cargar (el único paso humano de esta parte: sólo el dueño
del repositorio puede escribir secretos).

## `.github/workflows/ci.yml` — corre en cada push/PR, sin secretos

| Job | Qué valida | Gate del proyecto que reproduce |
|---|---|---|
| `architecture-guard` | `dart run tool/check_architecture.dart`: frontera frontend↔backend, sin ciclos, sin carpetas genéricas | G0 (`quickstart.md`) |
| `backend` | `dart format`, `flutter analyze`, `flutter test`, y los dos guards de `RuntimeConfig` (ver abajo) | — |
| `frontend` | `dart format`, `flutter analyze`, `flutter test` (unit + widget + golden) | — |
| `prototype` | `node agrocampo-acceptance.test.js` + sintaxis del JS embebido en `agrocampo-highfi.html` | G12 |
| `migration-manifest` | `node docs/architecture/verify-migration.cjs` | T123 |
| `supabase-local` | Levanta un stack Supabase **local y desechable** (`supabase --workdir backend start`), aplica las migraciones 0001–0020 (`db reset`), corre la suite pgTAP completa (`test db`) y los tests Deno de `weather-proxy`/`agro-ai` | G10/G11 (sin la parte Android) |

No incluye los `integration_test/*` de Flutter (necesitan un dispositivo/emulador
Android) ni la construcción de un release firmado — eso vive en el segundo workflow.
No se automatizó un runner de emulador Android: el propio proyecto documenta en
`docs/verification/003-remaining-plan.md` que no se debe simular una aprobación
Android con una suite host; mantener esa separación explícita evita reportar un
falso verde en T030/T115/T120/T121/T124.

### Guards de `RuntimeConfig` (backend, cada push)

`backend/tool/verify_runtime_config_guard.dart` se ejecuta dos veces:

1. Sin defines (modo `development`) → debe resolver sin exigir Supabase.
2. Con `-DAGROCAMPO_ENV=production` y sin `SUPABASE_URL`/`SUPABASE_PUBLISHABLE_KEY`
   → debe fallar (`FormatException`). Si algún cambio futuro debilita esa
   protección y un build de producción sin Supabase deja de fallar, este job rompe
   CI con un error explícito en vez de dejarlo pasar en silencio.

## `.github/workflows/android-release.yml`

| Job | Cuándo corre | Requiere secretos |
|---|---|---|
| `debug-build` | Todo push a `feature/**` | No — siempre sube un APK debug |
| `release-build` | Push de tag `v*`, release publicado, o `workflow_dispatch` manual con `publish_release=true` | Parcial — ver abajo |

`release-build` **siempre** produce un artefacto (nunca falla sólo por falta de
secretos), pero:

- Si faltan los 4 secretos de firma (`ANDROID_KEYSTORE_BASE64`,
  `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`), firma
  con la clave debug y sube el artefacto como
  `agrocampo-release-UNSIGNED-debugkey`, además de un `::warning::` visible en el
  resumen del run.
- Si faltan `SUPABASE_URL`/`SUPABASE_PUBLISHABLE_KEY`, compila en modo
  `development` (offline-only) en vez de `production`, y también lo marca con el
  mismo `::warning::`.
- Sólo cuando los 6 secretos están presentes, el artefacto queda firmado con el
  keystore real y apuntando al backend real: recién ahí es apto para Play Console.

### Secretos de GitHub Actions a cargar

Settings → Secrets and variables → Actions → New repository secret:

| Secreto | De dónde sale | Guía |
|---|---|---|
| `SUPABASE_URL` | Project Settings → API del proyecto Supabase | [`01-supabase-project.md`](01-supabase-project.md) |
| `SUPABASE_PUBLISHABLE_KEY` | Idem | [`01-supabase-project.md`](01-supabase-project.md) |
| `MAP_TILE_URL` | Opcional — sólo si se usa un proveedor de teselas distinto al default OSM | — |
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 frontend/android/app/release.keystore` | [`04-android-release-signing.md`](04-android-release-signing.md) |
| `ANDROID_KEYSTORE_PASSWORD` | Elegida al generar el keystore | [`04-android-release-signing.md`](04-android-release-signing.md) |
| `ANDROID_KEY_ALIAS` | Elegido al generar el keystore | [`04-android-release-signing.md`](04-android-release-signing.md) |
| `ANDROID_KEY_PASSWORD` | Elegida al generar el keystore | [`04-android-release-signing.md`](04-android-release-signing.md) |

Los secretos de las Edge Functions (`GEMINI_API_KEY`, `FIREBASE_SERVICE_ACCOUNT_JSON`,
`OPEN_METEO_DEFAULT_LATITUDE/LONGITUDE`) **no** van en GitHub Actions — se cargan
directamente en Supabase con `supabase secrets set`, porque el pipeline de GitHub
nunca despliega Edge Functions por sí solo en este cambio (eso sigue siendo un paso
manual con `supabase --workdir backend functions deploy <nombre>`, deliberadamente
fuera de este pipeline hasta decidir con qué frecuencia deben desplegarse).

## Qué revisar si un job falla

- `architecture-guard` rojo → algún import cruza la frontera frontend/backend
  documentada en `docs/architecture/frontend-backend-boundary.md`.
- `backend`/`frontend` rojo en `flutter test` → regresión real, no de
  infraestructura; correr localmente con el mismo comando del job.
- `supabase-local` rojo → probable drift entre `backend/supabase/migrations/` y los
  tests de `backend/supabase/tests/database/`; reproducir con
  `supabase --workdir backend start && supabase --workdir backend db reset && supabase --workdir backend test db`.
- `release-build` con `::warning::` (no rojo) → artefacto válido para smoke test,
  no para publicar; revisar la tabla de secretos de arriba.
