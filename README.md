# AgroCampo

Aplicación Android personal y **offline-first** para el agricultor: parcelas y sectores, temporadas
y cultivos, labores, suelo, riego por goteo, producción, apicultura, fotografías, recordatorios,
historial y exportación. Todo se guarda primero en el teléfono y se sincroniza con Supabase cuando
hay red. Clima y AgroIA son auxiliares: si fallan, el trabajo de campo continúa.

## Documentación

| Documento | Contenido |
|---|---|
| [`docs/architecture/overview.md`](./docs/architecture/overview.md) | Qué es, stack, módulos, sincronización y diagramas. |
| [`docs/architecture/frontend-backend-boundary.md`](./docs/architecture/frontend-backend-boundary.md) | Reglas de imports y ownership entre `frontend/` y `backend/`. |
| [`docs/deployment.md`](./docs/deployment.md) | Credenciales, Supabase, Firebase, Gemini, firma y CI/CD. |
| [`docs/status.md`](./docs/status.md) | Avance, pendientes y última verificación. |
| [`specs/`](./specs/) | Requisitos normativos: 001 (MVP), 002 (núcleo funcional), 003 (refinamiento). |
| [`master.md`](./master.md) | Design System: única autoridad de UI/UX. |

`index.html` (GitHub Pages) y `agrocampo-highfi.html` son prototipos estáticos que sirven de
evidencia visual; no definen arquitectura ni alcance.

## Estructura

```text
├── frontend/   # App Flutter Android: páginas, widgets, navegación, estado de presentación
├── backend/    # Paquete local sin UI (dominio, Drift, sync) + supabase/
├── specs/      # Requisitos y contratos
├── docs/       # Arquitectura, despliegue, estado
├── scripts/    # Ejecución, build de release y secretos a partir del .env
└── tool/       # Guard de arquitectura
```

Un único Pub Workspace (`pubspec.yaml` y `pubspec.lock` en la raíz). El backend se compila dentro
del APK: el flujo es **Frontend → Backend local → Drift → Outbox → Supabase**.

## Requisitos

Flutter 3.47.0 (Dart 3.13), Android SDK 36 con un emulador o dispositivo API 24+, y JDK 17
(`flutter config --jdk-dir <jdk17>`). Para Supabase local, además Docker, Supabase CLI y Deno.

## Ejecutar

```bash
flutter pub get                 # en la raíz
cp .env.example .env            # completar SUPABASE_URL y SUPABASE_PUBLISHABLE_KEY
./scripts/run_app.sh            # flutter run con la sección [APP] del .env
```

El primer acceso requiere Supabase (remoto o local con `supabase --workdir backend start`; desde
el emulador la URL local es `http://10.0.2.2:54321`). Sin Supabase la app abre, pero el login
responde "Configura Supabase para el primer acceso". Tras un primer login, la sesión guardada
permite trabajar offline.

El `.env` de la raíz centraliza todas las credenciales locales. Sólo la sección `[APP]` llega al
APK; los secretos de Edge Functions van a Supabase con `./scripts/supabase_secrets.sh`. Detalle en
[`docs/deployment.md`](./docs/deployment.md).

## Verificar

```bash
dart run tool/check_architecture.dart
cd backend && dart run build_runner build && flutter analyze && flutter test && cd ..
cd frontend && flutter analyze && flutter test && flutter build apk --debug && cd ..
cd frontend && flutter test integration_test && cd ..     # requiere emulador/dispositivo
node agrocampo-acceptance.test.js                          # prototipo
```

Supabase local:

```bash
supabase --workdir backend start
supabase --workdir backend db reset
supabase --workdir backend test db
./scripts/supabase_secrets.sh serve
deno test --allow-env backend/supabase/functions/weather-proxy/tests
deno test --allow-env backend/supabase/functions/agro-ai/tests
```

`db reset` sólo reinicia el stack local. Release firmado: `./scripts/build_android_release.sh`.

## Seguridad

No commitees `.env`, `google-services.json`, keystores ni `key.properties`: ya están en
`.gitignore`. La publishable key de Supabase es pública por diseño; la `service_role` key, Gemini y
la cuenta de servicio Firebase viven sólo como secretos de Edge Functions.
