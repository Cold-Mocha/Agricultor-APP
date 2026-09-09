# Backend AgroCampo

Responsable: Lógica / Datos / Backend. `agrocampo_backend` es un paquete Flutter sin interfaz
visual, compilado dentro del APK. Drift sigue siendo la fuente operativa offline; repositorios,
outbox y sincronización conservan sus transacciones. Supabase remoto vive en `supabase/`.

```powershell
# En la raíz: flutter pub get
dart run build_runner build
flutter analyze
flutter test
supabase --workdir . start
supabase --workdir . test db
deno test --allow-env supabase/functions/weather-proxy/tests supabase/functions/agro-ai/tests
```

`build_runner` usa `build.yaml`; las instantáneas de migración están en `drift_schemas/`.
Los tests de lógica, persistencia y contratos están en `test/`. pgTAP necesita Docker y el stack
local activo. Los tests E2E contra Supabase además necesitan las variables documentadas en
[`quickstart.md`](../specs/002-agrocampo-functional-core/quickstart.md).

La allowlist pública está en `lib/agrocampo_backend.dart`. No exportes repositorios, DAOs,
filas Drift, clientes SDK ni gateways. Cada capacidad delimita sus contratos mediante
`lib/src/modules/<feature>/<feature>_api.dart`; los controllers y estados de UI viven en Frontend.
Consulta la [frontera](../docs/architecture/frontend-backend-boundary.md).
