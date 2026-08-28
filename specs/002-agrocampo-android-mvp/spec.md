# Feature Specification: AgroCampo Android MVP - Módulo 001

**Feature Branch**: `not-created`

**Created**: 2026-08-28

**Status**: Ready for Planning

**Input**: User description: "Crear la especificación oficial del MVP AgroCampo para Android,
separando requisitos funcionales, requisitos visuales, reglas UX, restricciones y criterios de
aceptación. Toda decisión visual debe derivarse exclusivamente de master.md."

## Purpose and Authority

AgroCampo reemplaza cuadernos y registros agrícolas dispersos por una aplicación personal que el
agricultor propietario puede usar en terreno, incluso sin conexión. El MVP organiza parcelas,
sectores, cultivos y `LABORES`; conserva historial y temporadas; registra suelo, riego, producción,
apicultura y fotografías; programa recordatorios; ofrece clima y asistencia consultiva; sincroniza
los datos cuando recupera conectividad y permite exportarlos.

Esta especificación define **qué** debe entregar el MVP y **qué resultados** debe observar el
agricultor. La constitución del proyecto gobierna alcance y restricciones. `master.md` es la única
fuente oficial para interfaz gráfica, experiencia visual, colores, tipografía, componentes,
navegación visual, estados visuales, layouts y accesibilidad. El prototipo
`agrocampo-highfi.html` sirve como evidencia funcional y de flujo, pero no puede contradecir
`master.md` ni fijar cantidades de datos de producción.

Las cantidades de tres cuadrantes observadas en `agrocampo-highfi.html` y de ocho cuadrantes
descritas en `CONTEXTO.md` son datos de demostración. El MVP no impone ninguna de esas cantidades
como límite funcional.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Organizar parcelas y sectores (Priority: P1)

Como agricultor propietario, quiero crear mis parcelas, delimitar sus sectores y asignar cultivos
para representar la organización real de mi campo y dar contexto a todos mis registros.

**Why this priority**: Parcela, sector, cultivo y temporada son relaciones necesarias para casi
todas las demás funciones del MVP.

**Independent Test**: Se puede probar creando una parcela con un polígono válido, añadiendo dos
sectores de formas distintas, asignando un cultivo a cada uno y cambiando la parcela activa. El
resultado es una estructura agrícola consultable, aun sin labores registradas.

**Acceptance Scenarios**:

1. **Given** un agricultor autenticado sin parcelas, **When** crea una parcela con datos y geometría
   válidos, **Then** la parcela queda guardada y seleccionada como contexto activo.
2. **Given** una parcela activa, **When** crea un sector completamente contenido y le asigna un
   cultivo, **Then** el sector queda disponible en mapa, ficha y formularios.
3. **Given** dos parcelas activas, **When** selecciona una distinta, **Then** todas las vistas
   contextuales muestran la nueva parcela sin mezclar información de la anterior.

---

### User Story 2 - Registrar LABORES sin conexión (Priority: P1)

Como agricultor en terreno, quiero registrar `LABORES`, mediciones de suelo y riegos sin internet
para no perder información ni transcribirla después.

**Why this priority**: El registro confiable en condiciones de conectividad rural intermitente es
el valor central de AgroCampo.

**Independent Test**: Se puede probar desactivando la conexión, registrando una labor, una medición
de suelo y un riego, reiniciando la aplicación y comprobando que los tres registros permanecen
disponibles con su estado de respaldo correcto.

**Acceptance Scenarios**:

1. **Given** una parcela y un sector activos sin conexión, **When** el agricultor guarda una labor
   válida, **Then** la labor aparece inmediatamente en el historial local como pendiente de
   sincronización.
2. **Given** un formulario con valores inválidos, **When** intenta guardarlo, **Then** se identifican
   los campos que debe corregir y se conservan los demás valores ingresados.
3. **Given** registros locales pendientes, **When** cierra y vuelve a abrir la aplicación,
   **Then** los registros y sus estados siguen disponibles.

---

### User Story 3 - Respaldar y resolver cambios (Priority: P1)

Como agricultor, quiero que mis cambios se respalden al recuperar la conexión y recibir información
clara sobre pendientes o conflictos para confiar en que no perderé mi historial.

**Why this priority**: Offline First sólo es confiable si el respaldo es observable, reanudable y
no duplica ni descarta datos.

**Independent Test**: Se puede probar generando cien cambios offline, recuperando la conexión e
interrumpiendo el proceso. Al reanudar, cada cambio debe quedar respaldado una sola vez y cualquier
conflicto debe conservar ambas versiones hasta su resolución.

**Acceptance Scenarios**:

1. **Given** cambios pendientes, **When** vuelve una conexión estable, **Then** el respaldo comienza
   automáticamente y termina con cero pendientes confirmados.
2. **Given** una interrupción durante el respaldo, **When** el proceso se reanuda, **Then** continúa
   desde los cambios no confirmados sin duplicar los ya respaldados.
3. **Given** dos versiones incompatibles de un mismo registro, **When** se detecta el conflicto,
   **Then** ninguna versión se descarta y el agricultor puede decidir cuál conservar.

---

### User Story 4 - Calcular y registrar riego (Priority: P2)

Como agricultor, quiero estimar litros y tiempo de riego con datos del cultivo y del terreno y
registrar lo realizado para aplicar un criterio consistente y trazable.

**Why this priority**: El riego es frecuente y crítico, pero requiere que ya existan parcela,
sector, cultivo y datos básicos.

**Independent Test**: Se puede probar ingresando plantas, caudal, cultivo, humedad y temperatura
sin conexión. El sistema debe entregar una estimación local explicable y permitir guardarla como
riego realizado.

**Acceptance Scenarios**:

1. **Given** entradas locales válidas y clima no disponible, **When** solicita el cálculo,
   **Then** obtiene litros y tiempo identificados como estimación sin información climática actual.
2. **Given** plantas, caudal o duración inválidos, **When** solicita el cálculo, **Then** no recibe
   una recomendación utilizable y se indica qué debe corregir.
3. **Given** una estimación calculada, **When** guarda el riego, **Then** el registro conserva las
   entradas, resultados y contexto utilizados.

---

### User Story 5 - Consultar historial y producción (Priority: P2)

Como agricultor, quiero consultar labores, suelo, riegos, cambios de cultivo y cosechas por parcela,
sector, cultivo y temporada para comprender lo ocurrido y comparar periodos.

**Why this priority**: El registro agrícola adquiere valor cuando puede recuperarse con su contexto
y conservarse entre cambios de cultivo.

**Independent Test**: Se puede probar creando registros en dos parcelas y varias temporadas,
aplicando cada filtro y comprobando que sólo aparecen los elementos correspondientes en orden
cronológico.

**Acceptance Scenarios**:

1. **Given** registros de varias parcelas y sectores, **When** filtra por un sector, **Then** sólo
   aparecen registros de ese sector en orden cronológico.
2. **Given** una cosecha válida, **When** la guarda, **Then** queda vinculada a sector, cultivo y
   temporada y puede incluirse en el historial y la exportación.
3. **Given** un cambio de cultivo, **When** consulta el historial del sector, **Then** observa la
   asignación anterior y la nueva sin que los registros históricos cambien de cultivo.

---

### User Story 6 - Documentar y recordar trabajo (Priority: P2)

Como agricultor, quiero adjuntar fotografías y crear recordatorios para conservar evidencia de
terreno y recibir avisos de tareas futuras.

**Why this priority**: Fotografías y recordatorios complementan el registro base y ayudan a sostener
el trabajo diario sin convertir AgroCampo en un sistema administrativo.

**Independent Test**: Se puede probar adjuntando una fotografía offline a una labor, creando un
recordatorio y verificando que ambos siguen disponibles tras reiniciar el dispositivo.

**Acceptance Scenarios**:

1. **Given** una labor o sector, **When** captura o selecciona una fotografía, **Then** la imagen
   queda asociada y visible localmente antes del respaldo remoto.
2. **Given** un recordatorio futuro creado offline, **When** llega su fecha y hora, **Then** el
   agricultor recibe el aviso local si concedió el permiso correspondiente.
3. **Given** permiso de notificaciones denegado, **When** guarda el recordatorio, **Then** el
   recordatorio permanece consultable y se explica por qué no habrá aviso del sistema.

---

### User Story 7 - Gestionar apicultura (Priority: P3)

Como agricultor con colmenas, quiero registrar revisiones apícolas dentro de un sector para mantener
trazabilidad básica de colmenas, reina, postura, alimentación, sanidad, plagas y alzas.

**Why this priority**: La apicultura pertenece al MVP, pero utiliza la estructura común de sectores,
labores, fotografías e historial ya establecida.

**Independent Test**: Se puede probar creando un sector apícola, registrando una revisión completa
con fotografía y consultándola offline en su historial.

**Acceptance Scenarios**:

1. **Given** un sector apícola, **When** guarda una revisión válida, **Then** la revisión conserva
   los datos apícolas obligatorios y aparece en su historial.
2. **Given** una revisión apícola offline con fotografías, **When** vuelve la conexión, **Then** el
   registro y sus imágenes se respaldan conservando su asociación.

---

### User Story 8 - Consultar clima, AgroIA y exportar (Priority: P3)

Como agricultor, quiero consultar información climática, pedir orientación contextual y exportar
mis datos para apoyar decisiones y utilizar mi información fuera de AgroCampo.

**Why this priority**: Son capacidades valiosas, pero no deben bloquear el registro agrícola local
ni sustituir cálculos deterministas.

**Independent Test**: Se puede probar consultando la última información climática, formulando una
pregunta contextual y generando una exportación completa con registros sincronizados y pendientes.

**Acceptance Scenarios**:

1. **Given** el servicio climático no disponible, **When** abre Inicio, **Then** puede seguir usando
   las acciones agrícolas y se identifica la antigüedad de la última información válida.
2. **Given** una consulta a AgroIA, **When** recibe una respuesta, **Then** se presenta como orientación
   consultiva y no modifica registros ni sustituye cálculos críticos.
3. **Given** datos agrícolas locales, **When** solicita exportarlos, **Then** obtiene un archivo
   completo y legible que diferencia registros pendientes y respaldados.

### Edge Cases

- El primer inicio de sesión de un dispositivo no puede completarse sin conexión; una sesión
  previamente validada sí permite consultar y registrar datos locales.
- Si no existe parcela, Inicio y los formularios dependientes orientan a crear una antes de pedir
  sector o cultivo.
- Un polígono con menos de tres puntos distintos, autocruces o superficie nula no puede guardarse.
- Un sector que cruza el límite de su parcela no puede guardarse hasta corregir la geometría.
- La denegación del permiso GPS no impide dibujar manualmente ni consultar geometrías guardadas.
- Si el mapa base no está disponible, las geometrías locales y la lista de sectores siguen
  disponibles.
- Los números de sector deben ser únicos dentro de una parcela, aunque pueden repetirse en otra.
- Cambiar el cultivo no reescribe labores, riegos, suelo o cosechas de temporadas anteriores.
- Humedad fuera de 0–100 %, pH fuera de 0–14 y valores negativos de conductividad o nutrientes se
  rechazan con mensajes específicos.
- Una calculadora sin clima actual utiliza datos locales válidos, identifica la limitación y nunca
  inventa información climática.
- Si se agota el almacenamiento, no se confirma una captura o registro que no pueda conservarse;
  los datos previos permanecen intactos.
- Una fotografía eliminada localmente antes de sincronizar no reaparece tras un reintento.
- Una interrupción de sincronización conserva pendientes y no duplica cambios confirmados.
- Una exportación fallida no entrega un archivo parcial como si fuera válido.
- Un recordatorio con fecha pasada exige corrección o registro explícito sin aviso futuro.
- El número de cuadrantes del contenido de demostración no limita las parcelas o sectores reales.

## Requirements *(mandatory)*

### Functional Requirements

#### CAP-001 - Acceso y perfil del agricultor

**Objetivo**: Proteger los datos personales y agrícolas del único agricultor propietario del MVP.

**Comportamiento esperado**:

- **FR-001**: El sistema MUST autenticar al agricultor antes de mostrar datos privados.
- **FR-002**: El primer acceso de un dispositivo MUST requerir una validación conectada; una sesión
  válida ya establecida MUST permitir acceso a datos locales sin conexión.
- **FR-003**: El agricultor MUST poder consultar y actualizar su perfil personal sin crear otros
  usuarios, roles ni relaciones laborales.
- **FR-004**: El agricultor MUST poder cerrar sesión sin eliminar registros locales pendientes y
  MUST recibir una advertencia si existen pendientes.

**Estados**: no autenticado, autenticando, sesión activa, sesión recuperada offline, credenciales
inválidas, sesión vencida y cierre pendiente. **Presentación visual:** Implementar según master.md.

**Datos necesarios**: identificador del agricultor, nombre visible, dato de acceso, ubicación o
preferencias personales permitidas, estado de sesión y resumen de sincronización. No se almacenan
credenciales en texto visible.

**Criterios de aceptación**:

- **AC-CAP001-01**: Con credenciales válidas, el agricultor accede a su parcela activa o al estado
  inicial sin parcelas.
- **AC-CAP001-02**: Sin conexión y con sesión válida previa, puede consultar y crear datos locales.
- **AC-CAP001-03**: Cerrar sesión bloquea los datos privados sin borrar pendientes.

#### CAP-002 - Inicio y contexto agrícola activo

**Objetivo**: Dar un resumen de la parcela activa y accesos directos a las tareas principales.

**Comportamiento esperado**:

- **FR-005**: El sistema MUST mantener una sola parcela activa por vez cuando exista al menos una.
- **FR-006**: Inicio MUST resumir el contexto activo, información climática disponible, acceso a
  sectores y accesos a `LABORES`, suelo, riego y AgroIA.
- **FR-007**: Un cambio de parcela activa MUST propagarse a mapa, sectores, formularios, historial,
  clima contextual y AgroIA sin mezclar datos.
- **FR-008**: Si no existe parcela, Inicio MUST orientar a crear la primera y MUST NOT mostrar datos
  de demostración como si fueran reales.

**Estados**: sin parcela, resumen disponible, datos externos cargando, información desactualizada,
offline y error parcial. **Presentación visual:** Implementar según master.md.

**Datos necesarios**: parcela activa, resumen de sectores, actividad reciente, última información
climática válida, conteo de pendientes y accesos disponibles.

**Criterios de aceptación**:

- **AC-CAP002-01**: El contexto de parcela mostrado coincide en todas las pantallas abiertas desde
  Inicio.
- **AC-CAP002-02**: La ausencia de clima no impide acceder a ninguna función local.
- **AC-CAP002-03**: Un usuario sin parcelas recibe un estado inicial accionable y sin datos falsos.

#### CAP-003 - Parcelas

**Objetivo**: Representar las unidades territoriales administradas por el agricultor.

**Comportamiento esperado**:

- **FR-009**: El agricultor MUST poder crear múltiples parcelas con nombre, ubicación, superficie,
  polígono y descripción.
- **FR-010**: El agricultor MUST poder consultar y editar los datos y límites de una parcela.
- **FR-011**: El sistema MUST recalcular la superficie aproximada al confirmar cambios de geometría.
- **FR-012**: Una parcela con historial que deja de utilizarse MUST archivarse sin perder sus
  relaciones; cualquier eliminación irreversible MUST estar impedida mientras existan dependencias.
- **FR-013**: Crear o editar una parcela sin conexión MUST producir un cambio local pendiente.

**Estados**: vacío, borrador, geometría inválida, válida, guardando local, pendiente, sincronizada,
error y archivada. **Presentación visual:** Implementar según master.md.

**Datos necesarios**: identificador, propietario, nombre, descripción, ubicación GPS, polígono,
superficie aproximada, estado activo/archivado, fechas y estado de sincronización.

**Criterios de aceptación**:

- **AC-CAP003-01**: Una parcela válida queda disponible después del guardado local, incluso offline.
- **AC-CAP003-02**: Editar límites actualiza superficie sin cambiar el contexto histórico de
  registros anteriores.
- **AC-CAP003-03**: Archivar una parcela la retira de nuevos registros, pero conserva historial y
  permite restaurarla.

#### CAP-004 - Mapa, GPS y geometrías

**Objetivo**: Permitir localizar, delimitar y revisar parcelas y sectores espacialmente.

**Comportamiento esperado**:

- **FR-014**: El mapa MUST permitir buscar una ubicación cuando el servicio correspondiente esté
  disponible.
- **FR-015**: El agricultor MUST poder centrar el mapa con la ubicación del dispositivo después de
  conceder permiso.
- **FR-016**: El agricultor MUST poder marcar, deshacer, cerrar y editar puntos de polígonos de
  parcela y sector.
- **FR-017**: El sistema MUST rechazar polígonos abiertos, autocruzados, con puntos insuficientes o
  superficie nula.
- **FR-018**: La superficie aproximada MUST expresarse en unidades métricas admitidas.
- **FR-019**: La falta de mapa base MUST NOT ocultar geometrías guardadas ni impedir consultar la
  lista de parcelas y sectores.

**Estados**: sin permiso, buscando ubicación, GPS disponible/no disponible, dibujando, polígono
abierto, válido, inválido, mapa disponible, mapa offline y error.
**Presentación visual:** Implementar según master.md.

**Datos necesarios**: coordenadas, precisión disponible, puntos ordenados del polígono, superficie,
relación parcela-sector y última referencia de mapa disponible.

**Criterios de aceptación**:

- **AC-CAP004-01**: Un polígono válido se guarda y reproduce con sus puntos y superficie.
- **AC-CAP004-02**: Un polígono inválido no se confirma y conserva los puntos para corregirlos.
- **AC-CAP004-03**: Sin mapa base, el agricultor sigue identificando sectores mediante geometrías
  locales y la alternativa de lista.

#### CAP-005 - Sectores, cultivos y temporadas

**Objetivo**: Dividir una parcela en unidades de manejo y conservar el cultivo vigente e histórico.

**Comportamiento esperado**:

- **FR-020**: El agricultor MUST poder crear sectores cuadrados, rectangulares o irregulares dentro
  de una única parcela.
- **FR-021**: Cada sector MUST conservar número único dentro de su parcela, nombre, ubicación,
  superficie, geometría y cultivo vigente opcional.
- **FR-022**: Un sector MUST estar completamente contenido en su parcela; cualquier superposición
  relevante MUST advertirse antes de guardar.
- **FR-023**: El catálogo inicial MUST incluir frambuesa, arándanos, papas, sandía, melones, maíz,
  physalis, frutilla y apicultura.
- **FR-024**: Cada cultivo MUST exponer época de siembra, requisitos generales de suelo,
  necesidades hídricas, información agrícola básica y enfermedades comunes.
- **FR-025**: El agricultor MUST poder asignar o cambiar el cultivo con fecha efectiva y MUST
  conservar la asignación anterior como parte de la temporada histórica.
- **FR-026**: Apicultura MUST estar disponible como tipo de sector y activar sus datos especializados.

**Estados**: sin cultivo, cultivo vigente, cambio de cultivo en borrador, temporada cerrada, sector
agrícola, sector apícola, pendiente y sincronizado.
**Presentación visual:** Implementar según master.md.

**Datos necesarios**: identificador y número de sector, parcela, nombre, geometría, superficie,
catálogo, asignaciones de cultivo con fechas, temporada y estado de sincronización.

**Criterios de aceptación**:

- **AC-CAP005-01**: Un número duplicado dentro de la parcela se rechaza; el mismo número en otra
  parcela es válido.
- **AC-CAP005-02**: Cambiar cultivo crea una nueva asignación y no reescribe registros previos.
- **AC-CAP005-03**: El catálogo completo puede consultarse con la última información local sin
  conexión.

#### CAP-006 - LABORES

**Objetivo**: Registrar de forma común y trazable el trabajo agrícola realizado en terreno.

**Comportamiento esperado**:

- **FR-027**: La capacidad de registro MUST denominarse `LABORES`; un llamado a la acción MAY usar
  el verbo “Registrar” cuando así lo determine `master.md`, sin reemplazar el nombre del módulo.
- **FR-028**: `LABORES` MUST permitir registrar riego, suelo, fertilización, control de enfermedades
  y plagas, siembra, poda, cosecha y apicultura.
- **FR-029**: Toda labor MUST vincularse con agricultor, parcela, sector, fecha, tipo, cultivo o
  contexto aplicable, observaciones y estado de sincronización.
- **FR-030**: El formulario MUST mostrar únicamente los datos aplicables al tipo seleccionado y
  conservar los ya ingresados ante un error recuperable.
- **FR-031**: Las correcciones de una labor existente MUST preservar trazabilidad y no alterar
  silenciosamente registros históricos relacionados.

**Estados**: borrador, incompleto, válido, guardando local, guardado local, pendiente, sincronizando,
sincronizado, error y conflicto. **Presentación visual:** Implementar según master.md.

**Datos necesarios**: identificador, parcela, sector, cultivo/asignación, tipo, fecha, campos
especializados, observaciones, fotografías asociadas, temporada y estado de sincronización.

**Criterios de aceptación**:

- **AC-CAP006-01**: Una labor válida aparece en el historial inmediatamente después del guardado
  local.
- **AC-CAP006-02**: Cambiar el tipo antes de guardar adapta los datos requeridos sin generar campos
  ajenos al tipo final.
- **AC-CAP006-03**: Toda labor puede rastrearse hasta su parcela, sector y temporada aplicables.

#### CAP-007 - Medición manual de suelo

**Objetivo**: Conservar lecturas manuales del suelo asociadas a un sector y fecha.

**Comportamiento esperado**:

- **FR-032**: El registro de suelo MUST aceptar humedad, pH, temperatura del suelo, conductividad
  eléctrica EC, nitrógeno N, fósforo P y potasio K.
- **FR-033**: El sistema MUST validar humedad entre 0 y 100, pH entre 0 y 14 y valores no negativos
  para EC, N, P y K.
- **FR-034**: Una medición MUST poder guardarse cuando contiene al menos un indicador válido y los
  campos omitidos MUST distinguirse de valores cero.
- **FR-035**: La medición MUST conservar sector, cultivo vigente, fecha, unidades, observaciones y
  estado de sincronización.

**Estados**: sin mediciones, borrador, valor inválido, válido parcial, guardando local, pendiente,
sincronizado y error. **Presentación visual:** Implementar según master.md.

**Datos necesarios**: fecha, parcela, sector, asignación de cultivo, humedad, pH, temperatura, EC,
N, P, K, observaciones y estado de sincronización.

**Criterios de aceptación**:

- **AC-CAP007-01**: Valores fuera de rango no se guardan y los demás valores permanecen disponibles.
- **AC-CAP007-02**: Una lectura parcial válida diferencia campos ausentes de cero medido.
- **AC-CAP007-03**: La medición guardada queda disponible offline y aparece en el historial correcto.

#### CAP-008 - Riego y cálculo híbrido

**Objetivo**: Registrar riegos y producir estimaciones deterministas de litros y tiempo recomendado.

**Comportamiento esperado**:

- **FR-036**: El registro de riego MUST conservar fecha, sector, cultivo, tipo, duración, caudal y
  cantidad estimada de agua.
- **FR-037**: Los tipos iniciales MUST ser goteo, aspersión, surco y gravedad.
- **FR-038**: El cálculo MUST utilizar cantidad de plantas, caudal, tiempo, cultivo, humedad del
  suelo, temperatura y clima disponible.
- **FR-039**: El cálculo MUST producir litros estimados y tiempo recomendado mediante reglas
  deterministas, documentadas y reproducibles.
- **FR-040**: Si faltan datos climáticos, el cálculo MAY utilizar entradas locales suficientes, pero
  MUST identificar la limitación y las variables utilizadas.
- **FR-041**: El MVP MUST NOT utilizar modelos avanzados de evapotranspiración ni delegar cálculos
  críticos a AgroIA.
- **FR-042**: Al guardar un riego, el sistema MUST conservar entradas, resultados y carácter de
  estimación para permitir su revisión.

**Estados**: sin datos suficientes, entrada inválida, cálculo local, estimación limitada, estimación
completa, guardando, pendiente, sincronizado y error.
**Presentación visual:** Implementar según master.md.

**Datos necesarios**: parcela, sector, cultivo, fecha, tipo, plantas, caudal, duración, humedad,
temperatura, clima disponible, litros, tiempo recomendado, variables usadas y estado de sincronización.

**Criterios de aceptación**:

- **AC-CAP008-01**: Las mismas entradas producen el mismo resultado en ejecuciones repetidas.
- **AC-CAP008-02**: Entradas insuficientes o no positivas no generan una recomendación utilizable.
- **AC-CAP008-03**: Una estimación sin clima actual explica esa condición y puede guardarse si las
  entradas locales son suficientes.

#### CAP-009 - Historial y temporadas

**Objetivo**: Recuperar cronológicamente la actividad agrícola con su contexto completo.

**Comportamiento esperado**:

- **FR-043**: El historial MUST conservar `LABORES`, suelo, riegos, cambios de cultivo, cosechas,
  revisiones apícolas y temporadas.
- **FR-044**: El agricultor MUST poder consultar por parcela, sector, cultivo, tipo y rango de fechas.
- **FR-045**: Los resultados MUST mantener orden cronológico y relaciones históricas, aunque cambie
  el cultivo vigente.
- **FR-046**: Los registros locales pendientes MUST aparecer en el historial sin esperar respaldo.
- **FR-047**: Un estado vacío MUST distinguir falta de registros de un filtro sin coincidencias.

**Estados**: cargando local, con resultados, sin registros, filtro sin resultados, pendiente,
sincronizando y error. **Presentación visual:** Implementar según master.md.

**Datos necesarios**: parcela, sector, cultivo, temporada, tipo de evento, fecha, resumen,
relaciones y estado de sincronización.

**Criterios de aceptación**:

- **AC-CAP009-01**: Cada filtro devuelve exclusivamente registros que cumplen sus condiciones.
- **AC-CAP009-02**: Cambiar el cultivo vigente no altera la etiqueta histórica de eventos previos.
- **AC-CAP009-03**: Un registro recién creado offline aparece en la posición cronológica correcta.

#### CAP-010 - Cosecha y producción

**Objetivo**: Registrar resultados productivos vinculados al cultivo y la temporada.

**Comportamiento esperado**:

- **FR-048**: El agricultor MUST poder registrar fecha, cultivo, sector, cantidad positiva, unidad
  métrica admitida, calidad y observaciones.
- **FR-049**: Cada registro MUST conservar temporada y relaciones suficientes para consultas y
  comparativas posteriores.
- **FR-050**: Una cantidad no positiva o unidad no admitida MUST impedir el guardado hasta corregirse.
- **FR-051**: La producción MUST incluirse en historial y exportación.

**Estados**: sin producción, borrador, inválido, guardado local, pendiente, sincronizado y error.
**Presentación visual:** Implementar según master.md.

**Datos necesarios**: parcela, sector, cultivo, temporada, fecha, cantidad, unidad, calidad,
observaciones y estado de sincronización.

**Criterios de aceptación**:

- **AC-CAP010-01**: Una cosecha válida aparece en el historial del sector y temporada correctos.
- **AC-CAP010-02**: Cantidades y unidades inválidas no se aceptan como producción válida.
- **AC-CAP010-03**: Cambios posteriores de cultivo no reasignan cosechas históricas.

#### CAP-011 - Fotografías

**Objetivo**: Asociar evidencia visual de enfermedad, evolución, cosecha, apicultura u otra
observación a un sector o labor.

**Comportamiento esperado**:

- **FR-052**: El agricultor MUST poder capturar una fotografía o elegirla desde la galería.
- **FR-053**: Antes de guardar, MUST poder previsualizar y cancelar la selección.
- **FR-054**: Cada fotografía MUST asociarse al menos a un sector o labor y MAY incluir descripción.
- **FR-055**: Una fotografía guardada MUST permanecer visible offline mediante su referencia local.
- **FR-056**: El respaldo de una fotografía MUST conservar su asociación y no duplicarla tras reintentos.

**Estados**: permiso desconocido, concedido, denegado, selección cancelada, previsualización,
guardando local, pendiente de carga, sincronizada y error.
**Presentación visual:** Implementar según master.md.

**Datos necesarios**: identificador, referencia local, referencia remota cuando exista, origen,
fecha, descripción, sector o labor, estado de sincronización y marca de eliminación.

**Criterios de aceptación**:

- **AC-CAP011-01**: Una imagen guardada offline sigue visible después de reiniciar la aplicación.
- **AC-CAP011-02**: Cancelar una captura no crea un adjunto vacío.
- **AC-CAP011-03**: Una imagen eliminada antes del respaldo no reaparece al recuperar conexión.

#### CAP-012 - Apicultura

**Objetivo**: Mantener trazabilidad intermedia de revisiones de colmenas dentro de sectores apícolas.

**Comportamiento esperado**:

- **FR-057**: Una revisión apícola MUST registrar número de colmenas, fecha, responsable informado,
  estado de la reina, postura, alimentación, enfermedades, plagas y colocación de alza.
- **FR-058**: La revisión MAY incorporar fotografías y observaciones.
- **FR-059**: El responsable es un dato descriptivo y MUST NOT crear un usuario, trabajador o rol.
- **FR-060**: Las revisiones MUST poder registrarse y consultarse offline dentro del historial del
  sector apícola.

**Estados**: sector no apícola, sin revisiones, borrador, inválido, guardado local, pendiente,
sincronizado y error. **Presentación visual:** Implementar según master.md.

**Datos necesarios**: sector apícola, fecha, cantidad de colmenas, responsable, reina, postura,
alimentación, sanidad, plagas, alza, observaciones, fotografías y estado de sincronización.

**Criterios de aceptación**:

- **AC-CAP012-01**: Un sector agrícola no muestra ni exige campos apícolas.
- **AC-CAP012-02**: Una revisión válida aparece cronológicamente en el sector apícola.
- **AC-CAP012-03**: El responsable informado no obtiene acceso ni identidad de usuario.

#### CAP-013 - Recordatorios y avisos

**Objetivo**: Recordar fertilización, riego, revisión de colmenas, cosecha u otras labores.

**Comportamiento esperado**:

- **FR-061**: El agricultor MUST poder crear recordatorios con título, fecha, hora, tipo, sector
  opcional y descripción.
- **FR-062**: Un recordatorio guardado MUST conservarse localmente y activarse sin conexión.
- **FR-063**: La denegación del permiso de notificaciones MUST NOT eliminar ni impedir consultar el
  recordatorio.
- **FR-064**: Los recordatorios MUST poder modificarse, completarse o cancelarse conservando su
  estado de sincronización.

**Estados**: programado, vencido, completado, cancelado, permiso denegado, pendiente de respaldo,
sincronizado y error. **Presentación visual:** Implementar según master.md.

**Datos necesarios**: título, fecha, hora, tipo, sector opcional, descripción, estado, permiso de
notificación y estado de sincronización.

**Criterios de aceptación**:

- **AC-CAP013-01**: Un recordatorio futuro offline genera aviso local si existe permiso.
- **AC-CAP013-02**: Sin permiso, el recordatorio permanece visible y explica la ausencia de aviso.
- **AC-CAP013-03**: Un recordatorio completado no vuelve a notificarse como pendiente.

#### CAP-014 - Clima

**Objetivo**: Mostrar contexto climático útil sin convertirlo en dependencia de los registros locales.

**Comportamiento esperado**:

- **FR-065**: El sistema MUST mostrar temperatura, humedad ambiental, lluvia y pronóstico cuando
  exista información válida para la ubicación de la parcela.
- **FR-066**: La última información válida MUST conservar fecha y hora de actualización.
- **FR-067**: La indisponibilidad o antigüedad del clima MUST identificarse y MUST NOT bloquear
  `LABORES`, suelo, riego local, historial ni cálculos que puedan ejecutarse con entradas locales.

**Estados**: cargando, actualizado, desactualizado, sin ubicación, offline, sin datos y error.
**Presentación visual:** Implementar según master.md.

**Datos necesarios**: ubicación de parcela, temperatura, humedad, lluvia, pronóstico, fecha/hora de
actualización y estado de disponibilidad.

**Criterios de aceptación**:

- **AC-CAP014-01**: La información mostrada siempre incluye su momento de actualización.
- **AC-CAP014-02**: Sin clima disponible, el agricultor puede completar todos los flujos locales.
- **AC-CAP014-03**: Información antigua no se presenta como medición actual.

#### CAP-015 - AgroIA consultiva

**Objetivo**: Responder consultas usando el contexto agrícola disponible sin tomar decisiones ni
sustituir reglas agronómicas deterministas.

**Comportamiento esperado**:

- **FR-068**: AgroIA MUST utilizar el contexto activo autorizado de parcela, sector, cultivo y
  datos relevantes disponibles para responder consultas.
- **FR-069**: Toda respuesta MUST presentarse como orientación consultiva que requiere verificación
  en terreno.
- **FR-070**: AgroIA MUST NOT calcular ni modificar superficies, litros, tiempos de riego u otros
  resultados críticos.
- **FR-071**: AgroIA MUST NOT ejecutar acciones, automatizar riego, diagnosticar fotografías ni
  crear registros sin confirmación explícita del agricultor.
- **FR-072**: Sin conexión, el historial local de conversación MAY seguir visible, pero una nueva
  respuesta MUST indicar que requiere conectividad.

**Estados**: conversación vacía, contexto disponible, enviando, respondiendo, respuesta recibida,
offline, error y reintento. **Presentación visual:** Implementar según master.md.

**Datos necesarios**: mensaje, contexto autorizado, respuesta, fecha, estado de solicitud y aviso
consultivo. No se exponen credenciales ni datos ajenos al agricultor.

**Criterios de aceptación**:

- **AC-CAP015-01**: Una respuesta contextual identifica su carácter consultivo y no cambia datos.
- **AC-CAP015-02**: Una pregunta sobre cálculo crítico remite al resultado determinista disponible
  y no inventa otro cálculo.
- **AC-CAP015-03**: Offline, el intento de nueva consulta no borra el mensaje ni el historial visible.

#### CAP-016 - Operación Offline First y sincronización

**Objetivo**: Mantener continuidad de trabajo local y respaldo confiable cuando exista conexión.

**Comportamiento esperado**:

- **FR-073**: Toda creación, edición o eliminación permitida MUST guardarse localmente antes de
  confirmarse como exitosa para el agricultor.
- **FR-074**: Cada cambio local MUST conservar un estado distinguible de pendiente, sincronizando,
  sincronizado o error, además del estado global de conexión.
- **FR-075**: Al recuperar conexión, el sistema MUST iniciar el respaldo automáticamente sin
  bloquear el uso local.
- **FR-076**: Los reintentos MUST ser idempotentes: un mismo cambio confirmado no puede crear
  duplicados.
- **FR-077**: Una interrupción MUST conservar los cambios no confirmados y permitir continuar desde
  ellos.
- **FR-078**: Un conflicto MUST conservar ambas versiones, identificar sus diferencias y requerir
  una elección explícita; ninguna versión se descarta silenciosamente.
- **FR-079**: El agricultor MUST poder conocer cantidad de pendientes, último respaldo confirmado y
  errores con una acción de recuperación.
- **FR-080**: La falta de conexión MUST NOT impedir consultar datos locales, registrar `LABORES`,
  suelo, riegos, producción, apicultura, fotografías o recordatorios, ni ejecutar cálculos locales.

**Estados**: conectado, offline, guardando local, pendiente, sincronizando, sincronizado, error,
conflicto y reintentando. **Presentación visual:** Implementar según master.md.

**Datos necesarios**: identificador estable del cambio, entidad afectada, operación, versión local,
versión remota cuando exista, fechas, intentos, estado, error y decisión de conflicto.

**Criterios de aceptación**:

- **AC-CAP016-01**: Después de 24 horas offline y un reinicio, todos los registros confirmados siguen
  presentes con su estado.
- **AC-CAP016-02**: Tras reanudar cien cambios pendientes, cada cambio queda respaldado una sola vez.
- **AC-CAP016-03**: Una falla no cambia un pendiente a sincronizado ni oculta la opción de reintento.
- **AC-CAP016-04**: Todo conflicto conserva ambas versiones hasta la elección del agricultor.

#### CAP-017 - Exportación agrícola

**Objetivo**: Entregar una copia tabular y portable de los datos del MVP para análisis personal.

**Comportamiento esperado**:

- **FR-081**: El agricultor MUST poder generar un archivo `.xlsx` que incluya, como mínimo,
  parcelas, sectores, cultivos, `LABORES`, suelo, riegos y producción.
- **FR-082**: La exportación MUST conservar identificadores o referencias que permitan relacionar
  los conjuntos de datos.
- **FR-083**: Los registros locales pendientes MUST incluirse y distinguirse de los sincronizados.
- **FR-084**: La exportación MUST poder generarse con los datos locales disponibles sin exigir
  conexión.
- **FR-085**: Un fallo MUST NOT entregar un archivo parcial como si fuera completo.

**Estados**: sin datos exportables, preparando, completada, compartiendo, error de espacio y error
de generación. **Presentación visual:** Implementar según master.md.

**Datos necesarios**: todos los registros exportables, relaciones, unidades, fechas, temporadas,
estado de sincronización, fecha de generación y versión del formato.

**Criterios de aceptación**:

- **AC-CAP017-01**: El archivo se abre correctamente y contiene todos los conjuntos mínimos.
- **AC-CAP017-02**: Una muestra de registros puede rastrearse entre hojas mediante sus referencias.
- **AC-CAP017-03**: Offline, la exportación incluye datos locales pendientes claramente identificados.

### Visual Requirements

- **VR-001**: Toda interfaz, estado visual, componente, layout, jerarquía, color, tipografía,
  iconografía, navegación visual y comportamiento accesible MUST **Implementar según master.md**.
- **VR-002**: `master.md` es la única fuente visual oficial. Esta especificación MUST NOT duplicar,
  reinterpretar ni sustituir sus reglas.
- **VR-003**: `agrocampo-highfi.html` MAY utilizarse para verificar flujos y contenido de referencia,
  pero una decisión visual divergente MUST resolverse a favor de `master.md`.
- **VR-004**: Cada estado funcional definido en CAP-001 a CAP-017 MUST **Implementar según master.md**.
- **VR-005**: Si una necesidad visual o accesible no está resuelta en `master.md`, MUST actualizarse
  y aprobarse el Design System antes de implementarla; no se permite crear una variante local.
- **VR-006**: Las pantallas Inicio, Sectores, Mapa, Detalle de sector, `LABORES`/Registrar, Suelo,
  Riego, Historial, AgroIA, Más, Perfil y Configuración MUST **Implementar según master.md**.

### UX Rules

- **UXR-001**: La experiencia y navegación visual de cada flujo MUST **Implementar según master.md**.
- **UXR-002**: Un flujo iniciado desde una parcela o sector MUST conservar ese contexto hasta que el
  agricultor lo cambie explícitamente.
- **UXR-003**: Volver a una pantalla anterior MUST conservar scroll, filtros, selección y borradores
  recuperables.
- **UXR-004**: Todo guardado MUST diferenciar el éxito local del respaldo remoto; su comunicación
  visual MUST **Implementar según master.md**.
- **UXR-005**: Los errores MUST indicar causa y recuperación, conservar datos válidos ingresados y
  presentar su estado según `master.md`.
- **UXR-006**: La indisponibilidad de clima, mapa base, AgroIA o cualquier servicio externo MUST
  degradar sólo la capacidad afectada y ofrecer la alternativa local disponible.
- **UXR-007**: Toda confirmación destructiva o abandono con datos no guardados MUST permitir cancelar.
- **UXR-008**: La aplicación MUST usar español latinoamericano y unidades métricas permitidas por la
  constitución.
- **UXR-009**: El agricultor MUST poder reconocer el resultado principal de cada acción sin inferirlo
  por ausencia de error.
- **UXR-010**: Accesibilidad, lectura en terreno, blancos táctiles, escalado de texto, semántica,
  orientación y movimiento MUST **Implementar según master.md**.

### MVP Restrictions

- **MR-001**: El MVP es exclusivamente Android y no incluye versión iOS.
- **MR-002**: Existe un único agricultor propietario; no se crean trabajadores, múltiples roles,
  empresas ni permisos organizacionales.
- **MR-003**: No se incluye inventario, ERP, facturación, compras, ventas ni integraciones industriales.
- **MR-004**: No se automatiza físicamente el riego ni se controlan bombas, válvulas o equipos.
- **MR-005**: No se incluyen sensores Bluetooth, IoT ni lectura automática de dispositivos.
- **MR-006**: AgroIA es consultiva; no se incluye IA avanzada, acciones autónomas ni análisis fotográfico.
- **MR-007**: No se incluye panel web ni calendario lunar en el MVP.
- **MR-008**: El cálculo de riego no incorpora modelos avanzados de evapotranspiración.
- **MR-009**: No se añaden cultivos, tipos de labor o módulos fuera de los enumerados sin una
  especificación y aprobación posteriores.
- **MR-010**: No se crean diseños alternativos ni se modifica la identidad visual definida en
  `master.md`.
- **MR-011**: El prototipo HTML no se convierte en una segunda aplicación de producción ni define
  su arquitectura.
- **MR-012**: No se entrega funcionalidad simulada, placeholder o futura como si perteneciera al MVP.

### Acceptance Criteria

- **AC-001**: Cada capacidad CAP-001 a CAP-017 satisface todos sus criterios `AC-CAP` de manera
  independiente y dentro de los flujos integrados que la utilizan.
- **AC-002**: Toda pantalla y estado pasa una revisión visual y accesible contra `master.md`, sin
  reglas visuales alternativas en la especificación o implementación.
- **AC-003**: Todos los flujos de escritura confirman persistencia local antes del respaldo y siguen
  disponibles después de reiniciar sin conexión.
- **AC-004**: Todas las relaciones de parcela, sector, cultivo, temporada y registro pueden
  verificarse desde historial y exportación sin ambigüedad.
- **AC-005**: Ninguna indisponibilidad externa bloquea un flujo local que no depende de ella.
- **AC-006**: Los cálculos agrícolas críticos son reproducibles con sus entradas y nunca dependen de
  una respuesta de AgroIA.
- **AC-007**: Los conflictos y errores de sincronización no producen pérdida silenciosa ni duplicados.
- **AC-008**: El vocabulario funcional usa `LABORES`; los llamados a la acción visuales siguen
  `master.md` sin renombrar el dominio.
- **AC-009**: Las pruebas de alcance no encuentran trabajadores, roles, inventario, ERP,
  automatización de riego, IoT, IA avanzada, análisis fotográfico, panel web ni iOS.
- **AC-010**: Todo texto orientado al agricultor utiliza español y unidades métricas admitidas.

### Key Entities *(include if feature involves data)*

- **Agricultor**: Propietario único del MVP; contiene identidad visible, preferencias y relación con
  sus datos.
- **Parcela**: Unidad territorial con nombre, descripción, ubicación, polígono, superficie, estado y
  selección activa.
- **Sector**: Subdivisión identificada dentro de una parcela; tiene número único por parcela,
  geometría, superficie, tipo y cultivo vigente opcional.
- **Cultivo**: Elemento del catálogo con información de siembra, suelo, agua y enfermedades.
- **Asignación de cultivo**: Relación temporal entre sector y cultivo con inicio, fin y temporada.
- **Temporada**: Periodo agrícola que agrupa asignaciones, labores y producción sin reescribir etapas
  anteriores.
- **Labor**: Evento común con tipo, fecha, parcela, sector, cultivo aplicable, observaciones y estado.
- **Medición de suelo**: Especialización con humedad, pH, temperatura, EC, N, P y K.
- **Riego**: Especialización con tipo, caudal, duración, litros estimados y contexto de cálculo.
- **Estimación de riego**: Resultado determinista que conserva entradas, limitaciones, litros, tiempo
  y fecha.
- **Cosecha o producción**: Resultado productivo con cantidad, unidad, calidad, observaciones,
  cultivo y temporada.
- **Revisión apícola**: Labor especializada con colmenas, responsable descriptivo, reina, postura,
  alimentación, sanidad, plagas y alza.
- **Fotografía**: Evidencia visual asociada a sector o labor, con referencia local, referencia remota
  opcional, origen, fecha, descripción y estado.
- **Recordatorio**: Aviso con título, fecha, hora, tipo, sector opcional, descripción y estado.
- **Registro climático**: Información contextual con ubicación, variables, pronóstico y momento de
  actualización.
- **Conversación AgroIA**: Mensajes y contexto autorizado con estado de solicitud y aviso consultivo.
- **Cambio pendiente**: Creación, edición o eliminación local que espera confirmación de respaldo.
- **Conflicto de sincronización**: Dos versiones incompatibles conservadas hasta una resolución.
- **Exportación**: Archivo generado con fecha, versión, conjuntos incluidos y relaciones entre ellos.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Al menos 90 % de los agricultores de prueba completa la creación de una parcela, un
  sector y una asignación de cultivo en menos de 10 minutos sin asistencia.
- **SC-002**: Al menos 95 % registra una labor offline válida en menos de 2 minutos en el primer intento.
- **SC-003**: En una prueba de 24 horas sin conexión y con reinicios, 100 % de los registros
  confirmados localmente permanece disponible y trazable.
- **SC-004**: Después de recuperar conexión con cien cambios pendientes, 100 % queda respaldado una
  sola vez o identificado explícitamente como conflicto/error; no hay pérdida silenciosa.
- **SC-005**: Al menos 90 % de los agricultores identifica en menos de 5 segundos si un registro está
  guardado localmente, pendiente, sincronizando, sincronizado o con error.
- **SC-006**: El 100 % de los conflictos simulados conserva ambas versiones hasta una elección explícita.
- **SC-007**: Para un conjunto aprobado de al menos veinte escenarios de riego, 100 % de los
  resultados se reproduce con las mismas entradas y tolerancia definida por la regla agronómica.
- **SC-008**: Al menos 90 % de los agricultores interpreta correctamente que una respuesta de
  AgroIA es consultiva y no un cálculo o instrucción automática.
- **SC-009**: El 100 % de las consultas de prueba por parcela, sector, cultivo y temporada devuelve
  exclusivamente registros pertenecientes a esos filtros.
- **SC-010**: Una exportación de referencia abre correctamente e incluye 100 % de los registros
  mínimos, sus relaciones y su estado de sincronización.
- **SC-011**: Al menos 90 % completa sin asistencia una medición de suelo, un riego, una cosecha, una
  revisión apícola, una fotografía y un recordatorio en los flujos aplicables.
- **SC-012**: Con 20 parcelas, 200 sectores y 10.000 registros textuales de prueba, 95 % de las
  consultas locales muestra un resultado útil al agricultor en menos de 2 segundos.
- **SC-013**: El 100 % de las pantallas, componentes y estados incluidos obtiene conformidad en la
  revisión contra `master.md` y no introduce una identidad visual alternativa.
- **SC-014**: El 100 % de los flujos locales críticos permanece disponible cuando clima, mapa base
  remoto y AgroIA están indisponibles.

## Assumptions

- El único actor con acceso es el agricultor propietario; un nombre de responsable apícola es un
  dato descriptivo, no una cuenta.
- El primer acceso de cada dispositivo requiere conexión; una sesión válida previa habilita el uso
  local protegido.
- El agricultor puede gestionar múltiples parcelas y sectores; las cantidades del prototipo son
  ejemplos y no límites.
- `master.md` ya está aprobado como Design System y cualquier cambio visual se resuelve allí, no en
  esta especificación.
- La aplicación utiliza español latinoamericano y las unidades métricas definidas por la constitución.
- La información de cultivo es general e informativa; no sustituye diagnóstico profesional.
- Los valores y umbrales agronómicos exactos de la calculadora se validarán antes de aceptar su
  implementación, manteniendo los inputs, outputs y límites definidos aquí.
- Mapa base, búsqueda, clima y AgroIA pueden requerir conectividad; geometrías, registros, historial,
  recordatorios y cálculos locales permanecen disponibles sin esos servicios.
- Las fotografías se comprimen o administran sin alterar su función probatoria y sin perder su
  asociación local.
- Los avisos del sistema dependen del permiso del dispositivo; denegarlo no elimina el recordatorio.
- La exportación representa los datos disponibles en el dispositivo al momento de generarla e
  identifica los que aún no están respaldados.
- Las decisiones técnicas, proveedores, estructura interna y protocolos se definirán durante la
  planificación conforme a la constitución, sin cambiar los resultados exigidos por esta especificación.
