# Feature Specification: AgroCampo Functional Refinement - Módulo 003

**Feature Branch**: No creada; no existe un hook `before_specify` configurado

**Created**: 2026-09-09

**Status**: Ready for Task Generation

**Input**: User description: "Transformar el prototipo funcional validado de AgroCampo en flujos
agrícolas reales, persistentes, coherentes y comprobables, reutilizando y refinando los módulos 001
y 002 sin rediseñar la aplicación ni definir todavía su implementación técnica."

## Purpose and Authority

El Módulo 003 completa y refina comportamientos agrícolas sobre la base vigente de los módulos 001
y 002. No crea otra aplicación, no reemplaza el núcleo existente y no convierte las simulaciones o
datos de demostración del prototipo HTML en arquitectura ni en límites del producto. Su propósito es
que cada acción incluida produzca un resultado real: validado para el dominio correspondiente,
guardado con todos sus datos, recuperable después de cerrar y reabrir la aplicación, visible en el
contexto e historial correctos y utilizable offline cuando no dependa inherentemente de un servicio
externo.

La autoridad de requisitos se aplica en este orden:

1. La Constitución de AgroCampo v2.1.0 gobierna todas las decisiones transversales.
2. El Módulo 002 gobierna sobre 001 únicamente en las modificaciones que declara de forma expresa;
   el resto de 001 permanece vigente.
3. El feedback validado del agricultor refina los flujos incluidos por 003 sin autorizar por sí solo
   una expansión no delimitada.
4. `jerarquía 01.md` y el prototipo HTML aportan evidencia de navegación y comportamiento esperado,
   pero sus estados en memoria, simulaciones, datos fijos y controles sin función no son requisitos.
5. `master.md` es autoridad exclusiva para UX/UI, accesibilidad y presentación; no puede
   contradecir reglas funcionales posteriores.

Ante el conflicto conocido de AgroIA, prevalece 002: el chatbot recibe únicamente el texto que el
agricultor decide enviar. Las referencias del prototipo o de `master.md` a contexto privado
automático no se restauran.

## Increment Classification

| Clasificación | Comportamientos de 001/002 | Resultado exigido por 003 |
|---|---|---|
| Reutilizar | Acceso del agricultor, parcelas, sectores, mapa, contexto activo, temporadas, cultivos, historial, operación offline, respaldo, conflictos, fotografías, recordatorios, clima, exportación y AgroIA general | Mantener sus contratos vigentes y evitar regresiones; 003 sólo cambia lo declarado en esta especificación |
| Completar | Guardados provenientes de Registrar, Suelo, Riego y labores especializadas; creación de nuevas áreas; consulta detallada del historial | Sustituir cualquier comportamiento parcial o simulado por un flujo confirmado, persistente y recuperable de extremo a extremo |
| Refinar | Categoría funcional estable del Sector, compatibilidad por dominio, cambios de cultivo, riego, fertilización, apicultura y conservación del contexto | Incorporar las reglas y datos definidos para el incremento sin romper historial ni mezclar dominios |
| Preservar fuera del gate | Capacidades vigentes no modificadas expresamente por 003 | Continuar disponibles conforme a 001/002, pero no ampliar su alcance ni convertir cada control visual del prototipo en funcionalidad nueva |

### Priority and Completion Gate

Las prioridades P1 y P2 indican el orden recomendado de ejecución y reducción de riesgo; no hacen
opcionales las historias. El Módulo 003 sólo puede declararse funcionalmente completo cuando las
User Stories 1–7 superen todos sus escenarios y requisitos aplicables. La User Story 8 conserva
prioridad P3 porque reúne integraciones auxiliares: sus reglas de privacidad, aislamiento de fallas
y no regresión son obligatorias cuando la integración está configurada, pero la disponibilidad de
un proveedor externo no puede bloquear la aceptación de los flujos agrícolas locales.

### Prototype Flow Traceability

Todo flujo o control visible descrito por `jerarquía 01.md` queda clasificado a continuación. Una
fila “Preservado” mantiene el comportamiento vigente de 001/002; “Completado por 003” forma parte del
gate funcional de este módulo; “Fuera de alcance” no genera una función nueva. No existe una cuarta
categoría implícita.

| Flujo visible del prototipo | Clasificación | Resolución verificable |
|---|---|---|
| Carga inicial e Inicio con resumen y accesos rápidos | Preservado desde 001/002 | Abre el contexto agrícola válido o un estado vacío accionable; clima ausente no bloquea acciones locales |
| Barra inferior: Inicio, Sectores, Registrar, AgroIA y Más | Preservado desde 001/002 | Mantiene destinos y propósito conforme a `master.md`; los destinos abren flujos reales, no estados simulados |
| Botón Volver y retornos después de guardar o cancelar | Preservado desde 001/002 | Respeta el origen lógico, conserva el contexto y protege datos no confirmados conforme a `master.md` |
| Lista de Sectores, tarjetas y selección de un Sector | Completado por 003 | Permite áreas reales sin límite de demostración y conserva Sector, categoría y selección tras reabrir |
| Vista reducida del mapa y resumen de historial en Sectores | Preservado desde 001/002 | Reflejan geometrías y eventos persistentes; sus elementos informativos no adquieren acciones no aprobadas |
| Mapa: dibujar, seleccionar y abrir un Sector | Completado por 003 | Crea geometría válida, permite entrar al detalle y conserva alternativa local/textual si falla el mapa remoto |
| Mapa: mover vértices o límites | Completado por 003 | Sólo modifica un borrador dentro de edición explícita; confirmar persiste y cancelar restaura exactamente la geometría previa |
| Detalle de Sector y sus acciones contextuales | Completado por 003 | Muestra categoría y contexto reales y ofrece únicamente operaciones compatibles, con validación independiente de la interfaz |
| Registrar y selector de Sector | Completado por 003 | Conserva contexto enlazado y todos los campos confirmados del tipo elegido; nunca guarda en un Sector cambiado silenciosamente |
| Medición de Suelo | Completado por 003 | Persiste indicadores, unidades, omisiones y contexto y los recupera en detalle e historial |
| Riego | Completado por 003 | Trata método y parámetros como borrador hasta confirmar; persiste la acción realizada, ofrece sólo la estimación matemática básica definida para goteo y conserva caudal, duración y presión cuando corresponda; la recomendación agronómica avanzada permanece no disponible sin una fórmula definida |
| Fertilización | Completado por 003 | Distingue Manual, Foliar y Fertirriego y conserva datos comunes, específicos y opcionales confirmados |
| Control de Enfermedades y Plagas | Completado por 003 | Conserva producto, objetivo, dosis/unidad, carencia aplicable y observaciones, sin recomendaciones químicas automáticas |
| Cultivo como tipo de LABOR | Completado por 003 | Conserva labor realizada, variedad, plantas afectadas, estado observado, fecha y contexto confirmados |
| Cosecha y producción | Completado por 003 | Conserva cantidad/unidad, calidad, destino, jornada y observaciones confirmadas y genera un solo evento histórico |
| Apicultura | Completado por 003 | Usa formularios e historial especializados y rechaza operaciones vegetales incompatibles |
| Otra labor | Completado por 003 | Conserva nombre, detalle, fecha y contexto sin heredar campos de otra especialización |
| Cambiar cultivo y rotación | Completado por 003 | Aplica fechas efectivas y conserva asignaciones y eventos históricos sin sustitución inmediata simulada |
| Historial desde Sector, Sectores o Más | Completado por 003 | Proyecta eventos persistentes del contexto correcto, con filtros, detalles y estado de respaldo |
| AgroIA desde barra o Sector | Preservado desde 002 | Conserva navegación y presentación, pero sólo envía texto elegido por el agricultor y no restaura contexto privado automático |
| Clima y alertas informativas | Preservado desde 001/002 | Muestran vigencia y degradación; no se crean alertas decorativas ni se bloquean flujos locales |
| Respaldo Excel desde Más | Preservado desde 001 | Genera la exportación real vigente; el toast simulado del HTML no define su comportamiento |
| Conexión y sincronización desde Más/Configuración | Preservado desde 002 | Muestra estado real, pendientes, errores y recuperación; el interruptor online/offline simulado no se replica |
| Perfil y edición de información ya exigida | Preservado desde 001/002 | Mantiene consulta y actualización del perfil dentro de su contrato vigente |
| Tema, Idioma, Ayuda/soporte, Contacto, Privacidad y animaciones estacionales sin requisito vigente | Fuera de alcance | Permanecen sin ampliación funcional en 003; su sola presencia visual no autoriza implementación |
| Edición aislada del icono del Sector | Fuera de alcance | No se convierte en gestión productiva; la categoría, cultivo e historial sólo cambian mediante flujos funcionales aprobados |
| Rutas desconocidas y fallback silencioso a Inicio | Fuera de alcance | No son un flujo de usuario aprobado ni un criterio de 003 |
| Calculadora predictiva de costos, rendimiento y margen | Fuera de alcance | Se difiere completamente a un módulo futuro; 003 no registra ni predice esta capacidad |

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Gestionar áreas según su dominio productivo (Priority: P1)

Como agricultor, quiero crear y seleccionar áreas productivas cuya categoría determine las
operaciones válidas para registrar trabajo sin aplicar accidentalmente una labor vegetal a
apicultura ni mezclar información entre sectores.

**Why this priority**: La categoría y el contexto son condiciones previas para que todos los
registros posteriores sean válidos y confiables.

**Independent Test**: Se puede probar creando offline un Sector vegetal y otro apícola,
dibujando y editando sus geometrías, reabriendo la aplicación e intentando registrar operaciones
válidas e inválidas en cada una. Categorías, geometrías y opciones correctas deben conservarse, y
ninguna solicitud incompatible debe producir un registro.

**Acceptance Scenarios**:

1. **Given** una parcela existente, **When** el agricultor crea un Sector y elige la categoría
   vegetal, **Then** el área queda disponible offline con su identidad y categoría
   y contexto persistentes.
2. **Given** un Sector de categoría apícola, **When** abre sus acciones, **Then** dispone de los
   flujos apícolas y no se le ofrecen como aplicables riego vegetal, fertilización vegetal ni
   tratamientos fitosanitarios agrícolas.
3. **Given** una solicitud directa de riego vegetal sobre un Sector apícola, **When** el sistema
   valida la operación, **Then** la rechaza con una explicación comprensible y no crea ni modifica
   datos.
4. **Given** un Sector presentado como “Cuadrante” o “platabanda”, **When** el agricultor cambia ese
   nombre visible, **Then** la identidad territorial y la categoría funcional permanecen
   consistentes.
5. **Given** las áreas guardadas sin conexión, **When** cierra y reabre la aplicación, **Then**
   reaparecen con la misma parcela, Sector y categoría.
6. **Given** una parcela activa, **When** dibuja un polígono válido para un nuevo Sector y confirma,
   **Then** la geometría y superficie quedan guardadas y reaparecen sin cambios después de cerrar y
   reabrir la aplicación.
7. **Given** una geometría confirmada, **When** entra explícitamente en edición, modifica vértices y
   cancela, **Then** se descarta el borrador y se conserva exactamente la geometría anterior.
8. **Given** una geometría confirmada, **When** entra en edición, modifica vértices válidos y
   confirma, **Then** la nueva versión queda persistente sin reescribir el contexto histórico.
9. **Given** un polígono abierto, autocruzado, sin superficie, con puntos insuficientes o fuera de
   la parcela, **When** intenta confirmarlo, **Then** se explica el error, no se reemplaza la última
   geometría válida y el borrador permanece corregible.
10. **Given** un Sector vegetal o apícola existente, **When** se intenta cambiar su categoría al
    otro dominio, **Then** la operación se rechaza, no cambia el Sector ni su historial y se explica
    que la conversión de dominio no forma parte de 003.

---

### User Story 2 - Conservar registros agrícolas completos (Priority: P1)

Como agricultor en terreno, quiero que cada formulario conserve todos los datos específicos que
confirmé para consultar después exactamente qué hice o medí, incluso si estaba offline.

**Why this priority**: Un registro reducido a tipo, fecha y observaciones no reemplaza el cuaderno
agrícola ni permite trazabilidad útil.

**Independent Test**: Se puede probar guardando offline una medición de suelo y varias labores con
campos específicos, cerrando la aplicación y verificando en sus detalles e historial que cada valor,
unidad y contexto coincide con lo confirmado.

**Acceptance Scenarios**:

1. **Given** un formulario de labor con datos comunes y específicos válidos, **When** el agricultor
   confirma el guardado, **Then** todos los valores ingresados quedan disponibles en el detalle y no
   se resumen únicamente como observaciones.
2. **Given** una medición de suelo con varios indicadores y algunos campos omitidos, **When** se
   guarda y se reabre la aplicación, **Then** cada indicador, unidad y omisión se conserva sin
   convertir campos ausentes en cero.
3. **Given** un valor inválido en un formulario, **When** intenta guardar, **Then** se identifica el
   error, no se crea el registro y se conservan los demás valores ingresados.
4. **Given** un registro válido guardado offline, **When** consulta inmediatamente el historial y
   después reinicia la aplicación, **Then** encuentra el mismo registro con todos sus datos y estado
   de respaldo.
5. **Given** un formulario abierto desde un Sector concreto, **When** cambia el contexto global
   antes de guardar, **Then** el sistema conserva y muestra el contexto original o exige una
   decisión explícita; nunca guarda silenciosamente en otro Sector.
6. **Given** un formulario fitosanitario válido, **When** confirma el registro, **Then** conserva
   producto, plaga o enfermedad objetivo, dosis y unidad, periodo de carencia cuando corresponda,
   observaciones y contexto, sin generar una recomendación química automática.
7. **Given** una labor de Cultivo o una Cosecha con sus datos específicos, **When** se guarda y se
   reabre la aplicación, **Then** todos los valores confirmados permanecen disponibles y la cosecha
   aparece como un único evento productivo.
8. **Given** una actividad no cubierta, **When** registra “Otra labor” con nombre y detalle,
   **Then** ambos se conservan junto con fecha y contexto sin campos heredados de otro tipo.

---

### User Story 3 - Cambiar cultivos sin alterar el pasado (Priority: P1)

Como agricultor, quiero crear nuevas áreas, asignar cultivos y gestionar cambios o rotaciones por
fecha para saber qué cultivo ocupó cada lugar y mantener intactos los registros de temporadas
anteriores.

**Why this priority**: La utilidad del historial depende de que un cambio actual no cambie el
significado de labores, riegos o cosechas previas.

**Independent Test**: Se puede probar creando dos temporadas, registrando actividad con el cultivo
inicial, programando un cambio, activándolo en su fecha y comprobando que los eventos anteriores y
posteriores conservan sus asociaciones originales.

**Acceptance Scenarios**:

1. **Given** un Sector sin cultivo vigente, **When** el agricultor asigna un cultivo y una temporada
   válidos, **Then** los nuevos registros utilizan ese contexto sin modificar otros Sectores.
2. **Given** una rotación futura, **When** todavía no llega su fecha efectiva, **Then** el cultivo
   vigente y los formularios no cambian anticipadamente.
3. **Given** una rotación que entra en vigor, **When** se crean nuevas labores, **Then** usan la
   nueva asignación y los eventos anteriores conservan cultivo y temporada originales.
4. **Given** dos cambios incompatibles o solapados, **When** el agricultor intenta confirmarlos,
   **Then** la operación se rechaza sin alterar la asignación vigente ni el historial.
5. **Given** un cultivo o área con historial, **When** deja de utilizarse, **Then** puede retirarse
   de nuevas selecciones sin desaparecer de eventos históricos.

---

### User Story 4 - Refinar y registrar el riego con reglas verificables (Priority: P1)

Como agricultor, quiero registrar el riego y obtener una estimación matemática reproducible con los
datos confirmados; una recomendación agronómica avanzada sólo debe aparecer cuando exista una
fórmula definida y versionada que declare sus entradas pertinentes.

**Why this priority**: El riego es una labor frecuente y sensible; una aproximación simulada o una
fórmula inventada puede inducir decisiones equivocadas.

**Independent Test**: Se puede probar automáticamente con una matriz representativa de valores
normales, límites, unidades y redondeos, repitiendo las mismas entradas offline y registrando
caudal, duración y presión cuando corresponda. Tras reiniciar, cada entrada, fórmula, resultado,
limitación y acción realizada debe permanecer íntegra.

**Acceptance Scenarios**:

1. **Given** un Sector vegetal y valores válidos de caudal y duración, **When** solicita la
   estimación básica de goteo, **Then** recibe el volumen calculado, unidades, entradas y operación
   matemática utilizada, sin que el resultado se presente como recomendación agronómica.
2. **Given** las mismas entradas y versión de fórmula, **When** repite el cálculo, **Then** obtiene
   exactamente el mismo resultado y redondeo.
3. **Given** clima vigente disponible para la ubicación, **When** la regla lo utiliza, **Then** el
   sistema incorpora esa lectura automáticamente e identifica su momento; no solicita al
   agricultor volver a escribirla.
4. **Given** clima ausente o antiguo, **When** las entradas locales definidas son suficientes,
   **Then** el cálculo continúa e identifica la limitación; si no son suficientes, no inventa datos
   ni entrega una recomendación utilizable.
5. **Given** una recomendación y un riego realizado, **When** el agricultor confirma el registro,
   **Then** se conservan por separado lo recomendado y lo realizado, junto con todas las entradas,
   incluidos caudal, duración y presión confirmados, además del contexto y la regla utilizados.
6. **Given** un Sector apícola o una recomendación avanzada sin fórmula disponible, **When** se
   solicita riego vegetal, **Then** se rechaza el dominio incompatible o se informa que la
   recomendación avanzada no está disponible, sin impedir un registro manual vegetal válido.
7. **Given** una configuración o registro de riego ya confirmado, **When** modifica método,
   caudal, duración o presión y cancela antes de guardar, **Then** los cambios se descartan y el
   último estado confirmado permanece intacto.

---

### User Story 5 - Registrar fertilización según el método aplicado (Priority: P2)

Como agricultor, quiero diferenciar fertilización Manual, Foliar y Fertirriego y conservar sus datos
pertinentes, pudiendo completar información técnica opcional más tarde cuando todavía no disponga de
ella.

**Why this priority**: El método cambia el significado del registro y los datos necesarios, pero el
agricultor no debe quedar bloqueado por cálculos opcionales o todavía no aprobados.

**Independent Test**: Se puede probar registrando offline una fertilización de cada método,
reabriendo la aplicación, completando posteriormente datos opcionales en una de ellas y comprobando
que las tres mantienen método, producto, dosis, unidades, contexto y trazabilidad de la corrección.

**Acceptance Scenarios**:

1. **Given** un Sector vegetal, **When** el agricultor registra fertilización Manual, Foliar o
   Fertirriego, **Then** el método elegido, producto, dosis, unidad, fecha, contexto y observaciones
   quedan persistentes.
2. **Given** un método seleccionado, **When** abre el formulario, **Then** sólo se exigen los datos
   aplicables y no se fuerzan campos propios de otro método.
3. **Given** que aún no dispone de un cálculo técnico opcional, **When** guarda los datos mínimos
   válidos, **Then** el registro queda confirmado sin presentar un cálculo inventado.
4. **Given** un registro incompleto únicamente en datos opcionales, **When** el agricultor los añade
   después, **Then** la actualización conserva el registro original, su contexto y la trazabilidad
   del cambio.
5. **Given** un Sector apícola, **When** se solicita fertilización vegetal por cualquier ruta,
   **Then** la operación se rechaza antes de guardar.

---

### User Story 6 - Trabajar con apicultura como dominio especializado (Priority: P2)

Como agricultor con colmenas, quiero registrar inspecciones, sanidad, alimentación y cosechas
apícolas con datos propios, sin tratarlas como cultivos ni recibir operaciones vegetales.

**Why this priority**: La apicultura comparte territorio e historial, pero sus labores y reglas no
son intercambiables con las del dominio vegetal.

**Independent Test**: Se puede probar creando un Sector apícola, registrando offline una inspección
y una cosecha, reiniciando y verificando el historial especializado; luego se intenta cada operación
vegetal prohibida y se comprueba que ninguna deja datos.

**Acceptance Scenarios**:

1. **Given** un Sector apícola, **When** registra una inspección válida, **Then** conserva fecha,
   tipo de tarea, cantidad de colmenas y los datos suministrados sobre reina, postura, sanidad,
   alimentación, alzas, responsable descriptivo, observaciones y fotografías.
2. **Given** una alimentación, intervención sanitaria o cosecha apícola, **When** se confirma
   offline, **Then** aparece una sola vez en el historial de esa unidad y permanece tras reiniciar.
3. **Given** un Sector vegetal, **When** se intenta guardar una revisión apícola, **Then** la
   incompatibilidad se explica y no se crea el registro.
4. **Given** un Sector apícola, **When** se intenta registrar riego, fertilización o tratamiento
   fitosanitario vegetal, **Then** cada operación se rechaza sin alterar el historial.
5. **Given** un responsable escrito en una revisión, **When** se guarda, **Then** se conserva como
   información descriptiva y no crea otra cuenta, trabajador ni rol.

---

### User Story 7 - Recuperar historial y respaldar sin perder datos (Priority: P2)

Como agricultor, quiero que todos los registros de 003 aparezcan inmediatamente en el historial y se
respalden al recuperar conexión sin perder campos, duplicarse ni cambiar de contexto.

**Why this priority**: La persistencia local sólo es confiable si el agricultor puede verificar sus
datos y el respaldo mantiene exactamente el mismo significado.

**Independent Test**: Se puede probar con una matriz automatizada representativa de registros
mixtos offline, reaperturas, filtros y recuperación tras una interrupción. Cada registro debe
seguir visible y terminar confirmado exactamente una vez o con un estado recuperable.

**Acceptance Scenarios**:

1. **Given** registros de varias categorías, Sectores, cultivos y temporadas, **When** aplica filtros,
   **Then** sólo aparecen eventos que cumplen el contexto y cada uno conserva sus datos específicos.
2. **Given** un registro local confirmado, **When** cierra y reabre la aplicación, **Then** permanece
   disponible con estado local, pendiente, error, conflicto o respaldado veraz.
3. **Given** una interrupción durante el respaldo, **When** vuelve a intentarse, **Then** no se pierde
   ni duplica ningún registro ya confirmado.
4. **Given** dos versiones incompatibles, **When** se detecta el conflicto, **Then** ambas se
   conservan hasta que el agricultor elige explícitamente cuál mantener.
5. **Given** una falla de almacenamiento local, **When** intenta guardar, **Then** no se muestra
   éxito y el último estado válido permanece intacto.

---

### User Story 8 - Usar ayudas externas sin depender de ellas (Priority: P3)

Como agricultor, quiero consultar clima y AgroIA como ayudas opcionales sin que sus fallas bloqueen
mi trabajo local ni que el chatbot reciba automáticamente mis datos privados.

**Why this priority**: Las integraciones aportan contexto, pero no pueden ser autoridad sobre los
registros ni los cálculos críticos.

**Independent Test**: Se puede probar interrumpiendo por separado clima, mapa, respaldo y AgroIA
mientras se crean y consultan registros locales; también se inspecciona una consulta al chatbot para
comprobar que sólo contiene el texto enviado por el agricultor.

**Acceptance Scenarios**:

1. **Given** clima o mapa remoto no disponible, **When** el agricultor abre un flujo local, **Then**
   puede continuar y se muestra una alternativa o limitación comprensible.
2. **Given** datos privados de parcelas e historial, **When** envía una pregunta a AgroIA, **Then**
   sólo se transmite el texto que decidió escribir y la respuesta no modifica registros.
3. **Given** una solicitud de cálculo crítico o acción agrícola, **When** AgroIA responde, **Then**
   se mantiene consultiva, no inventa cifras y no ejecuta la acción.
4. **Given** ausencia de conexión, **When** intenta consultar AgroIA, **Then** se informa la
   dependencia, se conserva el texto para un reintento explícito y los demás flujos siguen
   disponibles.

### Edge Cases

- Un Sector con categoría ausente o desconocida permanece legible, pero no acepta operaciones
  especializadas ni recibe una categoría inferida.
- Un identificador, enlace o ruta obsoleta que apunte a otra categoría no evita la validación de
  compatibilidad.
- Durante 003 la categoría de un Sector es estable después de su creación. Rotar o cambiar un
  cultivo no cambia el dominio; convertir un Sector vegetal en apícola o viceversa queda fuera de
  alcance y requerirá un flujo histórico específico en otro incremento.
- Dos Sectores pueden compartir el nombre visible “Cuadrante” o “platabanda”, pero deben seguir
  siendo distinguibles dentro de su parcela.
- Un formulario abierto conserva su contexto enlazado aunque cambie la selección global; cambiarlo
  exige confirmar, descartar o volver a enlazar los valores.
- Cerrar la aplicación antes de confirmar un formulario no crea un registro parcial ni muestra
  éxito; la durabilidad exigida comienza después de un guardado local confirmado.
- Un campo opcional omitido se conserva como ausente y no se interpreta como cero, “normal” ni
  “no aplica”.
- Una corrección con fecha histórica incompatible con cultivo, temporada o categoría se rechaza o
  exige resolver explícitamente el contexto antes de guardarse.
- Una rotación cancelada o reemplazada no altera el cultivo vigente ni elimina su trazabilidad.
- La falta de una regla agronómica aprobada permite registrar una labor realizada cuando sea válida,
  pero impide presentar una recomendación calculada como utilizable.
- La presión omitida cuando no corresponde se conserva como ausente y no como cero; si fue
  confirmada, debe reaparecer junto con caudal, duración y los demás parámetros del riego.
- Un cambio posterior de caudal, duración, presión, etapa, textura o configuración no recalcula
  riegos históricos.
- Clima sin ubicación, sin hora de actualización o demasiado antiguo no se presenta como dato actual.
- Una fertilización con método cambiado conserva únicamente los datos compatibles confirmados; los
  datos descartados requieren una advertencia antes de perderse.
- Completar más tarde datos opcionales de fertilización no cambia silenciosamente fecha, unidad
  Sector, categoría, cultivo ni temporada del registro original.
- Una cosecha apícola no se presenta como cosecha vegetal ni se incorpora a cálculos productivos
  vegetales.
- La falla de una integración durante el guardado no cambia un éxito local por un falso respaldo.
- Un reintento de AgroIA no duplica el mensaje del agricultor ni adjunta contexto privado.
- Los datos y cantidades demostrativos del HTML no imponen límites al número de parcelas, Sectores,
  categorías productivas, colmenas o registros.

## Requirements *(mandatory)*

### Functional Requirements

#### Increment Boundary and Preservation

- **FR-001**: El Módulo 003 MUST extender los módulos 001 y 002 y MUST NOT reconstruir AgroCampo,
  duplicar su arquitectura funcional ni redefinir capacidades no incluidas expresamente.
- **FR-002**: Los comportamientos válidos y datos existentes de 001/002 MUST permanecer disponibles;
  una refinación de 003 MUST preservar sus relaciones y significado histórico.
- **FR-003**: Inicio, Sectores, detalle de Sector, mapa, Registrar, Riego, Suelo, LABORES, Historial,
  AgroIA y los demás flujos vigentes MUST conservar su propósito y navegación reconocible conforme a
  `master.md`.
- **FR-004**: Un estado, toast, cambio en memoria o dato de demostración del prototipo MUST NOT
  considerarse evidencia de una funcionalidad terminada.
- **FR-005**: Un control puramente visual o sin comportamiento aprobado en 001/002 MUST NOT
  convertirse automáticamente en alcance de 003.
- **FR-006**: Capacidades existentes no refinadas por 003 MUST conservarse mediante verificación de
  regresión, sin ampliarse como parte de este incremento.
- **FR-007**: 003 MUST NOT incorporar rediseño visual, panel web, organizaciones, administración de
  trabajadores, IoT, sensores automáticos, automatización física, diagnósticos mediante imágenes ni
  calculadora predictiva de costos, rendimiento o margen; esta última se difiere completamente a un
  módulo futuro.

#### Productive Domain and Category Validity

- **FR-008**: Toda operación agrícola MUST resolverse contra un Sector identificado y su categoría
  persistida válida; el identificador territorial sin categoría válida MUST NOT determinar
  compatibilidad.
- **FR-009**: Cada categoría MUST declarar el conjunto de operaciones que admite y los datos
  pertinentes para cada operación.
- **FR-010**: La compatibilidad MUST validarse antes de aceptar, guardar o respaldar una operación,
  independientemente de la pantalla, ruta o punto de entrada que la solicite.
- **FR-011**: Ocultar o deshabilitar un control en la interfaz MUST guiar al agricultor, pero MUST
  NOT ser la única garantía contra operaciones incompatibles.
- **FR-012**: Una incompatibilidad MUST devolver una explicación comprensible, conservar los datos
  todavía válidos del formulario y MUST NOT producir cambios parciales.
- **FR-013**: Los Sectores vegetales MAY admitir riego, fertilización, tratamientos fitosanitarios,
  labores culturales, suelo, cosecha y otras operaciones vegetales compatibles.
- **FR-014**: Los Sectores apícolas MUST admitir sólo sus flujos especializados y los flujos comunes
  expresamente compatibles; MUST NOT admitir riego vegetal, fertilización vegetal ni tratamientos
  fitosanitarios agrícolas.
- **FR-015**: La categoría elegida al crear un Sector MUST permanecer estable durante 003. Cambiar
  cultivo o temporada MUST NOT cambiarla; convertir un Sector entre vegetal y apícola queda fuera
  de alcance y MUST requerir una especificación histórica posterior.

#### Areas and Bound Context

- **FR-016**: El agricultor MUST poder crear nuevas áreas productivas sin un límite derivado del
  prototipo y utilizarlas después de un guardado local confirmado.
- **FR-017**: `Sector` MUST mantenerse como concepto territorial interno flexible; “Cuadrante” y
  “platabanda” MAY utilizarse como nombres visibles sin crear entidades incompatibles.
- **FR-018**: Cada Sector MUST conservar identidad, parcela, categoría, nombre visible y estado
  necesarios para validar sus operaciones.
- **FR-019**: Un formulario contextual MUST mostrar y conservar la parcela, Sector, categoría,
  temporada y cultivo aplicables antes de guardar.
- **FR-020**: Abrir un formulario MUST enlazar su contexto inicial; un cambio global posterior MUST
  conservar ese contexto o exigir confirmar, descartar o volver a enlazar el formulario.
- **FR-021**: El sistema MUST NOT elegir silenciosamente el primer Sector ni una categoría de
  fallback cuando la selección sea inexistente o ambigua.
- **FR-022**: El contexto y la categoría confirmados MUST permanecer disponibles después de cerrar y
  reabrir la aplicación.

#### Complete Agricultural Records

- **FR-023**: Cada tipo de LABOR o medición MUST presentar únicamente sus datos comunes y
  especializados pertinentes, identificando campos obligatorios, opcionales y unidades.
- **FR-024**: Un guardado confirmado MUST conservar todos los valores específicos ingresados y MUST
  NOT reducir el registro a tipo, fecha y observaciones.
- **FR-025**: Los campos omitidos MUST distinguirse de cero, falso, “normal” y “no aplica”.
- **FR-026**: Los valores inválidos MUST impedir el guardado, identificar el campo y conservar los
  demás valores ingresados.
- **FR-027**: El detalle y el historial MUST permitir recuperar los datos específicos confirmados,
  sus unidades y el contexto histórico.
- **FR-028**: Una corrección MUST ser explícita y trazable y MUST NOT cambiar silenciosamente fecha,
  Sector, categoría, cultivo o temporada.
- **FR-029**: Una falla de almacenamiento MUST impedir mostrar éxito y MUST preservar el último
  estado válido.
- **FR-030**: “Otra labor” MUST exigir un nombre o descripción suficiente y MUST conservarse con la
  misma trazabilidad que las labores tipificadas, sin heredar campos incompatibles.
- **FR-031**: Una medición de suelo MUST conservar cada indicador confirmado, su unidad, fecha,
  Sector vegetal, cultivo y temporada aplicables, además del estado de respaldo.

#### Seasons, Crops, and Historical Integrity

- **FR-032**: El agricultor MUST poder asignar cultivos a Sectores vegetales por temporada y fecha
  efectiva, utilizando el catálogo vigente o un cultivo personalizado válido.
- **FR-033**: Una nueva asignación, rotación o intercambio MUST finalizar o planificar las
  asignaciones afectadas sin solaparlas ni mover eventos históricos.
- **FR-034**: Una rotación planificada MUST NOT cambiar el cultivo vigente antes de su fecha
  efectiva.
- **FR-035**: Cada evento MUST conservar el Sector, categoría, cultivo y temporada que eran
  aplicables cuando ocurrió, aunque el contexto actual cambie. Durante 003 la categoría se toma del
  `Sector` estable y se guarda en el snapshot del evento, sin periodos de dominio separados.
- **FR-036**: Un cultivo, temporada o Sector con historial MAY retirarse de nuevas
  selecciones, pero MUST NOT desaparecer de registros históricos.
- **FR-037**: Crear una nueva área o cambiar su cultivo MUST funcionar offline y aparecer en el
  historial inmediatamente después del guardado local.

#### Irrigation Refinement

- **FR-038**: El registro de riego vegetal MUST conservar método, fecha, duración, caudal, presión
  cuando corresponda, volumen aplicado o estimado y todos los demás parámetros y datos contextuales
  confirmados.
- **FR-039**: Los métodos de riego vigentes en 001 MAY continuar registrándose, pero 003 MUST NOT
  inventar recomendaciones agronómicas avanzadas para un método sin fórmula definida.
- **FR-040**: Para goteo, 003 MUST ofrecer como estimación matemática básica el volumen derivado de
  caudal total y duración mediante una fórmula determinista, visible y comprobable. Esta estimación
  MUST NOT presentarse como recomendación agronómica ni requerir aprobación humana externa.
- **FR-041**: Una recomendación agronómica avanzada MUST incorporar caudal y duración, MUST
  incorporar presión cuando su fórmula la declare pertinente y MUST incorporar etapa de crecimiento
  y textura de suelo únicamente cuando esa fórmula las declare aplicables.
- **FR-042**: Los formularios MUST solicitar al agricultor únicamente entradas que no puedan
  obtenerse de forma confiable desde datos ya confirmados o una fuente disponible.
- **FR-043**: Cuando exista clima vigente y una fórmula avanzada lo use, el sistema MUST incorporarlo
  automáticamente, mostrar su momento y permitir reconocer que fue utilizado.
- **FR-044**: La ausencia o antigüedad del clima MUST NOT provocar datos inventados; una fórmula
  avanzada MAY continuar sólo si sus entradas locales definidas son suficientes y MUST explicar la
  limitación. La estimación matemática básica no depende del clima.
- **FR-045**: Una recomendación agronómica avanzada utilizable MUST depender de una fórmula,
  versión, fuente, rangos y casos automatizados de referencia definidos. Sin esa evidencia MUST
  mostrarse como no disponible; 003 MUST NOT exigir firma, reviewer ni aprobación externa para
  implementar o probar la estimación matemática básica.
- **FR-046**: Las mismas entradas y versión de fórmula MUST producir el mismo resultado dentro de la
  tolerancia declarada, sin intervención generativa.
- **FR-047**: La estimación básica MUST mostrar volumen, unidades, entradas y fórmula; una
  recomendación avanzada disponible MUST mostrar además tiempo, supuestos, advertencias y versión
  de regla en lenguaje comprensible.
- **FR-048**: Confirmar un riego MUST conservar lo realizado y, si se utilizó, la recomendación
  completa con sus entradas, incluidos caudal, duración y presión confirmados, resultado, clima
  aplicado, contexto y regla.
- **FR-049**: Modificar después caudal, duración, presión, etapa, textura, configuración o regla
  MUST NOT recalcular ni alterar un riego histórico.

#### Fertilization Refinement

- **FR-050**: La fertilización vegetal MUST distinguir los métodos Manual, Foliar y Fertirriego.
- **FR-051**: Todo registro de fertilización MUST conservar como mínimo método, producto, dosis,
  unidad, fecha, Sector, categoría, cultivo, temporada y observaciones aplicables.
- **FR-052**: Cada método MUST exigir sólo sus datos pertinentes y MUST NOT forzar datos técnicos o
  cálculos de otro método.
- **FR-053**: Los datos o cálculos técnicos declarados opcionales MAY omitirse sin impedir un
  registro mínimo válido.
- **FR-054**: El agricultor MUST poder completar posteriormente datos opcionales mediante una
  corrección explícita que conserve trazabilidad y contexto histórico.
- **FR-055**: Si se conserva un cálculo de fertilización, el registro MUST incluir entradas,
  unidades, resultado, supuestos y regla utilizada.
- **FR-056**: Sin una regla definida y versionada, el sistema MUST permitir el registro manual válido, pero MUST
  NOT inventar una dosis, recomendación ni resultado.
- **FR-057**: Fertirriego MUST conservar su identidad como método combinado y MAY enlazar el riego
  relacionado cuando el agricultor lo seleccione; esa relación MUST NOT alterar el riego original.

#### Specialized Apiary Domain

- **FR-058**: Un Sector apícola MUST conservar sus propios registros de colmenas, inspecciones,
  sanidad, alimentación y cosecha.
- **FR-059**: Una inspección apícola MUST conservar fecha, tipo de tarea, cantidad de colmenas y los
  datos suministrados sobre reina, postura, sanidad, alimentación, plagas, alzas, responsable
  descriptivo, observaciones y fotografías.
- **FR-060**: Alimentaciones, intervenciones sanitarias y cosechas apícolas MUST conservar los datos
  propios de su tipo y MUST NOT presentarse como labores o producción vegetal.
- **FR-061**: Todos los registros apícolas válidos MUST poder guardarse y consultarse offline y
  aparecer en el historial del Sector correcto.
- **FR-062**: Los formularios apícolas MUST NOT mostrar ni exigir caudal, textura de suelo,
  fertilización vegetal ni otros datos exclusivos del dominio vegetal.
- **FR-063**: El responsable informado en una revisión MUST permanecer como dato descriptivo y MUST
  NOT crear un usuario, trabajador, rol u organización.

#### History, Offline Continuity, and Backup

- **FR-064**: Todo guardado local confirmado de 003 MUST permanecer disponible después de cerrar y
  reabrir la aplicación.
- **FR-065**: El historial MUST mostrar cada evento una sola vez, en orden estable, con sus datos
  específicos, contexto histórico y estado de respaldo.
- **FR-066**: El historial MUST permitir limitar resultados por parcela, Sector, categoría,
  temporada, cultivo, tipo y rango de fechas cuando sean aplicables.
- **FR-067**: Un registro MUST distinguir al menos guardado local, pendiente, sincronizando,
  respaldado, error y conflicto, sin equiparar guardado local con respaldo remoto.
- **FR-068**: Al recuperar conexión, los cambios pendientes MUST reanudar su respaldo sin volver a
  introducir datos y sin crear duplicados.
- **FR-069**: Una interrupción o falla externa MUST conservar el registro local y ofrecer
  recuperación; un conflicto MUST conservar ambas versiones hasta la decisión del agricultor.
- **FR-070**: Mapa, clima, AgroIA y respaldo remoto MUST degradarse de forma aislada y MUST NOT
  bloquear operaciones locales no dependientes.

#### AgroIA and External Assistance

- **FR-071**: AgroIA MUST recibir únicamente el texto que el agricultor decide enviar y los datos
  mínimos de operación que no revelen automáticamente parcela, Sector, cultivo, historial, riego,
  producción ni otra información privada.
- **FR-072**: AgroIA MUST permanecer consultiva y MUST NOT calcular resultados críticos, modificar
  datos, ejecutar acciones ni presentarse como diagnóstico profesional.
- **FR-073**: Sin conexión, una consulta nueva MUST explicar que requiere conectividad, conservar el
  texto para un reintento explícito y MUST NOT duplicar mensajes confirmados.
- **FR-074**: La información externa utilizada por una regla o mostrada al agricultor MUST indicar
  origen funcional, vigencia o momento de actualización y limitaciones relevantes.

#### Prototype Completion and Geometry

- **FR-075**: Cada flujo o control visible enumerado en `jerarquía 01.md` MUST tener una fila en
  Prototype Flow Traceability que lo clasifique como Completado por 003, Preservado desde 001/002 o
  Fuera de alcance, con un resultado verificable.
- **FR-076**: El agricultor MUST poder crear la geometría de una parcela o Sector dibujando puntos y
  límites, revisar el polígono resultante y confirmarlo o cancelarlo antes de afectar datos vigentes.
- **FR-077**: Una geometría confirmada MUST permanecer inmutable durante navegación, selección y
  gestos normales; cualquier cambio MUST requerir entrar en un modo de edición explícito que trabaje
  sobre un borrador.
- **FR-078**: Confirmar una creación o edición MUST rechazar puntos insuficientes o inválidos,
  polígonos abiertos, autocruces, superficie nula y Sectores fuera de su parcela, sin reemplazar la
  última geometría válida.
- **FR-079**: Confirmar una edición válida MUST conservar la nueva geometría y superficie después de
  cerrar y reabrir; cancelar MUST descartar el borrador y restaurar exactamente la última versión
  confirmada.

#### Inherited Register Types

- **FR-080**: Registrar MUST mantener los tipos heredados Suelo, Riego, Fertilización, Control de
  Enfermedades y Plagas, Cultivo, Cosecha, Apicultura y Otra labor, además de cualquier tipo vigente
  compatible de 001/002; cada tipo MUST conservar todos sus campos específicos confirmados.
- **FR-081**: Un registro de Control de Enfermedades y Plagas MUST conservar como mínimo producto,
  objetivo, plaga o enfermedad, dosis y unidad, periodo de carencia cuando corresponda,
  observaciones, fecha y contexto; MUST NOT generar recomendaciones químicas automáticas.
- **FR-082**: Una labor de Cultivo MUST conservar como mínimo labor realizada, variedad, plantas
  afectadas cuando se informe, estado observado del cultivo, fecha, observaciones y contexto.
- **FR-083**: Una Cosecha MUST conservar como mínimo cantidad y unidad, calidad, destino y jornada
  cuando se informen, fecha, observaciones y contexto, y MUST aparecer como un único evento de
  historial aunque también actualice producción.
- **FR-084**: Otra labor MUST conservar nombre descriptivo, detalle, fecha, observaciones y contexto
  y MUST NOT heredar campos ni validaciones de una especialización incompatible.

#### Completion Applicability

- **FR-085**: Las prioridades P1 y P2 MUST ordenar el trabajo, no reducir alcance; 003 MUST NOT
  declararse funcionalmente completo hasta que las User Stories 1–7 superen todos sus criterios
  aplicables.
- **FR-086**: La User Story 8 MAY ejecutarse después de los flujos centrales como P3, pero sus
  garantías de privacidad, no regresión y aislamiento de fallas MUST cumplirse para toda integración
  configurada; la indisponibilidad del proveedor externo no invalida un flujo local completo.
- **FR-087**: Cambiar en un formulario el tipo de labor, método de riego o cualquier parámetro MUST
  afectar sólo el borrador hasta una confirmación válida; cancelar o abandonar de forma confirmada
  MUST conservar el último estado persistente sin aplicar el cambio temporal del prototipo.

### Requirement Acceptance Coverage

- **FR-001–FR-007**: límite incremental, matriz de clasificación, alcance excluido y regresión de
  001/002.
- **FR-008–FR-015**: User Stories 1, 5 y 6; incompatibilidades directas y estabilidad de categoría.
- **FR-016–FR-022**: User Stories 1 y 2; creación de áreas, alias y contexto enlazado.
- **FR-023–FR-031**: User Story 2; campos específicos, medición de suelo, validación y reapertura.
- **FR-032–FR-037**: User Story 3; asignaciones, rotaciones, vigencia e historial.
- **FR-038–FR-049**: User Story 4; riego, estimación básica, clima condicional, determinismo y
  snapshot histórico.
- **FR-050–FR-057**: User Story 5; métodos, datos opcionales, correcciones y ausencia de fórmulas.
- **FR-058–FR-063**: User Story 6; especialización, registros apícolas y prohibiciones vegetales.
- **FR-064–FR-070**: User Story 7; persistencia, historial, respaldo, conflictos y degradación.
- **FR-071–FR-074**: User Story 8; privacidad, límites, reintento y vigencia de integraciones.
- Requirement **FR-075**: matriz completa de Prototype Flow Traceability y SC-017.
- **FR-076–FR-079**: User Story 1; creación, edición, validación, confirmación, cancelación y
  reapertura de geometrías.
- **FR-080–FR-084**: User Story 2 y las historias especializadas 4–6; cobertura completa de
  Registrar y persistencia de campos específicos.
- **FR-085–FR-087**: Priority and Completion Gate, User Stories 1–8 y protección de cambios no
  confirmados.

### Key Entities *(include if feature involves data)*

- **Agricultor**: Único propietario y autoridad final sobre datos, correcciones y conflictos.
- **Parcela**: Unidad territorial superior que agrupa Sectores y mantiene el contexto activo.
- **Sector**: Única identidad territorial y productiva de 003; conserva `sectorId`, parcela,
  geometría y categoría estable. “Cuadrante” o “platabanda” son nombres visibles, no entidades ni
  categorías funcionales.
- **Categoría de dominio del Sector**: Clasificación funcional estable durante 003, inicialmente
  vegetal o apícola, que determina qué operaciones y datos son válidos.
- **Temporada**: Periodo agrícola que agrupa asignaciones y eventos sin reescribir periodos previos.
- **Asignación de cultivo**: Relación efectiva entre un Sector vegetal, cultivo y temporada.
- **Labor**: Evento común con contexto histórico y datos especializados según tipo.
- **Medición de suelo**: Conjunto fechado de indicadores confirmados para un Sector vegetal.
- **Configuración de riego**: Datos reutilizables y versionados de un Sector vegetal.
- **Estimación básica de riego**: Resultado matemático determinista derivado de caudal y duración,
  diferenciado de una recomendación agronómica.
- **Recomendación avanzada de riego**: Resultado agronómico opcional que sólo existe con una fórmula
  definida, versionada y verificable.
- **Riego realizado**: Evento que distingue la acción ejecutada de una recomendación previa.
- **Fertilización**: Labor vegetal con método Manual, Foliar o Fertirriego, producto, dosis y datos
  opcionales trazables.
- **Registro apícola**: Inspección, sanidad, alimentación, cosecha u otro evento compatible con un
  Sector apícola.
- **Evento histórico**: Vista cronológica inmutable en significado, con contexto y detalles propios.
- **Cambio pendiente**: Operación local confirmada que aún no posee confirmación de respaldo.
- **Conflicto**: Versiones incompatibles conservadas hasta una resolución del agricultor.
- **Mensaje AgroIA**: Texto decidido por el agricultor y respuesta consultiva sin contexto privado
  adjuntado automáticamente.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: La prueba parametrizada de cada incompatibilidad definida en la matriz operación ×
  categoría, ejecutada por cada clase de entrada soportada, rechaza la operación sin crear raíz,
  especialización, outbox ni cambio remoto.
- **SC-002**: Los fixtures representativos de Sector vegetal, Sector apícola y categoría legada
  desconocida conservan `sectorId`, categoría y capacidades tras un round-trip real y reapertura.
- **SC-003**: Existe cobertura representativa por tipo de registro para campos obligatorios,
  opcionales presentes o ausentes y límites inválidos; cada guardado válido conserva exactamente
  valores, unidades, nulos y contexto después de reabrir.
- **SC-004**: La verificación automatizada de interfaz e integración demuestra, para cada familia de
  formulario, que parcela, Sector, categoría, cultivo y temporada aplicables son visibles antes de
  guardar; un contexto ausente, ambiguo o incompatible impide persistir y conserva el borrador.
- **SC-005**: Los casos parametrizados de asignación vigente, futura, cancelada, solapada y archivada
  conservan los snapshots de cultivo y temporada esperados sin cambiar la categoría del Sector.
- **SC-006**: Cada caso canónico de la estimación matemática básica reproduce exactamente volumen,
  unidades y redondeo; una recomendación avanzada ausente, incompleta o no aplicable no produce un
  resultado utilizable.
- **SC-007**: La matriz automatizada de Manual, Foliar y Fertirriego, con opcionales presentes,
  ausentes y corregidos, conserva método, valores y contexto sin inventar dosis.
- **SC-008**: Cada familia de evento apícola persiste una sola vez en el historial de su Sector y
  toda operación vegetal prohibida por la matriz es rechazada sin cambios parciales.
- **SC-009**: Un ciclo automatizado con almacenamiento real en archivo, escrituras mixtas offline,
  cierre abrupto, reapertura y avance controlado del reloj conserva cada guardado confirmado.
- **SC-010**: La inyección de fallas en envío, ACK y reintento verifica idempotencia para creación,
  edición y retiro; cada operación termina respaldada una vez o en un estado recuperable veraz.
- **SC-011**: En el perfil de carga representativo y versionado del proyecto, cada consulta común de
  contexto e historial produce el resultado correcto y el percentil 95 se mantiene bajo 2 segundos
  en el dispositivo Android de referencia.
- **SC-012**: Cada estado de falla definido para mapa, clima, AgroIA y respaldo mantiene disponibles
  los flujos locales no dependientes y comunica una alternativa o limitación.
- **SC-013**: Las pruebas de contrato comparan el payload saliente de AgroIA con el texto autorizado:
  ninguna solicitud adjunta contexto agrícola privado y ninguna respuesta puede mutar datos ni
  sustituir un cálculo crítico.
- **SC-014**: Pruebas automatizadas end-to-end recorren desde sus puntos de entrada documentados un
  registro representativo de labor general, suelo, riego, fertilización e inspección apícola; cada
  flujo confirma localmente una vez, reaparece en detalle e historial y conserva su contexto.
- **SC-015**: Los chequeos estructurales y de trazabilidad no encuentran rutas, módulos, contratos ni
  controles funcionales nuevos para las capacidades excluidas por FR-007.
- **SC-016**: Las clases representativas de geometría válida, limítrofe e inválida verifican
  round-trip exacto, confirmación, cancelación y preservación de la última geometría válida.
- **SC-017**: La comparación automatizada entre `jerarquía 01.md` y Prototype Flow Traceability
  demuestra igualdad de cobertura y una sola clasificación por flujo visible.
- **SC-018**: El gate automatizado de 003 demuestra que todos los escenarios y requisitos aplicables
  de las User Stories 1–7 superan su verificación antes de declarar completitud funcional.

## Dependencies

- Los módulos 001 y 002 y sus datos válidos están disponibles como línea base del incremento.
- Debe existir una fórmula agronómica definida, versionada, trazable y acompañada de casos
  automatizados de referencia antes de habilitar una recomendación avanzada. Esta dependencia no
  aplica a la estimación matemática básica de volumen.
- Clima, mapa, AgroIA y respaldo requieren sus servicios disponibles para las capacidades online;
  su ausencia no impide verificar los flujos locales.
- La aceptación visual y de interacción depende de `master.md`, sin que este documento reintroduzca
  el envío automático de contexto privado a AgroIA.

## Assumptions

- El único actor con acceso es el agricultor propietario; 003 no introduce trabajadores, roles ni
  organizaciones.
- El archivo solicitado como `jerarquía 01(1).md` corresponde al `jerarquía 01.md` disponible en
  el repositorio, cuyo contenido describe la navegación y limitaciones del prototipo.
- El feedback disponible en `conversaciónAgricultor.md` corresponde al documento de feedback
  mencionado en la solicitud, porque contiene los refinamientos de riego, fertilización,
  nuevas áreas, apicultura, simplicidad semitécnica y la propuesta de calculadora predictiva.
- La calculadora predictiva de costos, rendimiento y margen se difiere completamente a un módulo
  futuro; 003 no incorpora predicción ni un registro económico sustituto.
- Un guardado local confirmado es el punto desde el cual se exige durabilidad. Recuperar un
  formulario nunca confirmado después de un cierre forzado queda fuera de 003 salvo obligación
  previa compatible de 001/002.
- `Sector` permanece como territorio y contexto productivo único de 003. Toda operación
  especializada identifica `sectorId` y su categoría persistida; no existe `unitId` ni otra
  identidad 1:1 paralela.
- La categoría `crop|apiary` se elige al crear el Sector y permanece estable durante 003. Cambiar
  cultivo o temporada no cambia el dominio; convertirlo entre dominios queda para otro incremento.
- Las categorías iniciales que 003 necesita distinguir son vegetal y apícola; agregar ganadería u
  otros dominios queda fuera de este incremento.
- Los tipos de riego existentes pueden seguir registrándose. La estimación matemática básica se
  limita a goteo; una recomendación avanzada permanece no disponible sin fórmula definida.
- Los datos de etapa de crecimiento y textura de suelo se exigen únicamente cuando una fórmula
  avanzada definida los declara aplicables; no se inventan catálogos ni coeficientes.
- Los cálculos opcionales de fertilización no son requisito para guardar un registro manual válido y
  sólo pueden mostrarse como recomendación cuando exista una regla definida y versionada.
- Las sesiones posteriores con agricultores MAY aportar información de usabilidad, pero no son un
  gate de aceptación de 003 ni sustituyen las verificaciones automatizadas.
- Fotografías, recordatorios, exportación, perfil, seguridad y otras capacidades de 001/002 no
  modificadas continúan bajo sus requisitos vigentes.
- La aplicación mantiene español latinoamericano, unidades métricas, enfoque semitécnico y las
  reglas de accesibilidad y presentación de `master.md`.
