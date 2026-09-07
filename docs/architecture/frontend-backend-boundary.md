# Frontera Frontend ↔ Backend

La separación física está aprobada: `frontend/` y `backend/` pertenecen al mismo repositorio Git.
La aplicación ejecutable se llama `agrocampo`; consume el paquete Flutter `agrocampo_backend`
mediante `path: ../backend`. No hay código productivo en un `lib/` de la raíz.

## Responsabilidades

| Área | Responsable | Contenido |
|---|---|---|
| `frontend/` | Frontend / UX | Pages, widgets, formularios visuales, navegación con go_router, shell, tema, accesibilidad, assets, feedback y estados visuales. |
| `backend/` | Lógica / Datos / Backend | Controllers, providers con lógica, DTOs, FormInput, comandos, entidades, validaciones, repositorios, Drift, outbox, sync, sesión, biometría, geometría, GPS lógico, fotos, notificaciones y exportación. |
| `backend/supabase/` | Lógica / Datos / Backend | Configuración, migraciones, RLS, RPC, funciones, Storage, seed y pruebas remotas. |
| `frontend/android/` | App Android; coordinación con Backend | Host nativo, Gradle, manifest, permisos y canales Android. Backend mantiene aquí biometría, WorkManager, notificaciones y exportación cuando corresponda. |
| `specs/`, `docs/`, `master.md`, `.github/` | Compartido | Requisitos, contratos, diseño, evidencia y herramientas del repositorio. |

El host Android permanece físicamente en `frontend/android/` porque genera el APK. La propiedad
de una integración nativa puede ser del desarrollador Backend sin mover el host a su paquete.

Toda UI se implementa con los tokens, componentes y estados de [`master.md`](../../master.md).
Las reglas agrícolas y funcionales permanecen en los specs aprobados; la separación no amplía su alcance.

## Dependencias permitidas

```text
frontend/lib/ (widgets, navegación, tema)
     ↓ controllers / estado / inputs públicos
backend/lib/agrocampo_backend.dart
     ↓ lógica local y repositorios
Drift + outbox durables dentro del APK
     ↓ sincronización oportunista
backend/supabase/ (PostgreSQL, RLS, RPC, Edge Functions)
```

En `frontend/lib/`, el único import del paquete Backend permitido es:

```dart
import 'package:agrocampo_backend/agrocampo_backend.dart';
```

La API pública expone controllers, estados consumibles por la UI, DTOs, inputs, comandos, IDs y
enums. Frontend solicita acciones y representa su resultado; no construye filas Drift, payloads
Supabase ni operaciones de sincronización. La fuente operativa sigue siendo Drift y la UI recibe
sus cambios a través de los contratos locales incluso cuando no existe conexión.

Queda prohibido en `frontend/lib/` importar o acceder a `AppDatabase`, Drift, SQL, DAOs,
`SupabaseClient`, RPC, outbox, colas de sync, PostgreSQL, RLS, Edge Functions o almacenamiento
interno. Tampoco se permiten imports a rutas internas `package:agrocampo_backend/core/...`,
`features/...`, `shared/...` ni rutas relativas que atraviesen `backend/lib/`.

Backend no importa `package:agrocampo/`, páginas, widgets, go_router ni el tema de Frontend.
Puede depender de Flutter/Riverpod y de los plugins existentes que necesita para ejecutarse
dentro del APK. Las dependencias de SDK no convierten el paquete en una aplicación visual.

Los tests de Backend pueden importar sus implementaciones para comprobar persistencia y reglas.
Los tests de integración del host pueden usar infraestructura del paquete para preparar fixtures
y verificar el flujo completo; esa excepción de pruebas no se aplica a `frontend/lib/`.

## Organización por feature

Sectores conserva una sola implementación, con las páginas y widgets separados de sus contratos:

```text
frontend/lib/features/sectors/
├── pages/
│   ├── sector_list_page.dart
│   └── sector_detail_page.dart
└── widgets/
    ├── sector_summary_card.dart
    └── quadrant_map_preview.dart

backend/lib/features/sectors/
├── controllers/
├── dto/                  # sector_ui_state.dart y contratos consumibles
├── domain/
├── repositories/
└── services/             # sector_ui_mapper.dart
```

Las demás features mantienen sus páginas/widgets en `frontend/lib/features/<feature>/presentation/`.
Sus entidades viven en `backend/lib/features/<feature>/domain/`; las antiguas carpetas `data/`
se trasladan a `repositories/`. Controllers y providers con lógica pertenecen al paquete Backend.
Las capacidades transversales viven en `backend/lib/core/`; UI compartida, en
`frontend/lib/shared/presentation/`. Sólo se crean carpetas con una responsabilidad real.

La composición de servicios y providers vive en `backend/lib/core/config/backend_bootstrap.dart`
y `backend_providers.dart`; `frontend/lib/app/bootstrap/app_bootstrap.dart` adapta el arranque de
la aplicación a esa API. Los nombres de rutas compartidos son contratos en
`backend/lib/shared/contracts/app_routes.dart`; el router y la navegación continúan en Frontend.
El catálogo local de datos pertenece a `backend/assets/data/`; Inter, SVG y otros assets visuales
pertenecen a `frontend/assets/`.

## Comandos de desarrollo

Cada bloque siguiente comienza en la raíz del repositorio y regresa a ella.

Backend local (Flutter sin UI, incluyendo generación Drift):

```powershell
cd backend
flutter pub get
dart run build_runner build
flutter analyze
flutter test
cd ..
```

Frontend Android:

```powershell
cd frontend
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
cd ..
```

Las pruebas instrumentadas se ejecutan con `flutter test integration_test` dentro de `frontend/`
sobre Android configurado. El APK debug queda en
`frontend/build/app/outputs/flutter-apk/app-debug.apk`.

Supabase desde la raíz:

```powershell
supabase --workdir backend start
supabase --workdir backend db reset
supabase --workdir backend test db
supabase --workdir backend functions serve
deno test --allow-env backend/supabase/functions/weather-proxy/tests
deno test --allow-env backend/supabase/functions/agro-ai/tests
```

`db reset` se usa sobre el entorno local de desarrollo. Desde el directorio de Supabase:

```powershell
cd backend/supabase
supabase --workdir .. start
supabase --workdir .. test db
supabase --workdir .. functions serve
cd ../..
```

El `--workdir` apunta a `backend/`, que contiene `supabase/config.toml`. El movimiento conserva
las migraciones y contratos remotos; no autoriza un reset remoto ni un redeploy funcional.

## Lectura de rutas históricas

Los backlogs ya ejecutados, investigaciones y reportes anteriores conservan su evidencia original.
Sus rutas anteriores se interpretan con este mapeo; no indican copias productivas en la raíz:

| Ruta anterior | Ubicación actual |
|---|---|
| `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml` | Archivo correspondiente de `frontend/`; Backend tiene su propia configuración de paquete. |
| `lib/main.dart`, `lib/app/routing/`, `lib/app/theme/`, shell y presentación de app | `frontend/lib/` con el mismo sufijo. |
| `lib/core/`, dominio compartido | `backend/lib/` bajo su capacidad correspondiente. |
| `lib/app/providers.dart`, lógica de bootstrap | `backend/lib/core/config/backend_providers.dart` y `backend_bootstrap.dart`; el arranque visual queda en `frontend/lib/app/bootstrap/`. |
| `lib/features/<feature>/presentation/` | Páginas/widgets en Frontend; controllers/estados/mappers en Backend. Sectores usa `pages/`, `widgets/`, `controllers/`, `dto/` y `services/`. |
| `lib/features/<feature>/domain/` | `backend/lib/features/<feature>/domain/`. |
| `lib/features/<feature>/data/` | `backend/lib/features/<feature>/repositories/`. |
| `lib/shared/presentation/` | `frontend/lib/shared/presentation/`. |
| `android/`, assets visuales | `frontend/android/`, `frontend/assets/`. |
| `assets/data/` | `backend/assets/data/`. |
| `supabase/`, `drift_schemas/`, `build.yaml` | `backend/supabase/`, `backend/drift_schemas/`, `backend/build.yaml`. |
| `test/core/`, tests de dominio/repositorios/contratos/performance | `backend/test/` con el mismo sufijo. |
| Tests de páginas/widgets, `test/golden/`, políticas visuales | `frontend/test/` con el mismo sufijo. |
| `integration_test/` | `frontend/integration_test/`. |

El [manifiesto de migración](./migration-manifest.json) registra rutas originales, destinos y hashes
previos al ajuste de imports. Los escenarios de integración que no necesitan un dispositivo están
en `backend/test/integration/`; los fixtures y helpers de infraestructura están en `backend/test/`.

Los resultados anteriores de análisis, tests y builds no certifican esta migración. Su verificación
debe ejecutar ambos paquetes y el APK desde sus ubicaciones nuevas.

Los prototipos HTML y `master.md` siguen en la raíz. GitHub Pages copia `frontend/assets/` a
`_site/assets/` para conservar las URLs públicas de los recursos; los prototipos continúan siendo
evidencia visual/funcional y no definen la arquitectura Flutter.
