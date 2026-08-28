# Implementation Plan: AgroCampo Android MVP - Módulo 001

**Branch**: `feature/v1.0` | **Feature**: `002-agrocampo-android-mvp` | **Date**: 2026-08-28 | **Spec**: [spec.md](./spec.md)

**Input**: `spec.md`, `master.md`, `CONTEXTO.md`, `AGENTS.md` y la constitución vigente.

## Summary

AgroCampo será una aplicación Android nativa en experiencia, implementada con Flutter y Dart, que permite al agricultor propietario organizar parcelas y sectores, registrar `LABORES` y evidencias, calcular riego de forma determinista, consultar historial y continuar trabajando sin internet. La aplicación usará Drift/SQLite como fuente de verdad operativa local y Supabase como autenticación, respaldo PostgreSQL, almacenamiento privado de fotografías y punto de integración seguro.

La arquitectura será modular por feature, con capas de presentación, dominio y datos. Riverpod gestionará estado e inyección de dependencias; `go_router` implementará las cinco ramas de navegación definidas en `master.md`; y la capa visual consumirá exclusivamente `ThemeData`, `ColorScheme` y extensiones/tokens derivados de `master.md`. Ningún widget de pantalla o componente podrá introducir colores, tipografías, espaciados, radios, elevaciones, tamaños de icono o duraciones visuales directos.

## Technical Context

**Language/Version**: Flutter 3.47.0 estable, Dart 3.13.0 y Kotlin/Gradle sólo para integración Android generada por Flutter.

**Primary Dependencies**: Flutter Material 3, `flutter_riverpod`, `go_router`, `drift`, `supabase_flutter`, `google_maps_flutter`, `geolocator`, `firebase_core`, `firebase_messaging`, `flutter_local_notifications`, `workmanager`, `image_picker`, `flutter_svg`, `lucide_icons_flutter`, `flutter_secure_storage`, `connectivity_plus`, cliente HTTP compatible y generador `.xlsx` validado en `research.md`.

**Storage**: SQLite mediante Drift para todos los datos operativos, borradores, cachés y cola de sincronización; Supabase PostgreSQL para respaldo remoto; Supabase Storage privado para fotografías; Android Keystore mediante almacenamiento seguro para material de sesión.

**Testing**: `flutter_test`, `integration_test`, pruebas Drift con SQLite temporal/en memoria, pruebas de widgets y golden contra `master.md`, pruebas de semántica/accesibilidad, Supabase CLI con pgTAP para esquema/RLS/RPC y pruebas contractuales de adaptadores externos.

**Target Platform**: Android API 24 o superior; `compileSdk` y `targetSdk` 36 según el SDK Flutter instalado. No se crea ni valida una entrega iOS.

**Project Type**: Aplicación móvil Flutter con backend administrado Supabase y funciones server-side acotadas.

**Performance Goals**: Mantener interacción fluida a la frecuencia de refresco del dispositivo; entregar resultados útiles en menos de 2 segundos para el percentil 95 de consultas locales con 20 parcelas, 200 sectores y 10.000 registros; sincronizar 100 cambios sin pérdida ni duplicados según SC-004; evitar trabajo pesado de geometría, exportación o imágenes en el isolate de UI.

**Constraints**: Offline First no negociable; persistencia local anterior a todo intento remoto; español latinoamericano y unidades métricas; tema claro único; Design System exclusivo de `master.md`; cálculo crítico determinista; claves privadas sólo server-side; degradación aislada de mapa base, clima, FCM y AgroIA; sin valores visuales hardcodeados.

**Scale/Scope**: Un agricultor propietario autenticado por cuenta, múltiples parcelas, las 17 capacidades de la especificación y la carga de referencia definida por SC-012. No incluye trabajadores, roles, organizaciones, inventario, ERP, iOS, IoT, automatización física, IA avanzada ni análisis fotográfico.

## Constitution Check

### Gate previo a Phase 0

| Gate | Resultado | Evidencia del plan |
|---|---|---|
| Utilidad agrícola y simplicidad | PASS | Flujos por contexto activo, formularios acotados por tipo de labor, español y unidades métricas. |
| Android con Flutter y Dart | PASS | Un único cliente Flutter Android; el prototipo HTML sólo es referencia de flujo. |
| Offline First | PASS | Drift es fuente de verdad; toda mutación confirma entidad y outbox en una transacción local. |
| Trazabilidad y cálculo determinista | PASS | Modelo relacional histórico y calculadora versionada sin dependencia de AgroIA. |
| Alcance disciplinado | PASS | Las exclusiones MR-001 a MR-012 quedan fuera de módulos, contratos y fases. |
| SQLite + Drift | PASS | Persistencia local y consultas reactivas mediante Drift. |
| Supabase | PASS | Auth, PostgreSQL, Storage, RLS, RPC de sincronización y Edge Functions acotadas. |
| Mapas, clima, Gemini, FCM y XLSX | PASS | Adaptadores explícitos con degradación local y sin exponer secretos. |
| Autoridad visual | PASS | Toda decisión visual delegada a `master.md`; no se crean variantes locales. |
| Pruebas equivalentes | PASS | Dominio, persistencia, sync, RLS, accesibilidad, golden e integración Android cubiertos. |

### Revisión posterior a Phase 1

`data-model.md`, `contracts/` y `quickstart.md` mantienen los gates anteriores. No se identifican excepciones constitucionales ni de Design System que requieran justificación.

## Project Structure

### Documentation (this feature)

```text
specs/002-agrocampo-android-mvp/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── design-system-consumption.md
│   ├── external-services.md
│   ├── navigation.md
│   ├── sync-protocol.md
│   └── xlsx-export.md
└── tasks.md                         # Generado posteriormente por speckit-tasks
```

### Source Code (repository root)

```text
android/
├── app/src/main/
│   ├── AndroidManifest.xml
│   └── res/                         # Recursos Android mínimos
└── app/build.gradle.kts             # SDK, desugaring y plugins Android

assets/
├── fonts/inter/                     # Pesos locales autorizados por master.md
├── icons/crops/                     # Pictogramas SVG locales
└── images/                          # Activos aprobados, sin dependencias remotas

lib/
├── main.dart                        # Entrada mínima; delega en bootstrap
├── app/
│   ├── bootstrap/                   # Inicialización ordenada y composición raíz
│   ├── routing/                     # go_router, guards, ramas y restauración
│   └── theme/
│       ├── agro_theme.dart          # ThemeData Material 3
│       ├── color_scheme.dart        # Mapeo autorizado desde master.md
│       ├── semantic_colors.dart     # ThemeExtension de estados
│       ├── typography.dart
│       ├── spacing.dart
│       ├── radii.dart
│       ├── elevation.dart
│       ├── iconography.dart
│       ├── motion.dart
│       └── component_themes.dart
├── core/
│   ├── auth/                        # Sesión, propietario y aislamiento local
│   ├── database/
│   │   ├── app_database.dart
│   │   ├── tables/
│   │   ├── daos/
│   │   └── migrations/
│   ├── sync/                        # Outbox, pull cursor, conflictos y scheduler
│   ├── network/                     # Cliente, timeout y clasificación de errores
│   ├── geometry/                    # WGS84, validación y superficie determinista
│   ├── permissions/                 # GPS, cámara y notificaciones
│   ├── files/                       # Archivos privados y hash
│   ├── notifications/               # Programación local y recepción FCM
│   ├── export/                      # Construcción y guardado de XLSX
│   ├── errors/                      # Fallos tipados y recuperación
│   └── observability/               # Logs sin datos sensibles
├── features/
│   ├── auth/
│   ├── home/
│   ├── parcels/
│   ├── map/
│   ├── sectors/
│   ├── crops/
│   ├── labors/
│   ├── soil/
│   ├── irrigation/
│   ├── history/
│   ├── production/
│   ├── apiary/
│   ├── photos/
│   ├── reminders/
│   ├── weather/
│   ├── agro_ai/
│   ├── export/
│   ├── profile/
│   ├── settings/
│   └── sync_status/
│
│   # Cada feature se divide de forma consistente en:
│   # ├── domain/                    # Entidades, repositorios, casos de uso
│   # ├── data/                      # Fuentes local/remota y repositorio concreto
│   # └── presentation/              # Controllers Riverpod, páginas y widgets
└── shared/
    ├── domain/                      # Unidades, fechas, ID y estados comunes
    ├── formatting/                  # Formato agrícola y español
    └── presentation/
        ├── components/              # Biblioteca derivada de master.md
        └── semantics/               # Etiquetas y anunciadores accesibles

supabase/
├── migrations/                     # Tablas, constraints, índices, RLS y RPC
├── functions/
│   ├── weather-proxy/
│   ├── agro-ai/
│   └── notification-dispatch/
├── seed.sql                         # Catálogo aprobado y fixtures locales
└── tests/database/                  # pgTAP para integridad, RLS y sincronización

drift_schemas/                       # Snapshots versionados de migración

test/
├── app/
├── core/
├── features/
├── shared/
├── golden/
└── helpers/

integration_test/
├── critical_offline_flows_test.dart
├── synchronization_test.dart
└── android_integrations_test.dart
```

Cada feature mantiene la misma dirección de dependencias: `presentation -> domain <- data`. `core` ofrece capacidades técnicas transversales, pero no contiene reglas de una feature. Los widgets no dependen de Drift, Supabase, Firebase ni clientes HTTP. En features CRUD simples se permite omitir clases de caso de uso triviales; las reglas críticas siempre permanecen en dominio.

## Architecture

### Composición y flujo de datos

1. `main.dart` inicializa binding, configuración no secreta y delega en `bootstrap`.
2. `bootstrap` abre el espacio local del propietario, registra adaptadores y crea `ProviderScope`.
3. La presentación observa estado Riverpod y streams de repositorio.
4. Un caso de uso valida una acción y la entrega al repositorio.
5. El repositorio confirma en una sola transacción Drift tanto el cambio como su outbox.
6. La UI reacciona de inmediato al registro local y presenta el estado semántico definido en `master.md`.
7. El coordinador de sync procesa la outbox y después aplica páginas remotas en Drift.
8. La UI nunca cambia de fuente: sólo recibe el nuevo estado desde Drift.

Este flujo elimina la bifurcación entre “datos online” y “datos offline” en la presentación y evita que una respuesta tardía de red reemplace una edición local sin control.

### Gestión de estado

- Adoptar Riverpod como único patrón. Usar `Notifier` para interacción, `AsyncNotifier` para comandos y `StreamProvider.family` para consultas Drift reactivas.
- No usar `StateNotifier`, `ChangeNotifier`, Provider o BLoC en paralelo; tampoco la persistencia experimental de Riverpod.
- Los repositorios, reloj, generador de UUID, conectividad, servicios externos y coordinador de sincronización se inyectan mediante providers sustituibles en pruebas.
- Mantener estado efímero de widget sólo para detalles puramente visuales que no sobreviven a navegación. Selección de parcela/sector, borradores, filtros, outbox, sync y permisos pertenecen a controllers/providers.
- Representar estados con tipos explícitos. No usar booleanos ambiguos como `isOnline` o `isSaved` cuando existen estados intermedios.
- Aplicar `keepAlive` únicamente a infraestructura, sesión, contexto activo y resumen global de sync; providers de pantalla y consulta se liberan por ruta.
- Reducir reconstrucciones con providers por feature y selección de campos; las listas observan consultas Drift paginadas o acotadas.
- Los borradores críticos se guardan localmente y se recuperan al volver; el ciclo de vida de un controller no determina la durabilidad del dato.

### Navegación

- Usar `go_router` con `StatefulShellRoute.indexedStack` para preservar las pilas de las cinco ramas de `master.md`: Inicio, Sectores, Registrar, AgroIA y Más.
- Mantener Registrar como destino central y conservar exactamente el orden y etiquetas definidos por `master.md`.
- Rutas secundarias tipadas por contexto: parcela, mapa, sector, cambio de cultivo, suelo, riego, historial, producción, apicultura, fotos, recordatorios, perfil, configuración, conflicto y exportación.
- Implementar guard de sesión: primer acceso requiere red; una sesión recuperable habilita el espacio local de su propietario; sesión ausente redirige al acceso.
- Conservar scroll, filtros, selección y borradores mediante estado persistente por rama y `restorationScopeId`.
- Back de Android usa `PopScope`/`Form.canPop`, cierra modal/edición antes de abandonar la ruta y permite cancelar si hay cambios sin persistir.
- Los taps de notificación se traducen a rutas internas sólo después de validar sesión y existencia local del destino.
- Los IDs de contexto viajan en ruta; no dependen sólo de memoria Riverpod. Cambiar parcela invalida providers del contexto anterior.
- En tablet se adapta el contenido, pero se mantiene la navegación inferior hasta que `master.md` autorice otra arquitectura.

El contrato exacto de rutas y precondiciones está en [contracts/navigation.md](./contracts/navigation.md).

## Visual Architecture

### Tema Material 3 y Design Tokens

`master.md` es la única autoridad visual. La implementación tendrá un único tema claro Material 3 compuesto por:

- `ColorScheme` para roles Material, construido explícitamente; no usar `fromSeed`, color dinámico ni defaults visuales no auditados.
- `ThemeExtension` para estados semánticos no cubiertos por `ColorScheme`.
- módulos de tokens para tipografía, espaciado, radios, elevación, iconografía, layout y movimiento.
- temas de componentes Material para inputs, botones, cards, navegación, banners, chips, diálogos y feedback.
- Inter empaquetada localmente y activos SVG aprobados disponibles offline.

Sólo los archivos dentro de `lib/app/theme/` pueden contener los valores visuales normativos extraídos de `master.md`. El resto de la aplicación obtiene esos valores mediante `Theme.of(context)`, extensiones del tema o propiedades temáticas de componentes. No se duplican valores en features ni en `shared`.

El control automatizado rechazará en `lib/features/**` y `lib/shared/presentation/**` colores literales, `TextStyle` con medidas locales, paddings numéricos, radios, sombras, duraciones de animación o tamaños de icono no provenientes de tokens. Una necesidad no cubierta pausa la implementación visual y requiere actualizar `master.md` antes de añadir el token.

### Componentes reutilizables

La biblioteca `shared/presentation/components` implementará, según `master.md`, estas familias sin redefinir sus reglas:

- shell, cabecera, barra inferior y destino central Registrar;
- indicador global de conexión/sincronización y estado por registro;
- tarjetas estándar, hero, acción, sector/cultivo y métricas;
- botones, FAB, icon buttons, chips, selectores y controles segmentados;
- campos, unidades, ayuda, validación, resumen de errores y confirmación de guardado;
- banners, alertas, snackbar, progreso, error recuperable y estado vacío;
- mapa con overlays, modo edición, vértices y alternativa textual;
- timeline/historial, adjunto fotográfico y estado de carga;
- mensajes, contexto, disclaimer y compositor de AgroIA;
- filas de perfil/configuración y confirmaciones destructivas.

Un componente reusable acepta contenido y estados semánticos; no acepta colores, radios o sombras arbitrarios desde la feature. Las variantes sólo existen cuando ya están definidas en `master.md`. Los elementos que sólo usa una feature permanecen dentro de ella.

El contrato vinculante está en [contracts/design-system-consumption.md](./contracts/design-system-consumption.md).

## Local Storage and Offline First

### Drift como fuente de verdad

- Abrir Drift en isolate de base de datos para no bloquear la UI; activar concurrencia adicional sólo si las mediciones la justifican.
- Cada entidad sincronizable usa UUID generado en el dispositivo, timestamps UTC, versión remota y estado local de sincronización.
- DAOs se agrupan por agregado/feature y exponen consultas reactivas; la presentación no ejecuta SQL.
- Las escrituras de dominio y la inserción en `sync_outbox` comparten una transacción.
- `sync_cursor`, conflictos, borradores, caché climática, bindings de notificación y conversación AgroIA son tablas locales separadas.
- Las migraciones Drift son incrementales, versionadas, conservan snapshots y se prueban con fixtures de versiones anteriores.
- La base se mantiene en almacenamiento privado, separada por propietario. Cerrar sesión bloquea el espacio y elimina tokens sin borrar datos pendientes.
- Las fotografías se copian inmediatamente desde la ruta temporal a un directorio privado estable y se referencian por UUID/hash.

### Cola y sincronización

- La outbox registra creación, actualización, archivo, eliminación o resolución con `operationId` estable, `baseVersion`, payload, dependencia causal, intentos y próximo reintento.
- El push usa un RPC transaccional Supabase con recibos idempotentes. No se usa `upsert` directo como protocolo de sincronización.
- El servidor valida `auth.uid()`, propiedad, versión y agregado; incrementa versión y emite un evento ordenado para pull.
- El pull usa `change_seq` monotónico y cursor por propietario; cada página y su cursor se confirman juntos en Drift.
- Conectividad es una señal para intentar, no prueba de internet. Timeout, respuesta perdida y reinicio conservan la operación.
- La sincronización se ejecuta al iniciar, reanudar, guardar, recuperar conectividad, recibir una señal remota y mediante trabajo oportunista de Android. No promete ejecución exacta en segundo plano.
- Se usa backoff exponencial con jitter y reintento manual; errores de validación o propiedad requieren acción, no reintento infinito.
- Los borrados sincronizados son tombstones; parcelas con historial se archivan. No hay purga física durante el MVP.
- Realtime/FCM pueden acelerar una actualización, pero nunca sustituyen el cursor durable.

### Conflictos

- El control optimista compara `baseVersion` con la versión canónica; no utiliza el reloj del dispositivo ni last-write-wins.
- Si hay divergencia, se conservan snapshot local y remoto. El registro local entra en `conflict` y no se sobrescribe.
- El agricultor elige conservar la versión local o remota en una pantalla implementada según `master.md`.
- Resolver crea una nueva operación versionada y mantiene auditoría del conflicto.
- Los agregados compuestos —labor más suelo, riego/estimación, producción o revisión apícola— se validan y sincronizan atómicamente.

El protocolo completo está en [contracts/sync-protocol.md](./contracts/sync-protocol.md).

## Supabase Design

- PostgreSQL almacena el modelo descrito en `data-model.md`; PostGIS valida polígonos WGS84 y crea índices espaciales.
- Toda tabla privada contiene `owner_id` y RLS de propietario. No se crean tablas de organizaciones, trabajadores, membresías ni roles.
- Las FKs incluyen propietario cuando corresponda para impedir referencias cruzadas.
- RPC de push y pull aplican protocolo, versionado e idempotencia dentro de transacciones.
- Storage usa bucket privado y rutas inmutables por propietario/fotografía/hash; metadata se sincroniza después de confirmar el archivo.
- El catálogo de cultivos es de sólo lectura, sembrado por migración y empaquetado localmente para uso offline.
- Edge Functions actúan como proxy seguro para clima y Gemini y como emisor autorizado de FCM. Ninguna clave privada se distribuye en el APK.
- La clave publicable Supabase puede vivir en configuración de build; la seguridad depende de RLS y validación server-side, no de ocultarla.

## External Integrations

### Mapas y GPS

- Selección inicial: Google Maps Flutter, compatible con el mínimo Android adoptado.
- `geolocator` encapsula permisos, ubicación actual y estados de servicio.
- El dominio conserva coordenadas/polígonos WGS84 independientes del proveedor; Google Maps sólo renderiza y edita.
- Sin mapa base, la app conserva geometrías guardadas, lista textual de sectores y cálculo local. Búsqueda y teselas se degradan de forma aislada.
- PostGIS revalida geometría y superficie al sincronizar; una diferencia fuera de tolerancia genera error explícito o revisión, nunca reemplazo silencioso.

### Clima

- Un Edge Function consulta el proveedor gratuito seleccionado, normaliza temperatura, humedad, lluvia y pronóstico, y aplica timeout/rate-limit.
- Drift conserva última lectura, ubicación y momento de actualización. La UI identifica datos desactualizados según `master.md`.
- La calculadora conserva el snapshot climático realmente usado; si no hay lectura válida, ejecuta la rama local documentada y muestra su limitación.

### Notificaciones

- Drift es fuente de verdad de recordatorios; `flutter_local_notifications` agenda avisos offline en la zona horaria del dispositivo.
- FCM entrega avisos remotos y señales no autoritativas. Un tap se resuelve contra datos locales antes de navegar.
- Se registra permiso concedido/denegado sin eliminar el recordatorio. Se prueban restricciones de fabricantes y Android; la app no promete hora exacta cuando el sistema la impide.

### AgroIA

- La app llama una Edge Function autenticada que invoca Gemini; la clave nunca vive en Flutter.
- El request contiene únicamente pregunta, contexto agrícola autorizado y versión del contrato; no envía fotografías para análisis.
- La respuesta es texto consultivo, con estado/reintento y aviso requerido; no modifica datos ni ejecuta cálculos críticos.
- Offline conserva conversación local y deshabilita el envío con explicación; el resto del producto continúa disponible.

### Fotografías y XLSX

- `image_picker` cubre cámara/galería y recuperación de actividad Android interrumpida; el archivo se copia a almacenamiento privado antes de confirmar la asociación.
- La carga comprime sólo si conserva el propósito probatorio, calcula hash y reintenta sin overwrite.
- El XLSX se genera desde un snapshot consistente de Drift, fuera del isolate de UI, e identifica registros no respaldados.
- La entrega del archivo usa una capacidad Android validada en `research.md`; no se agrega panel web ni exportación server-side.

Los límites y fallbacks están en [contracts/external-services.md](./contracts/external-services.md) y [contracts/xlsx-export.md](./contracts/xlsx-export.md).

## Security and Privacy

- Supabase Auth se limita a email/contraseña y perfil del propietario; el primer acceso requiere conexión.
- Tokens se almacenan mediante una implementación segura respaldada por Android Keystore; nunca se persiste contraseña.
- Cada repositorio requiere un `ownerId` autenticado y cada política RLS compara con `auth.uid()`.
- Se validan propiedad y versión de nuevo dentro de RPC; el cliente no es autoridad.
- Logs omiten JWT, claves, prompts con datos personales, rutas firmadas y payloads agrícolas completos.
- Fotografías usan bucket privado y URLs firmadas temporales cuando sea necesario.
- La base local no se comparte entre propietarios y permanece en sandbox privado de la aplicación.
- Maps, Firebase, clima y Gemini usan restricciones de clave por aplicación/servicio y cuotas configuradas fuera del código.

## Testing Strategy

### Pirámide

- **Unitarias**: validadores, unidades, superficie, cálculo híbrido, estados, casos de uso, backoff, conflicto y mapeos.
- **Persistencia**: constraints, migraciones, transacciones entidad+outbox, consultas/filtros y reinicio sin conexión.
- **Widget**: estados carga/vacío/contenido/error/pendiente/sync, formularios, restauración, navegación y componentes compartidos.
- **Golden y accesibilidad**: pantallas exigidas por `master.md`, tamaños de dispositivo, texto ampliado, contraste, semántica y movimiento reducido.
- **Contrato**: RPC push/pull, adaptadores externos, esquemas normalizados, archivos y workbook.
- **Backend**: migraciones, FKs, checks, índices, RLS, Storage y RPC mediante Supabase local/pgTAP.
- **Integración Android**: acceso, permisos, GPS, cámara, notificaciones, trabajo en background, proceso destruido, offline/reconexión y exportación.
- **Aceptación**: cada `AC-CAP`, AC-001 a AC-010 y SC-001 a SC-014 con fixtures trazables.

### Escenarios de resiliencia obligatorios

- 24 horas offline con reinicios y todos los registros críticos disponibles.
- 100 operaciones pendientes, pérdida de ACK, caída durante push/pull y reanudación sin duplicados.
- Dos dispositivos editando la misma versión y ambas resoluciones de conflicto.
- Cadena causal parcela -> sector -> labor -> fotografía.
- Sesión expirada, refresh fallido, logout con pendientes y acceso posterior del propietario correcto.
- Mapa, clima, FCM, Storage o Gemini indisponibles de forma independiente.
- 20 parcelas, 200 sectores y 10.000 registros con consultas bajo el objetivo de SC-012.

## Implementation Phases and Recommended Order

### Phase 1 - Foundation and visual architecture

1. Fijar toolchain Android, identificador de aplicación, configuración por entorno y política de secretos.
2. Crear estructura modular, composición raíz, manejo de errores y convenciones de pruebas.
3. Implementar tokens, ThemeData Material 3 y biblioteca base consumiendo únicamente `master.md`.
4. Crear shell `go_router`, cinco ramas, restauración y guard de sesión.
5. Integrar Supabase Auth, espacio local por propietario y perfil mínimo.

**Validación de fase**: build Android limpio; theme audit sin literales visuales fuera de `app/theme`; navegación/back/restauración probados; acceso online inicial y reapertura offline aislada por propietario; revisión visual base contra `master.md`.

### Phase 2 - Persistence and synchronization kernel

1. Crear esquema Drift, DAOs, migraciones y fixtures.
2. Implementar repositorios local-first y transacción entidad+outbox.
3. Crear esquema Supabase, constraints, índices, RLS y Storage privado.
4. Implementar RPC idempotente, pull por cursor, backoff, scheduler y estado observable.
5. Implementar conservación/resolución de conflictos y pruebas de interrupción.

**Validación de fase**: escritura visible tras reinicio offline; 100 operaciones sin pérdida/duplicado; aislamiento RLS; ACK perdido idempotente; conflicto conserva ambas versiones; UI diferencia guardado local y respaldo según `master.md`.

### Phase 3 - Parcelas, mapa, sectores y cultivos

1. Implementar parcela activa, CRUD/archivo y catálogo local de cultivos.
2. Integrar GPS y permisos.
3. Implementar búsqueda conectada, dibujo/edición de polígonos y cálculo local.
4. Implementar sectores dentro de parcela, asignación temporal y temporadas.
5. Añadir lista textual equivalente al mapa y sincronización de geometrías.

**Validación de fase**: user story 1 completa; geometrías sobreviven offline/reinicio; sector no puede cruzar propietario/parcela; catálogo disponible offline; mapa falla sin bloquear lista/edición local; pantallas conformes a `master.md`.

### Phase 4 - LABORES, suelo, riego e historial

1. Implementar agregado común `Labor` y formularios por tipo.
2. Añadir mediciones de suelo con rangos/unidades.
3. Implementar riego, fórmula híbrida versionada y snapshot climático opcional.
4. Construir historial filtrable por parcela, sector, cultivo y temporada.
5. Verificar atomicidad y sincronización de especializaciones.

**Validación de fase**: user stories 2 y 4; veinte escenarios de riego reproducibles; filtros sin contaminación; fórmula funciona sin red/IA; cada labor y especialización se confirma como un agregado; estados visuales según `master.md`.

### Phase 5 - Producción, apicultura, fotografías y recordatorios

1. Implementar producción/cosecha y revisión apícola como especializaciones.
2. Integrar cámara/galería, almacenamiento privado, hash y pipeline de upload.
3. Implementar recordatorios Drift y programación local.
4. Incorporar recepción FCM, tokens de dispositivo y rutas seguras.

**Validación de fase**: user stories 5, 6 y 7; fotografía permanece asociada tras proceso destruido; reintentos no duplican archivos; permiso denegado no elimina recordatorio; avisos y navegación se comportan correctamente en Android.

### Phase 6 - Clima, AgroIA y exportación

1. Implementar Edge Function y caché normalizada de clima.
2. Integrar clima opcional al cálculo sin volverlo dependencia.
3. Implementar Edge Function Gemini y conversación consultiva local.
4. Generar y guardar XLSX desde snapshot local trazable.

**Validación de fase**: user story 8; claves ausentes del APK; fallos externos aislados; AgroIA no escribe ni calcula; XLSX abre e incluye conjuntos/relaciones/estado exigidos por spec.

### Phase 7 - Hardening and Android release

1. Completar matriz AC/SC, accesibilidad, golden y pruebas de campo.
2. Perfilar consultas, exportación, geometría, imágenes y rebuilds.
3. Auditar RLS, Storage, secretos, logs, dependencias y configuración release.
4. Probar upgrade/migraciones, backup operativo, recuperación y firma Android.
5. Ejecutar build reproducible y checklist de distribución Android.

**Validación de fase**: todos los gates constitucionales en PASS; SC-003/004/006/007/010/012/013/014 medidos; cero funcionalidad excluida; análisis y pruebas sin fallos; AAB/APK release instalable en dispositivos de referencia.

## Technical Risks

| Riesgo | Impacto | Mitigación y señal de cierre |
|---|---|---|
| Complejidad de sync propio | Pérdida, duplicados o bloqueo de cola | RPC idempotente, cursor durable, tests de fallos en cada frontera y métricas de outbox. |
| Restricciones Android/OEM en background | Sync o avisos tardíos | Guardado local inmediato, triggers de foreground, WorkManager oportunista y comunicación honesta. |
| Sesión revocada durante offline | Datos locales válidos pero sin autorización remota | Aislar por propietario, refrescar antes de push y conservar pendientes al pedir reautenticación. |
| Divergencia de cálculos numéricos | Resultados de riego o superficie inconsistentes | Escala fija, fórmula versionada, fixtures aprobados y revalidación server-side. |
| Mapa/proveedor sin conexión o cuota | No hay teselas/búsqueda | Geometría independiente, lista textual y edición local; restricciones/cuotas monitorizadas. |
| Crecimiento de fotografías y outbox | Almacenamiento, batería y datos móviles | Compresión controlada, hash, lotes, backoff y visibilidad de uso; sin purga destructiva en MVP. |
| RLS o RPC incompletos | Exposición entre propietarios | Deny-by-default, owner_id, pruebas A/B/anon y revisión de cada nueva tabla/función. |
| Deriva visual | Inconsistencia y falla AC-002/SC-013 | Tokens centralizados, lint de literales, componentes compartidos y golden contra `master.md`. |
| Dependencias móviles volátiles | Build roto o cambios de APIs | Baseline documentado, `pubspec.lock`, actualizaciones separadas y smoke build real Android. |
| XLSX grande en UI isolate | Bloqueo o memoria alta | Snapshot consistente, generación fuera del isolate de UI y prueba con 10.000 registros. |

## Definition of Architectural Done

El plan puede pasar a `$speckit-tasks` cuando:

- no exista ningún marcador de decisión pendiente en los artefactos;
- cada capability tenga ubicación de módulo, entidad y estrategia de prueba;
- toda ruta visual dependa del contrato de `master.md` y ningún plan proponga valores alternativos;
- el modelo local/remoto, outbox, cursor, conflictos y Storage estén definidos;
- cada integración externa tenga adapter, secreto, timeout, caché/fallback y pruebas;
- los gates constitucionales sigan en PASS después de revisar `data-model.md` y `contracts/`.

## Complexity Tracking

No hay violaciones constitucionales ni excepciones de arquitectura que registrar.
