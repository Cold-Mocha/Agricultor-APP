# 2. Crear el proyecto Firebase y habilitar FCM (push remoto)

**Por qué es un paso humano:** requiere una cuenta Google, crear un proyecto en
Firebase Console y aceptar sus condiciones; el CLI `flutterfire configure` además
abre un login interactivo por navegador.

## Estado actual del código (importante)

Esto **no es sólo una credencial faltante** — la integración está a medio construir:

- `backend/pubspec.yaml` ya declara `firebase_core` y `firebase_messaging`.
- `backend/lib/src/platform/notifications/fcm_gateway.dart` ya implementa
  `FcmGateway.registerInstallation()`, que pide permiso, obtiene el token FCM y lo
  guarda en `deviceInstallations`.
- **Pero nada llama a `Firebase.initializeApp()` ni a `registerInstallation()`.**
  Revisado con `grep -rn "Firebase.initializeApp" frontend/lib backend/lib` → sin
  resultados. El gateway existe pero está desconectado del bootstrap de la app.
- `frontend/android/app/src/main/AndroidManifest.xml` no registra ningún
  `FirebaseMessagingService`.
- No existe `google-services.json` en el repo (correctamente gitignored).

Por eso este documento tiene dos partes: la alta del proyecto (humana, abajo) y el
cableado de código que debe hacerse **después**, una vez exista el proyecto real
(porque `flutterfire configure` necesita un proyecto Firebase existente para generar
`firebase_options.dart`; no tiene sentido cablear antes con datos falsos).

## Pasos (alta del proyecto)

1. Crear proyecto en https://console.firebase.google.com.
2. Habilitar **Cloud Messaging** (activado por defecto en proyectos nuevos).
3. Registrar la app Android con el `applicationId` real:
   `cl.agrocampo.app` (ver `frontend/android/app/build.gradle.kts`).
4. Descargar `google-services.json` y guardarlo en
   `frontend/android/app/google-services.json` (gitignored, no se sube al repo).
5. Generar la cuenta de servicio para el envío de push desde el backend:
   **Configuración del proyecto → Cuentas de servicio → Generar nueva clave
   privada**. Descarga un JSON — es el valor de `FIREBASE_SERVICE_ACCOUNT_JSON` en
   `backend/supabase/.env` (todo en una sola línea).
6. Instalar la CLI de FlutterFire y generar las opciones de la app (requiere login
   interactivo):

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=<firebase-project-id>
   ```

   Esto genera `frontend/lib/firebase_options.dart` (o la ruta que elija la CLI) y
   ajusta el Gradle de `frontend/android/app` para aplicar el plugin
   `com.google.gms.google-services`. **No lo genera este documento**: sin un
   proyecto Firebase real, el archivo generado sería inválido.

## Cableado de código pendiente (después del paso anterior)

Una vez exista `firebase_options.dart` real, falta implementar (fuera del alcance de
este cambio, que sólo prepara documentación/CI, no toca bootstrap de la app en
producción sin credenciales reales que probar):

1. Llamar `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
   en el arranque de `frontend/lib/main.dart`, envuelto en `try/catch` — siguiendo el
   mismo patrón defensivo que ya usa `WorkManagerSyncScheduler`
   (`backend/lib/src/composition/sync_scheduler.dart`: si Supabase no está
   configurado, la sincronización se salta en vez de fallar).
2. Invocar `FcmGateway.registerInstallation(...)` después de que el usuario complete
   sesión (mismo punto donde hoy se agenda `SyncScheduler.schedule`).
3. Registrar el servicio de mensajería en `AndroidManifest.xml` si
   `flutterfire configure` no lo agrega automáticamente.
4. Probar en un dispositivo real con Google Play Services (los emuladores sin
   Play Store no reciben push) — este paso vuelve a depender de dispositivo Android,
   igual que T030/T115 en `docs/verification/003-remaining-plan.md`.

## Verificación

```bash
./scripts/check_deployment_readiness.sh   # confirma FIREBASE_SERVICE_ACCOUNT_JSON cargado
```

`notification-dispatch` (`backend/supabase/functions/notification-dispatch/index.ts`)
ya sabe leer `FIREBASE_SERVICE_ACCOUNT_JSON` y firmar contra la API HTTP v1 de FCM;
no necesita cambios de código, sólo el secreto.
