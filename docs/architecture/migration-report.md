# Separación Frontend / Backend implementada

Validación final: 6 de septiembre de 2026 (America/Santiago). El mismo repositorio contiene
la aplicación Android `frontend/` y el paquete Flutter sin UI `backend/`. No existe `lib/`
productivo en la raíz. No se creó otro repositorio ni se desplegó el backend remoto.

## Estructura real

```text
frontend/
├── pubspec.yaml / pubspec.lock / analysis_options.yaml
├── README.md
├── android/                     # Host Android, manifest, Gradle, integraciones nativas
├── assets/                      # Inter, SVG y pictogramas
├── lib/
│   ├── main.dart
│   ├── app/                     # bootstrap, routing, shell, theme, AgroCampoApp
│   ├── features/
│   │   ├── sectors/pages/       # Lista y detalle
│   │   ├── sectors/widgets/     # Tarjeta y mapa de vista previa
│   │   └── <feature>/presentation/
│   └── shared/presentation/
├── test/                        # Widgets, goldens, navegación, accesibilidad y frontera
└── integration_test/            # Flujos instrumentados Android

backend/
├── pubspec.yaml / pubspec.lock / analysis_options.yaml / build.yaml
├── README.md
├── assets/data/                 # Catálogo local empaquetado con Backend
├── lib/
│   ├── agrocampo_backend.dart   # Única entrada pública para Frontend
│   ├── core/                    # auth, config, database, errors, export, files,
│   │                            # geometry, network, notifications, observability, sync
│   ├── features/
│   │   ├── sectors/             # controllers, dto, domain, repositories, services
│   │   └── <feature>/           # controllers, contratos, domain y repositories
│   └── shared/                  # domain y contracts (destinos de navegación)
├── test/                        # Lógica, persistencia, migraciones, contratos y fixtures
├── drift_schemas/
└── supabase/                    # config.toml, migrations, functions, tests, seed.sql
```

Se migraron todas las features existentes: sesión, contexto, Inicio, parcelas, sectores, mapa,
cultivos/temporadas/rotaciones, labores, suelo, riego, historial, producción, apicultura, clima,
AgroIA, recordatorios, fotos, exportación, perfil, Más y estado/conflictos de sincronización.
No quedaron features pendientes de separación física ni accesos productivos de Frontend a
Drift, SQL, clientes Supabase, repositorios o plugins de infraestructura.

## Movimientos, creaciones y eliminación de ubicaciones antiguas

- 424 archivos inventariados trasladados, más `android/` completo (19 archivos nativos versionados).
- 47 archivos nuevos de código y pruebas, incluyendo controllers, DTOs, APIs de feature,
  bootstrap Backend, contratos de presentación y pruebas de frontera.
- Dos configuraciones de paquete independientes y READMEs por área; documentación y comandos
  actualizados en la raíz, planes, quickstarts y CI de Pages.
- 188 directorios comprobados vacíos eliminados. Las implementaciones originales fueron
  movidas; no se conservó una segunda copia productiva. Se preservaron las caches anteriores
  bajo `frontend/.migration-cache/`, ignoradas y excluidas del análisis.
- Los cambios previos del usuario se conservaron: controladores de Sectores, sus páginas,
  repositorio y pruebas, selector de contexto y archivos locales. Se normalizaron las
  anidaciones `supabase/supabase`, `drift_schemas/drift_schemas` y `controllers/controllers`.

El detalle por archivo está en [migration-files.md](./migration-files.md); el
[manifiesto](./migration-manifest.json) conserva origen, destino final y hash inicial.

## Contrato y funcionamiento

`frontend/pubspec.yaml` declara `agrocampo_backend: { path: ../backend }`. Los imports productivos
de Frontend apuntan exclusivamente a `package:agrocampo_backend/agrocampo_backend.dart`.
Se corrigieron imports `package:agrocampo/...` y rutas relativas de tests según el destino;
Backend no depende del paquete Frontend. Las pruebas de frontera verifican ambos sentidos
y que el grafo de exports públicos no exponga repositorios ni bibliotecas de infraestructura.

Las páginas consumen controllers, inputs y estados tipados. Backend conserva consultas,
validaciones, construcción de filas/payloads, transacciones y plugins. Los puntos del mapa de
Sectores se preparan en su mapper; el widget sólo los dibuja. Bootstrap inicializa Drift,
sesión, Supabase, WorkManager y notificaciones en Backend; Frontend monta la aplicación.

Drift continúa dentro del APK como fuente operativa: **Frontend → Backend local → Drift →
Outbox → Supabase**. `frontend/android/` sigue siendo el host ejecutable y es la excepción
documentada para integraciones nativas mantenidas por el desarrollador Backend.

La lista, detalle, selección y mapa de Sectores compilan y pasan las pruebas. Navegación,
componentes y goldens mantienen `master.md` (Navigation, Screens, States y Offline UX).
Una diferencia introducida al extraer riego —mensaje de método no soportado sin sector— se
reprodujo con un test y se corrigió antes de la validación final.

## Resultados verificados

| Comando / comprobación | Resultado |
|---|---|
| Baseline `flutter analyze` | Fallaba: 72 incidencias por imports de Sectores inexistentes, entre otras referencias derivadas. |
| Baseline `flutter test` / APK debug | Fallaban por esa migración previa incompleta. |
| `cd frontend; flutter pub get --offline` | Correcto; dependencia local resuelta. |
| `cd backend; flutter pub get --offline` | Correcto; versiones fijadas conservadas. |
| `cd frontend; flutter analyze --no-pub` | Sin incidencias. |
| `cd backend; flutter analyze --no-pub` | Sin incidencias. |
| `cd frontend; flutter test --no-pub` | **45 pruebas aprobadas**, incluidos goldens y frontera. Sin regenerar imágenes de referencia. |
| `cd backend; flutter test --no-pub` | **119 pruebas aprobadas**, incluidos contratos, persistencia/reinicio, aislamiento y migraciones. |
| Generación Drift con `build_runner` | Correcta; los cinco `.g.dart` resultantes son idénticos a sus hashes iniciales. |
| `cd frontend; flutter build apk --debug --no-pub` | Correcto con la configuración final. |
| `node docs/architecture/verify-migration.cjs` | Correcto: no hay `lib/` raíz; **49 archivos de Supabase/esquemas idénticos** a los iniciales. |
| `deno test --allow-env backend/supabase/functions/.../tests` | **5 pruebas aprobadas**, Weather y AgroIA. |
| `node agrocampo-acceptance.test.js` | Correcto. |
| Sintaxis JS embebida de `agrocampo-highfi.html` | Correcta, 1 script. |

APK: [`frontend/build/app/outputs/flutter-apk/app-debug.apk`](../../frontend/build/app/outputs/flutter-apk/app-debug.apk).
Los resúmenes reproducibles están en [validation/](./validation/); los logs locales completos
se conservan en ese directorio y están ignorados por Git.

## Límites y deuda pendiente

- Se intentaron `supabase --workdir backend status` y `test db`: Docker/Podman no está disponible
  y PostgreSQL local rechaza conexión en `127.0.0.1:54422`. pgTAP/RLS/RPC y E2E contra servidor
  real quedan sin validar en este entorno. Los archivos remotos no cambiaron ni se desplegaron.
- `adb devices` no muestra dispositivos. No se ejecutó `frontend/integration_test/` sobre Android;
  quedan la comprobación física de GPS, cámara, biometría, permisos y tareas en segundo plano.
- El build mantiene avisos existentes de compatibilidad futura Kotlin de `firebase_core` y
  `workmanager_android`, y avisos Java de plugins. Se conservaron versiones y el override
  `path_provider_android: 2.2.23`; no se realizó una actualización funcional de dependencias.
- El controller de lista de Sectores recibido al inicio ya convertía un fallo de lectura del
  resumen histórico en error de toda la lista. Se conservó ese comportamiento previo; aislar
  ese fallo parcial queda como deuda del refactor anterior, fuera de esta reorganización.

Responsabilidades, imports permitidos y comandos de trabajo:
[frontend-backend-boundary.md](./frontend-backend-boundary.md).
