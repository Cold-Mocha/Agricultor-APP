# Phase 0 Research: AgroCampo Android MVP - Módulo 001

**Fecha de consolidación**: 2026-08-30
**Estado**: decisiones técnicas cerradas; quedan únicamente gates de aprobación agronómica y
verificación contractual externa, ambos ubicados antes de su implementación.  
**Autoridad funcional**: [spec.md](./spec.md) y constitución 1.0.0.  
**Autoridad visual**: [master.md](../../master.md). `CONTEXTO.md`, `AGENTS.md`, prototipos y reportes
son evidencia o gobernanza de repositorio, nunca fuentes funcionales adicionales.

## Baseline verificado

El SDK disponible en el entorno fija Flutter 3.47.0 estable, Dart 3.13.0, Android `minSdk` 24 y `compileSdk`/`targetSdk` 36. Las versiones de paquetes siguientes son referencias estables verificadas en la fecha indicada, no autorización para actualizaciones automáticas. La implementación debe resolver compatibilidad como conjunto, confirmar un build Android y versionar `pubspec.lock`.

| Capacidad | Baseline investigado | Política |
|---|---|---|
| Estado | `flutter_riverpod` 3.4.2 | Mantener APIs `Notifier`/`AsyncNotifier`; no usar APIs experimentales. |
| Navegación | `go_router` 18.0.0 | Probar shell, restauración y predictive back antes de fijar lockfile. |
| SQLite | `drift` 2.34.3, `drift_dev` 2.34.5 | Usar motor nativo en background; no añadir `sqflite`. |
| Supabase | `supabase_flutter` 2.17.2 estable | No adoptar prerelease 3.x en el MVP. |
| Mapa | `flutter_map` 8.3.2, `latlong2` 0.10.1 | Teselas OSM como capa visual; geometría canónica en Drift. |
| GPS | `geolocator` 14.0.3 | Ubicación sólo en primer plano. |
| Firebase | `firebase_core` 4.14.0, `firebase_messaging` 16.6.0 | FCM no es temporizador ni fuente de verdad. |
| Avisos locales | `flutter_local_notifications` 22.3.0 | Requiere configuración Android/desugaring y pruebas en dispositivo. |
| Background | `workmanager` 0.10.9 | Trabajo oportunista, nunca garantía de ejecución exacta. |
| Señal de conectividad | `connectivity_plus` 7.3.1 | Dispara intentos; no confirma acceso real a internet. |
| Fotos | `image_picker` 1.2.3 | Recuperar datos perdidos y mover capturas fuera de caché. |
| SVG | `flutter_svg` 2.3.0 | Sólo assets locales aprobados. |
| Iconos | `lucide_icons_flutter` 3.1.17 | Fijar versión y auditar cobertura/licencia antes de crear el catálogo. |
| Sesión segura | `flutter_secure_storage` 11.0.0 | Backend Android Keystore; contraseña nunca persistida. |
| XLSX | `excel_community` 2.3.0 | Aislar detrás de contrato y fijar versión exacta. |

Fuentes de baseline: [Flutter 3.47.0](https://docs.flutter.dev/release/release-notes/release-notes-3.47.0), [Dart 3.13](https://dart.dev/changelog), [Riverpod](https://pub.dev/packages/flutter_riverpod), [go_router](https://pub.dev/packages/go_router), [Drift](https://pub.dev/packages/drift), [drift_dev](https://pub.dev/packages/drift_dev), [Supabase Flutter](https://pub.dev/packages/supabase_flutter), [flutter_map](https://pub.dev/packages/flutter_map), [latlong2](https://pub.dev/packages/latlong2), [geolocator](https://pub.dev/packages/geolocator), [Firebase Core](https://pub.dev/packages/firebase_core), [Firebase Messaging](https://pub.dev/packages/firebase_messaging), [notificaciones locales](https://pub.dev/packages/flutter_local_notifications), [Workmanager](https://pub.dev/packages/workmanager), [connectivity_plus](https://pub.dev/packages/connectivity_plus), [image_picker](https://pub.dev/packages/image_picker), [flutter_svg](https://pub.dev/packages/flutter_svg), [Lucide](https://pub.dev/packages/lucide_icons_flutter), [almacenamiento seguro](https://pub.dev/packages/flutter_secure_storage) y [excel_community](https://pub.dev/packages/excel_community).

## Matriz comparativa y decisión de consolidación

| Elemento | `001-agrocampo-mvp` retirado | `002-agrocampo-android-mvp` adoptado | Decisión consolidada |
|---|---|---|---|
| Spec | Casos de uso detallados y fórmula conceptual de riego; menor separación UI/función | 17 capacidades, 85 FR, estados y AC por capacidad | Mantener estructura de capacidades; integrar eliminación segura, reglas de riego y requisitos agrícolas omitidos, total 91 FR. |
| Plan | Flutter 3.44.7, Provider, aplicación en `mobile/`, corte vertical de sync temprano | Flutter 3.47.0, Riverpod, raíz `lib/`, arquitectura y seguridad más maduras | Conservar stack/estructura adoptados y migrar el corte vertical de sync antes del desarrollo territorial completo. |
| Tasks | Backlog por sprints, sync temprano y pruebas agronómicas exigentes | 80 tareas por historias, pero territorio/LABORES precedían el kernel sync y la trazabilidad llegaba al final | Regenerar por dependencias: gates → base → Parcel+sync vertical → territorio → LABORES → capacidades P2/P3; trazabilidad definida desde el inicio. |
| Data Model | `crop_irrigation_rules`, enteros escalados y recomendación auditable | Modelo local/remoto, conflictos, fotos, recordatorios y seguridad más completo | Mantener modelo adoptado e integrar reglas versionadas, cultivos propios, rotaciones planificadas, Otra labor, tipo de suelo y tarea apícola. |
| Research | Buen detalle de Drift, sync vertical y cálculo; Provider/estructura obsoletos | Decisiones por adapters, RLS, Riverpod, navegación y secretos más sólidas | Mantener D-001..D-018; incorporar el valor agrícola/táctico sin copiar versiones ni Provider. |
| Contracts | Navegación simple, sync, XLSX y adapters | Contratos más completos de diseño, navegación, sync, proveedores y XLSX | Mantener contratos adoptados, añadir cálculo de riego y ampliar rutas/entidades sin duplicar reglas visuales. |

Resultado: `specs/001-agrocampo-android-mvp/` es el único módulo funcional. El módulo anterior fue
retirado después de migrar únicamente su valor compatible; no se conserva una segunda variante.

## D-001 — Arquitectura feature-first con capas pragmáticas

**Decision**: Una sola aplicación Flutter Android organizada por feature. Dentro de cada feature se separan `presentation`, `domain` y `data`, con dirección `presentation -> domain <- data`. Widgets, controllers y componentes no acceden directamente a Drift, Supabase o plugins.

`domain` se exige para geometría, cálculo de riego, sincronización/conflictos, trazabilidad y exportación. En CRUD simple se permite que el controller llame al contrato de repositorio sin crear una clase `UseCase` vacía por operación. Infraestructura transversal permanece en `core`; un componente usado por una sola feature permanece en esa feature.

**Rationale**: Las 17 capacidades comparten infraestructura compleja, pero no justifican múltiples aplicaciones ni paquetes internos prematuros. La separación permite probar reglas y sustituir proveedores sin replicar el modelo offline.

**Alternatives considered**:

- Capas globales `screens/services/models`: rechazadas porque mezclan dominios y hacen crecer dependencias transversales.
- Clean Architecture ceremonial con un caso de uso por CRUD: rechazada por complejidad sin comportamiento.
- Micro-paquetes por feature: rechazados para el MVP; se extraen sólo si aparecen fronteras reales.

**Evidence**: [Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations), [Architecture guide](https://docs.flutter.dev/app-architecture/guide) y [Architecture concepts](https://docs.flutter.dev/app-architecture/concepts).

## D-002 — Riverpod como único sistema de estado e inyección

**Decision**: Adoptar Riverpod 3 con `Provider`, `Notifier`, `AsyncNotifier` y `StreamProvider.family`. Usar providers family para IDs de ruta y filtros; `keepAlive` sólo para sesión, infraestructura, parcela activa y resumen global de sincronización. Persistir datos y borradores en Drift, no en Riverpod.

Se admite `riverpod_annotation`/generador porque Drift ya requiere `build_runner`; ambos generadores comparten pipeline. No se usan `StateNotifier`, `ChangeNotifier`, Provider, BLoC ni APIs experimentales de persistencia/mutation.

**Rationale**: El producto combina streams locales, comandos asíncronos, permisos, outbox y servicios degradables; Riverpod cubre esas necesidades con un único modelo de estado e inyección. Los overrides permiten probar cada feature sin singletons. `master.md` permanece limitado a decisiones visuales y de interacción.

**Alternatives considered**:

- Provider: válido en Flutter, pero rechazado para mantener una única decisión de estado e inyección.
- BLoC: aporta formalidad de eventos, pero añade ceremonia y un segundo modelo de estados.
- Service locator/singletons: rechazado por dependencias ocultas y pruebas más frágiles.

**Evidence**: [Providers](https://riverpod.dev/docs/concepts2/providers), [Provider overrides](https://riverpod.dev/docs/concepts2/overrides) y [code generation](https://riverpod.dev/docs/concepts/about_code_generation).

## D-003 — go_router con cinco ramas persistentes

**Decision**: Usar `go_router` y `StatefulShellRoute.indexedStack` con cinco branches exactas y en el orden de `master.md`: Inicio, Sectores, Registrar, AgroIA y Más. Los IDs de parcela/sector viajan en la ruta; la parcela activa también se conserva en Drift. Rutas, ramas y páginas usan restauración de estado.

Back Android se resuelve con `PopScope`/`Form.canPop`; no se usa `WillPopScope`. Los borradores recuperables se guardan en Drift, porque restaurar la navegación no garantiza recuperar formularios tras muerte del proceso. En tablet se adapta contenido, no se introduce `NavigationRail` sin modificación previa de `master.md`.

**Rationale**: Cada destino superior conserva su pila y contexto, satisface UXR-002/003 y evita duplicación de destinos.

**Alternatives considered**:

- Navigator imperativo único: rechazado por deep links, ramas y restauración.
- Una pila global con barra inferior: rechazado porque pierde el stack propio de cada destino.
- NavigationRail adaptativo: fuera del Design System vigente.

**Evidence**: [go_router](https://pub.dev/packages/go_router), [state restoration](https://pub.dev/documentation/go_router/latest/topics/State%20restoration-topic.html) y [Android predictive back](https://docs.flutter.dev/release/breaking-changes/android-predictive-back).

## D-004 — Material 3 y tokens exclusivos de master.md

**Decision**: Construir un único `ThemeData(useMaterial3: true)` claro con un `ColorScheme` explícito, `TextTheme`, temas de componentes y `ThemeExtension` para estados semánticos. No usar `ColorScheme.fromSeed`, color dinámico ni defaults visuales no auditados. Los únicos literales visuales permitidos viven en `lib/app/theme/**` y deben ser una transcripción trazable de `master.md`.

Features y componentes consumen roles mediante `Theme.of(context)` y extensiones; no exponen parámetros libres de color, radio, sombra o padding. Inter y SVG se empaquetan localmente. Se añade una prueba de política que detecta literales visuales fuera del tema.

**Rationale**: Garantiza VR-001 a VR-006, evita deriva por defaults de Material y hace comprobable la prohibición de valores hardcodeados.

**Alternatives considered**:

- Tema generado desde seed/dynamic color: rechazado porque crea una paleta no autorizada.
- Constantes visuales importadas por cada pantalla: rechazadas porque duplican y evitan el contexto del tema.
- Tema oscuro: fuera del MVP.

**Evidence**: [Material 3 en Flutter](https://docs.flutter.dev/ui/design/material), [ThemeExtension](https://api.flutter.dev/flutter/material/ThemeExtension-class.html) y `master.md` como contrato normativo.

## D-005 — Biblioteca de componentes por semántica

**Decision**: Crear componentes compartidos por propósito: shell/cabecera/navegación, tarjetas, acciones, campos/unidades/errores, feedback, estados offline/sync, timeline y estados vacíos. Mapa y AgroIA conservan componentes especializados dentro de sus features cuando no exista reutilización real.

Cada componente recibe contenido, callbacks y estados semánticos; no recibe valores visuales arbitrarios. Implementa estados de interacción, semántica y comportamiento con texto ampliado según `master.md`.

**Rationale**: Reutiliza patrones aprobados sin convertirlos en mega-widgets ni crear variantes locales.

**Alternatives considered**:

- Un widget universal de tarjeta configurable: rechazado por APIs visuales abiertas y estados imposibles.
- Copiar widgets por pantalla: rechazado por deriva visual y accesible.

## D-006 — Drift nativo como fuente de verdad local

**Decision**: Usar `drift/native.dart` con una conexión nativa en background. No añadir `sqflite` ni `sqlite3_flutter_libs` a un proyecto nuevo. Centralizar `AppDatabase`, dividir tablas/DAOs por feature, habilitar FKs, versionar snapshots en `drift_schemas/` y probar cada migración.

Toda escritura de un agregado y su operación outbox comparte transacción; sólo después del commit se informa “guardado local”. Las consultas reactivas `watch()` alimentan repositories y providers, sin una segunda copia mutable en memoria.

**Rationale**: Drift cumple la constitución, ofrece tipos, transacciones, streams, migraciones y ejecución fuera del isolate de UI.

**Alternatives considered**:

- `drift_flutter`: facilita apertura, pero la conexión explícita nativa proporciona control suficiente para Android y evita una capa innecesaria.
- `sqflite`: rechazado porque duplicaría la tecnología local obligatoria.
- WAL/read pool desde el inicio: diferido hasta que perfiles demuestren contención.

**Evidence**: [Drift native](https://drift.simonbinder.eu/platforms/vm/), [transactions](https://drift.simonbinder.eu/dart_api/transactions/), [stream queries](https://drift.simonbinder.eu/dart_api/streams/) y [migration tests](https://drift.simonbinder.eu/migrations/tests/).

## D-007 — Modelo local/remoto y propiedad

**Decision**: UUID generado en Android y reutilizado en Drift, PostgreSQL, Storage y XLSX. Toda tabla privada remota contiene `owner_id` referenciado a `auth.users`; no se introducen granjas organizacionales, membresías, roles o trabajadores. Cada fila sincronizable lleva versión, timestamps UTC y tombstone.

Drift conserva además versión remota y estado de sync. El catálogo combina un seed oficial
inmutable, empaquetado localmente, con fichas `custom` aisladas por `owner_id`. Las asignaciones de
cultivo tienen estado `planned|active|ended|cancelled` para que una rotación futura no sustituya el
contexto vigente antes de la fecha efectiva. Geometría local es una secuencia WGS84/GeoJSON;
remoto usa PostGIS `geometry(Polygon,4326)`.

**Rationale**: La propiedad directa habilita múltiples cuentas independientes sin implementar colaboración fuera del MVP. La geometría independiente del proveedor mantiene operación offline.

**Alternatives considered**:

- `farm_id` y memberships: rechazados por MR-002; pueden incorporarse en migración futura.
- Convertir cultivos personalizados en catálogo global: rechazado; mezclaría datos de propietarios.
- Guardar sólo el próximo cultivo sobre `sectors`: rechazado; perdería cancelaciones y planificación histórica.
- IDs creados por servidor: rechazados porque bloquean creación offline.
- Extensión espacial SQLite: rechazada; no se necesita para las consultas del MVP.

**Evidence**: [Supabase RLS](https://supabase.com/docs/guides/database/postgres/row-level-security) y [PostGIS](https://supabase.com/docs/guides/database/extensions/postgis).

## D-008 — Outbox, RPC idempotente y pull durable

**Decision**: La escritura local crea una operación outbox con `operationId`, `baseVersion`, agregado, acción y dependencia causal. Push usa un RPC PostgreSQL transaccional que valida `auth.uid()`, registra recibo idempotente, aplica control optimista y emite `sync_changes`. No se utiliza `.upsert()` directo como protocolo.

Pull usa cursor monotónico `change_seq`, no `updated_at`. Página y cursor se aplican juntos en Drift. Conectividad dispara intentos, pero cada request maneja timeout/ACK perdido. Realtime y FCM son sólo señales de aceleración.

**Rationale**: Evita duplicados y ventanas perdidas, incluso con reloj incorrecto, proceso terminado o respuesta perdida.

**Alternatives considered**:

- Last-write-wins por `updated_at`: rechazado por pérdida silenciosa y relojes no confiables.
- Realtime como sync: rechazado porque no repara períodos offline.
- CRUD/upsert directo: rechazado porque no conserva dos versiones en conflicto.

**Evidence**: [Database functions](https://supabase.com/docs/guides/database/functions), [RPC Flutter](https://supabase.com/docs/reference/dart/rpc), [PostgreSQL advisory locks](https://www.postgresql.org/docs/current/explicit-locking.html) y [ON CONFLICT](https://www.postgresql.org/docs/current/sql-insert.html).

## D-009 — Conflictos explícitos y tombstones

**Decision**: Comparar `baseVersion` con versión canónica. En divergencia se conservan snapshots local/remoto, se bloquea reemplazo automático y el agricultor elige qué versión conservar. Resolver crea una nueva operación. Los borrados usan `deleted_at`; parcelas con historial usan además `archived_at`. Una parcela sin dependencias puede tombstonearse tras confirmación; no hay purga física inmediata en el MVP.

**Rationale**: Cumple FR-078, SC-006 y trazabilidad sin depender de tiempo local. Tombstones alcanzan dispositivos atrasados.

**Alternatives considered**:

- Merge campo a campo automático: rechazado para el MVP porque requiere semántica por entidad y puede producir combinaciones inválidas.
- Eliminación física: rechazada porque rompe dispositivos offline y Storage requiere retención coordinada.

## D-010 — Sesión offline y almacenamiento seguro

**Decision**: Primer acceso conectado. Después, una sesión Supabase recuperable permite abrir exclusivamente la base privada del `owner_id` correspondiente. Personalizar el almacenamiento local de sesión con `flutter_secure_storage` respaldado por Android Keystore. Antes de push se refresca/valida sesión.

Logout cierra base y coordinador, elimina tokens y no borra automáticamente datos/outbox. Otra cuenta abre otro espacio. No se almacena contraseña ni se añaden PIN/biometría como función.

**Rationale**: Mantiene disponibilidad offline sin convertir el JWT cacheado en autoridad remota y evita exposición entre usuarios del dispositivo.

**Alternatives considered**:

- Sesión en SharedPreferences por defecto: rechazada para material sensible.
- Borrar base en logout: rechazada por FR-004 y cambios pendientes.

**Evidence**: [Supabase sessions](https://supabase.com/docs/guides/auth/sessions), [auth state Flutter](https://supabase.com/docs/reference/dart/auth-onauthstatechange) y [custom LocalStorage de Supabase Flutter](https://pub.dev/packages/supabase_flutter).

## D-011 — OpenStreetMap, GPS y búsqueda

**Decision**: `flutter_map` y `latlong2` renderizan mapas y polígonos con teselas públicas de OpenStreetMap; `geolocator` conserva ubicación en primer plano. `PlacesGateway` permanece como límite opcional y deshabilitado mientras no exista un proveedor de búsqueda aprobado. La geometría confirmada por el agricultor es el dato del dominio.

Persistir vértices WGS84 ordenados, superficie y versión de algoritmo. Rechazar polígono con menos de tres puntos distintos, autocruce, área nula o sector fuera de parcela. Las teselas sólo son la capa cartográfica: sin ellas, `PolygonLayer` sigue renderizando la geometría local Drift y la lista equivalente. No realizar descarga masiva ni precarga de teselas. Permiso GPS denegado no bloquea dibujo manual; no se solicita ubicación en background.

**Rationale**: El proveedor visual puede fallar sin afectar datos locales. Mantener geometría en dominio permitió cambiar el renderizador sin migrar datos ni duplicar GPS, repositorios o providers.

**Alternatives considered**:

- Mapbox: diferido porque el MVP no exige descarga de mapas base y añade SDK/licencia.
- Búsqueda HTTP directa desde APK: rechazada hasta aprobar proveedor, contrato y política de uso.

**Evidence**: [flutter_map](https://pub.dev/packages/flutter_map), [PolygonLayer](https://docs.fleaflet.dev/layers/polygon-layer), [TileLayer](https://docs.fleaflet.dev/layers/tile-layer), [política de teselas OSM](https://operations.osmfoundation.org/policies/tiles/) y [atribución OSM](https://www.openstreetmap.org/copyright).

## D-012 — Open-Meteo detrás de Edge Function, con gate contractual

**Decision**: El propietario aprobó Open-Meteo como proveedor climático el 2026-09-03. La app llama un Edge Function autenticado por `parcelId`; el servidor obtiene una coordenada desde la geometría autorizada de la parcela cuando existe, usa la coordenada de despliegue como respaldo y devuelve un DTO normalizado. No acepta coordenadas arbitrarias del cliente. Drift guarda caché con expiración; el clima es auxiliar y nunca bloquea los flujos offline.

La implementación queda detrás de `WeatherGateway`. El URL entregado es un endpoint público, no una clave API. La caché de condiciones expira a los 60 minutos. No se retiene el payload crudo; una estimación de riego sólo conserva el ajuste numérico aplicado, código de proveedor, marca temporal y versión contractual. La UI muestra atribución enlazada a Open-Meteo y el aviso de que el clima es informativo/probabilístico. El pronóstico no se presenta como alerta meteorológica oficial, por lo que `alerts[]` queda vacío hasta aprobar una fuente autoritativa.

Antes de habilitar tráfico comercial se verifica otra vez el plan vigente y sus términos. El endpoint público se usa sólo bajo sus condiciones de evaluación/no comercial; un producto comercial debe configurar en la Edge Function el endpoint y credencial del plan contratado, sin cambiar dominio, almacenamiento, cálculo o componentes Flutter.

**Rationale**: Resuelve el alcance funcional sin exponer clave ni hacer del clima una dependencia crítica. Los límites de caché, atribución y aviso documentan los términos vigentes, que se vuelven a verificar antes de producción por ser externos y mutables.

**Alternatives considered**:

- WeatherAPI: sustituido por la selección expresa de Open-Meteo.
- OpenWeather: descartado inicialmente por obligaciones de atribución/redistribución que requieren revisión adicional.
- Consulta directa desde Flutter: rechazada para mantener autenticación, normalización, caché y capacidad de cambiar de plan/proveedor sin recompilar el APK.

**Evidence**: [Open-Meteo API](https://open-meteo.com/en/docs), [licencia](https://open-meteo.com/en/license) y [pricing](https://open-meteo.com/en/pricing).

## D-013 — Recordatorios locales y FCM secundario

**Decision**: Drift es fuente de verdad de recordatorios. `flutter_local_notifications` y timezone programan/reconcilian avisos locales al arrancar, editar, completar, reiniciar o cambiar zona horaria. FCM sólo entrega avisos remotos para entidades ya respaldadas o una señal de actualización.

Solicitar permiso de notificación en contexto. Usar exact alarm sólo si el producto demuestra necesidad y el usuario concede el acceso permitido; de otro modo degradar a inexacta sin borrar el recordatorio. Identidades estables de ocurrencia deduplican aviso local y remoto. Tokens FCM se gestionan por instalación y el envío ocurre server-side con HTTP v1.

**Rationale**: FCM puede retrasarse o expirar, por lo que no satisface recordatorios offline por sí solo. Android también limita alarmas/background.

**Alternatives considered**:

- FCM como scheduler: rechazado por confiabilidad y ausencia de red.
- WorkManager como alarma exacta: rechazado; sólo se usa como trabajo oportunista.

**Evidence**: [Android alarms](https://developer.android.com/develop/background-work/services/alarms), [notification permission](https://developer.android.com/develop/ui/views/notifications/notification-permission), [FCM lifespan](https://firebase.google.com/docs/cloud-messaging/customize-messages/setting-message-lifespan), [server environment](https://firebase.google.com/docs/cloud-messaging/server-environment), [HTTP v1](https://firebase.google.com/docs/cloud-messaging/send/v1-api) y [token management](https://firebase.google.com/docs/cloud-messaging/manage-tokens).

## D-014 — Gemini consultivo mediante Edge Function

**Decision**: Edge Function autenticado para conversación textual con Gemini; modelo estable fijado por ID/configuración de ambiente y nunca alias flotante. Se desactivan tools, function calling, ejecución, grounding e imágenes. El servidor carga sólo contexto permitido por RLS y whitelist, limita entrada/salida, aplica safety y devuelve texto más metadata de política.

La clave/authorization key permanece server-side. AgroIA no escribe datos, no analiza fotos, no realiza cálculos críticos ni propone cifras alternativas a la calculadora. Offline conserva mensajes/borradores, pero el reenvío requiere acción explícita.

**Rationale**: Reduce exposición y prompt injection, mantiene el rol consultivo de la constitución y permite evaluar cambios de modelo/prompt con una suite fija en español.

**Alternatives considered**:

- SDK Gemini directo en Flutter: rechazado por exposición de credenciales y controles insuficientes.
- Agente con herramientas: fuera del MVP.
- Análisis multimodal: prohibido por MR-006.

**Evidence**: [Gemini API keys](https://ai.google.dev/gemini-api/docs/api-key), [models](https://ai.google.dev/gemini-api/docs/models), [deprecations](https://ai.google.dev/gemini-api/docs/deprecations), [safety settings](https://ai.google.dev/gemini-api/docs/safety-settings) y [terms](https://ai.google.dev/gemini-api/terms).

## D-015 — Fotografías privadas e idempotentes

**Decision**: `image_picker` para cámara/galería. Al iniciar se recupera actividad interrumpida; al confirmar se valida y copia el archivo a almacenamiento privado, elimina EXIF GPS no necesario, calcula SHA-256 y luego inserta metadata Drift. No se guardan BLOB/base64 en SQLite.

Storage usa bucket privado y ruta inmutable `{ownerId}/{photoId}/{sha256}.{ext}`, sin overwrite. El archivo local se conserva hasta confirmación remota y según FR-055; un tombstone previo al upload cancela dependencias y evita resurrección.

**Rationale**: Android puede destruir la actividad del picker y las capturas temporales pueden desaparecer. Hash+ruta determinista vuelve seguro el reintento.

**Alternatives considered**:

- Plugin `camera`: rechazado porque una captura custom no pertenece al MVP.
- Guardar imagen en SQLite: rechazado por tamaño y rendimiento.
- Ruta mutable con overwrite: rechazada por conflictos y caché.

**Evidence**: [image_picker](https://pub.dev/packages/image_picker), [Supabase standard uploads](https://supabase.com/docs/guides/storage/uploads/standard-uploads) y [Storage access control](https://supabase.com/docs/guides/storage/security/access-control).

## D-016 — XLSX local con adapter y SAF Android

**Decision**: Aislar `excel_community` detrás de `WorkbookExporter` y fijar versión exacta. Generar `agrocampo_export_v1` completamente offline desde un snapshot transaccional Drift y fuera del isolate de UI. Escribir temporal, reabrir/validar OOXML y conteos, y publicar mediante un canal Android acotado que invoque Storage Access Framework `ACTION_CREATE_DOCUMENT`.

El workbook usa IDs/FKs textuales, fechas explícitas, unidades, estado de sincronización y protección contra formula injection; no incrusta fotos ni fórmulas.

**Rationale**: Cumple exportación offline sin permiso amplio de almacenamiento. El adapter reduce riesgo del mantenedor comunitario.

**Alternatives considered**:

- Syncfusion XlsIO: técnicamente sólido, pero requiere aprobación de licencia.
- Exportación en Supabase: rechazada porque falla offline y duplica lógica.
- `file_selector` para guardar: no ofrece selector de ubicación en Android; SAF nativo es el contrato correcto.

**Evidence**: [excel_community](https://pub.dev/packages/excel_community) y [Android Storage Access Framework](https://developer.android.com/training/data-storage/shared/documents-files).

## D-017 — Seguridad de secretos y RLS

**Decision**: El APK sólo contiene la clave publicable Supabase y configuración cliente Firebase. OpenStreetMap no usa API key; el cliente se identifica con el application ID y muestra atribución. Weather, Gemini, `service_role`, claves secretas Supabase y credenciales FCM viven en secretos server-side separados por ambiente.

Cada Edge Function exige JWT y reduce su consulta a datos del propietario mediante RLS. Logs no contienen token, coordenada exacta, prompt completo, fotografía o payload agrícola. Se definen dev/staging/prod, rotación, cuota y alertas.

**Rationale**: Ofuscación no protege secretos móviles; RLS y validación server-side son el perímetro real.

**Alternatives considered**:

- Variables `.env` empaquetadas como secretos: rechazadas; todo contenido del APK es recuperable.
- `service_role` en Flutter: prohibido.

**Evidence**: [Supabase API keys](https://supabase.com/docs/guides/getting-started/api-keys), [Functions auth](https://supabase.com/docs/guides/functions/auth), [Functions secrets](https://supabase.com/docs/guides/functions/secrets) y [RLS](https://supabase.com/docs/guides/database/postgres/row-level-security).

## D-018 — Estrategia de pruebas y controles de política

**Decision**: Combinar pruebas unitarias/domain, Drift, widget, golden, semántica, contratos, pgTAP, integración Flutter y comprobación manual/instrumentada de UI nativa. Los permisos, cámara, notificaciones, GPS y comportamiento del mapa con red real se prueban en dispositivo además de mocks.

Los controles obligatorios incluyen:

- transacción entidad+outbox y rollback;
- migraciones desde cada snapshot Drift;
- 20 o más vectores aprobados de riego;
- 24 horas offline y 100 cambios pendientes;
- pérdidas de ACK y fallos en cada frontera push/pull;
- conflicto entre dos dispositivos y ambas resoluciones;
- RLS anon/propietario A/propietario B/RPC/Storage;
- consulta con 20 parcelas, 200 sectores y 10.000 registros;
- prueba de política sin literales visuales fuera de `app/theme`;
- goldens y semántica para las pantallas exigidas por `master.md`;
- fallbacks individuales de mapas, clima, FCM, Storage y Gemini;
- XLSX reabierto, conteos/FKs y formula injection.
- cultivo personalizado aislado por propietario y rotación planificada sin cambio prematuro;
- “Otra labor”, tipo de suelo y tipo de tarea apícola en persistencia, sync, UI e historial.

**Rationale**: Los fallos más costosos cruzan almacenamiento local, proceso Android y red; mocks unitarios no bastan. La conformidad visual también debe ser automatizable.

**Evidence**: [Flutter testing overview](https://docs.flutter.dev/testing/overview), [integration tests](https://docs.flutter.dev/testing/integration-tests), [golden matcher](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html), [accessibility guidelines](https://api.flutter.dev/flutter/flutter_test/meetsGuideline.html) y [Supabase database testing](https://supabase.com/docs/guides/database/testing).

## D-019 — Contrato agronómico versionado antes del motor de riego

**Decision**: Migrar del módulo retirado la estructura `crop_irrigation_rules`: volumen base por
planta y cultivo, ajustes simples/acotados de tipo de suelo, humedad, temperatura y clima, y tiempo
derivado de volumen/caudal. Almacenar enteros escalados, ID/versión/fuente de regla, inputs,
resultados y advertencias. `contracts/irrigation-calculation.md` define fórmula, unidades, redondeo,
límites y evidencia; ninguna regla se activa sin revisión agronómica y veinte vectores aprobados.

**Rationale**: La estructura vuelve el cálculo local, reproducible e histórico sin inventar
coeficientes en código. El tipo de suelo se incorpora como entrada explícita solicitada.

**Alternatives considered**:

- Coeficientes hardcodeados durante implementación: rechazados por falta de fuente/aprobación.
- Fórmula delegada a Weather o AgroIA: rechazada por constitución y funcionamiento offline.
- Evapotranspiración avanzada: fuera del MVP.

## Resolved tensions

| Tensión | Resolución vinculante |
|---|---|
| Artefactos previos proponían Provider y el módulo adoptado Riverpod | Riverpod queda seleccionado y no se mezcla con otro patrón; `master.md` no decide arquitectura. |
| Riverpod ofrece persistencia experimental, constitución exige Drift | Drift es la única persistencia operativa; no usar persistencia Riverpod. |
| Material 3 genera defaults no normados | Construir roles/temas explícitos desde `master.md`; no seed/dynamic color. |
| Guías adaptativas sugieren NavigationRail | Mantener barra inferior de cinco destinos; adaptar contenido solamente. |
| go_router restaura rutas pero no formularios durables | Restauración para stack; Drift `form_drafts` para contenido. |
| `master.md` usa términos visuales y spec usa `Sector` | Modelo interno usa `Sector`; la UI usa el copy exacto aprobado sin crear otra entidad. |
| Servicios exigen atribución no definida visualmente | No inventar presentación; añadirla primero a `master.md` mediante el gate previo al proveedor. |
| Background/FCM pueden ser tardíos | El estado local manda; avisos y sync remotos son oportunistas. |

## Phase 0 outcome

La arquitectura puede avanzar al backlog sin decisiones técnicas abiertas. La aprobación agronómica
del contrato de riego y la verificación vigente de licencia/atribución climática son tareas
bloqueantes previas a esos componentes; no autorizan inventar valores, variantes visuales ni ampliar
el MVP.
