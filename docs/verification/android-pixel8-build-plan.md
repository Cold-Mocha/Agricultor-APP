# AgroCampo 003 — plan reproducible para Android y Pixel 8

**Corte:** 2026-09-10
**AVD objetivo:** `Pixel_8`, `emulator-5554`, Android API 37.1
**Paquete:** `cl.agrocampo.app`

## Diagnóstico

El bloqueo observado no provenía del Pixel 8 ni de Gradle: Flutter no podía abrir su
`bin/cache/lockfile` porque el SDK estaba en una ruta de OneDrive fuera del área escribible del
entorno (`C:\Users\jmarr\OneDrive\Desktop\2026-2\APP-Agricultor\flutter`). Al ejecutar con acceso
al SDK, `flutter build apk --debug --no-pub` terminó correctamente y generó un APK nuevo.

Para otros equipos, la solución permanente es instalar o mover el SDK Flutter a una ruta local
escribible y comprobarla con `flutter doctor -v`. Si el SDK debe permanecer en una ruta protegida,
la alternativa temporal es ejecutar Flutter con permisos suficientes para escribir `bin/cache`.

## Precondiciones del AVD

- Android Studio debe tener iniciado `Pixel_8` y `adb devices -l` debe mostrar
  `emulator-5554 device`.
- La ubicación del emulador debe estar activa; en pruebas de mapa se usa una ubicación conocida y
  se conceden explícitamente los permisos de ubicación y notificaciones.
- Usar el mismo `adb.exe` que pertenece al SDK configurado por Android Studio.

## Procedimiento reproducible

Desde `frontend/` (con el SDK Flutter escribible):

```powershell
$agroAdb = 'C:\Users\jmarr\AppData\Local\Android\Sdk\platform-tools\adb.exe'
flutter doctor -v
flutter build apk --debug --no-pub
& $agroAdb -s emulator-5554 install -r -d .\build\app\outputs\flutter-apk\app-debug.apk
& $agroAdb -s emulator-5554 shell settings put secure location_mode 3
& $agroAdb -s emulator-5554 shell pm grant cl.agrocampo.app android.permission.ACCESS_FINE_LOCATION
& $agroAdb -s emulator-5554 shell pm grant cl.agrocampo.app android.permission.ACCESS_COARSE_LOCATION
& $agroAdb -s emulator-5554 shell pm grant cl.agrocampo.app android.permission.POST_NOTIFICATIONS
& $agroAdb -s emulator-5554 emu geo fix -72.5984 -38.7397
```

Las pruebas de dispositivo se ejecutan después de cada instalación. Si el runner reinstala la
aplicación y restablece permisos, repetir los `pm grant` y el `geo fix` antes de la suite.

```powershell
flutter test integration_test/android_platform_flow_test.dart -d emulator-5554 --no-pub --reporter expanded
flutter test integration_test/functional_refinement_e2e_test.dart -d emulator-5554 --no-pub --reporter expanded
```

## Evidencia obtenida

| Evidencia | Resultado |
|---|---|
| `flutter build apk --debug --no-pub` | PASS; `frontend/build/app/outputs/flutter-apk/app-debug.apk` generado |
| Instalación por ADB y arranque | PASS en `emulator-5554` |
| `android_platform_flow_test.dart` | PASS, 4/4 |
| `functional_refinement_e2e_test.dart` | PASS, 7/7 |
| `labor_form_page_test.dart` | PASS |
| `soil_measurement_page_test.dart` | PASS |

Capturas de la preparación del dispositivo: [`pixel8-current.png`](pixel8-current.png) y
[`pixel8-permission-dialog.png`](pixel8-permission-dialog.png).

La corrección de la prueba de mapa normaliza el texto real de atribución OSM y las pruebas de
Labor/Suelo ocultan el teclado y desplazan el botón antes de tocarlo; no cambia la funcionalidad de
producción.

## Qué sigue pendiente

El APK y las dos suites representativas ya no son un bloqueo. Esto no cierra automáticamente las
tareas que exigen una matriz más amplia o gates externos: T030, T050, T058, T080, T094, T110,
T115, T117, T120 y T121 siguen requiriendo sus criterios completos; T013, T026, T068, T105,
T111, T116, T119, T123 y T124 mantienen sus dependencias de Drift, Supabase/Deno, análisis y
manifest. No se debe marcar una tarea sólo por el PASS de estas suites representativas.

## Referencias operativas

- La matriz consolidada está en [`003-release-matrix.md`](003-release-matrix.md).
- El detalle de las 23 tareas abiertas está en [`003-remaining-plan.md`](003-remaining-plan.md).
- La guía oficial de Flutter para seleccionar/verificar el JDK de Android está en
  [Android Java/Gradle migration guide](https://docs.flutter.dev/release/breaking-changes/android-java-gradle-migration-guide).
- Para preparar ubicación puede usarse Extended Controls → Location del emulador; la consola
  también admite `geo fix` según la [documentación del emulador Android](https://developer.android.com/studio/run/emulator-console).
- El comando y el flujo de integración siguen la [guía oficial de integration tests de Flutter](https://docs.flutter.dev/testing/integration-tests).
