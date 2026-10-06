# Estado del proyecto

Fotografía vigente de AgroCampo. El estado canónico de cada tarea sigue en el `tasks.md` de cada
spec; este documento resume lo que falta y por qué. Actualízalo cuando cierres una tarea o
registres una ejecución de verificación.

**Release global: NO LISTO.** Faltan la verificación en Android API 24+ y las credenciales de
producción.

## Avance por spec

| Spec | Tareas | Pendientes |
|---|---:|---|
| [`001-agrocampo-android-mvp`](../specs/001-agrocampo-android-mvp/tasks.md) | 85/85 | — |
| [`002-agrocampo-functional-core`](../specs/002-agrocampo-functional-core/tasks.md) | 114/118 | T016, T096, T115, T118 |
| [`003-agrocampo-functional-refinement`](../specs/003-agrocampo-functional-refinement/tasks.md) | 119/124 | T030, T115, T120, T121, T124 |
| [`004-sector-only-territory`](../specs/004-sector-only-territory/spec.md) | sin `tasks.md` | pgTAP y Deno de la migración 0021 sin ejecutar |

Todas las pendientes requieren ejecución en **Android API 24+** (emulador o dispositivo real), no
cambios de implementación:

| Tarea | Qué falta demostrar |
|---|---|
| 002 T016 | Reapertura de sesión, offline, logout/re-login, cambio de propietario y biometría. |
| 002 T096 | Permiso de notificaciones, reboot y cambio de zona horaria. |
| 002 T115 | Biometría, GPS denegado, mapa, notificaciones y WorkManager en plataforma real. |
| 002 T118 | Gate global de 002 (format, analyze, tests, pgTAP, Edge, auditoría, revisión UI). |
| 003 T030 | Flujo territorial con denegación GPS y mapa remoto degradado. |
| 003 T115 | Fallas independientes de mapa/GPS/clima/AgroIA/Supabase con continuidad local. |
| 003 T120 | Gate frontend completo, incluidos integration tests. |
| 003 T121 | pgTAP/RLS/RPC, Deno y Android API 24+ sobre stacks desechables. |
| 003 T124 | Gate final: constitución, arquitectura, alcance y US1–US7. |

Los resultados de esas ejecuciones se registran en este documento.

## Verificación de 004 — sin parcelas (host, 2026-10-02)

| Suite | Resultado |
|---|---|
| Backend `flutter test` | 156/156 (incluye reinicio Drift v12 desde una base v9 poblada) |
| Frontend `flutter test` (widgets + goldens) | 86/86; golden `us8/export.png` regenerado por cambio de copy |
| `flutter analyze` backend y frontend | PASS |
| Aceptación del prototipo y sintaxis embebida | PASS |
| pgTAP (0001–0021) y Deno (`weather-proxy`) | **No ejecutado**: el host no tiene Supabase CLI, Docker ni Deno |
| Integration tests Android | No ejecutados |

La migración `0021_sector_only_territory.sql` **vacía los datos agrícolas y de sincronización** en
Supabase al aplicarse, y Drift v12 borra la base local al actualizar la app. Ambos reinicios están
aprobados por la spec 004.

## Ajuste de UI — pantallas de temporadas (host, 2026-10-04)

| Cambio | Detalle |
|---|---|
| Listado de Temporadas | El título de cada temporada es su rango de fechas (inicio — término), no su nombre; el estado se mantiene en el preview del listado. |
| Crear/editar temporada | Inicio y Término van lado a lado dentro de un contenedor con borde verde redondeado; debajo la etiqueta «Descripción:» y su campo; se quitó el tile «Estado:» (se calcula solo con las fechas). |

| Suite | Resultado |
|---|---|
| `flutter analyze` (módulos crop_cycles) | PASS |
| `flutter test test/modules/crop_cycles/` | 5/5 |
| Suite completa frontend | 91 pasan; 3 fallas preexistentes en Más/Perfil/LABORES por cambios pendientes ajenos a temporadas |

## Corrección de fallas preexistentes — Más/Perfil/LABORES (host, 2026-10-05)

| Falla | Causa | Solución |
|---|---|---|
| `more_page_test.dart` | `MorePage` resolvía `profileControllerProvider` (y por tanto `appDatabaseProvider`) de forma incondicional, sin esperar sesión activa. | La tarjeta de perfil se movió a un widget propio que sólo se construye cuando hay `ownerId`; se agregaron los grupos «Campo», «Organización» y «Respaldo y datos» con `AgroSectionHeader`. |
| `profile_page_test.dart` | Faltaban los accesos a Notificaciones y Tema dentro de «Preferencias». | Se agregaron `AgroSettingsTile` para Notificaciones (`AppRoutes.profileNotifications`) y Tema (`AppRoutes.profileTheme`), ambas rutas ya cableadas. |
| `labor_form_golden_test.dart` | El golden quedó desactualizado: el selector de tipo de labor ahora muestra el ícono de cada tipo en el valor seleccionado (parte del reemplazo de iconografía a Lucide), cambio no reflejado en la imagen de referencia. | Golden regenerado con `flutter test --update-goldens`. |

| Suite | Resultado |
|---|---|
| Suite completa frontend | 94/94 |
| `flutter analyze` frontend | PASS |
| `dart run tool/check_architecture.dart` | PASS |

## Exportar XLSX — excluir eliminados y ampliar columnas (host, 2026-10-06)

`ExportRepository.snapshot()` no filtraba sectores eliminados (`sectors.deleted_at`): un sector
borrado seguía apareciendo en la hoja `sectores`, junto con todas sus labores, mediciones de
suelo, riegos, producción y registros de apicultura, porque esas hojas no se acotaban a los
sectores vigentes. Ahora cada hoja se calcula a partir del conjunto de sectores no eliminados del
propietario, igual que el resto de la app (p. ej. `SectorHistoryDao`).

De paso se ampliaron las columnas exportadas por hoja para reflejar los formatos agregados por
migraciones recientes, antes ausentes del archivo: `categoria_dominio`, `estado` (recorded/
corrected/voided) y `detalle_json` en labores; humedad/pH/temperatura/conductividad/NPK completos
en suelo; duración en segundos, volumen aplicado y config de goteo en riego; notas de calidad en
producción; y los campos de estado de reina/cría/alimentación en apicultura.

| Suite | Resultado |
|---|---|
| Backend `flutter test` | 189/189 (incluye `export_repository_test.dart`) |
| `flutter analyze` backend | PASS |
| `dart run tool/check_architecture.dart` | PASS |

## Tema oscuro (host, 2026-10-05)

Aprobado y agregado al MVP (ver `master.md`, sección «Tema oscuro»). `AgroTheme.dark` reutiliza la
paleta de marca con superficies y contenedores oscuros nuevos, verificados contra el mismo criterio
de contraste del documento (4,5:1 texto normal, 3:1 texto grande/bordes). La preferencia se guarda
por dispositivo (`ProfileFacade.setDarkModeEnabled`, tabla `app_preferences`) y se activa desde
Perfil > Tema, reemplazando la página informativa anterior.

| Suite | Resultado |
|---|---|
| Frontend `flutter test` | 99/99 (incluye `theme_test.dart`, `theme_mode_controller_test.dart`, `profile_theme_page_test.dart`) |
| Backend `flutter test` | 187/187 (incluye `profile_facade_test.dart`) |
| `flutter analyze` backend y frontend | PASS |
| `dart run tool/check_architecture.dart` | PASS |

## Última verificación registrada (host, 2026-09-11)

| Suite | Resultado |
|---|---|
| Backend `flutter test` | 156/156 |
| Frontend `flutter test` (widgets + goldens) | 66/66 |
| pgTAP (migraciones 0001–0020) | 17 archivos, 164/164 |
| Deno Edge Functions | 5/5; endpoints sin auth responden 401 |
| Format, analyze, arquitectura, aceptación del prototipo | PASS |
| `flutter build apk --debug` | PASS (Flutter 3.47.0, JDK 17, SDK 36) |

`android-integration.yml` corre `frontend/integration_test/` en un emulador de CI (API 30). Es
una red de regresión, no reemplaza la verificación API 24+ anterior.

## Brechas de producto conocidas

| Brecha | Detalle |
|---|---|
| Push FCM sin cablear | `FcmGateway.registerInstallation()` existe, pero nada llama a `Firebase.initializeApp()` ni al registro, y `AndroidManifest.xml` no declara el servicio. Requiere el proyecto Firebase real (ver [`deployment.md`](./deployment.md#2-firebase-y-fcm)). |
| Proyecto Supabase remoto | `config.toml` sólo define el stack local; no hay proyecto remoto vinculado. |
| Credenciales de producción | Gemini, cuenta de servicio Firebase, keystore de release y coordenadas reales. Verificar con `./scripts/check_deployment_readiness.sh`. |
| Deploy de Edge Functions | Manual (`supabase functions deploy`); ningún workflow lo hace. |
