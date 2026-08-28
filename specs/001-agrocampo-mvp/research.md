# Technical Research: AgroCampo MVP - Módulo 001

**Date**: 2026-08-28

**Scope**: Decisiones necesarias para planificar el MVP Android definido en `spec.md` y
`constitution.md`.

**Status**: Complete; all technical decisions are resolved.

## 1. Toolchain and Android baseline

**Decision**: Usar Flutter `3.44.7` del canal estable como línea base, con la versión de Dart que
incluye ese SDK. El producto soportará Android API 24-37, compilará contra el API estable más
reciente admitido y se validará al menos en API 24, 29, 33 y 37. Las versiones exactas de paquetes
se fijarán en el lockfile después de probarlas juntas en CI.

**Rationale**: La matriz oficial vigente de Flutter soporta Android API 24-37. Mantener el SDK y
Dart acoplados evita combinaciones no soportadas y API 24 conserva compatibilidad con equipos
rurales sin mantener versiones de Android que Flutter ya no prueba.

**Alternatives considered**:

- Usar un Flutter anterior: rechazado porque pierde soporte y correcciones actuales.
- Subir el mínimo a API 26 o superior: simplifica algunas APIs Android, pero excluiría dispositivos
  que aún están dentro de la matriz soportada sin un requisito de producto que lo justifique.

**Sources**: [Flutter supported platforms](https://docs.flutter.dev/reference/supported-platforms),
[Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations).

## 2. Flutter application architecture

**Decision**: Crear una única aplicación Flutter Android en `mobile/`, organizada por feature y
con MVVM pragmático y flujo unidireccional:
`View -> ViewModel -> Repository -> Drift`. Usar `provider` para estado e inyección por constructor,
`go_router` para navegación y clases de servicio o caso de uso solo para reglas críticas o flujos
que coordinan varios repositorios. Drift será la única fuente de verdad persistente de la UI.

**Rationale**: El esquema separa presentación, reglas y datos sin imponer una capa ceremonial a
cada CRUD. Los ViewModels son probables de forma aislada, los repositorios ocultan el origen local o
remoto y ningún estado en memoria compite con la base Offline First.

**Alternatives considered**:

- Riverpod: ofrece buen aislamiento, pero su persistencia no sustituye Drift y añade otra
  abstracción sin beneficio obligatorio para el MVP.
- BLoC completo o Clean Architecture estricta: posible, pero produciría más clases y eventos que
  valor para un único producto móvil.
- Estado global mutable o acceso directo a Supabase desde widgets: rechazado por acoplamiento,
  dificultad de pruebas y doble fuente de verdad.

**Sources**: [Flutter architecture guide](https://docs.flutter.dev/app-architecture/guide),
[Flutter recommendations](https://docs.flutter.dev/app-architecture/recommendations),
[go_router](https://pub.dev/packages/go_router).

## 3. Local persistence with Drift

**Decision**: Usar Drift sobre SQLite nativo con una conexión creada en background, claves
foráneas habilitadas, transacciones para cada agregado y snapshots de esquema versionados. Las
entidades sincronizables usarán UUID generados en el dispositivo y conservarán propietario,
versión remota, estado de sincronización y tombstone. Polígonos se guardarán como GeoJSON WGS84;
las fotos se guardarán como archivos privados y SQLite conservará solo sus metadatos.

Los valores críticos se almacenarán en unidades enteras escaladas: mililitros, segundos, gramos,
milésimas de pH y centésimas de porcentaje. Latitud, longitud y superficie aproximada pueden usar
punto flotante, pero cada resultado guardará versión de algoritmo y entradas.

**Rationale**: Drift entrega consultas tipadas, streams, transacciones y migraciones comprobables.
La conexión en background evita bloquear cuadros de UI. UUID compartidos permiten crear offline
sin reasignar identificadores y los enteros evitan diferencias de redondeo en cálculos trazables.

**Alternatives considered**:

- SQLite sin Drift: reduce generación, pero pierde seguridad de tipos y herramientas de migración.
- SpatiaLite local: no es necesario para el volumen ni los polígonos del MVP y aumenta complejidad
  binaria; la geometría se validará mediante lógica Dart determinista.
- Guardar imágenes como BLOB: rechazado por tamaño, copias y migraciones costosas.

**Sources**: [Drift native](https://drift.simonbinder.eu/platforms/vm/),
[Drift transactions](https://drift.simonbinder.eu/dart_api/transactions/),
[Drift migrations](https://drift.simonbinder.eu/migrations/),
[Drift migration tests](https://drift.simonbinder.eu/migrations/tests/),
[SQLite foreign keys](https://www.sqlite.org/foreignkeys.html).

## 4. Offline First synchronization protocol

**Decision**: Implementar outbox transaccional local, mutaciones remotas idempotentes, control
optimista por versión y pull por secuencia monotónica de servidor.

1. Una transacción Drift valida y guarda el agregado junto con `sync_outbox`.
2. Un coordinador único reclama operaciones mediante lease persistente y las envía en orden causal.
3. Cada operación lleva `operation_id`, `aggregate_id`, acción, payload y `base_version`.
4. Un RPC Supabase transaccional valida usuario, registra la operación, aplica el agregado y crea
   un evento de `sync_changes`; repetir `operation_id` devuelve el mismo recibo.
5. Tras push, el cliente descarga eventos con `change_seq > cursor`, aplica el lote y avanza el
   cursor dentro de una misma transacción Drift.
6. Si `base_version` no coincide, se guardan snapshot local y remoto; la UI exige conservar remoto
   o aplicar la versión local contra la nueva versión remota.
7. Timeout, 429 y 5xx usan backoff exponencial con jitter; errores de validación o autorización
   quedan visibles y requieren acción.

La sincronización se dispara al iniciar, reanudar, recuperar conectividad y por acción manual.
WorkManager añadirá ejecución best-effort con red, reutilizando el mismo coordinador; no se prometerá
sincronización inmediata con la aplicación terminada.

**Rationale**: El protocolo soporta pérdida de ACK, reinicios, reloj incorrecto y conflictos sin
duplicados ni descarte silencioso. La secuencia de servidor es más segura que `updated_at` para
reconstruir periodos offline.

**Alternatives considered**:

- `upsert` directo: idempotente por fila, pero puede ocultar conflictos y repetir efectos compuestos.
- Last-write-wins: viola el requisito de conservar ambas versiones y depende del reloj del teléfono.
- Cursor por fecha: vulnerable a empates y orden de commit.
- Supabase Realtime como fuente de verdad: útil como señal conectada, pero no reconstruye por sí solo
  una desconexión prolongada.

**Sources**: [Android Offline First](https://developer.android.com/topic/architecture/data-layer/offline-first),
[WorkManager](https://developer.android.com/reference/androidx/work/WorkManager.html),
[PostgreSQL advisory locks](https://www.postgresql.org/docs/current/explicit-locking.html),
[Supabase RPC for Dart](https://supabase.com/docs/reference/dart/rpc),
[Supabase Realtime limitations](https://supabase.com/docs/guides/realtime/postgres-changes).

## 5. Supabase database, authentication and authorization

**Decision**: Usar Supabase Auth con cuentas provisionadas y correo/contraseña; PostgreSQL con
PostGIS; Storage privado para fotografías; migraciones y seeds versionados en `supabase/`.
Cada tabla privada incluirá `owner_id`, aunque también exista relación con una parcela, y tendrá
RLS y grants mínimos. La aplicación contendrá solo la publishable key.

Las mutaciones sincronizadas pasarán por un RPC público `SECURITY INVOKER` que delega en una
función interna `SECURITY DEFINER`, con `search_path` vacío, validación explícita de `auth.uid()` y
permisos de ejecución acotados. Se revocará DML directo de tablas de negocio al rol autenticado.
La sesión se almacenará en almacenamiento seguro de Android, nunca en SQLite ni logs. Offline se
permite leer el almacén del último propietario validado; al reconectar se exige renovar la sesión
antes de enviar datos.

**Rationale**: `owner_id = auth.uid()` hace las políticas RLS simples, indexables y preparadas para
propietarios independientes futuros sin introducir roles. El RPC es el único lugar que puede
aplicar versiones, agregados atómicos y recibos idempotentes.

**Alternatives considered**:

- Acceso DML directo con RLS: seguro para CRUD simple, pero permite omitir control de versión.
- `service_role` dentro de Flutter: prohibido porque omite RLS y compromete todo el proyecto.
- Políticas que derivan propietario mediante joins: aumentan costo y superficie de error.
- Aumentar la vida del JWT para soportar offline: rechazado; el modo offline no debe debilitar la
  política de sesión conectada.

**Sources**: [Supabase secure data](https://supabase.com/docs/guides/database/secure-data),
[Supabase RLS](https://supabase.com/docs/guides/database/postgres/row-level-security),
[Database functions](https://supabase.com/docs/guides/database/functions),
[Supabase sessions](https://supabase.com/docs/guides/auth/sessions),
[User data](https://supabase.com/docs/guides/auth/managing-user-data),
[PostGIS](https://supabase.com/docs/guides/database/extensions/postgis).

## 6. Map and GPS provider

**Decision**: Usar `google_maps_flutter` y ubicación puntual mediante `geolocator`. Google Maps
renderiza; el dominio Dart conserva vértices WGS84, valida cierre/autocruces/contención y calcula
superficie. Sin tiles, una vista esquemática local seguirá mostrando geometrías y coordenadas. La
búsqueda se encapsulará y usará Places/Geocoding mediante una función protegida cuando haya red.

La clave Android será exclusiva por entorno y estará restringida por package, SHA-1 y API. La app
mostrará atribución y avisos legales exigidos por Google.

**Rationale**: Existe plugin oficial, soporte de polígonos y coherencia con servicios Firebase. El
MVP no exige descargar mapas base; desacoplar la geometría permite trabajo local sin violar las
políticas de cache de tiles.

**Alternatives considered**:

- Mapbox: mejor opción si una futura especificación exige paquetes de mapas offline, pero añade
  administración, límites y costos de tiles que no necesita el MVP.
- Canal Flutter/Kotlin para búsqueda nativa: más complejo que una interfaz HTTP protegida.

**Sources**: [Google Maps for Flutter](https://pub.dev/packages/google_maps_flutter),
[Polygon sample](https://developers.google.com/maps/flutter-package/samples/polygons),
[API key security](https://developers.google.com/maps/api-security-best-practices),
[Map tile policies](https://developers.google.com/maps/documentation/tile/policies),
[Android location permissions](https://developer.android.com/develop/sensors-and-location/location/permissions).

## 7. Weather provider

**Decision**: Usar WeatherAPI.com Free mediante una Supabase Edge Function autenticada. La función
oculta la clave, valida coordenadas, limita frecuencia y normaliza temperatura, humedad,
precipitación y pronóstico. Drift cacheará condiciones actuales por hasta 60 minutos y pronóstico
por hasta 24 horas según sus términos. Los datos vencidos se mostrarán con fecha, pero no ajustarán
el cálculo de riego.

**Rationale**: El plan gratuito cubre el volumen del propietario, ofrece tres días de pronóstico y
sus reglas de cache, atribución y uso están documentadas. La calculadora siempre puede degradar a
entradas locales.

**Alternatives considered**:

- OpenWeather Free: ofrece mayor cuota y cinco días de pronóstico; queda como adaptador alternativo
  si cambian costos o términos, tras una revisión de licencia.
- Clave del clima en el APK: rechazada porque puede extraerse y consumirse sin control.

**Sources**: [WeatherAPI pricing](https://www.weatherapi.com/pricing.aspx),
[WeatherAPI docs](https://www.weatherapi.com/docs/),
[WeatherAPI terms](https://www.weatherapi.com/terms.aspx),
[OpenWeather pricing](https://openweathermap.org/price).

## 8. Reminders and notifications

**Decision**: Drift y las alarmas locales son la fuente primaria de recordatorios. Usar
`flutter_local_notifications` con zona horaria y alarma inexacta por defecto. Reconciliar alarmas
al iniciar, editar, reiniciar o cambiar zona horaria. Usar FCM solo para entrega remota de
recordatorios sincronizados, con tokens por usuario/dispositivo y deduplicación por `event_id`.

El envío FCM HTTP v1 ocurrirá únicamente desde una Supabase Edge Function con credencial de
servicio protegida. El payload no incluirá detalles agrícolas, solo identificadores necesarios
para que el cliente lea el contenido local. La denegación de permisos no elimina recordatorios.

**Rationale**: FCM no garantiza hora exacta ni funciona offline; las alarmas locales sí conservan
el valor principal. La entrega doble queda controlada por identificadores idempotentes.

**Alternatives considered**:

- Solo FCM: rechazado por conectividad, Doze, force-stop y latencia no garantizada.
- Alarmas exactas por defecto: rechazado por permisos y política; solo se considerarán si una futura
  aceptación exige precisión al minuto.

**Sources**: [FCM Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/get-started),
[FCM server environment](https://firebase.google.com/docs/cloud-messaging/server-environment),
[Manage FCM tokens](https://firebase.google.com/docs/cloud-messaging/manage-tokens),
[Android alarms](https://developer.android.com/develop/background-work/services/alarms).

## 9. Gemini advisory assistant

**Decision**: Implementar consultas textuales mediante una Supabase Edge Function, con modelo GA
fijado por configuración; a la fecha de investigación, `gemini-3.5-flash` es el candidato. La
función exige JWT, minimiza contexto, aplica límites de tamaño, timeout, rate limit, safety
settings y presupuesto. La clave o credencial nunca entra al APK.

El prompt de sistema impide diagnósticos fotográficos, dosificación de agroquímicos, cálculos de
superficie o riego, escrituras automáticas y presentación de respuestas como órdenes. Toda salida
se rotula como orientación consultiva. Antes de publicar se verificará deprecación del modelo y la
migración a authorization keys anunciada para septiembre de 2026.

**Rationale**: El proxy permite controlar secretos, costos y política. Un modelo Flash reduce
latencia/costo para orientación textual; ningún resultado alimenta reglas críticas.

**Alternatives considered**:

- Firebase AI Logic desde Flutter: incorpora App Check y SDK oficial, pero el proxy Supabase ofrece
  una frontera única para secretos, logging mínimo y límites del MVP.
- API key directa: rechazada por extracción y abuso.
- Fotos y análisis multimodal: fuera del MVP.

**Sources**: [Gemini API keys](https://ai.google.dev/gemini-api/docs/api-key),
[Models](https://ai.google.dev/gemini-api/docs/models),
[Deprecations](https://ai.google.dev/gemini-api/docs/deprecations),
[Safety settings](https://ai.google.dev/gemini-api/docs/safety-settings),
[Gemini terms](https://ai.google.dev/gemini-api/terms).

## 10. Photos and Supabase Storage

**Decision**: Usar `image_picker`, copiar de inmediato cada archivo temporal a almacenamiento
privado de la app, recuperar selecciones perdidas al arrancar, retirar EXIF no necesario y guardar
metadatos/hash en Drift. El bucket privado `agricultural-photos` usará ruta inmutable
`owner_id/photo_id/sha256.ext`, MIME y tamaño restringidos, RLS por primera carpeta y `upsert=false`.

La copia local solo se elimina mediante una política posterior a confirmación de archivo y metadata;
en el MVP puede conservarse para uso offline. Cargas estándar se usarán para archivos comprimidos
de hasta 6 MB; TUS se evaluará solo si pruebas reales muestran fallos repetidos.

**Rationale**: Evita BLOB, exposición pública y reaparición de archivos tras un retry. La ruta y
hash permiten tratar una respuesta perdida como éxito si el objeto coincide.

**Alternatives considered**:

- Plugin `camera` con UI propia: fuera de necesidad; `image_picker` cubre cámara y galería.
- Bucket público o sobreescritura: rechazados por privacidad e idempotencia.
- TUS desde el inicio: agrega complejidad sin evidencia para imágenes ya comprimidas.

**Sources**: [image_picker](https://pub.dev/packages/image_picker),
[Storage standard uploads](https://supabase.com/docs/guides/storage/uploads/standard-uploads),
[Storage access control](https://supabase.com/docs/guides/storage/security/access-control),
[Private buckets](https://supabase.com/docs/guides/storage/buckets/fundamentals).

## 11. XLSX export

**Decision**: Usar `excel_community` detrás de `WorkbookExporter`, con versión fijada y pruebas de
contrato. Generar el libro totalmente desde un snapshot Drift, en isolate, y entregarlo mediante
Android Storage Access Framework. Hojas mínimas: Parcelas, Sectores, Cultivos, Labores, Suelo,
Riegos y Producción. IDs, relaciones, fecha ISO, unidades métricas y estado de sincronización son
columnas obligatorias. Texto de usuario se escribe explícitamente como texto para evitar inyección
de fórmulas.

**Rationale**: Es una opción Dart compatible con Android y licencia permisiva. El snapshot produce
una exportación coherente y funciona offline sin pedir acceso amplio al almacenamiento.

**Alternatives considered**:

- Syncfusion XlsIO: más maduro, pero exige validar licencia comunitaria o comercial.
- Paquete `excel` original: mantenimiento actual insuficiente.
- CSV: no cumple el formato `.xlsx` ni la estructura multihoja.

**Sources**: [excel_community](https://pub.dev/packages/excel_community),
[Syncfusion XlsIO](https://pub.dev/documentation/syncfusion_flutter_xlsio/latest/),
[Storage Access Framework](https://developer.android.com/training/data-storage/shared/documents-files).

## 12. Testing strategy

**Decision**: Aplicar una pirámide de pruebas con:

- unitarias Dart para reglas de riego, geometría, validación, repositorios y sincronización;
- Drift en memoria y tests generados de migración;
- widget tests para formularios, rutas y estados offline/sync;
- pgTAP y Supabase CLI para migraciones, RLS, RPC, PostGIS e índices;
- integración Flutter contra Supabase local y Android real/emulado;
- pruebas de fault injection en cada frontera de ACK;
- fixtures de 20 parcelas, 200 sectores, 10.000 registros y 100 operaciones offline.

**Rationale**: Los riesgos principales son pérdida silenciosa, migraciones y reglas críticas; cada
uno necesita pruebas deterministas antes de depender de pruebas manuales de UI.

**Alternatives considered**:

- Solo pruebas end-to-end: lentas y poco precisas para fallos de reloj, transacción y retry.
- Supabase remoto compartido en CI: menos reproducible y con riesgo de datos/credenciales.

**Sources**: [Flutter integration tests](https://docs.flutter.dev/testing/integration-tests),
[Drift testing](https://drift.simonbinder.eu/testing/),
[Supabase database testing](https://supabase.com/docs/guides/database/testing),
[Supabase local workflow](https://supabase.com/docs/guides/local-development/cli-workflows).
