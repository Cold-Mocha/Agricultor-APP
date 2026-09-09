# AgroCampo

AgroCampo es un MVP Flutter/Android local-first para gestionar parcelas, sectores, labores, suelo,
riego, producción, apicultura, fotografías y recordatorios. Clima y AgroIA son auxiliares: su
indisponibilidad no bloquea el trabajo de campo.

| Propósito | Fuente |
|---|---|
| Requisitos, plan, modelo, contratos y backlog | [`specs/001-agrocampo-android-mvp/`](./specs/001-agrocampo-android-mvp/) |
| Extensión funcional aprobada | [`specs/002-agrocampo-functional-core/`](./specs/002-agrocampo-functional-core/) |
| Design System UI/UX | [`master.md`](./master.md) |
| Prototipo publicado en GitHub Pages | [`index.html`](./index.html) |
| Prototipo visual de referencia | [`agrocampo-highfi.html`](./agrocampo-highfi.html) |

Los prototipos, `CONTEXTO.md` y `REPORTE_FUTURO.md` son evidencia histórica/no normativa: no amplían
el MVP ni sustituyen la especificación canónica. El orden de implementación está en
[`tasks.md`](./specs/001-agrocampo-android-mvp/tasks.md).

## Monorepo modular

El mismo repositorio Git contiene dos áreas de desarrollo:

| Directorio | Responsable | Contenido |
|---|---|---|
| [`frontend/`](./frontend/) | Frontend / UX | Aplicación Flutter Android: páginas, widgets, navegación, estado de presentación, tema, assets y pruebas visuales. |
| [`backend/`](./backend/) | Lógica / Datos / Backend | Paquete Flutter local sin UI: contratos, facades, dominio, Drift, sincronización, integraciones y Supabase remoto. |

```text
AgroCampo/
├── frontend/             # Aplicación agrocampo
├── backend/              # Paquete agrocampo_backend + supabase/
├── specs/                # Requisitos y contratos funcionales
├── docs/                 # Arquitectura y evidencia
├── master.md             # Autoridad visual
├── pubspec.yaml          # Pub Workspace: frontend + backend
├── pubspec.lock          # Único lockfile canónico
├── README.md
└── .github/              # CI global; prototipos HTML conservados en raíz
```

El `pubspec.yaml` raíz declara exactamente `frontend/` y `backend/` como miembros. Los dos
pubspecs usan `resolution: workspace`; `frontend/pubspec.yaml` consume `agrocampo_backend`
mediante `path: ../backend`.
El flujo sigue siendo **Frontend → Backend local → Drift → Outbox → Supabase**.
El backend local se compila dentro del APK y conserva el funcionamiento offline.

La [frontera de arquitectura](./docs/architecture/frontend-backend-boundary.md) define imports
públicos, responsabilidades, ubicación de tests y la excepción de integraciones nativas en
`frontend/android/`. Toda interfaz sigue [`master.md`](./master.md).

## Requisitos y verificación

Requiere Flutter 3.47, Dart 3.13, Android SDK 36 y Java 17.

```powershell
flutter pub get
dart pub workspace list
dart run tool/check_architecture.dart
cd backend
dart run build_runner build
flutter analyze
flutter test
cd ..
```

Aplicación Android, desde la raíz:

```powershell
cd frontend
flutter analyze
flutter test
flutter build apk --debug
cd ..
```

La suite instrumentada se ejecuta con `flutter test integration_test` dentro de `frontend/`
y requiere un emulador/dispositivo Android configurado. Para un release, dentro de `frontend/`:

```powershell
flutter build appbundle --release
```

Supabase local, desde la raíz (requiere Docker y Supabase CLI):

```powershell
supabase --workdir backend start
supabase --workdir backend db reset
supabase --workdir backend test db
supabase --workdir backend functions serve
deno test --allow-env backend/supabase/functions/weather-proxy/tests
deno test --allow-env backend/supabase/functions/agro-ai/tests
```

`db reset` reinicia únicamente el stack local de desarrollo. Los comandos equivalentes desde
`backend/supabase/` usan `supabase --workdir ..`; no se cambia el proyecto remoto por mover archivos.

Los prototipos se verifican desde la raíz con `node agrocampo-acceptance.test.js`.
GitHub Pages publica `index.html` y copia `frontend/assets/` a `frontend/assets/` del sitio.

No añada secretos al repositorio. OpenStreetMap no usa API key: el cliente identifica la aplicación
con `cl.agrocampo.app`, usa el endpoint oficial de teselas y muestra atribución enlazada. Flutter
inicializa Supabase con `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY`; esta última es una clave pública,
no una credencial de servidor. El `weather-proxy` autenticado usa Open-Meteo y toma
`OPEN_METEO_DEFAULT_LATITUDE`, `OPEN_METEO_DEFAULT_LONGITUDE` y opcionalmente
`OPEN_METEO_FORECAST_URL` desde el entorno de la Edge Function. El endpoint público de Open-Meteo
no requiere API key para evaluación/no comercial; una publicación comercial debe usar el endpoint
y plan de cliente aplicable. AgroIA espera `GEMINI_API_KEY` y opcionalmente `GEMINI_MODEL`, siempre
como secretos de Edge Functions. `.env`, `google-services.json`, keystores y `key.properties` están
ignorados.

Los tests pgTAP/Deno requieren sus CLIs y un proyecto Supabase local. La firma de producción exige
un keystore aportado por el propietario. La evidencia de diseño, seguridad, resiliencia, aceptación
y release está en [`docs/verification/`](./docs/verification/).
