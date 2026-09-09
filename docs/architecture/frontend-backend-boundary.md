# Frontera Frontend ↔ Backend

AgroCampo es un monorepo modular con un único Pub Workspace. La raíz declara solamente los
miembros `frontend/` y `backend/`, y `pubspec.lock` en la raíz es el lockfile canónico. El
Frontend ejecutable consume el paquete local Backend mediante `path: ../backend`; esto no crea
un servidor adicional ni cambia el flujo offline-first.

## Responsabilidades

| Área | Ownership |
|---|---|
| `frontend/lib/src/app/` | Bootstrap visual, router, shell, tema y composición de la aplicación. |
| `frontend/lib/src/modules/<feature>/` | Páginas, widgets, navegación local, controllers/Notifiers, estado y formateo para UI. |
| `frontend/lib/src/shared/` | Componentes y semántica visual transversal sin lógica funcional. |
| `backend/lib/src/modules/<feature>/` | Contratos públicos, coordinación de aplicación, dominio, persistencia e integraciones propias de la capacidad. |
| `backend/lib/src/composition/` | Ensamblaje de providers, codecs, bootstrap e integraciones. |
| `backend/lib/src/platform/` | Base Drift única, motor de sync, red, archivos, notificaciones y observabilidad transversales. |
| `backend/lib/src/shared/` | Kernel y contratos estables sin owner funcional natural ni dependencia de infraestructura. |
| `backend/supabase/` | Migraciones, RLS, RPC, Storage, Edge Functions y pruebas remotas existentes. |

Frontend posee todo estado específico de presentación: loading de pantalla, formularios,
selección visual, errores mostrables y transformación de contratos para widgets. Backend no
conoce páginas, widgets, navegación ni estado de una pantalla. Backend conserva reglas de
negocio, validaciones, transacciones, persistencia, sincronización e integraciones.

Toda UI sigue [`master.md`](../../master.md). La reorganización no agrega comportamiento y no
modifica los requisitos aprobados de `001-agrocampo-android-mvp` ni
`002-agrocampo-functional-core`.

## Frontera pública

El único import Backend permitido en código productivo Frontend es:

```dart
import 'package:agrocampo_backend/agrocampo_backend.dart';
```

`backend/lib/agrocampo_backend.dart` es una allowlist que reexporta los `<feature>_api.dart`.
Esas APIs pueden exponer facades, contratos de lectura, inputs, entidades y value objects
estables. No exponen `AppDatabase`, tablas o companions Drift, DAOs, repositorios concretos,
`SupabaseClient`, gateways, codecs, outbox, cursores ni plugins.

Frontend no importa `backend/lib/src` ni una ruta `package:agrocampo_backend/src/**`. Backend no
importa `package:agrocampo/`, Flutter visual ni `go_router`. Los tests pueden usar internals para
fixtures de persistencia o drivers nativos; esa excepción no se extiende a `frontend/lib/`.

`AppRoutes` pertenece a `frontend/lib/src/app/routing/`. Para conservar el deep link de los
recordatorios sin introducir navegación en Backend, el bootstrap Frontend inyecta únicamente una
función que transforma el ID del recordatorio en el payload que recibe el scheduler nativo.

## Organización por funcionalidad

Primero se identifica el owner funcional y luego la capa técnica:

```text
frontend/lib/
├── main.dart
└── src/
    ├── app/
    ├── modules/
    │   └── <feature>/
    │       ├── <feature>_ui.dart
    │       └── presentation/
    │           ├── pages/
    │           ├── widgets/
    │           ├── controllers/
    │           ├── state/
    │           └── formatters/
    └── shared/

backend/lib/
├── agrocampo_backend.dart
└── src/
    ├── composition/
    ├── modules/
    │   └── <feature>/
    │       ├── <feature>_api.dart
    │       ├── contracts/
    │       ├── application/
    │       ├── domain/
    │       └── infrastructure/
    ├── platform/
    └── shared/
```

Sólo existen las carpetas que contienen código real. No se crean `utils/`, `services/` o `types/`
genéricos. Los módulos Frontend se consumen entre sí mediante `<feature>_ui.dart`; los módulos
Backend coordinan otra capacidad mediante su `<feature>_api.dart`, nunca mediante su
infraestructura o facade interna.

Dependencias públicas destacadas:

- `irrigation` y `production` consumen `LaborContextReader`, contrato público de `labors`.
- `agricultural_context` expone la coordinación del owner y sus selecciones agrícolas sin estado
  de widget; el Notifier seleccionado vive en Frontend.
- `history` mantiene una proyección de lectura propia y no usa repositorios concretos ajenos.
- `home` existe sólo en Frontend y compone contratos/estados de las capacidades visibles.

`domain/` es Dart puro: puede depender de Dart y de dominio propio, pero no de Flutter,
Riverpod, Drift, Supabase, navegación ni plugins.

## Drift y sincronización

Existe una sola base física: `backend/lib/src/platform/database/app_database.dart`. Conserva el
schema completo, versión, migraciones, nombres, IDs, outbox, atomicidad y aislamiento por owner.
Las declaraciones de tablas de negocio viven con su owner en
`modules/<feature>/infrastructure/persistence/tables/`.

La única excepción deliberada `platform → modules` permite que `app_database.dart` declare
`part` exclusivamente sobre esas tablas para componer el schema. Ningún otro archivo de
`platform/` puede depender de módulos. `tool/check_architecture.dart` valida la ruta exacta de
esta excepción, incluidos directives relativos.

El motor de sincronización, outbox, cursores y resolución transversal viven en `platform/sync/`.
Cada codec agregado pertenece a `modules/<owner>/infrastructure/sync/`; el registro se ensambla
en `composition/sync_codec_composition.dart`. `sync_status` sólo representa la capacidad visible
al usuario y su estado de presentación permanece en Frontend.

## Guardas y comandos

`implementation_imports` está activo en ambos paquetes. Desde la raíz:

```powershell
flutter pub get
dart pub workspace list
dart run tool/check_architecture.dart
```

Después se validan los miembros sin resolver dependencias por separado:

```powershell
cd backend
dart run build_runner build
flutter analyze
flutter test
cd ../frontend
flutter analyze
flutter test
flutter build apk --debug
cd ..
```

Las pruebas instrumentadas se ejecutan desde `frontend/` con `flutter test integration_test` en
un emulador o dispositivo Android. Supabase se opera desde la raíz con
`supabase --workdir backend ...`.

`tool/check_architecture.dart` rechaza imports privados entre paquetes, dependencias internas
entre features, ciclos de módulos, dominio acoplado a frameworks, `shared` acoplado a features o
infraestructura, carpetas genéricas, entrypoints productivos inesperados y exportación accidental
de infraestructura.

## Evidencia histórica

`migration-manifest.json`, `migration-files.md`, `migration-report.md` y
`verify-migration.cjs` documentan la separación histórica desde el paquete raíz hacia
`frontend/` y `backend/`. Sus destinos intermedios son evidencia de ese cambio anterior, no el
mapa de la arquitectura vigente. Para validar la estructura actual se usa el checker Dart.
