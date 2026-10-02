# Despliegue

Pasos para llevar AgroCampo a producción. Todos requieren una acción humana: crear cuentas o
proyectos externos, o custodiar un secreto. El código, la CI y las plantillas ya están listos.

## Configuración centralizada

Todas las credenciales locales viven en un único `.env` en la raíz (gitignored), creado desde
[`.env.example`](../.env.example):

```bash
cp .env.example .env
```

| Sección | Destino | Script |
|---|---|---|
| `[APP]` | `--dart-define` del APK. **Públicas**: quedan embebidas en el binario. | `scripts/run_app.sh`, `scripts/build_android_release.sh` |
| `[FUNCTIONS]` | Secretos de Edge Functions. Nunca llegan al APK. | `scripts/supabase_secrets.sh push\|serve` |

La lista de variables de cada sección está en [`scripts/lib/env.sh`](../scripts/lib/env.sh). Una
variable que no está en ninguna lista se ignora. Los secretos de CI son aparte y viven en GitHub
Actions (ver [sección 6](#6-cicd)).

Para ver qué falta, sin imprimir secretos:

```bash
./scripts/check_deployment_readiness.sh
```

## Orden recomendado

| # | Paso | Variables / archivos |
|---|---|---|
| 1 | [Proyecto Supabase](#1-proyecto-supabase) | `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` |
| 2 | [Firebase y FCM](#2-firebase-y-fcm) | `google-services.json`, `FIREBASE_SERVICE_ACCOUNT_JSON` |
| 3 | [Gemini (AgroIA)](#3-gemini-agroia) | `GEMINI_API_KEY`, `GEMINI_MODEL` |
| 4 | [Firma Android](#4-firma-android) | `release.keystore`, `key.properties` |
| 5 | [Coordenadas de la parcela](#5-coordenadas-de-la-parcela) | `OPEN_METEO_DEFAULT_*`, `MAP_INITIAL_*` |
| 6 | [CI/CD](#6-cicd) | Secretos de GitHub Actions |

## 1. Proyecto Supabase

1. Crea el proyecto en <https://supabase.com>. Anota el Project Ref, la región (por ejemplo
   `sa-east-1`) y la contraseña de la base, en un gestor de contraseñas.
2. Vincula el CLI y aplica las migraciones `0001`–`0020`. Son append-only; no generan SQL nuevo.

   ```bash
   supabase login
   supabase --workdir backend link --project-ref <PROJECT_REF>
   supabase --workdir backend db push
   ```

3. En **Project Settings → API**, copia al `.env`:
   - `Project URL` → `SUPABASE_URL`
   - Publishable key (`sb_publishable_…`) → `SUPABASE_PUBLISHABLE_KEY`
   - La `service_role` key **nunca** va al `.env` ni al cliente: Supabase la inyecta en las Edge Functions.
4. Con `AGROCAMPO_ENV=production`, `RuntimeConfig.fromCompileTime()` rechaza el arranque si falta
   alguno de los dos valores. La CI comprueba ese guard en cada push.

## 2. Firebase y FCM

La integración está **a medio construir** (ver [`status.md`](./status.md#brechas-de-producto-conocidas)).

1. Crea el proyecto en <https://console.firebase.google.com> y registra la app Android
   `cl.agrocampo.app`.
2. Descarga `google-services.json` en `frontend/android/app/` (gitignored).
3. Ve a **Configuración → Cuentas de servicio → Generar nueva clave privada**. Pega el JSON, en una
   sola línea, en `FIREBASE_SERVICE_ACCOUNT_JSON`.
4. Genera las opciones de la app:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=<firebase-project-id>
   ```

5. Cableado pendiente, una vez exista el proyecto real:
   - Llamar a `Firebase.initializeApp()` en el bootstrap, con fallo tolerado igual que Supabase.
   - Invocar `FcmGateway.registerInstallation()` tras el login.
   - Declarar el servicio en `AndroidManifest.xml` si FlutterFire no lo agrega.
   - Probar en un dispositivo con Google Play Services.

`notification-dispatch` ya firma contra FCM HTTP v1 y sólo necesita el secreto.

## 3. Gemini (AgroIA)

1. Genera una API key en <https://aistudio.google.com/app/apikey>.
2. Completa `GEMINI_API_KEY` y, si quieres otro modelo, `GEMINI_MODEL` (por defecto
   `gemini-2.5-flash`).

AgroIA sólo recibe el texto que escribe el agricultor, su locale y metadata de política. Nunca
recibe parcelas, historial, riego, producción ni fotos, y nunca escribe datos. No cambies esto sin
revisar la spec 002.

Para probarla contra el proyecto remoto: un 401 sin cabecera de autorización es lo esperado; un 200
confirma la key.

```bash
curl -i -X POST "https://<project-ref>.supabase.co/functions/v1/agro-ai" \
  -H "Authorization: Bearer <SUPABASE_PUBLISHABLE_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"message":"¿Cuándo conviene regar tomates en verano?"}'
```

## 4. Firma Android

El keystore es la identidad permanente del publicador en Play Store. Si se pierde, no se pueden
subir más actualizaciones.

1. Genera el keystore. El script pide la contraseña y crea `frontend/android/app/release.keystore`
   y `frontend/android/key.properties`, ambos gitignored:

   ```bash
   ./scripts/generate_release_keystore.sh
   ```

2. Haz backup del keystore y de su contraseña **fuera del repositorio**.
3. Construye el release localmente con la sección `[APP]` del `.env`:

   ```bash
   ./scripts/build_android_release.sh
   ```

   Sin `key.properties`, el artefacto se firma con la clave debug y no se puede publicar. El archivo
   que se sube a Play Console es el AAB (`frontend/build/app/outputs/bundle/release/app-release.aab`).

## 5. Coordenadas de la parcela

Open-Meteo no requiere API key, pero `weather-proxy` necesita una ubicación para las consultas que
llegan sin coordenadas. Completa `OPEN_METEO_DEFAULT_LATITUDE` y `OPEN_METEO_DEFAULT_LONGITUDE` con
la ubicación real. Opcionalmente, completa también `MAP_INITIAL_LATITUDE` y `MAP_INITIAL_LONGITUDE`
para centrar el mapa. Temuco (`-38.7363, -72.5974`) es sólo un fixture de pruebas.

## Cargar los secretos de Edge Functions

```bash
./scripts/supabase_secrets.sh push    # al proyecto vinculado
./scripts/supabase_secrets.sh serve   # servir las funciones localmente con esos secretos
supabase --workdir backend functions deploy <agro-ai|weather-proxy|notification-dispatch>
```

El script filtra sólo la sección `[FUNCTIONS]` a un archivo temporal con permisos 600 y lo borra al
terminar.

## 6. CI/CD

| Workflow | Cuándo | Qué hace |
|---|---|---|
| `ci.yml` | push/PR | Guard de arquitectura; format, analyze y tests de ambos paquetes; guards de `RuntimeConfig`; aceptación del prototipo; Supabase local con pgTAP y tests Deno. Sin secretos. |
| `android-integration.yml` | push/PR | `frontend/integration_test/` en un emulador API 30 del runner. |
| `android-release.yml` | push a `feature/**`, tag `v*` o manual | Siempre genera un APK debug. El release sale firmado y en modo `production` sólo si existen los secretos; si no, se marca con `::warning::` como no publicable. |
| `pages.yml` | push | Publica el prototipo `index.html` en GitHub Pages. |

Secretos de GitHub Actions (**Settings → Secrets and variables → Actions**):

| Secreto | Origen |
|---|---|
| `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` | Paso 1 |
| `MAP_TILE_URL` | Opcional, sólo si se usa otro proveedor de teselas |
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 frontend/android/app/release.keystore` |
| `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` | Paso 4 |

Los secretos de Edge Functions **no** van a GitHub: se cargan en Supabase con
`supabase_secrets.sh push`.

Si un job falla:
- `architecture-guard`: algún import cruza la [frontera](./architecture/frontend-backend-boundary.md).
- `supabase-local`: drift entre migraciones y tests pgTAP. Reproduce con
  `supabase --workdir backend start && supabase --workdir backend db reset && supabase --workdir backend test db`.
- `android-integration`: revisa primero si el emulador llegó a bootear y después el archivo de
  test que falló.
