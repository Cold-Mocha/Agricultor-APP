# Dependencias, licencias y alcance

Fecha de revisión: 2026-08-28.

## Dependencias directas justificadas

- Drift/SQLite: persistencia local-first y migraciones.
- Riverpod y go_router: estado y navegación tipada.
- Supabase: autenticación, RLS, Storage, sincronización y Edge Functions.
- Workmanager/connectivity: sincronización diferida.
- Secure Storage: sesión cifrada por Android.
- Google Maps/geolocator: territorio y captura GPS.
- Firebase Messaging/local notifications: avisos remotos y locales.
- Image Picker/crypto: captura privada y deduplicación SHA-256.
- Excel 4.0.6: OpenXML XLSX offline; dependencia MIT según su metadata publicada.

`flutter_secure_storage` permanece en 10.3.1 porque la rama 11 exige un compile SDK superior al 36 fijado por el plan. Las claves de Google Maps, WeatherAPI, Gemini, Firebase y Supabase no forman parte del código.

## Exclusiones mantenidas

No hay backend adicional, analítica publicitaria, pagos, IoT, diagnóstico agronómico automático, coeficientes de riego inventados, cuentas para apicultores descriptivos ni dependencia online para registrar trabajo.

Fuente verificable: `pubspec.lock`, `android/app/build.gradle.kts`, contratos en `specs/001-agrocampo-android-mvp/contracts/` y funciones en `supabase/functions/`.
