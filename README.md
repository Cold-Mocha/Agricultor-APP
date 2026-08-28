# AgroCampo

AgroCampo es un MVP Flutter/Android local-first para gestionar parcelas, sectores, labores, suelo,
riego, producción, apicultura, fotografías y recordatorios. Clima y AgroIA son auxiliares: su
indisponibilidad no bloquea el trabajo de campo.

| Propósito | Fuente |
|---|---|
| Requisitos, plan, modelo, contratos y backlog | [`specs/001-agrocampo-android-mvp/`](./specs/001-agrocampo-android-mvp/) |
| Design System UI/UX | [`master.md`](./master.md) |
| Prototipo publicado en GitHub Pages | [`index.html`](./index.html) |
| Prototipo visual de referencia | [`agrocampo-highfi.html`](./agrocampo-highfi.html) |

Los prototipos, `CONTEXTO.md` y `REPORTE_FUTURO.md` son evidencia histórica/no normativa: no amplían
el MVP ni sustituyen la especificación canónica. El orden de implementación está en
[`tasks.md`](./specs/001-agrocampo-android-mvp/tasks.md).

## Requisitos y verificación

Requiere Flutter 3.47, Dart 3.13, Android SDK 36 y Java 17.

```powershell
flutter pub get
flutter pub run build_runner build
flutter analyze
flutter test
flutter build apk --debug
flutter build appbundle --release
```

No añada secretos al repositorio. `GOOGLE_MAPS_ANDROID_KEY` se inyecta en el entorno de build;
WeatherAPI, Gemini y la cuenta Firebase se configuran como secretos de Supabase. `.env`,
`google-services.json`, keystores y `key.properties` están ignorados.

Los tests pgTAP/Deno requieren sus CLIs y un proyecto Supabase local. La firma de producción exige
un keystore aportado por el propietario. La evidencia de diseño, seguridad, resiliencia, aceptación
y release está en [`docs/verification/`](./docs/verification/).
