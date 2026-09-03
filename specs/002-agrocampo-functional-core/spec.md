# Feature Specification: AgroCampo Functional Core - Módulo 002

**Feature Branch**: `feature/v1.0`

**Created**: 2026-08-28

**Status**: Implementation validation in progress

**Last Updated**: 2026-08-30

**Input**: User description: "Completar el núcleo funcional agrícola de AgroCampo sobre la
aplicación existente, con acceso seguro, gestión territorial, temporadas, labores, riego por
goteo, historial, operación offline e integraciones acotadas."

## Purpose and Increment Boundary

El Módulo 002 convierte capacidades existentes o parciales en flujos agrícolas completos,
utilizables y demostrables. Es un incremento sobre `001-agrocampo-android-mvp`; no reemplaza su
definición del producto ni vuelve a especificar el MVP completo. Cuando una capacidad seleccionada
ya exista y cumpla este documento, se conserva. Cuando esté incompleta, simulada o desconectada, el
resultado exigido por 002 es completar el flujo observable y preservar los datos existentes.

La constitución del proyecto gobierna las decisiones transversales. `001` sigue gobernando las
capacidades generales que no forman parte de este incremento. `master.md` conserva autoridad sobre
UX/UI, navegación visual, estados, accesibilidad y lenguaje de interacción. Ante una diferencia,
002 sólo modifica el comportamiento incluido expresamente en su alcance; no elimina requisitos
compatibles de 001.

Este incremento se concentra en acceso, parcelas y sectores, temporadas y cultivos, labores,
producción, riego por goteo, historial por sector, persistencia offline, sincronización confiable,
recordatorios, alertas meteorológicas y un chatbot agrícola básico. Capacidades de 001 no nombradas
aquí, como medición de suelo, fotografías, apicultura y exportación, permanecen vigentes en 001
pero no son criterios de finalización de 002.

La única sustitución deliberada de comportamiento en una capacidad compartida es AgroIA: dentro
de 002 deja de recibir automáticamente el contexto privado que contemplaba 001 y funciona como
chatbot agrícola general. Sólo utiliza el texto que el agricultor decide enviar.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Entrar y retomar el trabajo de forma segura (Priority: P1)

Como agricultor propietario, quiero iniciar sesión, mantener un acceso válido y desbloquear de
forma opcional una sesión existente para retomar mi trabajo con rapidez sin exponer mis datos
después de cerrar sesión.

**Why this priority**: Ningún flujo privado puede utilizarse con confianza si el acceso local no
distingue una sesión válida, un desbloqueo del dispositivo y un cierre de sesión.

**Independent Test**: Se prueba iniciando sesión con conexión, cerrando y reabriendo la aplicación,
habilitando el desbloqueo del dispositivo, utilizándolo sin conexión y cerrando sesión. El acceso
posterior debe quedar bloqueado sin borrar cambios agrícolas pendientes.

**Acceptance Scenarios**:

1. **Given** credenciales válidas y conexión disponible, **When** el agricultor inicia sesión,
   **Then** accede al contexto agrícola existente o a un inicio vacío accionable.
2. **Given** una sesión previamente validada y todavía autorizada, **When** reabre la aplicación,
   **Then** puede retomar el acceso sin repetir innecesariamente la autenticación remota.
3. **Given** que habilitó el desbloqueo del dispositivo, **When** valida correctamente su identidad
   local, **Then** desbloquea únicamente la sesión existente y puede trabajar sin conexión.
4. **Given** un dispositivo sin biometría disponible o una validación cancelada, **When** intenta
   desbloquear, **Then** permanece bloqueado y recibe una alternativa de acceso comprensible.
5. **Given** una sesión abierta con cambios pendientes, **When** cierra sesión, **Then** los datos
   privados dejan de ser accesibles, el desbloqueo local ya no reabre la sesión y los cambios no se
   eliminan.

---

### User Story 2 - Organizar parcelas y sectores reales (Priority: P1)

Como agricultor, quiero administrar una o varias parcelas, elegir la activa y delimitar múltiples
sectores con polígonos libres para que todas las operaciones agrícolas utilicen el terreno correcto.

**Why this priority**: Parcela y sector son el contexto mínimo de temporadas, labores, riego,
producción, historial y alertas.

**Independent Test**: Se prueba creando dos parcelas, cambiando la activa, añadiendo al menos tres
sectores de polígonos distintos, reiniciando la aplicación y verificando que contexto y geometrías
se conservan sin mezclarse.

**Acceptance Scenarios**:

1. **Given** un agricultor sin parcelas, **When** crea una parcela válida, **Then** queda guardada y
   seleccionada como parcela activa.
2. **Given** dos parcelas con sectores, **When** cambia la parcela activa, **Then** mapa, listas,
   formularios e historial muestran exclusivamente el nuevo contexto.
3. **Given** una parcela activa, **When** dibuja y confirma dos sectores mediante polígonos libres,
   **Then** ambos quedan disponibles con su nombre, geometría y superficie correspondientes.
4. **Given** una geometría guardada en modo visualización, **When** toca o desplaza el mapa sin
   iniciar edición, **Then** ningún vértice ni límite se modifica.
5. **Given** que inicia explícitamente la edición de un sector, **When** modifica vértices y
   confirma, **Then** se guarda la nueva geometría; si cancela, se conserva exactamente la anterior.
6. **Given** que el mapa remoto o la ubicación del dispositivo no están disponibles, **When**
   consulta una parcela, **Then** sigue viendo la lista, los datos y las geometrías guardadas sin
   bloquear las demás operaciones locales.

---

### User Story 3 - Gestionar temporadas y rotación de cultivos (Priority: P1)

Como agricultor, quiero asociar cultivos a cada sector por temporada y rotarlos o intercambiarlos
sin perder el historial para conocer qué hubo en cada lugar y momento.

**Why this priority**: El contexto temporal evita que labores y producción cambien de significado
cuando un sector recibe otro cultivo.

**Independent Test**: Se prueba creando dos temporadas, asignando cultivos de catálogo y
personalizados a dos sectores, efectuando una rotación y comprobando los eventos anteriores y
posteriores a la fecha efectiva.

**Acceptance Scenarios**:

1. **Given** un sector y una temporada vigente, **When** asigna un cultivo, **Then** los nuevos
   registros del sector utilizan esa combinación sin modificar registros previos.
2. **Given** un cultivo vigente con historial, **When** programa o confirma una rotación en una
   fecha efectiva, **Then** la asignación anterior finaliza y la nueva comienza sin solapamiento.
3. **Given** dos sectores con cultivos diferentes, **When** intercambia sus cultivos para una fecha
   efectiva, **Then** cada sector conserva su historial anterior y recibe la nueva asignación.
4. **Given** que el cultivo requerido no está en el catálogo inicial, **When** crea un cultivo
   personalizado válido, **Then** puede asignarlo y usarlo en los mismos flujos que uno precargado.
5. **Given** una temporada cerrada, **When** consulta un sector, **Then** sus cultivos, labores,
   riegos y producción permanecen vinculados a esa temporada.

---

### User Story 4 - Registrar labores y producción offline (Priority: P1)

Como agricultor en terreno, quiero registrar labores estructuradas y resultados de cosecha aunque
no tenga internet para no perder información ni transcribirla más tarde.

**Why this priority**: El registro diario y confiable del trabajo agrícola es el valor operativo
central del incremento.

**Independent Test**: Se prueba sin conexión registrando riego, fertilización, fitosanitarios,
siembra, poda, cosecha y otra labor en distintos sectores; tras reiniciar, cada evento debe
conservar contexto, datos y estado.

**Acceptance Scenarios**:

1. **Given** sector, temporada y cultivo vigentes, **When** guarda una labor válida sin conexión,
   **Then** aparece inmediatamente en el historial con el contexto correcto.
2. **Given** que selecciona fertilización, fitosanitarios, siembra, poda o cosecha, **When**
   completa el formulario, **Then** sólo se exigen y conservan los datos pertinentes a ese tipo.
3. **Given** una actividad no cubierta por los tipos disponibles, **When** elige “Otra labor”,
   describe el trabajo y guarda, **Then** se registra con la misma trazabilidad que las demás.
4. **Given** una cosecha con cantidad y unidad válidas, **When** la guarda, **Then** la producción
   queda vinculada al sector, cultivo y temporada y se muestra una sola vez en el historial.
5. **Given** varias labores guardadas offline, **When** cierra y reabre la aplicación, **Then**
   todas continúan disponibles con sus datos y estado de respaldo.

---

### User Story 5 - Configurar y calcular riego por goteo (Priority: P2)

Como agricultor, quiero guardar la configuración de riego por goteo de cada sector y obtener una
recomendación reproducible de tiempo y volumen para planificar y registrar el riego con criterios
comprensibles.

**Why this priority**: El riego es una operación frecuente y sensible, pero depende de que sector,
cultivo y temporada ya estén correctamente definidos.

**Independent Test**: Se prueba configurando plantas, goteros, caudal y los parámetros aprobados
para un sector; el mismo conjunto de entradas debe producir siempre el mismo resultado, explicar
sus datos principales y poder guardarse sin conexión.

**Acceptance Scenarios**:

1. **Given** un sector sin configuración de goteo, **When** completa valores válidos y guarda,
   **Then** la configuración permanece disponible para cálculos posteriores y tras reiniciar.
2. **Given** una configuración y entradas suficientes, **When** solicita una recomendación,
   **Then** obtiene tiempo y volumen con unidades y una explicación breve de los datos utilizados.
3. **Given** exactamente las mismas entradas, **When** repite el cálculo, **Then** obtiene el mismo
   resultado dentro de la tolerancia declarada por la regla aprobada.
4. **Given** datos faltantes, nulos o fuera de rango, **When** intenta calcular, **Then** no recibe
   una recomendación utilizable y se identifican los campos que debe corregir.
5. **Given** que no existe clima actual pero los datos locales son suficientes, **When** calcula,
   **Then** obtiene el resultado local y la explicación identifica que no se usó clima actual.
6. **Given** una recomendación válida, **When** registra el riego realizado, **Then** el historial
   conserva entradas, resultado, configuración aplicada y contexto agrícola.

---

### User Story 6 - Consultar el historial completo de un sector (Priority: P2)

Como agricultor, quiero revisar cronológicamente temporadas, cultivos, labores, riegos y producción
de un sector para comprender su evolución sin que los cambios actuales alteren el pasado.

**Why this priority**: El historial convierte registros aislados en trazabilidad agrícola útil.

**Independent Test**: Se prueba generando datos en dos temporadas y dos sectores, aplicando filtros
y verificando orden, relaciones históricas y visibilidad de registros pendientes.

**Acceptance Scenarios**:

1. **Given** un sector con dos temporadas, **When** abre su historial, **Then** ve asignaciones y
   eventos en orden cronológico, agrupables por temporada.
2. **Given** registros de varios sectores, **When** consulta uno concreto, **Then** no aparecen
   eventos pertenecientes a otro sector.
3. **Given** un cambio de cultivo, **When** consulta eventos anteriores, **Then** conservan el
   cultivo y la temporada que tenían al registrarse.
4. **Given** una labor recién guardada offline, **When** abre el historial, **Then** aparece en la
   posición temporal correcta sin esperar respaldo remoto.
5. **Given** un historial sin eventos o un filtro sin coincidencias, **When** abre la vista,
   **Then** distingue ambos estados y ofrece una acción pertinente.

---

### User Story 7 - Respaldar cambios con confirmación real (Priority: P2)

Como agricultor, quiero trabajar offline y que mis cambios se respalden al recuperar conexión sin
desaparecer, duplicarse ni mostrarse como sincronizados antes de la confirmación real.

**Why this priority**: Offline-first sólo es confiable si la persistencia y el respaldo pueden
observarse y recuperarse después de fallos.

**Independent Test**: Se prueba creando cien operaciones locales de los tipos incluidos,
reiniciando la aplicación, recuperando conexión e interrumpiendo el respaldo. Cada cambio debe
quedar confirmado una sola vez o seguir identificado como pendiente, error o conflicto.

**Acceptance Scenarios**:

1. **Given** cien cambios guardados sin conexión, **When** vuelve una conexión estable, **Then**
   comienza el respaldo y cada cambio confirmado queda registrado una sola vez.
2. **Given** una falla antes de recibir confirmación remota, **When** termina el intento, **Then**
   el cambio no se marca como sincronizado y conserva una opción de reintento.
3. **Given** una interrupción y posterior reinicio, **When** se reanuda el respaldo, **Then**
   continúa con los cambios no confirmados sin duplicar los ya confirmados.
4. **Given** dos versiones incompatibles, **When** se detecta el conflicto, **Then** ambas se
   conservan y el agricultor elige explícitamente cuál mantener.
5. **Given** una eliminación local pendiente, **When** el respaldo se reintenta y se confirma,
   **Then** el elemento eliminado no reaparece por una copia remota anterior.

---

### User Story 8 - Recibir recordatorios y alertas útiles (Priority: P3)

Como agricultor, quiero programar recordatorios que funcionen offline y recibir alertas
meteorológicas cuando haya conexión para anticipar labores sin depender de servicios externos para
mis registros.

**Why this priority**: Los avisos apoyan el trabajo diario, pero no son condición para registrar o
consultar la actividad agrícola.

**Independent Test**: Se prueba creando un recordatorio sin conexión, reiniciando el dispositivo y
verificando el aviso; luego se simulan información meteorológica vigente, datos antiguos y falla
del servicio sin afectar los flujos locales.

**Acceptance Scenarios**:

1. **Given** un recordatorio futuro creado offline y permisos concedidos, **When** llega su fecha y
   hora, **Then** el agricultor recibe el aviso local.
2. **Given** permisos de avisos denegados, **When** guarda un recordatorio, **Then** permanece
   consultable y se explica que no habrá una notificación del dispositivo.
3. **Given** una alerta meteorológica vigente para la parcela activa, **When** llega información
   nueva, **Then** se muestra el riesgo, su momento de actualización y su carácter informativo.
4. **Given** ausencia de conexión o datos antiguos, **When** consulta alertas, **Then** se comunica
   la indisponibilidad o antigüedad sin bloquear ninguna función local.

---

### User Story 9 - Consultar AgroIA sin exponer datos privados (Priority: P3)

Como agricultor, quiero hacer preguntas agrícolas generales a un chatbot básico para obtener
orientación independiente sin que mis parcelas, historial o registros privados se incorporen
automáticamente.

**Why this priority**: La orientación general aporta valor complementario, pero debe permanecer
separada de los datos privados y de los cálculos críticos.

**Independent Test**: Se prueba realizando consultas generales, solicitando un cálculo crítico,
desconectando la red y comprobando que el chatbot no lee ni modifica datos agrícolas privados.

**Acceptance Scenarios**:

1. **Given** conexión disponible, **When** envía una pregunta agrícola general, **Then** recibe una
   respuesta identificada como orientación que debe verificarse en terreno.
2. **Given** datos privados en la aplicación, **When** inicia una conversación, **Then** ningún dato
   de parcela, sector, historial o producción se adjunta automáticamente.
3. **Given** una solicitud para calcular riego o modificar registros, **When** el chatbot responde,
   **Then** no ejecuta la acción ni sustituye el cálculo determinista.
4. **Given** ausencia de conexión, **When** intenta enviar una consulta, **Then** se informa que la
   función requiere conexión y se conserva el texto para reintentar sin duplicarlo.

### Edge Cases

- El primer acceso en un dispositivo sin conexión no puede validar una identidad remota; una sesión
  previamente autorizada puede continuar offline mientras no haya sido cerrada.
- Un cambio de credenciales o revocación remota conocido por el dispositivo invalida el acceso
  local; estar offline no crea una identidad nueva.
- Fallar o cancelar repetidamente la biometría no borra datos ni habilita acceso por sí solo.
- Cerrar sesión durante un respaldo interrumpe el acceso visual sin descartar cambios pendientes.
- Si no existe ninguna parcela, las funciones dependientes orientan a crear una antes de pedir
  sector, temporada o cultivo.
- Un cambio de parcela activa no puede dejar formularios abiertos guardando silenciosamente en la
  parcela anterior; debe pedir confirmar, descartar o mantener el contexto original de forma clara.
- Un polígono con menos de tres puntos distintos, superficie nula, autocruces o vértices inválidos
  no puede confirmarse.
- Un sector que excede los límites de su parcela no puede guardarse hasta corregirlo.
- La denegación del permiso de ubicación no impide dibujar manualmente ni consultar geometrías.
- La pérdida del mapa remoto durante una edición conserva los puntos locales sin confirmar una
  geometría incompleta.
- Dos sectores pueden compartir un nombre, pero deben seguir siendo distinguibles dentro de su
  parcela.
- Una edición cancelada o interrumpida no cambia la última geometría confirmada.
- Una temporada puede estar planificada, activa o cerrada; una temporada cerrada no recibe nuevos
  eventos salvo una corrección explícita y trazable.
- Dos asignaciones de cultivo para el mismo sector no pueden estar vigentes en la misma fecha.
- Intercambiar cultivos entre sectores no mueve labores, riegos ni producción históricos.
- Un cultivo personalizado ya utilizado no puede desaparecer del historial aunque se archive.
- “Otra labor” sin descripción no puede guardarse.
- Una cosecha con cantidad nula, negativa o sin unidad válida no genera producción.
- Corregir la fecha de una labor no puede dejarla asociada a un cultivo inexistente para esa fecha
  sin advertencia y confirmación explícita.
- Una configuración de goteo incompleta o con plantas, goteros o caudal no positivos no produce una
  recomendación.
- Cambiar la configuración actual de goteo no recalcula ni modifica riegos históricos.
- Si no existe una regla agronómica aprobada para una entrada, el sistema no inventa un coeficiente
  ni presenta el resultado como validado.
- Agotar el almacenamiento durante un guardado no muestra éxito ni altera el último estado válido.
- Una falla, cierre o reinicio durante el respaldo conserva los cambios no confirmados.
- Un conflicto no resuelto permanece visible y no bloquea el registro de nuevas operaciones locales.
- Un aviso local programado para una fecha pasada exige corregir la fecha o registrarlo sin aviso
  futuro de forma explícita.
- Información meteorológica sin hora de actualización no se presenta como alerta vigente.
- Una respuesta vacía, fallida o interrumpida del chatbot permite reintentar sin duplicar mensajes.

## Requirements *(mandatory)*

### Functional Requirements

#### Increment Boundary and Preservation

- **FR-001**: El Módulo 002 MUST completar únicamente los flujos seleccionados en este documento y
  MUST NOT redefinir el alcance completo de 001.
- **FR-002**: Los datos válidos creados antes de 002 MUST permanecer disponibles, relacionados y
  utilizables después del incremento.
- **FR-003**: Un comportamiento existente que ya satisfaga esta especificación MUST conservar el
  mismo resultado observable y MUST NOT duplicar entidades ni registros.
- **FR-004**: Una pantalla, ruta, formulario o dato simulado MUST NOT contarse como funcionalidad
  completa hasta demostrar guardado, reapertura, consistencia y respaldo cuando corresponda.
- **FR-005**: Las capacidades de 001 fuera del alcance de 002 MUST mantener su contrato vigente y
  MUST NOT bloquear la aceptación de este incremento salvo que sufran una regresión.

#### Access and Local Session

- **FR-006**: El agricultor MUST autenticarse mediante el servicio de cuenta remoto existente antes
  del primer acceso a datos privados en un dispositivo.
- **FR-007**: Una autenticación válida MUST crear una sesión que pueda mantenerse entre cierres y
  reaperturas conforme a su vigencia.
- **FR-008**: Una sesión válida previa MUST permitir consultar y crear datos locales sin conexión.
- **FR-009**: El agricultor MAY habilitar o deshabilitar el desbloqueo biométrico sólo después de
  una autenticación remota válida.
- **FR-010**: El desbloqueo biométrico MUST desbloquear únicamente una sesión existente y MUST NOT
  sustituir la identidad remota.
- **FR-011**: La falta, cancelación o falla de biometría MUST mantener los datos bloqueados y
  ofrecer una alternativa de acceso segura y comprensible.
- **FR-012**: Cerrar sesión MUST invalidar el acceso local y el desbloqueo biométrico asociado, sin
  eliminar cambios agrícolas pendientes.
- **FR-013**: El acceso de 002 MUST representar a un único agricultor y MUST NOT exponer roles,
  organizaciones, MFA obligatorio ni administración empresarial.

#### Parcels, Active Context, and Sectors

- **FR-014**: El agricultor MUST poder crear, consultar y editar una o múltiples parcelas.
- **FR-015**: Cuando exista al menos una parcela, el sistema MUST mantener exactamente una como
  activa y recordar la selección entre reaperturas.
- **FR-016**: Cambiar la parcela activa MUST actualizar mapa, sectores, temporada, cultivo,
  formularios, historial, recordatorios y alertas sin mezclar datos de otra parcela.
- **FR-017**: Si no existe una parcela, el inicio MUST ofrecer un estado vacío accionable y MUST NOT
  mostrar datos agrícolas ficticios.
- **FR-018**: Cada parcela MUST conservar nombre, ubicación disponible, geometría, superficie y
  estado necesarios para identificarla.
- **FR-019**: Una parcela MUST admitir múltiples sectores sin un límite derivado de los datos de
  demostración.
- **FR-020**: Cada sector MUST conservar una identidad distinguible dentro de su parcela, nombre,
  geometría poligonal libre, superficie y estado.
- **FR-021**: Un polígono de sector MUST tener al menos tres puntos distintos, superficie positiva y
  no presentar autocruces.
- **FR-022**: La geometría de un sector MUST permanecer dentro de su parcela antes de confirmarse.
- **FR-023**: La geometría confirmada MUST permanecer inmutable durante visualización, navegación,
  selección y gestos normales del mapa.
- **FR-024**: Modificar una geometría MUST requerir entrar en un modo de edición explícito, mostrar
  el estado de edición y ofrecer confirmar o cancelar.
- **FR-025**: Confirmar una edición MUST actualizar geometría y superficie; cancelar MUST conservar
  exactamente la última versión confirmada.
- **FR-026**: El agricultor MUST poder utilizar la ubicación del dispositivo con permiso y disponer
  de una alternativa manual cuando el permiso o la señal no estén disponibles.
- **FR-027**: La falta de mapa remoto MUST NOT ocultar geometrías guardadas, la lista de sectores ni
  las acciones locales que no dependan del mapa.
- **FR-028**: Toda operación dependiente de sector MUST mostrar y conservar la parcela y el sector
  seleccionados antes de guardar.

#### Seasons and Crops

- **FR-029**: El agricultor MUST poder crear, consultar, editar y cerrar temporadas agrícolas con
  nombre o identificación, periodo y estado.
- **FR-030**: Cada sector MUST conservar sus temporadas históricas, vigentes y planificadas sin que
  una nueva temporada reescriba otra.
- **FR-031**: El agricultor MUST poder asociar un cultivo a un sector dentro de una temporada con
  una fecha efectiva.
- **FR-032**: Un sector MUST tener como máximo una asignación de cultivo vigente para una fecha
  determinada.
- **FR-033**: Rotar un cultivo MUST finalizar la asignación anterior y crear una nueva desde la
  fecha efectiva sin mover registros históricos.
- **FR-034**: El agricultor MUST poder intercambiar los cultivos de dos sectores para una fecha
  efectiva conservando el historial individual de ambos.
- **FR-035**: Una asignación planificada MUST NOT cambiar el cultivo actual antes de su fecha
  efectiva.
- **FR-036**: El sistema MUST incluir un catálogo inicial de cultivos utilizable sin conexión.
- **FR-037**: El agricultor MUST poder crear y editar cultivos personalizados con al menos nombre e
  información descriptiva básica.
- **FR-038**: Un cultivo personalizado MUST participar en asignaciones, labores, riego, producción e
  historial igual que uno del catálogo inicial.
- **FR-039**: Un cultivo personalizado referenciado por historial MAY archivarse, pero MUST NOT
  eliminarse de los eventos donde fue utilizado.

#### Structured Work and Production

- **FR-040**: El sistema MUST permitir registrar labores de riego, fertilización, fitosanitarios,
  siembra, poda, cosecha y otra labor.
- **FR-041**: Toda labor MUST conservar fecha y hora, parcela, sector, temporada, cultivo aplicable,
  tipo, observaciones y estado de respaldo.
- **FR-042**: Cada tipo de labor MUST solicitar únicamente los datos pertinentes y MUST identificar
  claramente los campos obligatorios y sus unidades.
- **FR-043**: “Otra labor” MUST requerir una descripción que permita comprender el trabajo
  realizado.
- **FR-044**: Una labor válida MUST quedar disponible inmediatamente después del guardado local,
  incluso sin conexión.
- **FR-045**: Editar una labor MUST conservar relaciones históricas coherentes y advertir antes de
  cambiar fecha, sector, temporada o cultivo.
- **FR-046**: Una cosecha MUST permitir registrar cantidad positiva, unidad, calidad opcional y
  observaciones como producción del sector, cultivo y temporada.
- **FR-047**: Guardar una cosecha como labor y producción MUST mostrar un único evento comprensible
  en el historial, sin duplicar el resultado productivo.
- **FR-048**: Valores inválidos MUST impedir el guardado sin borrar los demás datos ingresados.

#### Drip Irrigation

- **FR-049**: Cada sector MUST poder conservar una configuración permanente de riego por goteo.
- **FR-050**: La configuración MUST incluir cantidad de plantas, cantidad o distribución de
  goteros, caudal y los demás parámetros exigidos por la regla agronómica aprobada.
- **FR-051**: La configuración de goteo MUST permanecer disponible offline y entre reaperturas.
- **FR-052**: El cálculo de 002 MUST producir recomendaciones únicamente para riego por goteo; otros
  tipos MAY seguir registrándose cuando 001 lo permita, sin recibir una recomendación avanzada.
- **FR-053**: Las mismas entradas y la misma versión de regla MUST producir el mismo resultado
  dentro de una tolerancia declarada.
- **FR-054**: El resultado MUST mostrar tiempo recomendado, volumen recomendado, unidades y una
  explicación breve de las entradas principales y limitaciones.
- **FR-055**: El cálculo MUST NOT depender de un chatbot ni de contenido generativo.
- **FR-056**: Entradas faltantes, no positivas o fuera de rango MUST impedir una recomendación
  utilizable y señalar qué debe corregirse.
- **FR-057**: La falta de clima actual MUST NOT impedir el cálculo cuando las entradas locales
  aprobadas sean suficientes; el resultado MUST declarar esa limitación.
- **FR-058**: Al registrar un riego realizado, el sistema MUST conservar la configuración, entradas,
  resultado, fecha y contexto utilizados.
- **FR-059**: Cambiar la configuración actual MUST NOT recalcular ni modificar riegos históricos.

#### Sector History

- **FR-060**: Cada sector MUST ofrecer un historial unificado de temporadas, asignaciones de
  cultivo, labores, riegos y producción.
- **FR-061**: El historial MUST ordenar eventos cronológicamente y permitir agruparlos por temporada
  sin ocultar eventos recientes.
- **FR-062**: El agricultor MUST poder limitar el historial por temporada, cultivo, tipo de evento y
  rango de fechas.
- **FR-063**: Cada evento MUST conservar el cultivo y la temporada aplicables al momento de ocurrir,
  aunque el contexto vigente cambie después.
- **FR-064**: Los eventos pendientes, con error o conflicto MUST aparecer sin esperar confirmación
  remota y mostrar su estado.
- **FR-065**: Un historial vacío MUST distinguir ausencia total de eventos de un filtro sin
  coincidencias.

#### Offline Operation and Reliable Backup

- **FR-066**: Parcelas, sectores, cultivos, temporadas, labores, riego, producción y recordatorios
  MUST poder crearse, consultarse y modificarse sin conexión cuando la operación sea local.
- **FR-067**: Todo guardado local confirmado MUST persistir después de cerrar y reabrir la
  aplicación.
- **FR-068**: El sistema MUST confirmar al agricultor el guardado local antes de depender del
  respaldo remoto.
- **FR-069**: Cada cambio local MUST distinguir al menos guardado local, pendiente, sincronizando,
  sincronizado, error y conflicto.
- **FR-070**: Un cambio MUST NOT marcarse como sincronizado hasta recibir confirmación real del
  servicio remoto.
- **FR-071**: Al recuperar conectividad, los cambios pendientes MUST reanudar su respaldo sin exigir
  volver a introducir los datos.
- **FR-072**: Reintentar un cambio MUST NOT crear duplicados de un cambio ya confirmado.
- **FR-073**: Una falla o interrupción MUST conservar el cambio como pendiente o error y ofrecer
  reintento.
- **FR-074**: Un conflicto MUST conservar las dos versiones y sus diferencias hasta una decisión
  explícita del agricultor.
- **FR-075**: Una eliminación local confirmada remotamente MUST NOT reaparecer por reintentos o por
  una versión remota anterior.
- **FR-076**: El agricultor MUST poder conocer la cantidad de pendientes, el último respaldo
  confirmado y los errores que requieren atención.
- **FR-077**: La caída de un servicio externo MUST afectar sólo la función dependiente y MUST NOT
  bloquear guardados ni consultas locales.
- **FR-078**: Un error de almacenamiento local MUST impedir mostrar éxito y MUST preservar el último
  estado válido.
- **FR-079**: Después de cerrar sesión, ningún dato privado local MUST quedar visible hasta una
  nueva autenticación válida.

#### Reminders, Weather, and AgroIA

- **FR-080**: El agricultor MUST poder crear, consultar, editar, completar y cancelar recordatorios
  con título, fecha, hora y contexto agrícola opcional.
- **FR-081**: Un recordatorio MUST conservarse y activarse localmente sin conexión cuando el
  dispositivo lo permita.
- **FR-082**: Denegar permisos de avisos MUST NOT impedir guardar o consultar recordatorios y MUST
  explicar la ausencia de notificación.
- **FR-083**: Los recordatorios pendientes MUST recuperar su programación después de reiniciar la
  aplicación o el dispositivo, dentro de las capacidades permitidas.
- **FR-084**: El sistema MUST mostrar información meteorológica y pronóstico con ubicación y momento
  de actualización cuando el servicio configurado esté disponible.
- **FR-085**: El agricultor MUST poder habilitar o deshabilitar alertas meteorológicas online para
  condiciones relevantes de la parcela activa.
- **FR-086**: Toda alerta meteorológica MUST identificar condición, parcela o ubicación aplicable,
  momento de actualización y carácter informativo.
- **FR-087**: Información antigua, incompleta o no disponible MUST identificarse y MUST NOT
  presentarse como una alerta vigente.
- **FR-088**: AgroIA MUST responder preguntas agrícolas generales como orientación consultiva.
- **FR-089**: AgroIA MUST NOT incorporar automáticamente datos privados de parcelas, sectores,
  cultivos, historial, riego o producción.
- **FR-090**: AgroIA MUST NOT calcular riego, modificar datos, ejecutar acciones, analizar
  fotografías ni presentarse como diagnóstico profesional.
- **FR-091**: Sin conexión, una consulta nueva MUST mostrar que requiere conectividad y MUST
  conservar el texto para un reintento controlado.
- **FR-092**: Un reintento del chatbot MUST NOT duplicar el mensaje del agricultor ni una respuesta
  ya confirmada.

#### Observable UX and Scope Restrictions

- **FR-093**: Las funciones principales MUST ser accesibles mediante navegación visible conforme a
  `master.md` y MUST NOT depender de rutas ocultas.
- **FR-094**: Las vistas y formularios MUST mostrar parcela, sector, cultivo y temporada activos
  cuando esos datos determinen dónde se guardará una operación.
- **FR-095**: Los estados offline y de respaldo MUST comunicarse con texto e icono además de color.
- **FR-096**: Los mapas MUST ofrecer una lista o alternativa textual equivalente para accesibilidad
  y para fallas del mapa remoto.
- **FR-097**: Los formularios MUST identificar errores junto a los campos, conservar valores válidos
  y ofrecer recuperación después de un fallo.
- **FR-098**: El Módulo 002 MUST NOT incorporar aplicación web, panel administrativo, IoT o sensores
  automáticos, fertilidad calculada, IA contextual, análisis fotográfico, automatización física ni
  recomendaciones avanzadas para otros tipos de riego.

### Requirement Acceptance Coverage

- **FR-001–FR-005**: límite incremental, revisión de regresión y SC-017.
- **FR-006–FR-013**: User Story 1, primeros cuatro casos límite, SC-001 y SC-002.
- **FR-014–FR-028**: User Story 2, casos límite territoriales, SC-003, SC-004, SC-011, SC-013 y
  SC-016.
- **FR-029–FR-039**: User Story 3, casos límite de temporadas y cultivos, SC-005 y SC-010.
- **FR-040–FR-048**: User Story 4, casos límite de labores y producción, SC-006, SC-007, SC-010 y
  SC-011.
- **FR-049–FR-059**: User Story 5, casos límite de configuración y reglas, y SC-009.
- **FR-060–FR-065**: User Story 6, estados vacíos y SC-010.
- **FR-066–FR-079**: User Story 7, casos límite de persistencia y respaldo, SC-007, SC-008 y SC-013.
- **FR-080–FR-092**: User Stories 8 y 9, casos límite de avisos y chatbot, SC-012, SC-013 y SC-014.
- **FR-093–FR-098**: todas las historias y SC-011, SC-013, SC-016 y SC-017.

### Key Entities *(include if feature involves data)*

- **Agricultor**: Único propietario con identidad remota y relación exclusiva con sus datos.
- **Sesión local protegida**: Acceso previamente autorizado que puede mantenerse o desbloquearse
  localmente, y queda invalidado al cerrar sesión.
- **Parcela**: Unidad territorial administrada por el agricultor; una se mantiene como contexto
  activo.
- **Sector**: Subdivisión poligonal libre y estable dentro de una parcela, con superficie y nombre.
- **Temporada**: Periodo agrícola planificado, activo o cerrado que agrupa asignaciones y eventos.
- **Cultivo**: Entrada inicial o personalizada utilizable en asignaciones y registros.
- **Asignación de cultivo**: Relación temporal entre sector, cultivo y temporada con fecha efectiva.
- **Labor**: Evento agrícola estructurado con tipo, contexto temporal y territorial, datos propios y
  estado de respaldo.
- **Producción**: Resultado de cosecha con cantidad, unidad, calidad opcional y relaciones
  históricas.
- **Configuración de goteo**: Parámetros permanentes y reutilizables de un sector para calcular
  riego.
- **Recomendación de riego**: Resultado determinista con entradas, versión de regla, tiempo,
  volumen, unidades, explicación y limitaciones.
- **Riego realizado**: Evento que conserva lo ejecutado y la recomendación o configuración
  utilizada.
- **Recordatorio**: Aviso local con fecha, hora, estado y contexto agrícola opcional.
- **Alerta meteorológica**: Información online fechada y asociada a una ubicación o parcela.
- **Conversación AgroIA**: Mensajes generales sin contexto agrícola privado adjuntado
  automáticamente.
- **Cambio pendiente**: Creación, edición o eliminación local a la espera de confirmación remota.
- **Confirmación de respaldo**: Evidencia de que un cambio concreto fue aceptado remotamente.
- **Conflicto de sincronización**: Dos versiones incompatibles conservadas hasta una resolución.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Al menos 90 % de los agricultores de prueba inicia sesión y llega al contexto activo
  en menos de 2 minutos sin asistencia.
- **SC-002**: Al menos 90 % de quienes habilitan desbloqueo local retoma una sesión válida en menos
  de 15 segundos; 100 % de las pruebas posteriores a logout permanece bloqueado.
- **SC-003**: En una prueba con 3 parcelas y 10 sectores por parcela, 100 % de las vistas y
  guardados utiliza el contexto activo correcto sin mezclar registros.
- **SC-004**: El 100 % de 30 geometrías válidas conserva exactamente sus vértices confirmados tras
  cinco reaperturas y sólo cambia después de una edición explícita confirmada.
- **SC-005**: En 20 rotaciones o intercambios de prueba, 100 % de los eventos previos y posteriores
  conserva sector, cultivo y temporada correctos.
- **SC-006**: Al menos 95 % de los agricultores de prueba registra una labor válida offline en menos
  de 90 segundos en el primer intento.
- **SC-007**: Durante 24 horas sin conexión, con tres reinicios y cien cambios de los tipos
  incluidos, 100 % de los guardados confirmados localmente permanece disponible y trazable.
- **SC-008**: Al recuperar conexión, 100 % de cien cambios queda confirmado exactamente una vez o
  identificado como pendiente, error o conflicto; ninguno se pierde ni se marca antes de confirmar.
- **SC-009**: Para al menos 20 casos de referencia aprobados de riego por goteo, 100 % de los
  resultados se reproduce con las mismas entradas y muestra tiempo, volumen y explicación.
- **SC-010**: El 100 % de las consultas de prueba del historial devuelve sólo los eventos del sector
  y filtros elegidos, en orden cronológico y con relaciones históricas correctas.
- **SC-011**: Al menos 90 % de los agricultores identifica en menos de 5 segundos parcela, sector,
  cultivo, temporada y estado de respaldo antes de guardar una operación.
- **SC-012**: El 100 % de los recordatorios offline de una batería de 30 casos permanece tras
  reinicio y genera o explica el aviso correspondiente dentro de un minuto de la hora programada.
- **SC-013**: El 100 % de las fallas simuladas de mapa, clima, chatbot o respaldo deja disponibles
  los flujos locales que no dependen de ese servicio.
- **SC-014**: Al menos 90 % de los usuarios de prueba reconoce que las alertas meteorológicas y
  respuestas de AgroIA son informativas y no cálculos o instrucciones automáticas.
- **SC-015**: Con 20 parcelas, 200 sectores y 10.000 eventos textuales, 95 % de las consultas
  locales comunes presenta un resultado útil en menos de 2 segundos.
- **SC-016**: El 100 % de las pantallas y estados incluidos supera la revisión de navegación,
  legibilidad en terreno, accesibilidad y recuperación definida por `master.md`.
- **SC-017**: La revisión de alcance encuentra cero roles, organizaciones, MFA obligatorio, panel
  web, IoT, fertilidad calculada, IA contextual o riego avanzado implementado por 002.

## Dependencies

- La aceptación de mapas, ubicación, biometría, avisos del dispositivo, clima, chatbot y respaldo
  requiere que las capacidades o servicios existentes correspondientes estén disponibles en el
  entorno de prueba.
- Los proveedores concretos, credenciales cliente y configuración por ambiente se definirán en
  `plan.md` conforme a la constitución; esta especificación sólo fija resultados observables.
- La regla de cálculo de goteo, sus rangos, unidades, tolerancias y fuente agronómica deben quedar
  aprobados antes de implementar recomendaciones.
- La compatibilidad de datos existentes y cualquier transformación necesaria deben validarse
  durante planificación antes de modificar información local o remota.

## Assumptions

- El único actor con acceso es el agricultor propietario; no existen trabajadores, roles ni
  organizaciones en este incremento.
- El primer acceso de un dispositivo requiere conexión. Una sesión válida previa permite trabajo
  local protegido hasta que expire, sea revocada o el agricultor cierre sesión.
- El desbloqueo biométrico es voluntario y depende de capacidades seguras disponibles en el
  dispositivo; nunca sustituye el inicio de sesión remoto.
- Cerrar sesión bloquea los datos locales sin borrar cambios pendientes; una nueva autenticación
  válida permite recuperarlos y continuar su respaldo.
- Una parcela activa es una preferencia del agricultor y no elimina la posibilidad de administrar
  otras parcelas.
- Cada sector tiene como máximo un cultivo vigente por fecha. Las asignaciones pasadas y futuras se
  conservan como historial.
- Los cultivos iniciales concretos permanecen definidos por 001. Este incremento añade el flujo
  completo para cultivos personalizados sin redefinir todo el catálogo.
- Las reglas agronómicas de goteo no confirmadas se aíslan y no se presentan como científicamente
  validadas. Si no existe una regla aprobada, el cálculo no se considera listo.
- Mapa remoto, clima, chatbot, primer login y respaldo pueden requerir conexión; geometrías
  guardadas, datos agrícolas, historial, cálculos locales y recordatorios siguen disponibles sin
  esos servicios cuando técnicamente sea posible.
- Las alertas meteorológicas son opcionales, fechadas e informativas; no sustituyen fuentes
  oficiales ni bloquean decisiones o registros locales.
- AgroIA recibe únicamente el texto que el agricultor decide enviar y no incorpora automáticamente
  contexto privado. Sus respuestas requieren verificación en terreno.
- Los avisos locales dependen de permisos y restricciones del dispositivo; denegar el permiso no
  elimina el recordatorio.
- La aplicación mantiene español latinoamericano, unidades métricas y las reglas visuales y de
  accesibilidad de `master.md`.
- Las decisiones de arquitectura, proveedores, almacenamiento, sincronización y configuración
  pertenecen a `plan.md` y no cambian los resultados exigidos por esta especificación.
