# Phase 0 Research: AgroCampo Functional Core - Módulo 002

**Date**: 2026-08-29  
**Inputs**: Constitution 2.0.0, [spec.md](./spec.md), Módulo 001, `master.md`, Flutter/Drift/Supabase source and test audit.

## Outcome

No se necesita reescribir AgroCampo. El repositorio ya contiene la mayoría de los límites útiles —features, Drift, repositories, outbox, gateways, cálculo entero, geometría y UI base—, pero varios flujos son prototipos conectados a datos parciales. El mayor riesgo no está en una pantalla faltante sino en dos invariantes rotas: una sesión local puede restaurarse sólo con `ownerId`, y el RPC de sync puede confirmar tipos que no aplicó. Ambos se corrigen antes de ampliar funcionalidad.

Las decisiones siguientes resuelven las incógnitas técnicas del plan. No quedan decisiones abiertas; la activación de coeficientes de riego continúa siendo un gate explícito de datos/aprobación, no una ambigüedad arquitectónica.

## Repository Evidence

### Base reusable

- Aplicación Flutter en raíz con Riverpod, `go_router`, tokens de `master.md` y features separadas.
- Drift v9 con 24 tablas, DAOs técnicos y migraciones incrementales v1-v9.
- Repositories de parcela, sector, labor, producción, riego, recordatorio y otras capacidades.
- Patrón correcto ya presente en varios guardados: fila de dominio + `sync_outbox` dentro de `transaction()`.
- `PolygonGeometry`, GPS foreground y `flutter_map`/`latlong2` disponibles; OpenStreetMap es sólo la capa visual.
- Catálogo oficial en asset, cultivos personalizados y modelo `CropRotation` parcial.
- `IrrigationCalculator` puro basado en enteros, reglas versionadas y estado sin regla aprobada.
- Gateways/Edge Functions para Open-Meteo y AgroIA; scheduler local de notificaciones.
- RLS por propietario, tablas técnicas `sync_operations`, `sync_changes`, `sync_conflicts` y RPC iniciales.
- Pruebas unitarias, widget/golden, pgTAP e integración que sirven como base de regresión.

### Defects that block 002

- `SessionController` puede restaurar acceso local usando sólo el propietario persistido, sin exigir material de sesión recuperable.
- Bootstrap crea un `SupabaseClient` independiente, mientras algunas pantallas usan `Supabase.instance.client`; el singleton no se inicializa como autoridad común.
- No existe biometría ni dependencia `local_auth`.
- Varias pantallas obtienen “un único sector” del propietario. Con más de uno, pueden lanzar `Bad state: too many elements` o registrar en un contexto ambiguo.
- El mapa permite dibujar un sector nuevo, pero no muestra/edita de forma completa polígonos persistidos ni separa un borrador de la geometría confirmada.
- `crop_seasons` representa una asignación sector-cultivo con fechas, no una temporada agrícola independiente.
- Cultivos personalizados, rotaciones y estimaciones de riego no completan outbox/sync/UI.
- No existe configuración permanente de riego por sector; la pantalla usa `cropId: unassigned`, por lo que no obtiene una regla real.
- Labor y producción pueden representar una cosecha como dos eventos desconectados; varios payloads omiten contexto histórico.
- Historial carga tablas completas y filtra en memoria; omite eventos de temporada/asignación y no resuelve bien etiquetas/estado sync.
- `sync_push` de la migración 0003 aplica sólo `parcel` pero agrega ACK para cada operación recibida.
- `SyncCoordinator` sólo aplica pulls de parcela, ignora los demás y luego avanza cursor.
- El gateway convierte payload remoto mediante `.toString()`, lo que no garantiza JSON decodificable.
- Estados `sending`, `retryWait`, `blocked`, dependencias e información de reintento existen en schema pero no gobiernan la ejecución.
- Las pruebas de integración usan mayormente SQLite en memoria y gateways falsos; no prueban reapertura ni ACK real Supabase.
- `migration_policy.dart` declara versión 1 mientras `AppDatabase.schemaVersion` declara 9; el “snapshot” v9 actual es un manifiesto de nombres, no el snapshot Drift completo.

## Decision D2-001 — Incremento sobre la arquitectura existente

**Decision**: conservar la aplicación única, la organización feature-first y la dirección pragmática `presentation → domain ← data`. Extender los repositories/controllers actuales y refactorizar únicamente donde exista un defecto de datos, sesión, contexto o sync.

**Rationale**: la estructura ya contiene los módulos 002 y cambiarla no produce valor funcional. Los defectos son locales y corregibles detrás de límites existentes.

**Alternatives considered**:

- Reescribir desde un schema/modelo ideal: rechazada por riesgo de pérdida y Constitución I.
- Crear un segundo módulo/app para 002: rechazado por FR-001 y límites técnicos.
- Crear casos de uso/interactors para cada CRUD: rechazado; sólo dominio crítico requiere una capa explícita.

## Decision D2-002 — Una instancia Supabase inyectada y sesión local protegida

**Decision**: el bootstrap crea una sola instancia `SupabaseClient?`, expuesta por Riverpod a repositories/gateways. `SessionController` distingue `restoring`, `locked`, `signedIn`, `signedOut` y error recuperable. Una restauración requiere propietario y refresh token/sesión previamente validada; una sesión offline abre sólo el espacio local del mismo propietario. Logout borra tokens y opt-in biométrico, cierra acceso/providers y conserva DB/outbox.

`BiometricUnlockGateway` encapsula `local_auth` 3.0.2, compatible con Flutter 3.47/Dart 3.13 y el mínimo Android API 24 del proyecto. La integración cambia la actividad actual de `FlutterActivity` a `FlutterFragmentActivity` sin perder su canal XLSX, agrega `USE_BIOMETRIC` y ajusta `LaunchTheme`/`NormalTheme` a un padre AppCompat compatible. Biometría es opt-in después del login y sólo cambia `locked → signedInLocal` para una sesión existente. Cancelación, indisponibilidad o falla no borra datos ni crea una identidad.

**Rationale**: corrige acceso local posterior a logout sin introducir MFA, PIN propio o autenticación adicional.

**Alternatives considered**:

- Mantener `Supabase.instance` y también cliente manual: rechazada por divergencia de sesión/configuración.
- Borrar la base al cerrar sesión: rechazada porque eliminaría cambios pendientes.
- Guardar contraseña o crear PIN local: rechazado por seguridad y alcance.
- Cifrado custom de DB: rechazado; no existe requisito/modelo de amenaza que lo justifique en 002.

**Evidence**: [`local_auth` 3.0.2 y plataformas soportadas](https://pub.dev/packages/local_auth), [configuración Android oficial del paquete](https://pub.dev/packages/local_auth_android).

## Decision D2-003 — Contexto agrícola explícito y persistido

**Decision**: crear un controller/projection, no otra tabla de dominio, sobre `AppPreferences`: `ownerId`, `activeParcelId`, `activeSectorId?`, `activeSeasonId?`, `activeAssignmentId?`, `revision`. El controller valida que cada hijo pertenece al padre y escoge una alternativa determinista cuando un elemento activo se archiva/cierra. Los formularios capturan su contexto al abrir y no cambian silenciosamente si la selección global cambia.

**Rationale**: elimina supuestos de sector único y hace observable la jerarquía requerida sin duplicar datos agrícolas.

**Alternatives considered**:

- Pasar IDs manualmente a cada constructor sin estado persistido: insuficiente tras reinicio y para navegación global.
- Elegir “primer sector” automáticamente: rechazada por riesgo de registrar en el terreno equivocado.
- Estado sólo en Riverpod: rechazado porque no sobrevive muerte del proceso.

## Decision D2-004 — Drift v10 aditivo, dos tablas nuevas

**Decision**: mantener las 24 tablas y agregar:

1. `agricultural_seasons`, porque temporada de parcela no existe.
2. `sector_irrigation_configs`, porque configuración permanente no es un evento ni una estimación.

Conservar físicamente `crop_seasons` y modelarlo en Dart como asignación sector-cultivo, añadiendo `agriculturalSeasonId` y metadata requerida. Añadir campos de relación/sync/tombstone e índices sólo en entidades 002. Reconciliar `migration_policy.dart`, generar snapshot real y probar v9→v10 con fixture poblado.

**Rationale**: usar `crop_seasons` como temporada y asignación a la vez impide intercambios y temporadas con varios sectores; guardar configuración en el último riego destruiría reproducibilidad histórica.

**Alternatives considered**:

- Renombrar/recrear `crop_seasons`: rechazada por riesgo; el nombre físico no bloquea dominio.
- Crear tablas separadas por tipo de labor: rechazada; `detailsJson` versionado satisface estructura sin explosión de schema.
- Incorporar metadata sync a cada una de las 24 tablas: rechazada; local-only y capacidades fuera de 002 no lo requieren ahora.
- Normalizar cada gotero como fila: rechazada; 002 necesita conteo/distribución, no inventario de hardware.

## Decision D2-005 — Backfill temporal preservador

**Decision**: para cada parcela con asignaciones/eventos v9 sin temporada explícita, crear una `agricultural_season` importada con ID determinista derivado de owner+parcel+versión de migración. Su rango cubre las fechas existentes disponibles; si faltan fechas, usa una fecha de importación declarada y estado cerrado/activo según registros actuales. Enlazar `crop_seasons` existentes a esa temporada sin cambiar ID, cultivo, sector, estado o rango. Eventos con relación ya disponible heredan temporada/asignación; los restantes quedan enlazados a la temporada importada y conservan su snapshot textual actual.

**Rationale**: evita valores nulos permanentes en relaciones críticas y conserva significado sin inventar múltiples temporadas históricas no demostrables.

**Alternatives considered**:

- Inferir temporadas agronómicas por mes/cultivo: rechazada; inventaría semántica.
- Dejar todos los FK nuevos nulos: rechazada para flujos/historial que exigen temporada.
- Descartar filas incoherentes: prohibido por FR-002.

## Decision D2-006 — `detailsJson` versionado para labores; agregados atómicos

**Decision**: mantener `Labors` como raíz con contexto obligatorio y `detailsJson` como estructura específica validada por `laborType` y `detailsSchemaVersion`. Tipos mínimos 002: irrigation, fertilization, phytosanitary, sowing, pruning, harvest y other. Una cosecha guarda labor+production en una transacción y un payload de agregado; un riego guarda labor+record+estimate/snapshot de configuración de igual forma.

Editar datos históricos crea una corrección/supersesión cuando cambia fecha/contexto de forma relevante; no reescribe silenciosamente la relación original. Ediciones simples autorizadas mantienen versión/control de conflicto.

**Rationale**: completa estructura observable y evita que cada tipo genere arquitectura/tablas sin necesidad. Agregados atómicos eliminan eventos duplicados e inconsistentes.

**Alternatives considered**:

- Una tabla por fertilización/siembra/poda: rechazada por datos actuales simples y alcance.
- Guardar todos los campos como notas: rechazada porque no satisface labor estructurada.
- Producción como registro independiente sin labor: rechazada por FR-047 y trazabilidad.

## Decision D2-007 — Protocolo sync v2 por resultados, no lista de ACK

**Decision**: conservar outbox, gateway, coordinador, receipts y change log, pero reemplazar la semántica actual con resultados individuales. Cada agregado habilitado tiene un codec pequeño que valida payload, aplica push remoto, aplica pull local y maneja tombstone. La allowlist inicial se despliega por fases.

Una operación sólo queda `done` por `applied|duplicate` con receipt/hash coincidente. `unsupported`, decode inválido o handler faltante es `rejected/blocked`, nunca ACK. El coordinator persiste `sending`, `attemptCount`, `nextAttemptAt`, error y recuperación de envío interrumpido; respeta dependencias y procesa pull+cursor en una transacción. Payload es JSON estructurado y versionado.

**Rationale**: generalizar el RPC actual propagaría pérdida silenciosa. Un registro pequeño de codecs es la mínima abstracción que garantiza simetría push/pull por entidad.

**Alternatives considered**:

- Mantener `acknowledgedOperationIds`: rechazada porque no expresa rechazo/conflicto/retry ni prueba aplicación.
- Upsert directo por repository: rechazado por idempotencia, conflicto y offline.
- Generador/framework de sincronización: rechazado por complejidad y necesidad de reglas por agregado.
- Last-write-wins por fecha: rechazado por pérdida silenciosa.

## Decision D2-008 — Retry, orden causal, tombstones y conflictos simples

**Decision**: backoff exponencial persistido con jitter y techo razonable; reintento inmediato manual sólo para retryable. Un trigger de red es pista, la llamada determina reachability. Operaciones padre preceden a hijos mediante `dependsOnOperationId`. Create+delete nunca respaldado cancela operaciones; elemento ya remoto usa tombstone. Conflictos conservan snapshot local/remoto; mantener remoto aplica el codec local, mantener local crea nueva operación contra la versión remota.

**Rationale**: cumple reinicio, reconexión y no resurrección con las tablas técnicas existentes.

**Alternatives considered**:

- Reintento infinito inmediato: rechazado por batería/cuota.
- Cascadas físicas: rechazadas por historia/dispositivos atrasados.
- Merge automático campo a campo: fuera de alcance y potencialmente inválido.

## Decision D2-009 — Territorio independiente del mapa remoto

**Decision**: reutilizar `PolygonGeometry`, agregar detección de autocruce y mantener WGS84/área versionada. Un editor usa copia de borrador separada de la geometría confirmada. GPS foreground centra/propone, nunca reemplaza confirmación. El mapa renderiza datos locales; si fallan teselas, una vista geométrica simplificada y lista conservan acceso. El servidor mantiene validación PostGIS.

**Rationale**: geometría es dato agrícola, no estado del widget/proveedor.

**Alternatives considered**:

- Guardar sólo overlays del plugin: rechazado por portabilidad/offline.
- Editar al tocar el mapa sin modo: rechazado por FR-023/024.
- Cachear teselas Google: rechazado por necesidad/licencia; no es requisito 002.

## Decision D2-010 — Temporadas, asignaciones, rotación e intercambio

**Decision**: temporada pertenece a parcela y tiene `planned|active|closed`. Asignación pertenece a sector+temporada+cropRef y tiene rango efectivo/estado. Máximo una asignación efectiva por sector/fecha. Activar una rotación cierra la vigente y abre la nueva en una transacción. Intercambiar cultivos crea dos nuevas asignaciones con la misma fecha efectiva y termina las dos anteriores de forma atómica; no mueve eventos.

El catálogo combina official read-only y custom owner-scoped; custom puede archivarse, no borrarse físicamente si tiene referencias.

**Rationale**: separa calendario de parcela y uso de cada sector, preservando historia.

**Alternatives considered**:

- Cambiar `cropId` directamente sobre sector: rechazada porque destruye historia.
- Duplicar catálogo oficial por propietario: rechazada por datos y sync innecesarios.
- Mover labores al nuevo cultivo en intercambio: prohibido por spec.

## Decision D2-011 — Riego por goteo como configuración + cálculo + snapshot

**Decision**: la configuración permanente es versionada y efectiva por sector; el cálculo recibe configuración, crop/rule real y variables del evento. Reutilizar fórmula exacta entera de 001, retornar resultado/explicación/warnings y guardar snapshot inmutable al confirmar riego. `IrrigationRecommendationEngine` tiene una implementación `Drip...`; no se crean engines de otros métodos.

Ninguna regla queda activa sin fuente/revisor y 20 vectores aprobados. Sin regla, UI permite configurar/registrar y muestra `crop_rule_unavailable`, pero no una recomendación validada. Clima sólo aporta ajuste opcional normalizado; no bloquea cálculo local.

**Rationale**: separa datos reutilizables de evento y conserva reproducibilidad.

**Alternatives considered**:

- Gemini para calcular/explicar números: prohibido.
- Copiar configuración actual al leer historia: rechazada porque reescribe significado.
- Implementar evapotranspiración u otros métodos: fuera de 002.

## Decision D2-012 — Historial como query/proyección local indexada

**Decision**: crear una proyección de lectura que une temporadas, asignaciones, labores y especializaciones por relaciones históricas. Orden estable por `occurredAt`+tipo+ID, con filtros SQL por sector/temporada/cultivo/tipo/rango. Producción y riego decoran su labor raíz y no crean una segunda tarjeta. El estado sync procede de agregado/outbox/conflicto.

**Rationale**: cargar tablas completas no escala ni garantiza aislamiento. Una proyección/DAO es suficiente; no se necesita event sourcing.

**Alternatives considered**:

- Mantener filtro en Dart: rechazado por SC-015 y riesgo de mezcla.
- Duplicar todos los eventos en tabla timeline: rechazado por divergencia.
- Event sourcing: desproporcionado.

## Decision D2-013 — Recordatorios locales reconciliados

**Decision**: mantener Drift+`flutter_local_notifications`. Persistir una identidad numérica estable de notificación o derivarla de forma determinista con colisión gestionada. Reconciliar scheduled reminders al login/unlock/bootstrap, edición, completar/cancelar, reboot y cambio de zona horaria. Solicitar permiso en contexto; denegación no revierte el recordatorio. WorkManager no se usa como alarma exacta.

**Rationale**: `String.hashCode` no constituye ID durable entre procesos y el scheduler actual no cubre el ciclo completo.

**Alternatives considered**:

- FCM como scheduler: rechazado por offline.
- No persistir binding: rechazada por cancelación/deduplicación.

## Decision D2-014 — Open-Meteo normalizado y degradable

**Decision**: conservar `WeatherGateway` y `weather-proxy`, sustituyendo WeatherAPI por Open-Meteo. La configuración server-side contiene la coordenada de respaldo y un endpoint opcional de cliente; el URL público no es una clave. El DTO mínimo contiene ubicación, observed/fetched/expires y condiciones/pronóstico normalizados. La caché antigua aparece como antigua, no vigente. Open-Meteo no se trata como fuente de alertas oficiales y no se inventa riesgo de helada desde un umbral local.

**Rationale**: ya existe un límite server-side correcto; falta conectarlo y expresar estados.

**Alternatives considered**:

- Open-Meteo directo desde APK: rechazado para conservar autenticación, contrato, política de caché y cambio de endpoint sin recompilar.
- Hacer clima requisito del riego: prohibido por offline-first.
- Guardar payload completo indefinidamente: innecesario y contrario al contrato 001.

## Decision D2-015 — AgroIA general, idempotente y sin contexto privado

**Decision**: reutilizar gateway/Edge Function con prompt consultivo, pero enviar únicamente `clientMessageId`, texto del usuario, locale y metadata de política necesaria. No consultar Drift/Supabase para contexto. Persistir estado del mensaje; un reintento reutiliza ID y reemplaza/continúa el intento, sin insertar otra pregunta. No tools, imágenes, cálculos ni escritura.

**Rationale**: implementa la sustitución expresa de 002 y corrige duplicación por fallos.

**Alternatives considered**:

- Mantener contexto privado definido visualmente en `master.md`: rechazado; 002 gobierna comportamiento/datos.
- Cola automática offline de prompts: rechazada; el usuario debe reintentar explícitamente.
- SDK/clave Gemini en Flutter: rechazado por credencial y control.

## Decision D2-016 — Evidencia de pruebas reales

**Decision**: mantener unit/fakes para reglas y fallos, pero exigir adicionalmente:

- DB de archivo cerrada/reabierta para persistencia;
- snapshot Drift real y fixtures de migración;
- Supabase local/pgTAP para apply/ACK/idempotencia/conflicto/RLS;
- pruebas Flutter con reinicio lógico y reconexión;
- Android real/instrumentado para biometría, GPS/mapa y notificaciones/reboot.

**Rationale**: las pruebas en memoria actuales no prueban las fronteras donde 002 promete durabilidad.

**Alternatives considered**:

- Aceptar fakes como evidencia end-to-end: rechazada por Constitución III/IX.
- Probar todo en dispositivo: innecesario; dominio y codecs son más rápidos/deterministas en host.

## Decision D2-017 — Secuencia por dependencias y gates

**Decision**: implementar en orden: sesión/persistencia/sync → territorio/contexto → temporadas/cultivos → labores/producción → goteo → historial → recordatorios/clima/AgroIA → hardening. Cada fase habilita el contexto requerido por la siguiente y termina con un flujo observable.

**Rationale**: construir pantallas agrícolas sobre sesión/sync/contexto defectuosos multiplicaría retrabajo y riesgo.

**Alternatives considered**:

- Ordenar por capas técnicas completas: rechazada porque demoraría evidencia funcional.
- Empezar por riego: rechazado porque depende de sector, temporada, cultivo y regla.

## Resolved Tensions

| Tensión | Resolución |
|---|---|
| `master.md` describe AgroIA contextual; 002 prohíbe contexto privado automático | 002 gobierna payload/comportamiento; `master.md` conserva UI, navegación, disclaimer y accesibilidad. |
| 001 modeló temporadas/asignaciones, pero código v9 las fusionó | 002 materializa temporada y migra la tabla existente como asignación, preservando filas. |
| Outbox existe, pero sólo parcela funciona realmente | Se conserva kernel y se reemplaza semántica RPC/codec gradualmente; no se generaliza hasta probar parcela. |
| Spec pide riego funcional, reglas aún no aprobadas | Infraestructura/configuración/registro pueden completarse; recomendación sólo se activa con regla y vectores aprobados. |
| Biometría no estaba en 001 | Se añade `local_auth` como dependencia concreta, sin cambiar Supabase como autenticación. |
| Apicultura usa territorio, pero no es gate 002 | Mantener modelo especializado y ajustar sólo selección/FKs afectados por contexto. |

## Phase 0 Conclusion

La arquitectura puede pasar a diseño y posterior generación de tareas sin reescritura ni decisiones técnicas pendientes. La condición de entrada más importante para implementación es convertir los defectos de sesión y ACK/cursor en pruebas fallidas reproducibles; ninguna expansión de entidades sync debe preceder ese corte.
