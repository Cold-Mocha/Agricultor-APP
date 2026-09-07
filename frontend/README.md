# Frontend AgroCampo

Responsable: Frontend / UX. Este paquete es la aplicación Flutter Android `agrocampo`.

Pantallas, widgets, tema, navegación, assets visuales, accesibilidad, widget tests y goldens
se desarrollan aquí siguiendo [`master.md`](../master.md). La única entrada al paquete de lógica
es `package:agrocampo_backend/agrocampo_backend.dart`, declarado mediante `path: ../backend`.

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

El APK está en `build/app/outputs/flutter-apk/app-debug.apk`. Las pruebas instrumentadas en
`integration_test/` requieren Android conectado. El host nativo permanece en `android/`, incluso
para integraciones mantenidas por Backend. Consulta la [frontera](../docs/architecture/frontend-backend-boundary.md).

`.migration-cache/` conserva únicamente caches generadas de la ubicación anterior, está ignorado
por Git y el analizador, y no participa en la compilación actual.
