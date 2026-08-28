# Feature Specification: AgroCampo MVP - Módulo 001

**Feature Branch**: `not-created`

**Created**: 2026-08-27

**Status**: Draft

**Input**: User description: "Definir completamente la primera versión funcional de AgroCampo
para un agricultor propietario, con operación Offline First, gestión agrícola, riego, historial,
fotografías, recordatorios y exportación, sin generar código."

## Objetivo del módulo

El Módulo 001 reemplaza cuadernos y planillas dispersas por un registro agrícola único que el
agricultor puede usar durante su trabajo en terreno, incluso cuando no tiene conexión. Su usuario
principal y único en el MVP es el agricultor propietario. El valor entregado consiste en organizar
parcelas, sectores, cultivos y labores; conservar un historial trazable; apoyar decisiones de riego
con cálculos explicables; y respaldar o exportar la información sin interrumpir el trabajo rural.

El módulo comprende autenticación básica, perfil, parcelas, mapa agrícola, sectores, catálogo de
cultivos, `LABORES`, mediciones manuales de suelo, riego, cálculo de riego, producción, fotografías,
apicultura, recordatorios, historial, exportación y sincronización. Las decisiones tecnológicas y
de proveedores se rigen por la constitución y se detallarán durante la planificación.

## Arquitectura funcional

El flujo funcional es el siguiente:

1. El agricultor interactúa con la aplicación Android.
2. Toda consulta o registro de trabajo utiliza primero la información disponible en el dispositivo.
3. Cada cambio queda guardado localmente y recibe un estado de sincronización visible.
4. Cuando existe conectividad, el sistema respalda los cambios pendientes y recupera cambios
   remotos aplicables sin duplicar ni perder información.
5. Los servicios de mapas, clima, asistencia consultiva y notificaciones complementan la
   experiencia, pero su indisponibilidad no bloquea los registros ni cálculos locales.

La aplicación reconoce cinco estados operativos: `Conectado`, `Offline`, `Sincronizando`,
`Sincronizado` y `Error`. El agricultor puede continuar trabajando en los estados Offline y Error,
consultar la cantidad de cambios pendientes y solicitar un nuevo intento de sincronización.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Organizar el campo (Priority: P1)

Como agricultor propietario, quiero crear mis parcelas, dibujar sus límites, dividirlas en sectores
y asignar cultivos para representar digitalmente la organización real de mi campo.

**Why this priority**: Parcelas y sectores son el contexto obligatorio de casi todos los demás
registros agrícolas.

**Independent Test**: Se puede probar creando una parcela con polígono, añadiendo dos sectores de
formas distintas y asignando un cultivo a cada uno; el resultado entrega una estructura agrícola
consultable aunque aún no existan labores.

**Acceptance Scenarios**:

1. **Given** que el agricultor no tiene parcelas, **When** dibuja un polígono válido y completa los
   datos obligatorios, **Then** la parcela queda guardada con su superficie aproximada.
2. **Given** una parcela activa, **When** crea un sector irregular completamente dentro de sus
   límites, **Then** el sector aparece identificado y disponible para asignar un cultivo.
3. **Given** varias parcelas guardadas, **When** selecciona otra parcela activa, **Then** todas las
   vistas contextuales muestran la parcela recién seleccionada.

---

### User Story 2 - Registrar labores sin conexión (Priority: P1)

Como agricultor en terreno, quiero registrar labores, mediciones de suelo y riegos sin internet
para no perder información ni tener que transcribirla posteriormente.

**Why this priority**: El registro confiable en terreno es el beneficio central del producto y la
conectividad rural es intermitente.

**Independent Test**: Se puede probar desactivando la conectividad, registrando una medición de
suelo y un riego, reiniciando la aplicación y verificando que ambos registros siguen disponibles y
marcados como pendientes.

**Acceptance Scenarios**:

1. **Given** una parcela y sector activos sin conectividad, **When** el agricultor guarda una labor
   con datos válidos, **Then** la labor aparece en el historial local con estado pendiente.
2. **Given** un formulario con datos inválidos, **When** intenta guardarlo, **Then** el sistema
   identifica los campos que debe corregir y conserva los valores ya ingresados.
3. **Given** registros locales pendientes, **When** el agricultor cierra y vuelve a abrir la
   aplicación, **Then** los registros y su estado se mantienen.

---

### User Story 3 - Respaldar y recuperar información (Priority: P1)

Como agricultor, quiero que mis cambios se sincronicen al volver la conexión y recibir una
confirmación clara para saber que mi historial está respaldado.

**Why this priority**: La continuidad Offline First requiere respaldo confiable y estados que el
usuario pueda comprender.

**Independent Test**: Se puede probar generando cambios offline, restableciendo la conexión y
verificando que cada cambio se respalda una sola vez, desaparece de pendientes y continúa visible.

**Acceptance Scenarios**:

1. **Given** tres cambios pendientes, **When** vuelve una conexión estable, **Then** el estado pasa
   por Sincronizando y termina Sincronizado con cero pendientes.
2. **Given** una interrupción durante la sincronización, **When** el proceso falla, **Then** los
   cambios no confirmados permanecen pendientes y se muestra una opción de reintento.
3. **Given** dos versiones diferentes del mismo registro, **When** se detecta el conflicto,
   **Then** ninguna versión se descarta y el agricultor puede elegir cuál conservar.

---

### User Story 4 - Planificar y documentar el riego (Priority: P2)

Como agricultor, quiero estimar agua y tiempo de riego con información del cultivo y del terreno,
y luego registrar el riego realizado para tomar decisiones consistentes.

**Why this priority**: El riego es una labor frecuente y de alto impacto, pero depende de que ya
existan parcelas, sectores y cultivos.

**Independent Test**: Se puede probar ingresando plantas, caudal, humedad y temperatura sin
conexión; el sistema entrega litros y tiempo recomendados, explica los datos usados y permite
guardar el riego.

**Acceptance Scenarios**:

1. **Given** datos mínimos válidos y ausencia de clima actualizado, **When** calcula una
   recomendación, **Then** obtiene un resultado local identificado como estimación sin clima.
2. **Given** caudal o cantidad de plantas igual a cero, **When** solicita el cálculo, **Then** el
   sistema no genera una recomendación y explica qué valor debe corregir.
3. **Given** una recomendación calculada, **When** el agricultor la usa para crear un riego,
   **Then** el registro conserva las entradas y los resultados aplicados.

---

### User Story 5 - Consultar producción e historial (Priority: P2)

Como agricultor, quiero consultar labores, mediciones, riegos, cambios de cultivo y cosechas por
parcela, sector y cultivo para entender qué ocurrió y comparar futuras temporadas.

**Why this priority**: La información registrada adquiere valor cuando puede recuperarse por su
contexto y conservarse entre temporadas.

**Independent Test**: Se puede probar creando registros para dos sectores, aplicando cada filtro y
verificando que el historial y los totales de producción solo incluyan los registros pertinentes.

**Acceptance Scenarios**:

1. **Given** registros de varios sectores, **When** filtra por un único sector, **Then** solo se
   muestran elementos asociados a ese sector y se preserva el orden cronológico.
2. **Given** una cosecha válida, **When** la guarda, **Then** queda vinculada a cultivo, sector y
   temporada y puede incluirse en comparaciones posteriores.
3. **Given** un cambio de cultivo, **When** consulta el historial del sector, **Then** observa tanto
   la asignación anterior como la nueva con sus fechas.

---

### User Story 6 - Complementar y compartir registros (Priority: P2)

Como agricultor, quiero añadir fotografías, programar recordatorios y exportar mis datos para
documentar evidencias, recordar tareas y trabajar con la información fuera de la aplicación.

**Why this priority**: Estas capacidades completan el flujo cotidiano y facilitan respaldo y
análisis personal, aunque el registro agrícola base puede funcionar sin ellas.

**Independent Test**: Se puede probar adjuntando una fotografía offline, creando un recordatorio y
generando una exportación con todos los conjuntos de datos obligatorios.

**Acceptance Scenarios**:

1. **Given** una labor guardada, **When** adjunta una fotografía desde cámara o galería, **Then** la
   imagen queda visible en el registro incluso antes de sincronizar.
2. **Given** un recordatorio futuro creado offline, **When** llega su fecha en el dispositivo,
   **Then** el agricultor recibe el aviso y el registro continúa pendiente de respaldo.
3. **Given** datos agrícolas locales, **When** solicita una exportación, **Then** obtiene un archivo
   `.xlsx` legible que incluye tanto registros sincronizados como pendientes, claramente
   identificados.

---

### User Story 7 - Gestionar un sector apícola (Priority: P3)

Como agricultor con colmenas, quiero registrar revisiones apícolas y fotografías dentro de un
sector para mantener trazabilidad básica de la reina, postura, alimentación, sanidad y alzas.

**Why this priority**: La apicultura pertenece al MVP, pero es una especialización posterior a la
estructura y al historial agrícola común.

**Independent Test**: Se puede probar creando un sector apícola, registrando una revisión completa
y consultándola en el historial del sector sin depender de otro tipo de labor.

**Acceptance Scenarios**:

1. **Given** un sector apícola, **When** guarda una revisión con los campos obligatorios, **Then** la
   revisión aparece en su historial con cantidad de colmenas y estado sanitario.
2. **Given** una revisión apícola offline con fotografías, **When** vuelve la conexión, **Then** el
   registro y sus imágenes se respaldan sin perder su asociación.

### Edge Cases

- Si nunca se completó un inicio de sesión en el dispositivo, el usuario no puede autenticarse por
  primera vez sin conectividad y recibe una explicación sin perder acceso a ayuda local.
- Si el mapa base no está disponible, el sistema mantiene visibles las geometrías ya guardadas y
  permite usar GPS; la búsqueda de direcciones queda indicada como no disponible.
- Un polígono con menos de tres puntos distintos, autocruces o superficie nula no se puede guardar.
- Un sector que cruza el límite de la parcela no se guarda hasta quedar completamente contenido.
- Los números de sector deben ser únicos dentro de una parcela, aunque pueden repetirse en otra.
- Eliminar una parcela con historial la retira de las vistas activas, pero conserva sus registros y
  permite restaurarla; una parcela sin dependencias puede eliminarse tras confirmación.
- Cambiar el cultivo de un sector no reescribe registros históricos creados con el cultivo anterior.
- Si fecha o zona horaria cambian durante un registro offline, se conserva la hora de captura y se
  muestra al usuario la fecha interpretada antes de confirmar.
- Humedad fuera de 0-100 %, pH fuera de 0-14, valores negativos de EC o nutrientes y duraciones o
  caudales no positivos son rechazados con mensajes específicos.
- Si faltan clima o datos opcionales, la calculadora utiliza solo entradas locales, identifica la
  limitación y nunca inventa una observación climática.
- Si se agota el almacenamiento, el sistema impide nuevas capturas que no pueda conservar, mantiene
  los registros existentes y orienta al usuario para liberar espacio.
- Una fotografía eliminada antes de sincronizar no debe reaparecer después de un reintento.
- Si una exportación no puede completarse, no se entrega un archivo parcial como si fuera válido.
- Si un recordatorio se crea con una fecha pasada, el sistema exige cambiarla o guardarlo sin aviso
  futuro como registro histórico explícito.

### Casos de uso detallados

#### CU-USR-01 - Iniciar sesión

- **Actor**: Agricultor propietario.
- **Descripción**: Validar su identidad y acceder a sus datos agrícolas.
- **Precondiciones**: Cuenta vigente; para el primer acceso del dispositivo existe conectividad.
- **Flujo principal**: Abre la aplicación, ingresa credenciales, confirma y accede a su parcela
  activa o al estado inicial sin parcelas.
- **Flujos alternativos**: Credenciales inválidas muestran un error sin revelar información de la
  cuenta; una sesión previamente validada permite acceso offline; una cuenta no validada requiere
  conexión.
- **Resultado esperado**: Sesión activa y datos del propietario disponibles según el estado local.

#### CU-USR-02 - Cerrar sesión

- **Actor**: Agricultor propietario.
- **Descripción**: Finalizar el acceso protegido en el dispositivo.
- **Precondiciones**: Sesión activa.
- **Flujo principal**: Selecciona cerrar sesión, revisa la advertencia de cambios pendientes y
  confirma.
- **Flujos alternativos**: Puede cancelar; si está offline, los cambios pendientes se conservan y
  no se eliminan del dispositivo.
- **Resultado esperado**: La información queda bloqueada hasta una nueva autenticación.

#### CU-USR-03 - Visualizar perfil

- **Actor**: Agricultor propietario.
- **Descripción**: Consultar su información identificatoria y el estado general del respaldo.
- **Precondiciones**: Sesión activa.
- **Flujo principal**: Abre Perfil y consulta nombre, identificación de cuenta y resumen de
  sincronización.
- **Flujos alternativos**: Offline muestra los últimos datos disponibles y lo indica.
- **Resultado esperado**: Perfil legible sin exponer credenciales ni datos secretos.

#### CU-PAR-01 - Crear parcela

- **Actor**: Agricultor propietario.
- **Descripción**: Registrar una nueva unidad de terreno.
- **Precondiciones**: Sesión activa.
- **Flujo principal**: Indica nombre, descripción y ubicación; dibuja o confirma el polígono;
  revisa la superficie y guarda.
- **Flujos alternativos**: Datos o geometría inválidos impiden guardar y conservan el formulario;
  offline crea la parcela como pendiente.
- **Resultado esperado**: Parcela disponible y seleccionable con nombre, ubicación, superficie,
  polígono y descripción.

#### CU-PAR-02 - Seleccionar parcela activa

- **Actor**: Agricultor propietario.
- **Descripción**: Cambiar el contexto agrícola utilizado por las pantallas y formularios.
- **Precondiciones**: Existen al menos dos parcelas activas.
- **Flujo principal**: Abre el selector, elige una parcela y confirma el cambio de contexto.
- **Flujos alternativos**: Una parcela archivada no aparece entre las activas; puede cancelar sin
  alterar la selección anterior.
- **Resultado esperado**: La nueva parcela se identifica como activa en toda vista contextual.

#### CU-PAR-03 - Editar parcela

- **Actor**: Agricultor propietario.
- **Descripción**: Corregir los datos o límites de una parcela.
- **Precondiciones**: Parcela existente y activa.
- **Flujo principal**: Abre edición, modifica campos o puntos, revisa la superficie recalculada y
  guarda.
- **Flujos alternativos**: Una edición que deje sectores fuera del límite exige corregir el límite
  o reubicar esos sectores; puede descartar cambios.
- **Resultado esperado**: Datos actuales actualizados sin reescribir el historial anterior.

#### CU-PAR-04 - Eliminar parcela

- **Actor**: Agricultor propietario.
- **Descripción**: Retirar una parcela que ya no debe utilizarse.
- **Precondiciones**: Parcela existente.
- **Flujo principal**: Solicita eliminar, revisa el resumen de datos asociados y confirma.
- **Flujos alternativos**: Con historial se archiva y puede restaurarse; sin dependencias se permite
  eliminación definitiva tras una segunda confirmación; puede cancelar.
- **Resultado esperado**: La parcela deja de estar disponible para nuevos registros sin pérdida
  accidental de historial.

#### CU-PAR-05 - Visualizar parcela en mapa

- **Actor**: Agricultor propietario.
- **Descripción**: Consultar límites, sectores y referencia territorial de una parcela.
- **Precondiciones**: Parcela con polígono guardado.
- **Flujo principal**: Abre la vista de mapa y observa polígono, superficie y sectores.
- **Flujos alternativos**: Sin mapa base se muestran geometrías guardadas sobre una referencia
  neutral y se indica la limitación.
- **Resultado esperado**: Límites y sectores distinguibles y vinculados a sus fichas.

#### CU-MAP-01 - Abrir mapa

- **Actor**: Agricultor propietario.
- **Descripción**: Acceder al contexto espacial para consultar o editar terrenos.
- **Precondiciones**: Sesión activa; permiso de ubicación no obligatorio para abrir.
- **Flujo principal**: Abre Mapa y el sistema centra la parcela activa o una vista inicial.
- **Flujos alternativos**: Sin parcela presenta opciones para buscar, usar GPS o crear manualmente.
- **Resultado esperado**: Vista espacial disponible con el estado de conectividad visible.

#### CU-MAP-02 - Buscar ubicación

- **Actor**: Agricultor propietario.
- **Descripción**: Ubicar el mapa mediante un texto de búsqueda.
- **Precondiciones**: Servicio de búsqueda disponible y conectividad.
- **Flujo principal**: Ingresa una referencia, revisa resultados y selecciona uno.
- **Flujos alternativos**: Sin resultados permite reformular; offline ofrece GPS o geometrías
  guardadas sin simular resultados.
- **Resultado esperado**: Mapa centrado en la ubicación elegida.

#### CU-MAP-03 - Obtener GPS

- **Actor**: Agricultor propietario.
- **Descripción**: Centrar el mapa usando la posición del dispositivo.
- **Precondiciones**: Ubicación habilitada y permiso concedido.
- **Flujo principal**: Solicita mi ubicación, espera la lectura y confirma el punto obtenido.
- **Flujos alternativos**: Permiso denegado o señal insuficiente muestra instrucciones y permite
  continuar manualmente.
- **Resultado esperado**: Posición señalada con una indicación de precisión disponible.

#### CU-MAP-04 - Dibujar polígono

- **Actor**: Agricultor propietario.
- **Descripción**: Marcar el contorno de una parcela o sector.
- **Precondiciones**: Modo de dibujo activo.
- **Flujo principal**: Agrega al menos tres puntos distintos, revisa las líneas y cierra el
  polígono.
- **Flujos alternativos**: Puede deshacer el último punto; autocruces, puntos duplicados o área nula
  impiden confirmar.
- **Resultado esperado**: Geometría cerrada y válida lista para revisar.

#### CU-MAP-05 - Modificar puntos

- **Actor**: Agricultor propietario.
- **Descripción**: Ajustar una geometría antes o después de guardarla.
- **Precondiciones**: Polígono visible en modo edición.
- **Flujo principal**: Selecciona y mueve, agrega o elimina un punto; revisa el nuevo contorno.
- **Flujos alternativos**: Una modificación inválida se resalta y no puede confirmarse; puede
  restaurar la última versión guardada.
- **Resultado esperado**: Polígono válido actualizado con superficie recalculada.

#### CU-MAP-06 - Guardar parcela desde el mapa

- **Actor**: Agricultor propietario.
- **Descripción**: Convertir una geometría revisada en una parcela registrada.
- **Precondiciones**: Polígono de parcela válido y nombre informado.
- **Flujo principal**: Revisa límites y superficie, completa datos restantes y confirma.
- **Flujos alternativos**: Si falta un dato obligatorio vuelve al formulario sin perder el dibujo;
  offline guarda como pendiente.
- **Resultado esperado**: Parcela creada una sola vez con geometría y superficie asociadas.

#### CU-MAP-07 - Calcular superficie

- **Actor**: Agricultor propietario.
- **Descripción**: Obtener el área aproximada de un polígono.
- **Precondiciones**: Polígono válido.
- **Flujo principal**: El sistema recalcula el área tras cerrar o modificar el contorno y muestra
  metros cuadrados y hectáreas.
- **Flujos alternativos**: Geometría inválida no produce una cifra utilizable y explica el error.
- **Resultado esperado**: Superficie aproximada, métrica y vinculada a la versión del polígono.

#### CU-MAP-08 - Crear sector dentro de parcela

- **Actor**: Agricultor propietario.
- **Descripción**: Delimitar una subdivisión cuadrada, rectangular o irregular.
- **Precondiciones**: Parcela activa con polígono válido.
- **Flujo principal**: Dibuja el sector, asigna identificación y nombre, revisa que esté contenido y
  guarda.
- **Flujos alternativos**: Superposición se advierte; cruce del límite impide guardar; offline queda
  pendiente.
- **Resultado esperado**: Sector visible dentro de la parcela y disponible para asignar cultivo.

#### CU-SEC-01 - Crear sector

- **Actor**: Agricultor propietario.
- **Descripción**: Registrar una unidad de manejo dentro de la parcela activa.
- **Precondiciones**: Parcela activa.
- **Flujo principal**: Ingresa número único, nombre, superficie o geometría y guarda.
- **Flujos alternativos**: Número duplicado o geometría fuera de parcela exige corrección.
- **Resultado esperado**: Sector vinculado exclusivamente a su parcela.

#### CU-SEC-02 - Asignar número

- **Actor**: Agricultor propietario.
- **Descripción**: Identificar un sector de forma breve en su parcela.
- **Precondiciones**: Sector nuevo o editable.
- **Flujo principal**: Ingresa un número no utilizado en la parcela y confirma.
- **Flujos alternativos**: Duplicado muestra el sector que ya lo usa; vacío no permite guardar.
- **Resultado esperado**: Número único y visible en lista, mapa e historial.

#### CU-SEC-03 - Asignar cultivo

- **Actor**: Agricultor propietario.
- **Descripción**: Indicar el cultivo vigente de un sector.
- **Precondiciones**: Sector activo y catálogo disponible.
- **Flujo principal**: Abre el catálogo, consulta información, elige un cultivo y confirma fecha de
  inicio.
- **Flujos alternativos**: Puede dejar un sector nuevo sin cultivo; apicultura activa su ficha
  especializada.
- **Resultado esperado**: Cultivo vigente visible sin alterar registros históricos.

#### CU-SEC-04 - Cambiar cultivo

- **Actor**: Agricultor propietario.
- **Descripción**: Cerrar una asignación e iniciar otra.
- **Precondiciones**: Sector con cultivo vigente.
- **Flujo principal**: Elige cambiar, selecciona nuevo cultivo, informa fecha y confirma.
- **Flujos alternativos**: Fecha anterior al inicio vigente se rechaza; puede cancelar.
- **Resultado esperado**: Nueva asignación activa y asignación anterior preservada en historial.

#### CU-SEC-05 - Consultar información del sector

- **Actor**: Agricultor propietario.
- **Descripción**: Revisar identidad, geometría, cultivo y actividad de un sector.
- **Precondiciones**: Sector existente.
- **Flujo principal**: Abre la ficha y consulta datos, últimos registros y accesos al historial.
- **Flujos alternativos**: Sin cultivo o registros muestra estados vacíos orientadores.
- **Resultado esperado**: Información coherente con la parcela activa y sus relaciones.

#### CU-CUL-01 - Consultar catálogo e información de cultivos

- **Actor**: Agricultor propietario.
- **Descripción**: Revisar los cultivos iniciales y su información agrícola básica.
- **Precondiciones**: Sesión activa; catálogo local disponible.
- **Flujo principal**: Abre el catálogo, elige frambuesa, arándanos, papas, sandía, melones, maíz,
  physalis, frutilla o apicultura y consulta siembra, suelo, agua y enfermedades comunes.
- **Flujos alternativos**: Offline usa la última versión local; una ficha incompleta se identifica
  sin inventar datos.
- **Resultado esperado**: Información consultable y cultivo disponible para asignación.

#### CU-LAB-01 - Registrar labor

- **Actor**: Agricultor propietario.
- **Descripción**: Documentar una actividad desde el módulo denominado `LABORES`.
- **Precondiciones**: Parcela y sector seleccionados.
- **Flujo principal**: Selecciona parcela, sector y tipo; ingresa fecha, detalles y observaciones;
  revisa y guarda.
- **Flujos alternativos**: Riego, suelo, cosecha y apicultura abren sus campos especializados;
  fertilización, enfermedades y plagas, siembra y poda aceptan sus datos generales y notas.
- **Resultado esperado**: Labor guardada con contexto, fecha, tipo y estado de sincronización.

#### CU-SUE-01 - Registrar medición de suelo

- **Actor**: Agricultor propietario.
- **Descripción**: Guardar una lectura manual del terreno.
- **Precondiciones**: Sector seleccionado.
- **Flujo principal**: Informa fecha, humedad, pH, temperatura, EC, N, P y K; revisa unidades y
  guarda.
- **Flujos alternativos**: Valores fuera de rango se identifican; puede guardar campos opcionales
  vacíos si existe al menos una medición válida.
- **Resultado esperado**: Medición consultable offline, vinculada al sector y cultivo vigente.

#### CU-RIE-01 - Registrar riego

- **Actor**: Agricultor propietario.
- **Descripción**: Documentar el agua aplicada a un sector.
- **Precondiciones**: Sector y cultivo seleccionados.
- **Flujo principal**: Informa fecha, tipo, caudal total, duración y litros; revisa y guarda.
- **Flujos alternativos**: Puede calcular litros desde caudal y duración; discrepancias con un valor
  manual se advierten; admite goteo, aspersión, surco o gravedad.
- **Resultado esperado**: Riego trazable con entradas y volumen estimado conservados.

#### CU-CAL-01 - Calcular recomendación de riego

- **Actor**: Agricultor propietario.
- **Descripción**: Estimar litros requeridos y tiempo recomendado sin modelos avanzados.
- **Precondiciones**: Sector y cultivo definidos; cantidad de plantas y caudal positivos.
- **Flujo principal**: Ingresa plantas, caudal, humedad, temperatura y datos disponibles; el sistema
  aplica la necesidad base del cultivo, ajustes simples y divide el volumen recomendado por el
  caudal total para obtener el tiempo.
- **Flujos alternativos**: Sin clima usa solo datos locales y lo informa; entradas insuficientes o
  incoherentes impiden calcular; el usuario puede ajustar valores y recalcular.
- **Resultado esperado**: Litros y tiempo recomendados con variables usadas, fecha y carácter
  estimativo visibles; cálculo disponible offline.

#### CU-PRO-01 - Registrar producción y cosecha

- **Actor**: Agricultor propietario.
- **Descripción**: Registrar el resultado productivo de un sector.
- **Precondiciones**: Sector con cultivo asociado.
- **Flujo principal**: Informa cultivo, fecha, cantidad, unidad, calidad y observaciones; confirma.
- **Flujos alternativos**: Cantidad no positiva o unidad no métrica se rechaza; calidad puede quedar
  sin clasificar de forma explícita.
- **Resultado esperado**: Cosecha vinculada a sector, cultivo y temporada, apta para agregaciones.

#### CU-FOT-01 - Asociar fotografía

- **Actor**: Agricultor propietario.
- **Descripción**: Añadir evidencia visual desde cámara o galería.
- **Precondiciones**: Permiso correspondiente y sector o labor de destino.
- **Flujo principal**: Elige origen, captura o selecciona, previsualiza, describe opcionalmente y
  guarda la asociación.
- **Flujos alternativos**: Permiso denegado ofrece instrucciones; captura cancelada no crea adjunto;
  falta de espacio impide guardar con un mensaje claro.
- **Resultado esperado**: Imagen asociada a enfermedad, evolución, cosecha, apicultura u otro
  registro y disponible offline.

#### CU-API-01 - Registrar revisión apícola

- **Actor**: Agricultor propietario.
- **Descripción**: Documentar el estado de un sector de apicultura.
- **Precondiciones**: Sector clasificado como apícola.
- **Flujo principal**: Informa número de colmenas, fecha, apicultor, estado de reina, postura,
  alimentación, enfermedades, plagas, alza y fotografías; confirma.
- **Flujos alternativos**: Sin enfermedad o plaga registra explícitamente ausencia; cantidad de
  colmenas negativa se rechaza; puede guardar sin fotografías.
- **Resultado esperado**: Revisión apícola completa y consultable cronológicamente.

#### CU-REC-01 - Crear recordatorio

- **Actor**: Agricultor propietario.
- **Descripción**: Programar un aviso asociado al trabajo agrícola.
- **Precondiciones**: Sesión activa.
- **Flujo principal**: Ingresa título, fecha y hora, sector opcional y descripción; confirma el aviso.
- **Flujos alternativos**: Sin permiso de notificaciones conserva el recordatorio y explica cómo
  habilitar avisos; offline lo programa localmente y marca pendiente.
- **Resultado esperado**: Recordatorio visible, notificable en el dispositivo y sincronizable.

#### CU-SIN-01 - Sincronizar, resolver conflictos y recuperar

- **Actor**: Agricultor propietario; proceso automático del sistema.
- **Descripción**: Respaldar cambios locales y recuperar estado tras interrupciones.
- **Precondiciones**: Sesión válida y cambios pendientes o datos remotos por recibir.
- **Flujo principal**: Detecta conexión, cambia a Sincronizando, procesa cada cambio una sola vez,
  confirma respaldos y termina Sincronizado.
- **Flujos alternativos**: Un fallo conserva pendientes y ofrece reintento; un conflicto preserva
  ambas versiones, muestra diferencias y solicita elección; un cierre inesperado reanuda desde el
  último elemento confirmado.
- **Resultado esperado**: Sin duplicados ni pérdida silenciosa, con estado y pendientes visibles.

#### CU-EXP-01 - Exportar datos agrícolas

- **Actor**: Agricultor propietario.
- **Descripción**: Obtener una copia tabular de la información del MVP.
- **Precondiciones**: Existe al menos un registro exportable y espacio disponible.
- **Flujo principal**: Elige exportar, revisa alcance y genera un `.xlsx` con parcelas, sectores,
  cultivos, labores, suelo, riego y producción.
- **Flujos alternativos**: Offline usa todos los datos locales e identifica pendientes; sin datos no
  genera archivo vacío engañoso; error de escritura permite reintentar.
- **Resultado esperado**: Archivo completo, abrible y con relaciones identificables entre hojas.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema MUST autenticar al agricultor propietario antes de mostrar datos privados.
- **FR-002**: El primer inicio de sesión en un dispositivo MUST requerir validación conectada; una
  sesión vigente previamente validada MUST permitir acceso offline.
- **FR-003**: El agricultor MUST poder cerrar sesión sin que se eliminen cambios locales pendientes.
- **FR-004**: El agricultor MUST poder consultar su perfil y el resumen de sincronización.
- **FR-005**: El sistema MUST permitir crear y mantener múltiples parcelas con nombre, ubicación,
  superficie, polígono y descripción.
- **FR-006**: El agricultor MUST poder seleccionar exactamente una parcela activa a la vez.
- **FR-007**: El sistema MUST propagar la parcela activa a mapa, sectores, `LABORES` e historial.
- **FR-008**: El agricultor MUST poder editar los datos y la geometría de una parcela.
- **FR-009**: El sistema MUST recalcular la superficie al confirmar una geometría modificada.
- **FR-010**: La eliminación de una parcela MUST exigir confirmación y MUST preservar como archivada
  toda parcela que tenga historial dependiente.
- **FR-011**: El sistema MUST mostrar parcelas, sectores y límites guardados aun cuando el mapa base
  no esté disponible.
- **FR-012**: El mapa MUST permitir búsqueda de ubicación cuando el servicio necesario esté disponible.
- **FR-013**: El mapa MUST permitir centrar la vista mediante GPS con autorización del usuario.
- **FR-014**: El agricultor MUST poder dibujar y editar polígonos con al menos tres puntos distintos.
- **FR-015**: El sistema MUST rechazar polígonos abiertos, autocruzados o con superficie nula.
- **FR-016**: La superficie aproximada MUST mostrarse en metros cuadrados y hectáreas.
- **FR-017**: El agricultor MUST poder crear sectores cuadrados, rectangulares e irregulares.
- **FR-018**: Todo sector MUST estar contenido completamente en una única parcela.
- **FR-019**: Cada sector MUST conservar número, nombre, ubicación, superficie y cultivo vigente.
- **FR-020**: El número de sector MUST ser único dentro de su parcela.
- **FR-021**: El catálogo inicial MUST incluir frambuesa, arándanos, papas, sandía, melones, maíz,
  physalis, frutilla y apicultura.
- **FR-022**: Cada ficha de cultivo MUST mostrar época de siembra, requisitos generales de suelo,
  necesidades hídricas y enfermedades comunes.
- **FR-023**: El agricultor MUST poder asignar y cambiar el cultivo de un sector indicando la fecha
  efectiva, sin alterar asignaciones históricas.
- **FR-024**: El módulo de registro MUST llamarse `LABORES` en toda la interfaz orientada al usuario.
- **FR-025**: `LABORES` MUST ofrecer riego, suelo, fertilización, enfermedades y plagas, siembra,
  poda, cosecha y apicultura.
- **FR-026**: Toda labor MUST vincularse con parcela, sector, tipo, fecha y estado de sincronización.
- **FR-027**: El registro de suelo MUST aceptar humedad en porcentaje, pH, temperatura en grados
  Celsius, EC en mS/cm y N, P y K en mg/kg.
- **FR-028**: El sistema MUST validar humedad entre 0 y 100, pH entre 0 y 14 y valores no negativos
  para EC, N, P y K.
- **FR-029**: Una medición de suelo MUST poder guardarse con al menos uno de sus indicadores válido.
- **FR-030**: El registro de riego MUST conservar fecha, sector, cultivo, tipo, caudal, duración y
  litros estimados.
- **FR-031**: Los tipos de riego iniciales MUST ser goteo, aspersión, surco y gravedad.
- **FR-032**: El sistema MUST calcular el agua aplicada como caudal total en litros por minuto
  multiplicado por duración en minutos cuando ambos valores estén disponibles.
- **FR-033**: La calculadora MUST usar cantidad de plantas, caudal, cultivo, humedad de suelo y
  temperatura como entradas locales y MAY añadir clima disponible como ajuste.
- **FR-034**: La recomendación MUST partir de una necesidad hídrica base del cultivo, ajustarla con
  reglas simples declaradas para humedad, temperatura y clima, y calcular el tiempo dividiendo los
  litros recomendados por el caudal total.
- **FR-035**: La calculadora MUST entregar litros estimados, tiempo recomendado, variables usadas y
  advertencias por datos faltantes sin depender de conexión.
- **FR-036**: La calculadora MUST NOT usar evapotranspiración avanzada ni presentar resultados como
  sustituto de una decisión profesional del agricultor.
- **FR-037**: El sistema MUST conservar labores, suelo, riegos, cambios de cultivo, cosechas y
  temporadas en un historial ordenable y filtrable.
- **FR-038**: El historial MUST permitir filtros por parcela, sector, cultivo, tipo y rango de fechas.
- **FR-039**: El registro de producción MUST conservar cultivo, sector, fecha, cantidad positiva,
  unidad métrica, calidad y observaciones.
- **FR-040**: Los registros de producción MUST conservar temporada y relaciones suficientes para
  futuras comparaciones anuales y de rendimiento por sector.
- **FR-041**: El agricultor MUST poder capturar una fotografía o seleccionarla desde la galería.
- **FR-042**: Cada fotografía MUST vincularse a un sector o labor y MAY llevar descripción.
- **FR-043**: Las fotografías MUST permanecer visibles offline una vez guardadas localmente.
- **FR-044**: Un sector apícola MUST aceptar número de colmenas, fecha de revisión, nombre del
  apicultor, estado de reina, postura, alimentación, enfermedades, plagas, colocación de alza y
  fotografías.
- **FR-045**: El agricultor MUST poder crear recordatorios con título, fecha y hora, sector opcional
  y descripción.
- **FR-046**: Los recordatorios MUST activarse localmente sin internet y sincronizarse después.
- **FR-047**: La interfaz MUST mostrar los estados Conectado, Offline, Sincronizando, Sincronizado y
  Error, además del número de cambios pendientes.
- **FR-048**: Toda escritura MUST guardarse localmente antes de considerarse exitosa para el usuario.
- **FR-049**: La sincronización MUST reintentar cambios no confirmados sin crear duplicados.
- **FR-050**: Un conflicto de edición MUST conservar ambas versiones y requerir una decisión
  explícita del agricultor antes de descartar una.
- **FR-051**: Tras una interrupción, la sincronización MUST continuar desde el último cambio
  confirmado y mantener visibles los elementos pendientes o fallidos.
- **FR-052**: El agricultor MUST poder generar un archivo `.xlsx` con parcelas, sectores, cultivos,
  labores, suelo, riego y producción.
- **FR-053**: La exportación MUST incluir datos locales pendientes y diferenciarlos de los ya
  respaldados.
- **FR-054**: La asistencia inteligente del MVP MUST ser solo consultiva y MUST NOT calcular ni
  reemplazar superficies, volúmenes o recomendaciones críticas.

### Non-Functional Requirements

- **NFR-001 - Rendimiento**: El 95 % de las aperturas de pantallas basadas en datos locales y de los
  guardados locales MUST confirmar resultado en menos de 2 segundos en un dispositivo objetivo.
- **NFR-002 - Inicio**: La aplicación MUST dejar disponible la navegación local en menos de 5
  segundos para el 95 % de los inicios con una sesión vigente.
- **NFR-003 - Offline**: El 100 % de los registros válidos confirmados durante una prueba de 24 horas
  sin conexión MUST seguir disponibles tras cierres y reinicios.
- **NFR-004 - Integridad**: Reintentos, cierres inesperados y recuperación de conexión MUST producir
  cero pérdidas silenciosas y cero duplicados confirmados en los escenarios de aceptación.
- **NFR-005 - Seguridad**: Una persona sin sesión válida MUST NOT visualizar ni exportar datos del
  agricultor; mensajes y diagnósticos MUST NOT exponer credenciales.
- **NFR-006 - Usabilidad**: Formularios MUST indicar campos obligatorios, unidades, errores y estado
  de guardado con lenguaje comprensible y acciones táctiles aptas para uso en terreno.
- **NFR-007 - Idioma**: Toda copia de usuario MUST usar español latinoamericano.
- **NFR-008 - Unidades**: La interfaz y exportación MUST usar metros, centímetros, hectáreas,
  litros, kilos y grados Celsius, además de las unidades métricas de dominio declaradas; MUST NOT
  usar pulgadas, libras ni Fahrenheit.
- **NFR-009 - Volumen**: Consultas locales MUST mantener los objetivos de rendimiento con al menos
  20 parcelas, 200 sectores y 10.000 registros textuales del propietario.
- **NFR-010 - Accesibilidad operativa**: Información esencial y estados MUST distinguirse por texto
  e iconografía, no únicamente por color, y los controles MUST tener etiquetas comprensibles.
- **NFR-011 - Escalabilidad funcional**: Los datos MUST conservar identificadores y relaciones que
  permitan agregar más propietarios en el futuro sin exponer esa capacidad en el MVP.

### Key Entities *(include if feature involves data)*

- **Agricultor**: Propietario único del MVP; contiene identidad visible, preferencias y relación con
  sus parcelas, sin roles de trabajadores.
- **Parcela**: Unidad territorial con nombre, descripción, ubicación, polígono, superficie, estado
  activo o archivado y sectores dependientes.
- **Sector**: Subdivisión identificada dentro de una parcela; tiene número único por parcela,
  nombre, geometría, superficie y asignaciones de cultivo.
- **Cultivo**: Elemento del catálogo con información de siembra, suelo, agua y enfermedades.
- **Asignación de cultivo**: Relación temporal entre sector y cultivo que preserva fechas de inicio
  y término para no perder rotaciones históricas.
- **Labor**: Evento agrícola común con tipo, fecha, parcela, sector, cultivo aplicable,
  observaciones y estado de sincronización.
- **Medición de suelo**: Especialización de labor con humedad, pH, temperatura, EC, N, P y K.
- **Riego**: Especialización de labor con tipo, caudal, duración y litros estimados.
- **Recomendación de riego**: Resultado explicable que conserva entradas, ajustes, litros, tiempo,
  advertencias y fecha, sin sustituir la decisión del agricultor.
- **Cosecha o producción**: Resultado productivo con cantidad, unidad, calidad, observaciones,
  cultivo, sector y temporada.
- **Revisión apícola**: Labor especializada de un sector apícola con colmenas, responsable, reina,
  postura, alimentación, sanidad y alza.
- **Fotografía**: Evidencia visual asociada a un sector o labor, con origen, fecha, descripción y
  estado de respaldo.
- **Recordatorio**: Aviso con título, fecha y hora, sector opcional, descripción y estado.
- **Temporada**: Periodo agrícola usado para agrupar cultivos, labores y producción.
- **Cambio pendiente**: Representación funcional de una creación, edición o eliminación local que
  espera confirmación de respaldo.
- **Conflicto de sincronización**: Par de versiones incompatibles de un registro que requiere una
  resolución explícita sin pérdida silenciosa.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Al menos 90 % de usuarios de prueba completa la creación de su primera parcela y
  sector válido en menos de 10 minutos sin asistencia.
- **SC-002**: Al menos 95 % de usuarios de prueba registra una labor offline en menos de 2 minutos
  y puede encontrarla nuevamente en el historial.
- **SC-003**: En pruebas de 24 horas sin conexión, 100 % de los registros confirmados permanece
  disponible después de tres cierres y reinicios de la aplicación.
- **SC-004**: Al recuperar conectividad tras 100 cambios offline, 100 % termina respaldado una sola
  vez o identificado explícitamente como pendiente, fallido o en conflicto.
- **SC-005**: El usuario puede identificar conexión, sincronización, éxito, error y cantidad de
  pendientes en menos de 5 segundos en pruebas de comprensión.
- **SC-006**: El 100 % de los conflictos simulados conserva ambas versiones hasta una elección
  explícita y ninguno produce pérdida silenciosa.
- **SC-007**: Para 20 escenarios de riego con entradas conocidas, el sistema reproduce de forma
  determinista los mismos litros y tiempos, muestra todas las variables usadas y funciona offline.
- **SC-008**: Al menos 90 % de usuarios de prueba interpreta correctamente que la recomendación de
  riego es una estimación y no una orden automática.
- **SC-009**: Una consulta por parcela, sector o cultivo devuelve exclusivamente los registros
  correspondientes en 100 % de un conjunto de pruebas con datos cruzados.
- **SC-010**: Una exportación de referencia abre correctamente e incluye 100 % de los registros
  locales de parcelas, sectores, cultivos, labores, suelo, riego y producción, con su estado de
  respaldo identificable.
- **SC-011**: Al menos 90 % de usuarios de prueba completa una medición de suelo, una cosecha y un
  recordatorio sin ayuda y sin introducir unidades no métricas.
- **SC-012**: Con 20 parcelas, 200 sectores y 10.000 registros textuales, 95 % de las consultas y
  guardados locales percibidos por el usuario finaliza en menos de 2 segundos.

## Assumptions

- El MVP atiende a un único agricultor propietario por cuenta y dispositivo; no existen
  trabajadores, permisos diferenciados ni administración multiusuario visible.
- El primer inicio de sesión requiere conectividad. Una sesión vigente ya validada permite entrar
  offline, pero las políticas exactas de expiración se definirán en planificación bajo las reglas
  de seguridad del proyecto.
- El usuario concede, cuando corresponde, permisos de ubicación, cámara, galería y notificaciones;
  negar uno no bloquea módulos no relacionados.
- La búsqueda de direcciones y la descarga de un mapa base requieren disponibilidad del servicio.
  El GPS y las geometrías locales continúan utilizables sin esa disponibilidad.
- La eliminación de parcelas con historial se interpreta como archivo recuperable para preservar
  trazabilidad; solo elementos sin dependencias pueden eliminarse definitivamente.
- EC se registra en mS/cm, N/P/K en mg/kg, caudal total en L/min, duración en minutos, humedad en
  porcentaje, temperatura en °C, superficies en m² y ha, y producción en kg u otra unidad métrica
  explícita permitida.
- Las necesidades hídricas base por cultivo y los ajustes simples serán validados por el
  propietario o una fuente agronómica durante la planificación; la especificación define el
  comportamiento y trazabilidad, no valores agronómicos concretos.
- Clima y asistencia consultiva son dependencias complementarias. Su indisponibilidad no impide
  guardar, consultar, exportar o calcular con datos locales.
- La exportación representa el estado local completo al momento de generarse, incluidos cambios
  aún no respaldados.
- Las fotografías se consideran parte del historial, pero las metas de 10.000 registros y 2
  segundos se miden sobre datos textuales y metadatos, no sobre transferencia masiva de imágenes.
- El usuario es responsable de revisar la exactitud de datos manuales y de confirmar las
  recomendaciones antes de ejecutar un riego real.
- Las decisiones de plataforma, persistencia, backend y proveedores externos se toman de la
  constitución vigente y se documentarán en el plan, no en esta especificación funcional.

## Fuera de alcance

- Aplicación iOS.
- Trabajadores, roles múltiples o colaboración multiusuario en el MVP.
- ERP agrícola, facturación, compras, inventario avanzado e integraciones industriales.
- Automatización física del riego.
- Sensores Bluetooth, IoT o lectura automática de sensores.
- Panel web.
- Asistencia inteligente avanzada, diagnóstico automático o análisis fotográfico.
- Modelos científicos complejos y evapotranspiración avanzada.
- Calendario lunar funcional en el MVP.

## Consideraciones futuras

Las entidades y relaciones se preparan para admitir posteriormente múltiples agricultores, panel
web, sensores conectados, recomendaciones inteligentes, análisis de fotografías y comparaciones
productivas avanzadas. El calendario lunar futuro será solo informativo y nunca alimentará
cálculos críticos. Estos puntos de extensión no autorizan interfaces simuladas, flujos incompletos
ni lógica anticipada dentro del Módulo 001.
