# Feature Specification: AgroCampo Sector-Only Territory - Módulo 004

**Created**: 2026-10-02

**Status**: Approved by the product owner (2026-10-02)

**Input**: "Vamos a eliminar las parcelas, deja solo los sectores." Decisiones confirmadas: quitar la
parcela del modelo (no sólo de la UI), temporadas por cuadrante, clima desde el centro del
cuadrante activo, reinicio de datos existentes y entrega en `feature/backend`.

## Purpose and Authority

El Módulo 004 elimina la entidad **Parcela** de AgroCampo. El agricultor organiza su terreno
directamente en **cuadrantes** (sectores) dibujados en el mapa. 004 prevalece sobre 001, 002 y 003
únicamente en lo que declara aquí; el resto de esos módulos permanece vigente. Toda mención a
parcela, parcela activa, localidad de parcela o contención sector-en-parcela en 001–003 queda
derogada por esta especificación.

`master.md` sigue siendo la autoridad visual. Las pantallas que mostraban parcela conservan su
jerarquía y componentes, retirando sólo el nivel de parcela.

## Decisions

| Tema | Antes (001–003) | Ahora (004) |
|---|---|---|
| Raíz territorial | Parcela → Sector | Sector (cuadrante) pertenece directamente al agricultor |
| Numeración | `UNIQUE(parcel_id, number)` | `UNIQUE(owner_id, number)`; los números de cuadrantes eliminados no se reutilizan |
| Geometría | El sector debía quedar contenido en la parcela | Sólo se valida el polígono del propio cuadrante |
| Temporada agrícola | Pertenece a una parcela | Pertenece a un cuadrante (`sector_id`) |
| Contexto activo | Parcela → Sector → Temporada → Asignación | Sector → Temporada (del sector) → Asignación |
| Clima | Localidad y contorno de la parcela activa | Centro del polígono del cuadrante activo; la etiqueta visible es el nombre del cuadrante |
| Labores, producción, recordatorios, riego, suelo, apicultura | Guardaban `parcel_id` | Se identifican por `sector_id` (y temporada/asignación cuando aplica) |
| Exportación XLSX | Hoja `parcelas` y columna `parcela_id` | Se retiran |
| Sincronización | Agregado `parcel` y dependencia sector→parcela | El agregado `parcel` deja de existir; los payloads no incluyen `parcel_id` |

## Data Reset

Los datos existentes no se migran. Al actualizar:

- **Android (Drift)**: el esquema pasa a v12. Una base con versión menor se elimina completa y se
  recrea vacía, incluida la cola de sincronización y los cursores.
- **Supabase**: la migración `0021_sector_only_territory.sql` vacía los datos agrícolas y de
  sincronización, elimina `parcels` y las columnas `parcel_id`, y redefine los handlers de
  sincronización. Perfiles y usuarios se conservan.

## User Scenarios

### Organizar cuadrantes (P1)

1. **Given** un agricultor sin cuadrantes, **When** abre Sectores, **Then** ve un estado vacío que
   lo lleva al mapa para dibujar el primero, sin pedir parcela.
2. **Given** el mapa, **When** confirma un polígono válido con categoría, **Then** se crea el
   cuadrante con el siguiente número libre del agricultor.
3. **Given** que eliminó el cuadrante con el número más alto, **When** dibuja otro, **Then** recibe
   un número nuevo y el guardado no falla.
4. **Given** varios cuadrantes, **When** elige uno en el selector de contexto, **Then** ese
   cuadrante queda activo y se recuerda al reabrir la app.

### Temporadas por cuadrante (P1)

1. **Given** un cuadrante activo, **When** crea una temporada, **Then** la temporada pertenece a ese
   cuadrante y sólo aparece en él.
2. **Given** una temporada de otro cuadrante, **When** se intenta asignar un cultivo con ella,
   **Then** la operación se rechaza.
3. **Given** un cambio de cuadrante activo, **Then** la temporada y la asignación activas se
   limpian.
4. **Given** un cuadrante vegetal, **When** crea una temporada vigente o futura, **Then** la app
   pregunta si también cambia el cultivo; en una temporada vigente reemplaza al cultivo actual
   desde hoy y en una futura empieza junto con la temporada.

### Clima del cuadrante (P2)

1. **Given** un cuadrante activo y modo en línea, **When** abre Inicio, **Then** el clima se
   consulta con el centro del polígono de ese cuadrante y se rotula con su nombre.
2. **Given** que no hay cuadrante activo, **Then** Inicio invita a dibujar o elegir un cuadrante.
3. **Given** un cuadrante activo, **When** abre Inicio, **Then** "Clima de hoy" muestra
   temperatura, mínima/máxima del día, helada y fase lunar.
4. **Given** un pronóstico con mínima ≤ 0 °C hoy o en días siguientes, **Then** la tarjeta Helada
   dice "Pronosticada" con el día y la mínima, aclarando "Según pronóstico, no es alerta oficial";
   si no, "No pronosticada". Reemplaza, para esta tarjeta, la regla de 002 que prohibía derivar
   helada de un umbral local: el valor sólo repite el pronóstico del proveedor.
5. **Given** clima disponible, **Then** "Próximos días" lista el pronóstico diario de 7 días con
   condición, % y mm de lluvia, viento máximo y mínima/máxima.
6. **Given** cualquier conexión, **Then** la fase lunar se calcula en el dispositivo con el mes
   sinódico medio (precisión de alrededor de un día) e indica % iluminado y próxima luna llena o
   nueva.

## Functional Requirements

- **FR-004-01**: No existe pantalla, ruta, selector ni texto de UI de parcelas.
- **FR-004-02**: Un cuadrante se crea, renombra y elimina sin referencia a parcela.
- **FR-004-03**: El número de cuadrante es único por agricultor e incluye cuadrantes eliminados.
- **FR-004-04**: Una temporada agrícola pertenece a exactamente un cuadrante; su nombre es único
  dentro de ese cuadrante; una asignación de cultivo exige que temporada y asignación compartan
  cuadrante.
- **FR-004-05**: Las labores, producción, riego, suelo, apicultura, recordatorios e historial se
  filtran por agricultor, cuadrante y temporada, nunca por parcela.
- **FR-004-06**: El clima usa el centro del polígono del cuadrante activo.
- **FR-004-09**: Cultivos del sector ofrece "Cambiar a otro cultivo" e "Intercambiar cultivo con
  otro sector"; no existe una acción separada para planificar cultivos: el cultivo futuro se elige
  al crear la temporada.
- **FR-004-10**: La sincronización es automática y no tiene UI: no hay pantalla de sincronización,
  resolución de conflictos ni banner global, y ningún registro muestra "Sincronizado", "Local" o
  "pendiente de sincronizar".
- **FR-004-11**: Recordatorios incluye "Alertas automáticas" con una tarjeta por alerta, cada una
  con interruptor y umbral editable: fin de temporada (días antes, 7 por defecto), helada (mínima ≤
  0 °C), temperatura baja (mínima ≤ 5 °C) y temperatura alta (máxima ≥ 30 °C); las dos últimas
  parten desactivadas. Se revisan al abrir la app, al cambiar un umbral y cada 3 horas en segundo
  plano (WorkManager), con el pronóstico de cada cuadrante; cada evento se notifica una sola vez y
  las de clima aclaran que repiten el pronóstico, no una alerta oficial. Los umbrales se guardan en
  `app_preferences` del dispositivo (no se sincronizan).
- **FR-004-07**: La sincronización rechaza el agregado `parcel` como no soportado y no exige
  `parcel_id` en ningún payload.
- **FR-004-08**: La actualización reinicia los datos locales y remotos según **Data Reset**.

## Out of Scope

- Agrupar cuadrantes en otra entidad que reemplace a la parcela.
- Conservar o migrar datos registrados antes de 004.
- Cambios visuales fuera de retirar el nivel de parcela.
