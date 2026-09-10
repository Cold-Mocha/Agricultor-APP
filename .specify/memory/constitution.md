<!--
Sync Impact Report
- Version change: 2.0.0 -> 2.1.0
- Bump rationale: MINOR because this amendment adds the material principle
  "Validez funcional por dominio y categoría" and establishes backend enforcement of operation
  compatibility while preserving the existing product, offline, integrity, security, UX, and
  delivery principles.
- Modified principles:
  - I. Funcionalidad antes que sobreingeniería -> strengthened individual-farmer simplicity and
    compatibility with the established modular monorepository.
  - II. Offline-First como comportamiento fundamental -> strengthened reliable local persistence,
    later Supabase backup, and deterministic recovery.
  - III. Desarrollo por flujos funcionales completos -> generalized beyond the completed module
    002 and reinforced end-to-end delivery.
  - IV. Modelo agrícola estable y extensible -> IV. Integridad histórica y autoridad del
    agricultor; preserved stable modeling while making historical integrity and farmer authority
    explicit.
  - V. Cálculos deterministas y verificables -> removed feature-specific irrigation parameters
    and retained only cross-cutting requirements for reproducible, sourced calculations.
  - VI. Integraciones simples y configurables -> VII. Integraciones auxiliares y degradables.
  - VII. Seguridad proporcional y experiencia práctica -> VIII. Seguridad proporcional.
  - VIII. UX orientada al trabajo agrícola -> IX. UX semitécnica orientada al trabajo agrícola.
  - IX. Calidad suficiente para evolucionar -> X. Calidad suficiente para evolucionar.
- Added principles:
  - VI. Validez funcional por dominio y categoría.
- Modified sections:
  - Base técnica y límites de la segunda etapa -> Base técnica y límites arquitectónicos; records
    the established /frontend and /backend Feature-Based Architecture and their contract boundary.
  - Flujo de especificación y entrega -> recognizes modules 001 and 002 as the existing baseline
    and defers module 003 feature details to its future specification.
- Removed sections: none.
- Deferred feature details: flow fields, phenological stages, soil texture, fertilization methods,
  bed creation, rotation behavior, form persistence, and any AI economic calculator belong to the
  future 003 specification and are intentionally not constitutionalized.
- Follow-up TODOs: none.
-->

# AgroCampo Constitution

## Core Principles

### I. Funcionalidad antes que sobreingeniería

AgroCampo MUST priorizar funcionalidades completas, utilizables y demostrables para un agricultor
individual sobre abstracciones anticipadas, patrones innecesarios, infraestructura empresarial o
refactorizaciones extensas. La solución MUST mantener un enfoque semitécnico: suficientemente
preciso para apoyar el trabajo agrícola sin exigir conocimientos especializados de software ni
ocultar al agricultor la información necesaria para decidir.

El código y la estructura existentes MUST reutilizarse cuando sean razonablemente mantenibles. Una
refactorización solo está justificada cuando corrige un defecto real, desbloquea una funcionalidad,
evita pérdida o inconsistencia de datos o elimina un impedimento concreto, y MUST limitarse a esa
causa. El proyecto MUST NOT reconstruir módulos completos, revertir el monorepositorio modular
vigente ni crear una arquitectura paralela para alcanzar una perfección teórica. Mientras el
producto atienda a un agricultor individual, capacidades multiempresa, roles empresariales e
infraestructura organizacional MUST permanecer fuera salvo cambio de alcance expresamente aprobado.

### II. Offline-First como comportamiento fundamental

Las funciones agrícolas principales MUST operar sin internet siempre que sea técnicamente posible.
La persistencia local MUST ser la fuente operativa para crear, consultar y modificar los datos del
dominio. Una operación local válida MUST persistir de forma confiable antes de depender de un
servicio remoto y MUST conservar el estado necesario para su posterior respaldo o sincronización.

Supabase MUST limitarse a autenticación, respaldo remoto, sincronización y servicios cloud
aprobados. La falta de conexión MUST degradar únicamente las capacidades que realmente la necesitan
y MUST NOT inutilizar los flujos locales. La interfaz MUST comunicar el estado offline y las
operaciones pendientes. Al recuperar conectividad, el sistema MUST evitar pérdida y duplicación de
datos y MUST aplicar una política de conflicto determinista, trazable y respetuosa de la autoridad
final del agricultor.

### III. Desarrollo por flujos funcionales completos

Una pantalla, tabla, ruta, repositorio, mock o prueba aislada MUST NOT considerarse por sí sola una
funcionalidad terminada. Cada incremento MUST cerrar, dentro de su alcance declarado, un flujo
vertical observable: presentación -> contrato -> reglas de dominio -> persistencia local ->
reapertura consistente -> respaldo, sincronización o degradación cuando corresponda. Los estados de
carga, vacío, error, offline y recuperación que afecten el flujo MUST formar parte de la entrega.

Las especificaciones, planes y tareas MUST priorizar profundidad funcional sobre cantidad de piezas
parciales. Cuando un flujo no pueda completarse dentro de un incremento, su límite y el
comportamiento realmente entregable MUST quedar declarados. Mocks, navegación incompleta o
persistencia temporal MUST NOT presentarse como una funcionalidad terminada.

### IV. Integridad histórica y autoridad del agricultor

El modelo agrícola MUST conservar relaciones estables entre el agricultor, sus parcelas, los
sectores, las unidades productivas y su historial. `Sector` MUST continuar como el concepto interno
territorial flexible; MAY admitir geometría y nombres libres. `Cuadrante` MAY utilizarse como nombre
visible, pero MUST NOT crear un concepto de dominio paralelo ni imponer una forma territorial
rígida.

Los cambios actuales MUST NOT destruir, trasladar ni reescribir implícitamente registros históricos.
Toda corrección o transición que afecte historial MUST conservar trazabilidad suficiente para
comprender qué cambió, cuándo y por qué. El agricultor MUST conservar la autoridad final sobre sus
datos y acciones: recomendaciones, automatizaciones e integraciones MAY asistir, pero MUST NOT
confirmar decisiones, alterar historia ni ejecutar acciones irreversibles en su nombre sin una regla
aprobada y una confirmación explícita cuando corresponda.

### V. Cálculos deterministas y verificables

Los cálculos agrícolas o económicos que influyan en una decisión MUST implementarse mediante código
o reglas deterministas, con entradas, unidades, supuestos y redondeos explícitos. Un resultado MUST
poder reproducirse con las mismas entradas y MUST ofrecer una explicación comprensible de los datos
y reglas principales utilizados.

La inteligencia artificial generativa MUST NOT inventar entradas, fórmulas, rendimientos ni
resultados críticos, y MUST NOT sustituir reglas de dominio validadas. Una regla no confirmada MUST
permanecer identificada, aislada y reemplazable y MUST NOT presentarse como científicamente validada
sin una fuente o validación aceptada. Los detalles de cada cálculo pertenecen a la especificación del
módulo que los introduzca.

### VI. Validez funcional por dominio y categoría

El backend MUST conocer el tipo o categoría de cada unidad productiva y MUST validar qué operaciones
son compatibles con su dominio antes de aceptarlas, persistirlas o sincronizarlas. El sistema MUST
NOT depender exclusivamente del frontend, de la visibilidad de un control ni de la navegación para
impedir una acción inválida. Los contratos MUST devolver un resultado de validación explícito y
comprensible cuando una operación no sea aplicable.

Compartir un `Sector` territorial MUST NOT hacer equivalentes los dominios productivos. Por ejemplo,
un sector vegetal MAY admitir riego, fertilización y labores fitosanitarias, mientras una unidad
apícola MUST utilizar su dominio especializado y MUST NOT recibir riego, fertilización vegetal ni
tratamientos agrícolas por el solo hecho de ocupar un `Sector`. Toda nueva categoría u operación
MUST declarar y probar su compatibilidad de dominio en el backend; el frontend MUST reflejar esas
reglas para guiar al usuario, pero no puede ser su única garantía.

### VII. Integraciones auxiliares y degradables

Supabase, proveedores cartográficos, clima, inteligencia artificial y cualquier API externa MUST
permanecer encapsulados detrás de contratos limitados a las necesidades reales del producto. Estas
integraciones MUST ser auxiliares: una falla, latencia, falta de credenciales o ausencia de conexión
MUST afectar solamente la capacidad dependiente y MUST ofrecer un estado comprensible sin corromper
datos ni bloquear funciones locales no relacionadas.

URL, identificadores y claves cliente MUST obtenerse desde configuración o variables de entorno y
MUST NOT quedar incorporados como secretos en el código fuente. Las credenciales privadas MUST NOT
distribuirse en la aplicación cliente. Un proveedor externo MUST NOT convertirse en autoridad sobre
el historial, las reglas de dominio ni las decisiones finales del agricultor.

### VIII. Seguridad proporcional

La autenticación remota MUST mantenerse mediante el mecanismo aprobado de Supabase, con controles
proporcionales a una aplicación destinada a un agricultor individual. El desbloqueo biométrico MAY
proteger el acceso local a una sesión válida, pero MUST NOT reemplazar la autenticación remota ni
crear una identidad independiente.

AgroCampo MUST impedir pérdida de datos, exposición accidental de credenciales privadas y acceso
local incorrecto después de cerrar sesión. El cierre de sesión MUST invalidar el acceso protegido y
una sesión posterior MUST requerir autenticación válida antes de exponer nuevamente datos locales.
Roles complejos, MFA obligatorio, cifrado personalizado y administración empresarial MUST NOT
introducirse sin un requisito y un modelo de amenaza aprobados.

### IX. UX semitécnica orientada al trabajo agrícola

La aplicación MUST ser sencilla, rápida y comprensible durante el trabajo en terreno, sin sacrificar
la precisión necesaria para decisiones informadas. Las funciones principales MUST ser alcanzables
mediante navegación visible. El contexto productivo activo, el estado offline y las operaciones
importantes MUST mostrarse con claridad suficiente para evitar registros en una unidad equivocada.

La presentación MUST usar lenguaje semitécnico comprensible, explicar validaciones relevantes y
evitar tanto jerga de implementación como simplificaciones que oculten unidades, supuestos o
consecuencias. `master.md` MUST continuar como autoridad visual y de interacción. Una diferencia
visual menor MAY aceptarse cuando no altere jerarquía, comprensión, accesibilidad ni flujo, pero una
función importante MUST NOT bloquearse por fidelidad meramente cosmética.

### X. Calidad suficiente para evolucionar

Todo comportamiento crítico nuevo MUST contar con pruebas proporcionales a su riesgo. La estrategia
MUST priorizar persistencia real, reglas y validaciones de dominio, cálculos, navegación funcional,
operaciones offline, sincronización, integridad histórica y regresiones que puedan causar pérdida o
inconsistencia de datos. Una corrección de un defecto crítico MUST incluir una prueba de regresión
cuando sea técnicamente razonable.

Las pruebas MUST verificar comportamiento observable y contratos relevantes; MUST NOT existir solo
para aumentar una métrica. Los criterios de aceptación MUST describir evidencia demostrable para el
usuario o para el estado persistido. La calidad es suficiente cuando reduce riesgo real y permite
evolucionar con confianza, no cuando maximiza cobertura o complejidad sin valor equivalente.

## Base técnica y límites arquitectónicos

- El producto de destino MUST continuar como aplicación Android desarrollada con Flutter y Dart.
  Los prototipos HTML MAY aportar evidencia visual o de flujo, pero MUST NOT definir arquitectura de
  producción ni introducir un módulo funcional paralelo.
- El monorepositorio modular vigente, separado en `/frontend` y `/backend`, MUST conservarse. Ambos
  paquetes MUST organizarse mediante Feature-Based Architecture y MUST evolucionar extendiendo sus
  módulos existentes, sin revertir la separación ni crear una segunda arquitectura competidora.
- `/frontend` MUST ser responsable de presentación, navegación, componentes visuales y estado de
  interfaz. La lógica de dominio, validación funcional, persistencia, sincronización y reglas de
  negocio MUST pertenecer al módulo correspondiente de `/backend`.
- Frontend y backend MUST permanecer desacoplados mediante contratos públicos, claros y verificables.
  El frontend MUST consumir únicamente la superficie pública aprobada del backend y MUST NOT importar
  implementaciones internas de persistencia, sincronización o infraestructura. El backend MUST NOT
  depender de presentación ni importar código del frontend.
- La implementación MUST evolucionar sobre la base aprobada de Flutter, Riverpod, `go_router`,
  Drift/SQLite y Supabase. Un cambio de tecnología o una reescritura MUST demostrar una limitación
  real y documentar la migración de datos, contratos y comportamiento.
- Las dependencias nuevas MUST responder a una necesidad funcional concreta, ser compatibles con
  Android y disponer de una estrategia razonable de operación offline o degradación.
- Los campos, formularios, catálogos, fórmulas y comportamientos particulares de una función
  pertenecen a su `spec.md`. MUST NOT fijarse en esta Constitución salvo que expresen una obligación
  transversal aplicable a todos los módulos.

## Flujo de especificación y entrega

`spec.md` MUST definir QUÉ comportamiento observable entrega cada incremento. `plan.md` MUST definir
CÓMO se integra con el código, los contratos y los datos existentes. `tasks.md` MUST convertir el
plan en trabajo ordenado, trazable y orientado a flujos. La implementación MUST ejecutar esos
artefactos sin ampliar alcance por conveniencia técnica. `master.md` MUST continuar como autoridad
UX/UI y esta Constitución MUST gobernar todas las decisiones transversales.

Los módulos 001 y 002 constituyen la base funcional y arquitectónica existente. Un módulo posterior,
incluido `003-agrocampo-functional-refinement`, MUST extender esa base, preservar sus componentes
válidos y evitar duplicar alcance o crear rutas arquitectónicas paralelas. La definición de campos,
etapas, clasificaciones agronómicas, métodos de trabajo, estructuras productivas específicas,
comportamiento de formularios y calculadoras pertenece a la especificación futura de 003 y MUST NOT
deducirse de esta Constitución.

Antes de planificar un cambio, el trabajo MUST clasificar las piezas relevantes como reutilizar,
corregir, extender o crear. Toda refactorización MUST enlazar una justificación admitida por el
Principio I. Las tareas MUST agruparse, siempre que sea viable, en cortes verticales que produzcan
comportamiento verificable. Una secuencia puramente por capas MUST indicar cómo y cuándo cierra el
flujo del usuario.

Un flujo solo MAY declararse completo cuando sus criterios aplicables demuestren presentación,
contratos, validación de dominio y categoría, persistencia local, reapertura consistente,
funcionamiento offline, respaldo o degradación cuando corresponda, manejo de estados relevantes y
pruebas proporcionales al riesgo. Las excepciones MUST quedar visibles en la especificación y MUST
NOT ocultarse como deuda implícita.

## Governance

Esta Constitución prevalece sobre guías, especificaciones, planes, tareas y decisiones técnicas que
la contradigan. Ante un conflicto, el artefacto dependiente MUST corregirse o la Constitución MUST
enmendarse antes de implementar el cambio. Una enmienda MUST incluir motivación, principios o
secciones afectados, impacto sobre artefactos existentes, necesidades de migración y aprobación
explícita del propietario del proyecto. También MUST actualizar el Sync Impact Report, la versión y
la fecha de última modificación.

El versionado de gobernanza MUST seguir Semantic Versioning: MAJOR para eliminar o redefinir de
forma incompatible un principio u obligación; MINOR para agregar un principio, sección o guía
material compatible; PATCH para aclaraciones que no cambien obligaciones. La fecha de ratificación
MUST conservar la adopción original y `Last Amended` MUST registrar la fecha de la última enmienda
material.

Cada especificación, plan, conjunto de tareas e implementación MUST realizar una comprobación
constitucional apropiada a su fase. Las revisiones MUST verificar simplicidad para el agricultor,
cierre de flujo, comportamiento offline, persistencia y respaldo confiables, integridad histórica,
autoridad del agricultor, validez por dominio y categoría en backend, separación contractual entre
frontend y backend, determinismo de cálculos, degradación de integraciones, seguridad proporcional,
coherencia con `master.md` y evidencia de pruebas. Una excepción MUST documentar alcance, motivo,
riesgo, duración y condición de eliminación; ninguna excepción implícita es válida.

**Version**: 2.1.0 | **Ratified**: 2026-08-27 | **Last Amended**: 2026-09-09
