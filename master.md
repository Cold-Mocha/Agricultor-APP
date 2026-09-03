# AgroCampo Design System

**Estado:** fuente visual oficial para AgroCampo MVP Módulo 001  
**Plataforma objetivo:** Android con Flutter y Material 3  
**Evidencia visual auditada:** `agrocampo-highfi.html` y, para Physalis/Apicultura, `index.html`
**Tema oficial del MVP:** claro  
**Ámbito:** identidad, tokens, componentes, navegación, estados, pantallas y criterios de implementación visual. No define lógica de negocio ni amplía el alcance funcional.

**Límite de autoridad:** `master.md` no es un módulo funcional. La única fuente de requisitos es
`specs/001-agrocampo-android-mvp/spec.md`; este documento define exclusivamente cómo se presentan
los flujos que esa especificación ya autoriza.

**Regla obligatoria para el backlog:** toda tarea que cree o modifique UI, UX, componentes,
colores, layouts, navegación visual, estados o accesibilidad debe citar la sección concreta de
`master.md` que consumirá. Si la regla visual necesaria no existe, la tarea queda bloqueada hasta
actualizar y aprobar este Design System; no se permite inventar una variante en código.

Este documento formaliza el lenguaje visual ya presente en el prototipo de alta fidelidad. No reemplaza su identidad por una propuesta nueva. Cuando el HTML presenta un valor correcto y consistente, ese valor se conserva. Cuando presenta una brecha de accesibilidad, legibilidad o adaptación nativa, el documento registra el valor observado y establece una corrección canónica para Flutter.

La lectura de las reglas sigue tres etiquetas:

- **Extraído:** valor o patrón literalmente presente en el HTML.
- **Canónico:** regla que debe aplicar la implementación Flutter.
- **Corrección:** ajuste imprescindible que conserva la intención visual, pero resuelve una brecha comprobada.

En caso de discrepancia entre el prototipo HTML y este documento, prevalece la regla marcada como **Canónico** o **Corrección**. Cualquier cambio posterior de paleta, tipografía, forma, densidad o jerarquía debe actualizar primero este archivo.

## Brand Identity

### Esencia de marca

AgroCampo es una herramienta de trabajo agrícola personal que convierte información de terreno en decisiones claras. Su identidad combina tres ideas:

1. **Agricultura real:** cultivos, suelo, riego, clima, labores y temporadas son el centro de la interfaz.
2. **Tecnología cercana:** mapas, sincronización y AgroIA se presentan como ayudas comprensibles, no como complejidad técnica.
3. **Simplicidad operativa:** la persona usuaria debe reconocer el estado de su parcela y registrar una acción con pocas decisiones y sin depender de conectividad continua.

### Personalidad visual

- **Confiable:** bordes visibles, superficies blancas, información explícita y estados con texto.
- **Agrícola:** verde profundo como color rector, pictogramas de cultivo y fotografía aérea de la parcela.
- **Cálida:** acento amarillo cosecha, formas redondeadas y lenguaje directo.
- **Práctica:** jerarquías cortas, métricas grandes, acciones agrupadas y navegación inferior persistente.
- **Moderna sin exceso corporativo:** composición limpia y Material, sin estética financiera, industrial ni de ERP.
- **Serena:** sombras suaves y fondos claros; el diseño evita ruido, lujo artificial y efectos decorativos innecesarios.

### Sensación que debe transmitir

La interfaz debe sentirse como una libreta de campo ordenada, asistida por tecnología y preparada para condiciones reales. La persona usuaria debe percibir:

- control sobre sus registros;
- seguridad de que la información se guardó, incluso sin conexión;
- lectura rápida bajo presión o luz intensa;
- relación evidente entre parcela, cuadrante, cultivo y actividad;
- recomendaciones consultivas, nunca automáticas ni autoritarias;
- continuidad entre lo que observa en terreno y lo que ve en pantalla.

### Concepto visual

El sistema se construye sobre **superficies de campo delimitadas**. Las tarjetas blancas con borde verde suave representan unidades de información; los radios amplios evocan parcelas y contenedores físicos sin caer en una estética infantil. El verde identifica la marca y las acciones confiables; el amarillo aporta energía y señal de atención; los colores de cultivo sólo distinguen especies o cuadrantes.

### Principios de diseño

1. **Claridad antes que decoración.** Todo efecto visual debe mejorar jerarquía, estado o interacción.
2. **La parcela es el contexto.** Las pantallas operativas deben mantener visible el cuadrante o cultivo seleccionado.
3. **Offline es un estado normal.** Nunca debe comunicarse como pérdida automática de datos.
4. **Una acción primaria por pantalla.** Las acciones secundarias se subordinan visualmente.
5. **Información escaneable.** Etiqueta breve, valor prominente, unidad visible y contexto temporal cuando corresponda.
6. **Color más texto e icono.** Ningún estado depende sólo del color.
7. **Uso en terreno.** Contraste alto, blancos limpios, blancos táctiles amplios y tipografía resistente a luz solar.
8. **Consistencia sobre novedad.** Se reutilizan tokens y componentes; no se crean estilos aislados por pantalla.
9. **Tecnología explicable.** Sincronización, cálculo y AgroIA deben exponer estado, alcance y recuperación.
10. **Android primero.** Gestos, navegación, áreas seguras, semántica y feedback siguen convenciones Material.

### Voz visual y verbal

- Textos breves, concretos y en español.
- Verbos de acción al inicio: “Guardar medición”, “Ver historial”, “Cambiar cultivo”.
- Terminología agrícola consistente: **parcela** para el predio general y **cuadrante** para la subdivisión gestionada.
- Se muestran unidades junto al valor: °C, %, L/h, min, L, mS/cm.
- AgroIA usa lenguaje prudente: informa, sugiere verificar y evita asegurar resultados agronómicos.
- No se usan emojis como iconos estructurales.

## Color System

### Paleta principal extraída

| Token de origen | HEX | Rol canónico | Uso correcto | Uso incorrecto |
|---|---:|---|---|---|
| `brand` / `green` | `#2A6E54` | Marca, acción primaria, selección, icono activo | Botón primario, fondo de mensaje propio, pestaña activa, foco y elementos de marca | Grandes bloques de texto, estados de error o todos los iconos sin jerarquía |
| `brand-dark` | `#1F4B3A` | Texto de marca oscuro y contenido sobre amarillo | Títulos, texto sobre `accent` y `accent-soft`, bordes fuertes puntuales | Sustituir todo el texto principal o crear superficies extensas oscuras en el MVP claro |
| `brand-soft` | `#BFE1D0` | Verde suave de apoyo | Separadores destacados o ilustración de marca aprobada | Fondo de texto sin comprobar contraste; en el HTML está definido pero no utilizado |
| `accent` / `amber` | `#EDB240` | Acento cosecha y atención visual | Forma decorativa del hero, indicador gráfico sin texto, fondo con texto oscuro | Texto pequeño sobre blanco; su contraste es insuficiente |
| `accent-soft` | `#F6E4B7` | Contenedor secundario cálido | Estado pendiente o información temporal con texto `brand-dark` | Sustituir alertas de error o usar texto amarillo encima; en el HTML está definido pero no utilizado |
| `ink` | `#17372B` | Texto principal | Títulos, valores, contenido principal sobre blanco y superficies claras | Texto sobre fondos oscuros o uso como color de estado sin etiqueta |
| `muted` observado | `#638175` | Texto secundario legado | Referencia al prototipo y elementos decorativos no informativos | Texto normal en Flutter: da 4,26:1 sobre blanco y no alcanza AA |
| `muted-accessible` | `#587267` | Texto secundario canónico | Subtítulos, ayudas, metadatos y descripciones en Flutter | Valores críticos, errores o texto sobre superficies oscuras |
| `line` | `#B7DCCB` | Borde y divisor | Bordes de 1–1,5 dp, separadores, límites de tarjetas y campos | Texto, iconos informativos o único indicador de foco |
| `bg` | `#FFFFFF` | Fondo de aplicación | Lienzo general del tema claro | Distinguir tarjetas sólo por color; deben conservar borde o elevación |
| `card` | `#FFFFFF` | Superficie elevada | Tarjetas, campos, mensajes de AgroIA, navegación | Superponer tarjeta blanca sin borde sobre fondo blanco |
| `green-soft` | `#DDF4EA` | Contenedor de éxito/conexión | Estado conectado o sincronizado con texto verde | Advertencias o estados pendientes |
| `sky` | `#2563EB` | Identidad informativa y color de cultivo arándano | Elementos gráficos, identidad de cultivo o controles informativos aprobados | Reemplazar el verde primario; en CSS está definido pero no usado directamente |
| `sky-dark` | `#1D4ED8` | Texto e icono informativo | Contenido sobre `sky-soft`, iconos informativos | Texto de cuerpo sobre fondos oscuros |
| `sky-soft` | `#DBEAFE` | Contenedor informativo | Banners informativos, avatar y sincronización en progreso | Estados de éxito o error |
| `rose` | `#B9435B` | Error o acción destructiva | Fondo sólido con texto blanco, borde o icono de peligro | Texto normal sobre `rose-soft` sin oscurecerlo; esa combinación queda bajo 4,5:1 |
| `rose-soft` | `#FFE0E6` | Contenedor de error | Banner de error con texto `#7C1F2D` | Fondo decorativo de contenido neutro |
| `violet` | `#6657A6` | Categoría secundaria | Icono o texto sobre `violet-soft` para configuración/suelo cuando la semántica lo requiera | Estado global de conexión, éxito o error |
| `violet-soft` | `#E8E4FF` | Contenedor violeta | Fondo de categoría secundaria | Uso extendido que compita con la marca |
| `leaf` | `#3F7A50` | Verde alternativo reservado | Sólo tras aprobación explícita | Crear un segundo verde primario; actualmente está definido pero no usado |
| Lienzo del dispositivo | `#8FC2AA` | Sólo presentación web | Fondo exterior del marco de demostración HTML | Fondo de una pantalla Flutter; el marco de dispositivo no se implementa |

### Correcciones de contraste obligatorias

| Combinación | Contraste medido | Decisión |
|---|---:|---|
| Blanco sobre `brand` | 6,07:1 | Aprobada para texto normal y controles primarios |
| Blanco sobre `brand-dark` | 9,88:1 | Aprobada |
| `ink` sobre blanco | 12,98:1 | Aprobada y preferida para lectura en terreno |
| `muted` `#638175` sobre blanco | 4,26:1 | **Corregir:** Flutter usa `#587267`, que alcanza 5,23:1 |
| `brand` sobre `green-soft` | 5,27:1 | Aprobada para conectado/sincronizado |
| `#92400E` sobre `amber-soft` | 6,30:1 | Aprobada para offline/advertencia |
| `#7C1F2D` sobre `rose-soft` | 8,16:1 | Aprobada para error |
| `sky-dark` sobre `sky-soft` | 5,49:1 | Aprobada para información/sincronización |
| `violet` sobre `violet-soft` | 4,88:1 | Aprobada para texto normal |
| `accent` sobre blanco | 1,90:1 | **Prohibida para texto.** El valor de configuración ámbar observado debe usar `#92400E` o `brand-dark` |
| `rose` sobre `rose-soft` | 4,25:1 | No usar para texto normal; usar `#7C1F2D` |

El criterio mínimo es 4,5:1 para texto normal, 3:1 para texto grande y 3:1 para límites o iconos informativos. El modo de alto brillo no introduce una paleta nueva: usa `ink`, `brand-dark`, bordes más claros y superficies opacas de esta misma paleta.

### Estados semánticos

| Estado | Fondo | Contenido | Icono sugerido | Mensaje base | Regla |
|---|---:|---:|---|---|---|
| Conectado | `#DDF4EA` | `#2A6E54` | nube con confirmación o wifi | “Conectado” | Estado discreto; no ocupa un banner permanente si no hay pendientes |
| Sincronizado | `#DDF4EA` | `#2A6E54` | confirmación | “Sincronizado” | Puede mostrarse por registro y desaparecer del resumen cuando ya no aporta información |
| Sincronizando | `#DBEAFE` | `#1D4ED8` | sincronizar con progreso | “Sincronizando…” | Animación no bloqueante y alternativa estática con movimiento reducido |
| Pendiente | `#F6E4B7` | `#1F4B3A` | reloj | “Pendiente de sincronización” | Siempre indicar la cantidad cuando exista: “3 registros pendientes” |
| Offline | `#FFF1C7` | `#92400E` | wifi desconectado | “Sin conexión · guardado local activo” | No usar lenguaje de pérdida ni impedir registros locales |
| Éxito | `#DDF4EA` | `#2A6E54` | círculo con confirmación | “Guardado” | Confirmación breve y contextual |
| Advertencia | `#FFF1C7` | `#92400E` | triángulo de alerta | Mensaje específico | Debe incluir causa y acción recomendada |
| Error | `#FFE0E6` | `#7C1F2D` | triángulo de alerta | “No se pudo sincronizar” | Debe incluir recuperación: reintentar, editar o revisar conexión |
| Informativo | `#DBEAFE` | `#1D4ED8` | información | Mensaje contextual | No sustituye confirmaciones ni errores |

### Colores de cultivo

Los colores de cultivo identifican categorías, no estados operativos. Siempre se acompañan por pictograma y nombre.

| Cultivo | HEX | Fondo de pictograma | Superposición de mapa |
|---|---:|---|---|
| Frambuesa | `#E11D48` | color al 16 % | color al 34 % |
| Arándano | `#2563EB` | color al 16 % | color al 34 % |
| Frutilla | `#DB2777` | color al 16 % | color al 34 % |
| Sandía | `#16A34A` | color al 16 % | color al 34 % |
| Melón | `#F59E0B` | color al 16 % | color al 34 % |
| Maíz | `#CA8A04` | color al 16 % | color al 34 % |
| Papas / raíz | `#92400E` | color al 16 % | color al 34 % |
| Physalis | `#D97706` | color al 16 % | color al 34 % |
| Apicultura | `#B45309` | color al 16 % | color al 34 % |
| Cultivo personalizado | `brand` `#2A6E54` | `green-soft` | `brand` al 24 % |

No se permite reutilizar estos colores para “bien”, “error”, “pendiente” o “conectado”. En mapas, la etiqueta debe conservar blanco legible mediante relleno suficiente, contorno o scrim; el color translúcido por sí solo no garantiza contraste sobre toda fotografía aérea.

### Transparencias y tratamientos

- Hero pill: blanco al 14 % y borde blanco al 26 % sobre `brand`.
- Fondo de pictograma de cultivo: color del cultivo al 16 %.
- Polígono de cultivo: color del cultivo al 34 %.
- Foco observado: halo `brand` al 18 %, 3 px; en Flutter se conserva como halo o state layer, acompañado por borde sólido.
- Cabecera: blanco al 96 % con desenfoque en el prototipo; Flutter debe preferir superficie opaca o tonal equivalente para legibilidad y rendimiento.
- Navegación inferior: blanco al 98 %; en Android se usa una superficie opaca equivalente.
- Cualquier transparencia sobre mapa o fotografía debe comprobarse contra la imagen real, no contra un fondo teórico.

### Mapeo a ColorScheme y extensiones Flutter

| Rol Flutter | Valor canónico | Origen o criterio |
|---|---:|---|
| `primary` | `#2A6E54` | `brand` |
| `onPrimary` | `#FFFFFF` | Contraste 6,07:1 |
| `primaryContainer` | `#DDF4EA` | `green-soft` |
| `onPrimaryContainer` | `#1F4B3A` | `brand-dark` |
| `secondary` | `#EDB240` | `accent` |
| `onSecondary` | `#1F4B3A` | Contraste 5,19:1 |
| `secondaryContainer` | `#F6E4B7` | `accent-soft` |
| `onSecondaryContainer` | `#1F4B3A` | Contraste alto |
| `tertiary` | `#2563EB` | `sky` |
| `onTertiary` | `#FFFFFF` | Contraste 5,17:1 |
| `tertiaryContainer` | `#DBEAFE` | `sky-soft` |
| `onTertiaryContainer` | `#1D4ED8` | `sky-dark` |
| `error` | `#B9435B` | `rose` |
| `onError` | `#FFFFFF` | Contraste 5,23:1 |
| `errorContainer` | `#FFE0E6` | `rose-soft` |
| `onErrorContainer` | `#7C1F2D` | Texto de alerta observado y accesible |
| `surface` / `background` | `#FFFFFF` | `card` / `bg` |
| `onSurface` | `#17372B` | `ink` |
| `onSurfaceVariant` | `#587267` | Corrección accesible de `muted` |
| `outline` | `#B7DCCB` | `line` |
| `outlineVariant` | `#DDF4EA` | Separación tonal suave |

Los roles **success**, **warning**, **info**, **offline**, **syncing** y **pending** no pertenecen todos a `ColorScheme`; deben vivir en una extensión semántica del tema. Los colores de cultivo pertenecen a datos de dominio o a una extensión específica de cultivos. Ningún componente debe contener HEX directos.

## Typography

### Familia y pesos extraídos

- **Familia:** Inter para display y cuerpo.
- **Pesos cargados:** 400, 500, 600, 700, 800 y 900.
- **Pesos realmente dominantes:** 400 para contenido; 700, 800 y 900 para etiquetas, títulos y métricas.
- **Estilo:** sans serif de alta legibilidad, compacta y neutral.
- **Flutter:** la fuente debe empaquetarse como recurso local para funcionar offline; no debe depender de Google Fonts en tiempo de ejecución.

El prototipo usa negritas con mucha frecuencia. Flutter mantiene títulos y métricas fuertes, pero reduce el uso indiscriminado de 800/900 en textos secundarios para que la jerarquía no se aplane.

### Inventario tipográfico observado

| Uso observado | Tamaño | Peso | Interlineado | Observación |
|---|---:|---:|---:|---|
| Métrica hero | 38 px | 900 | normal | Temperatura principal |
| Título de pantalla | 28 px | 900 | 1,05 | Cabeceras secundarias e Inicio |
| Métrica | 24 px | 900 | normal | Valores de suelo y clima |
| Métrica compacta | 20 px | 900 | normal | Fechas o valores largos en cards |
| Título de tarjeta | 16 px | 800 | 1,15 | Nombre de sector, pasos, eventos |
| Encabezado de sección | 15 px | 800 | normal | “Acciones”, “Cuadrantes” |
| Acción | 14 px | 800 | normal | Tiles y acciones de cuadrante |
| Marca/eyebrow | 13 px | 900 | normal | Mayúsculas, tracking 0,7 px |
| Burbuja/chat/toast | 13 px | 400–700 | 1,45 | Conversación y feedback |
| Texto de tarjeta | 12,5 px | 400 | 1,45 | Descripciones principales |
| Etiqueta/formulario/subtítulo | 12 px | 700–800 | 1,35–normal | Alta densidad; requiere mejora en Flutter |
| Texto pequeño | 11–11,5 px | 400–800 | 1,4 | Ayudas y navegación |
| Etiqueta métrica/tag | 10 px | 800 | normal | Demasiado pequeña para uso general en terreno |
| Etiqueta mapa estrecho | 9 px | 700 | normal | Sólo aparece bajo 360 px; no se conserva en Flutter |

### Escala canónica Flutter

| Rol de TextTheme | Tamaño / altura | Peso | Uso |
|---|---:|---:|---|
| Display Large | 38 / 44 sp | 900 | Temperatura o métrica hero única |
| Display Medium | 32 / 38 sp | 900 | Reservado para una cifra dominante en pantallas especiales |
| Headline Large | 28 / 34 sp | 900 | Título de pantalla |
| Headline Medium | 24 / 30 sp | 900 | Métrica destacada o título de bloque principal |
| Headline Small | 22 / 28 sp | 800 | Diálogo, estado vacío relevante o subtítulo de pantalla |
| Title Large | 20 / 26 sp | 800 | Paso de formulario o título de card prominente |
| Title Medium | 16 / 22 sp | 800 | Título estándar de tarjeta, sector o evento |
| Title Small | 15 / 20 sp | 800 | Encabezado de sección |
| Body Large | 16 / 24 sp | 400 | Campos, mensajes, texto principal y chat |
| Body Medium | 14 / 21 sp | 400 | Descripciones de cards, ayudas y metadatos legibles |
| Body Small / Caption | 12 / 18 sp | 400–500 | Información auxiliar no crítica |
| Label Large | 14 / 20 sp | 800 | Botón, acción y destino de navegación |
| Label Medium | 12 / 16 sp | 800 | Etiqueta de campo, chip y estado |
| Label Small | 11 / 16 sp | 800 | Sólo etiquetas breves con contraste alto; nunca para instrucciones |

### Reglas tipográficas

- Los tamaños se expresan en `sp` y respetan el escalado de texto del sistema Android.
- No se fija una altura que recorte contenido al aumentar la escala. Tarjetas y botones crecen verticalmente.
- El cuerpo operativo usa como mínimo 14 sp; formularios y chat usan 16 sp.
- Las unidades no se separan visualmente del valor. Para datos comparables se usan cifras tabulares.
- Los títulos se permiten en dos líneas; no se truncan si son esenciales.
- La marca “AGROCAMPO” conserva mayúsculas, 13 sp, peso 900 y tracking equivalente a 0,7 px.
- Los textos auxiliares de 11–12 sp sólo son válidos con contraste alto y nunca contienen instrucciones críticas.
- Se evita usar 900 en párrafos, ayuda, estado o texto de formulario.
- Los nombres agrícolas y topónimos usan ortografía española completa: “Arándano”, “Medición”, “Cálculo”, “Duración”, “Último”.

## Components

### Estructura base de componente

Todo componente reutilizable debe definir, como mínimo: propósito, anatomía, dimensiones, espaciado, forma, color, elevación, estados, semántica y adaptación responsive. Las variantes no pueden introducir valores fuera de los tokens de este documento.

### Shell de aplicación y cabecera

| Propiedad | Especificación |
|---|---|
| Propósito | Enmarcar cada destino, identificar AgroCampo y dar acceso consistente a volver o perfil |
| Anatomía | Área segura superior, marca o botón volver, eyebrow, título, subtítulo y acción contextual opcional |
| Extraído | Cabecera sticky; padding 28/16/12 px, reducido a 14 px arriba en móvil; borde inferior `line`; fondo blanco al 96 % |
| Canónico Flutter | App bar flexible en superficie blanca opaca; inset horizontal 16 dp; botón de navegación con blanco táctil 48 dp; altura adaptable al texto |
| Título | Headline Large; subtítulo Body Small/Medium con `onSurfaceVariant` |
| Comportamiento | Inicio muestra marca y perfil; destinos secundarios muestran volver, título y contexto de cuadrante/temporada |
| Accesibilidad | Orden: volver o marca, título, subtítulo, acción; cada control de icono tiene nombre accesible |

La maqueta de teléfono de 430 × 900 px, marco verde oscuro, notch simulado y fondo exterior verde son exclusivos de la presentación HTML y no se implementan en Flutter.

### Tarjeta estándar

| Propiedad | Especificación |
|---|---|
| Propósito | Agrupar información relacionada y separar unidades de trabajo |
| Estructura | Contenedor, icono o pictograma opcional, bloque de título/texto y acción o indicador opcional |
| Extraído | Fondo blanco; borde 1,5 px `line`; radio 22 px; padding 14 px; sombra `0 12 24 -20` verde oscuro al 45 % |
| Canónico Flutter | Radio 22 dp, borde 1–1,5 dp, padding 16 dp normalizado, elevación perceptiva baja |
| Colores | `surface`, `onSurface`, `onSurfaceVariant`, `outline` |
| Comportamiento | Si es interactiva, toda la tarjeta es táctil, tiene ripple y conserva su tamaño al presionar |
| Estados | Normal, presionada, enfocada, seleccionada, deshabilitada y error cuando aplique |
| Accesibilidad | El contenedor interactivo expone una sola acción y un nombre compuesto; no duplica hijos en TalkBack |

### Tarjeta hero de clima

| Propiedad | Especificación |
|---|---|
| Propósito | Comunicar en un vistazo las condiciones actuales de la parcela |
| Estructura | Ubicación, temperatura, condición/actualización y dos métricas compactas |
| Extraído | Alto mínimo 150 px; padding 17 px; radio 24 px; fondo `brand`; borde 1,5 px `brand-dark`; texto blanco; bloque amarillo decorativo de 142 px rotado |
| Métricas | Temperatura 38/900; pills en cuadrícula 2 columnas, gap 8 px, radio 18 px, padding 8 px |
| Canónico Flutter | Alto flexible, padding 16 dp, radio 24 dp; bloque amarillo decorativo excluido de semántica |
| Comportamiento | No es un botón salvo que toda la tarjeta tenga un destino explícito; actualización muestra hora y estado de carga/error |
| Restricción | El acento amarillo no lleva texto; no debe tapar ubicación, temperatura ni métricas con escalado de texto |

### Tarjetas de acción rápida y acción de cuadrante

| Variante | Extraído | Uso | Canónico Flutter |
|---|---|---|---|
| Acción rápida | 2 columnas, gap 10 px, alto mínimo 78 px, radio 22 px, icono 24 px | Inicio | Mantener 2 columnas sólo si cada celda conserva ancho y texto; colapsar a una columna con texto grande |
| Acción de cuadrante | 2 columnas, alto mínimo 78 px, padding 13 px, icono 24 px | Detalle de cuadrante | Etiqueta 14/800 y ayuda 12–14; blanco táctil completo; ripple |
| Tarjeta navegable | Card horizontal con icono, título, texto y chevron | Acceso a cuadrantes, Más | Chevron decorativo; la tarjeta anuncia destino y acción |

No debe haber más de una acción primaria visual por vista. Las tarjetas de acción son accesos secundarios; “Guardar” es la acción primaria de los formularios.

### Tarjeta de sector o cultivo

| Propiedad | Especificación |
|---|---|
| Propósito | Identificar cuadrante, cultivo, estado y actividad reciente |
| Estructura | Pictograma 46 × 46, título, estado, último riego, último registro y chevron |
| Extraído | Alto mínimo 76 px; padding 13 px; gap 12 px; radio 22 px; borde 1,5 px |
| Pictograma | 46 × 46 px, radio 9 px, asset al 72 %, fondo del color de cultivo al 16 % |
| Canónico Flutter | Padding 16 dp; pictograma 48 × 48 dp; altura intrínseca; texto puede crecer a varias líneas |
| Estado | Punto de 10 px más etiqueta textual; el texto es obligatorio y el color sólo refuerza |
| Comportamiento | Tap en cualquier punto abre el detalle; estado presionado visible; conserva posición al volver |

### Tarjetas de métricas

| Propiedad | Especificación |
|---|---|
| Propósito | Comparar clima, humedad y fechas recientes |
| Extraído | Cuadrícula 2 × 2; gap 9 px; fondo blanco; borde 1,5 px; radio 22 px; padding 12 px |
| Jerarquía | Etiqueta 10/800 mayúscula y valor 24/900; valores largos bajan a 20 px |
| Corrección | Etiqueta mínima 12 sp; mantener 24 sp para valores; no reducir valores largos por debajo de 18 sp, permitir dos líneas |
| Unidades | Siempre visibles y localizadas; cifras tabulares cuando se comparan |
| Responsive | Dos columnas en teléfonos estándar; una columna con texto grande o ancho estrecho |

### Botones

| Variante | Dimensiones y forma | Color | Uso y comportamiento |
|---|---|---|---|
| Primario | Alto mínimo 48 dp; padding 12 × 16; radio 22 dp | Fondo `primary`, texto/icono `onPrimary` | Una acción principal: guardar, confirmar o reintentar |
| Secundario | Alto mínimo 48 dp; radio 22 dp; borde `outline` | Fondo `surface`, contenido `primary` | Acciones alternativas y navegación contextual |
| Destructivo | Alto mínimo 48 dp; radio 22 dp | Fondo `error` con `onError`, o borde `error` en baja prioridad | Sólo acciones destructivas confirmadas |
| Enlace | Blanco táctil 48 × 48 dp cuando es sólo icono | `primary` sobre transparente | Abrir una sección; no usar un icono visual de 18 px como área táctil completa |
| Volver | 48 × 48 dp; circular o radio 22 dp | `primary` / `onPrimary` | Navegación hacia atrás y Android predictive back |
| Perfil/editar | 48 × 48 dp; borde `outline` | `surface` / `primary` | Acción de icono con etiqueta accesible |
| Enviar AgroIA | 50 × 50 dp; radio 8 dp | `primary` / `onPrimary` | Deshabilitado con mensaje vacío; progreso durante envío |

El HTML presenta los botones de guardado como blancos con texto verde. **Corrección canónica:** la única acción de guardado de cada formulario se muestra rellena con `primary` para reforzar jerarquía; los demás botones conservan el estilo delineado. Todos tienen feedback visual en menos de 100 ms, estado deshabilitado real y progreso sin alterar el ancho.

### Acción central de Registrar

- **Propósito:** mantener Registrar al alcance del pulgar como acción transversal.
- **Extraído:** pestaña central elevada; icono visual equivalente a 54 px, radio 16 px, borde y sombra; etiqueta persistente.
- **Canónico:** acción central de 56 dp dentro de un blanco táctil mínimo de 64 dp, sin ocultar la etiqueta “Registrar”.
- **Estado activo:** no depende sólo del verde; incorpora indicador de selección, peso y semántica `selected`.
- **Restricción:** no flota sobre campos, teclado o contenido sin reservar inset inferior.

### Chips y selectores

| Propiedad | Especificación |
|---|---|
| Propósito | Seleccionar icono de cultivo, categoría o valor corto |
| Extraído | Borde 1,5 px; radio 22 px; padding 10 × 12 px; gap 8 px; etiqueta 12/800; seleccionado con fondo `brand` y blanco |
| Icono de cultivo | 28 × 28 px; pictograma SVG de color |
| Canónico | Alto mínimo 48 dp; colección con `Wrap`; separación mínima 8 dp; seleccionado con icono/texto además de color |
| Comportamiento | Selección inmediata, foco visible, estado anunciado; las etiquetas se envuelven antes de truncarse |
| Accesibilidad | Un chip sólo con pictograma debe anunciar el nombre del cultivo |

El selector de cuadrante es una variante de ancho completo: alto mínimo 52 px observado, padding 10 × 12 px, pictograma 32 px y halo de selección. En Flutter el alto táctil no baja de 56 dp y el cuadrante seleccionado se expone semánticamente.

### Inputs y formularios

| Propiedad | Especificación |
|---|---|
| Campo simple | Alto mínimo 48 px observado; canónico 56 dp; borde 1–1,5 dp; radio 22 dp; padding 13 × 14 observado, 12 × 16 canónico |
| Área de texto | Alto mínimo 92 px; redimensiona por contenido y escala de texto |
| Etiqueta | Siempre visible; Label Medium 12/800 como mínimo; no se reemplaza por placeholder |
| Foco | Borde `primary` y halo equivalente a 3 dp; el foco no se oculta bajo cabecera, teclado o navegación |
| Ayuda | Body Small/Medium bajo el campo; causa y formato esperado |
| Error | Texto `onErrorContainer`, icono y borde de error; mensaje específico junto al campo |
| Teclado | Tipo numérico, decimal, fecha o texto según dato; las unidades permanecen visibles |
| Lectura | Estado de sólo lectura visual y semánticamente distinto de deshabilitado |

Los formularios observados usan tarjetas por paso y un `grid2` de dos columnas con gap 10 px. La adaptación canónica conserva dos columnas sólo para pares numéricos cortos cuando hay al menos 400 dp útiles y el escalado de texto lo permite. En teléfonos estrechos, landscape bajo o texto ampliado se usa una columna.

Estados obligatorios de formulario:

1. inicial;
2. editado con borrador local;
3. validando;
4. guardando localmente;
5. guardado local y pendiente;
6. sincronizado;
7. error de campo;
8. error de persistencia o sincronización;
9. deshabilitado por dependencia no disponible.

### Banners, alertas y feedback

| Variante | Fondo / contenido | Estructura | Uso |
|---|---|---|---|
| Informativo | `sky-soft` / `sky-dark` | Icono 20–24, título, mensaje, acción opcional | Alcance, explicación o actualización |
| Éxito | `green-soft` / `brand` | Confirmación, mensaje | Guardado o sincronización completada |
| Advertencia/offline | `amber-soft` / `#92400E` | Alerta o wifi-off, mensaje y acción | Riesgo, conexión o pendientes |
| Error | `rose-soft` / `#7C1F2D` | Alerta, causa y recuperación | Fallo de carga, guardado o sincronización |

Los banners heredan radio 22 px, padding 14 px, borde 1,5 px y gap 11 px. El HTML ya define estas variantes, aunque el banner de alertas de Inicio retorna vacío. Flutter debe usarlas sólo cuando exista contenido real; no se crean avisos decorativos.

El toast observado dura 2,3 s, usa fondo `brand`, radio 8 px y aparece sobre la navegación. **Corrección canónica:** feedback tipo snackbar de 4 s para mensajes legibles, sin robar foco, anunciado por accesibilidad y con acción cuando haya recuperación o deshacer. Los mensajes críticos no desaparecen automáticamente y usan banner persistente.

### Estados vacíos

El único estado vacío explícito del HTML aparece en Historial. El patrón canónico es:

- icono contextual de 32 dp;
- título Title Medium;
- explicación Body Medium que indique qué aparecerá y cuándo;
- una acción primaria sólo si existe una acción válida dentro del MVP;
- tarjeta de radio 22 dp y padding 24 dp;
- nunca mostrar una lista, gráfico o mapa en blanco sin explicación.

Ejemplo conceptual aprobado: “Sin registros para este cuadrante. Los nuevos registros aparecerán aquí asociados a la temporada y al cultivo.”

### Mapa de parcela

| Propiedad | Especificación |
|---|---|
| Propósito | Relacionar físicamente parcela, cuadrantes y cultivos |
| Extraído | Alto 315 px en pantalla y 185 px en preview; radio 24 px; borde 1,5 px; imagen aérea con velo verde |
| Parcela | Contorno blanco de 3 px, inset 12 px, radio 22 px y relleno verde al 8 % |
| Cuadrante | Polígono con color de cultivo al 34 %, borde blanco 2 px, radio visual 20 px, icono hasta 28 px y etiqueta blanca |
| Interacción | Tap abre sector; edición mueve vértices por arrastre |
| Canónico Flutter | Proveedor de mapa aprobado o imagen offline; polígonos geográficos, cámara estable y overlays temáticos; preview no interactivo salvo apertura |
| Accesibilidad | Cada polígono anuncia cuadrante, cultivo y acción; existe alternativa textual en lista |

La fotografía no puede ser la única representación de la parcela. Si el mapa no carga, se conserva la lista de cuadrantes y un estado de recuperación.

### Cuadrantes y vértices editables

- Vértice observado: círculo de 18 × 18 px, borde 2 px, seleccionado con `accent`.
- **Corrección crítica:** el blanco táctil Android es de al menos 48 × 48 dp; el punto visual puede permanecer en 18–20 dp dentro de esa zona.
- El vértice seleccionado añade borde, halo o etiqueta, no sólo amarillo.
- El arrastre ofrece feedback en tiempo real y no bloquea el gesto de navegación del sistema.
- Debe existir una alternativa sin arrastre para ajustes precisos y accesibilidad, usando controles visibles dentro del mismo flujo de edición.
- El mapa no exige precisión de un píxel ni utiliza sólo color para identificar el cuadrante.

### Timeline e historial

| Propiedad | Especificación |
|---|---|
| Propósito | Presentar actividades en orden cronológico por cuadrante y temporada |
| Extraído | Lista vertical con gap 10 px; evento en card de radio 22 px, padding 13 px, borde 1,5 px y sombra baja |
| Marcador | 28 × 28 px, icono 22 px verde, sin fondo |
| Contenido | Fecha y tipo como título; cultivo y notas como cuerpo |
| Etiqueta auxiliar | Tag observado: radio 12 px, padding 3 × 7 px, 10/800; debe normalizarse a 12 sp y usar estado semántico |
| Canónico | Agrupar por temporada cuando haya volumen; estado de sincronización por registro sólo si es relevante |

La línea vertical no está presente en el prototipo y no es obligatoria. La prioridad es la lectura de los eventos, no simular una cronología decorativa.

### AgroIA chat

| Propiedad | Especificación |
|---|---|
| Propósito | Consulta agronómica asistida usando el contexto del cuadrante |
| Mensaje propio | Alineado a la derecha, máximo 84 %, fondo `brand`, texto blanco, radio 10 px y esquina inferior 3 px |
| Mensaje IA | Alineado a la izquierda, máximo 84 %, fondo `surface`, borde `outline`, radio 10 px y esquina inferior 3 px |
| Texto | 13 px observado; Body Medium 14/21 sp canónico |
| Composer | Sticky, input de radio 8 px, gap 8 px, botón enviar 50 px |
| Canónico Flutter | Lista que conserva historial y posición, compositor sobre el teclado y safe area, botón con nombre accesible |
| Estados | enviando, respuesta en progreso, enviado, sin conexión, error y reintento |

AgroIA debe mostrar de forma persistente que su respuesta es consultiva y que la persona debe verificar en terreno. No se añaden análisis fotográfico, automatización ni recomendaciones agronómicas no contempladas por el MVP.

### Perfil y configuración

- Avatar observado: 68 × 68 px, radio 18 px, `sky-soft` con `sky-dark`, icono 34 px.
- Grupo de ajustes: card con padding vertical 4 px; filas de padding 11 × 14 px; separador fino.
- **Corrección:** cada fila alcanza al menos 48 dp y su valor no usa `accent` como texto sobre blanco. Se usa `#92400E`, `brand-dark` o `onSurfaceVariant` según semántica.
- Los chevrons son decorativos; la fila completa es el control.
- Acciones sensibles, seguridad y cierre de sesión —si están dentro del alcance— se separan espacialmente de preferencias normales.

### Elevación y sombras

| Nivel | Referencia observada | Uso canónico |
|---|---|---|
| 0 | Sin sombra | Fondos, inputs y contenedores internos con borde |
| 1 | Card: verde oscuro, muy difusa | Tarjeta estándar |
| 2 | Acción/back: sombra ligeramente más definida | Botón flotante o control superpuesto |
| 3 | Navegación inferior/FAB | Elemento fijo por encima del contenido |
| Mapa | Sombra negra localizada | Etiqueta o polígono sobre fotografía |

Flutter reproduce la jerarquía perceptiva, no los valores CSS con spread negativo literalmente. El borde sigue siendo el principal separador; la sombra es secundaria y sutil.

## Layout Rules

### Unidad y escala de espaciado

| Token | Valor | Uso |
|---|---:|---|
| Spacing 4 | 4 dp | Separación mínima entre icono y estado, padding interno muy compacto |
| Spacing 8 | 8 dp | Gap de chips, hero pills, icono-etiqueta compacta |
| Spacing 12 | 12 dp | Gap interno de filas, formularios y listas; normaliza valores observados de 10–13 px |
| Spacing 16 | 16 dp | Gutter móvil, padding estándar de card y separación principal |
| Spacing 24 | 24 dp | Separación entre secciones y padding de estados vacíos |
| Spacing 32 | 32 dp | Separación de bloques mayores, respiración superior o cierre de flujo |

Los valores 5, 6, 9, 10, 11, 13, 14 y 17 px observados se normalizan al token más cercano según jerarquía. No se introducen valores arbitrarios en nuevas pantallas.

### Grid y gutters

- Gutter de teléfono: 16 dp; en ancho útil menor a 360 dp puede bajar a 12 dp.
- Gutter de teléfono grande o landscape: 24 dp cuando el contenido lo permite.
- Contenido operativo de formularios en tablet: ancho máximo recomendado de 600 dp, centrado.
- Dashboard o mapa en tablet: ancho máximo de 840 dp, con paneles adaptativos sólo si no altera el MVP.
- Separación entre cards de una pila: 12 dp.
- Separación entre celdas de grid: 8–12 dp.
- No existe scroll horizontal en pantallas operativas.
- El contenido nunca queda bajo app bar, navegación inferior, teclado o barras del sistema.

### Responsive

| Contexto | Regla |
|---|---|
| Teléfono estrecho, menos de 360 dp útiles | Gutter 12 dp; métricas y campos en una columna; texto sin reducir a 9–10 sp |
| Teléfono estándar, 360–599 dp | Gutter 16 dp; acciones y métricas pueden usar dos columnas si cada celda conserva legibilidad |
| Landscape con poca altura | Cabecera compacta, contenido desplazable y acción primaria alcanzable; la navegación no debe ocultar la primera sección |
| Tablet, 600 dp o más | Contenido centrado; se puede usar dos paneles para lista/detalle sin duplicar navegación |
| Texto ampliado | Colapsar grids, aumentar altura y permitir wrap; nunca truncar instrucciones o valores críticos |

La inspección del prototipo en 800 × 430 mostró que el marco y la navegación dejan muy poco contenido visible. Flutter no replica el marco web y debe reservar correctamente áreas seguras y scroll para landscape.

### Radios

| Token | Valor | Uso |
|---|---:|---|
| Radius Small | 8 dp | Input de chat, snackbar y controles compactos |
| Radius Medium | 12 dp | Tags, subcontroles y agrupaciones pequeñas |
| Radius Large | 22 dp | Cards, botones, campos, selectores y filas principales |
| Radius Hero | 24 dp | Hero y mapa |
| Radius Full | 999 dp | Chip de estado y formas circulares |

Excepciones heredadas válidas: pictograma de cultivo 9 dp, avatar 18 dp y bubble de chat 10 dp con cola de 3 dp. Los radios de 30–34 px pertenecen sólo al marco web.

### Bordes

- Borde estándar: 1–1,5 dp `outline`.
- Borde de mapa/parcela: 2–3 dp según contraste sobre imagen.
- Foco/selección: borde `primary` más halo o indicador visible.
- Los separadores internos usan 1 dp y no sustituyen el espaciado.
- El borde no puede desaparecer en brillo alto; si la pantalla lo exige, se aumenta opacidad o grosor, no se cambia de familia cromática.

### Alturas y blancos táctiles

- Botón o campo: mínimo 48 dp; campo recomendado 56 dp.
- Icon button: blanco táctil 48 × 48 dp.
- Fila de configuración o selector: mínimo 48–56 dp.
- Tile de acción: mínimo 78 dp observado; crece con texto.
- Navegación inferior: 80–82 dp más safe area inferior.
- Hero: mínimo 150 dp, sin altura fija cuando aumenta el texto.
- Mapa principal: 315 dp como referencia, adaptable a pantalla; preview: 185 dp.

### Scroll y zonas de alcance

- La app usa un único scroll vertical principal por pantalla.
- La acción primaria de un formulario se mantiene al final del flujo o en una barra inferior segura si el formulario es largo; nunca queda detrás de la navegación.
- Registrar permanece en la zona inferior y central, accesible con una mano.
- Acciones destructivas, mapa editable y controles de precisión no se colocan pegados a gestos del sistema.
- El padding inferior del contenido debe equivaler a navegación + safe area + al menos 12 dp; los 92 px del HTML son la referencia mínima, no un valor absoluto universal.

## Navigation

### Navegación primaria

La barra inferior contiene exactamente cinco destinos:

| Orden | Destino | Icono | Ruta del prototipo | Rol |
|---:|---|---|---|---|
| 1 | Inicio | casa | `#inicio` | Resumen diario |
| 2 | Sectores | mapa | `#sectores` | Parcela, cuadrantes y mapa |
| 3 | Registrar | círculo con más | `#registrar` | Acción transversal central |
| 4 | AgroIA | destellos | `#ia` | Consulta contextual |
| 5 | Más | cuadrícula | `#mas` | Historial, respaldo, conexión y opciones |

### Especificación de la barra inferior

- Alto observado: 82 px; padding 8/8/13; borde superior 1,5 px.
- Icono normal: 20 px; etiqueta 11/800; gap 5 px.
- Registrar: pestaña de 76 px elevada 30 px, icono visual mayor y etiqueta visible.
- Canónico Flutter: `NavigationBar` o composición Material equivalente con cinco destinos y acción central integrada sin romper semántica.
- El destino activo usa color, indicador visual, peso y estado `selected`; no depende sólo del cambio de color.
- La posición de los cinco destinos no cambia entre pantallas.
- Los destinos de nivel secundario no se agregan a la barra.

### Jerarquía de rutas

| Ruta visual | Jerarquía | Entrada | Salida esperada |
|---|---|---|---|
| Inicio | Nivel superior | Barra inferior | Back de Android sale o minimiza según convención del sistema |
| Sectores | Nivel superior | Barra inferior o Inicio | Conserva scroll y selección |
| Mapa | Secundaria de Sectores | Resumen de Sectores | Vuelve a Sectores |
| Detalle sector | Secundaria de Sectores | Lista o mapa | Vuelve al origen conservando estado |
| Registrar | Nivel superior y contextual | Barra o acción del sector | Tras guardar, abre el sector seleccionado |
| Medición de suelo | Secundaria contextual | Inicio o sector | Tras guardar, abre el sector |
| Riego | Secundaria contextual | Inicio o sector | Tras guardar, abre el sector |
| Cambiar cultivo | Secundaria del sector | Detalle sector | Tras confirmar, vuelve al sector |
| Historial | Secundaria | Sector o Más | Vuelve al origen lógico |
| AgroIA | Nivel superior y contextual | Barra o sector | Conserva contexto seleccionado |
| Más | Nivel superior | Barra inferior | Abre opciones secundarias |
| Perfil | Secundaria | Acción de Inicio | Vuelve a Inicio |
| Configuración | Secundaria de Más | Más | Vuelve a Más |
| Acceso | Fuera del shell | Inicio de aplicación sin sesión | Entra a la rama válida tras autenticar |
| Parcelas | Secundaria de Inicio | Selector de parcela | Vuelve a Inicio con contexto confirmado |
| Catálogo/ficha de cultivo | Secundaria contextual | Sector o cambio de cultivo | Vuelve al origen conservando selección |
| Rotación futura | Secundaria del sector | Cambiar cultivo | Vuelve al sector sin cambiar el cultivo vigente |
| Producción | Secundaria de Registrar | Cosecha | Tras guardar abre el sector |
| Revisión apícola | Secundaria de Registrar | Sector apícola | Tras guardar abre el sector apícola |
| Fotografías | Secundaria/contextual | Sector o labor | Vuelve al origen con adjunto persistido |
| Recordatorios | Secundaria de Más | Más | Vuelve a Más |
| Sincronización | Secundaria de Más | Más o indicador global | Vuelve al origen lógico |
| Resolver conflicto | Secundaria de Sincronización | Conflicto abierto | Vuelve al estado de sincronización |
| Exportar | Secundaria de Más | Más | Vuelve a Más tras completar, cancelar o fallar |

### Comportamiento Android

- El botón del sistema y el gesto predictivo de volver siguen la misma pila que el botón visual.
- Volver no reinicia filtros, scroll, borradores ni cuadrante seleccionado.
- Una notificación puede abrir el destino relevante manteniendo una ruta de retorno coherente.
- El teclado se cierra antes de abandonar un formulario, salvo que haya datos sin guardar; en ese caso se confirma la salida o se conserva borrador.
- Las pantallas de nivel superior no apilan copias al tocar repetidamente su pestaña.
- Los modales y sheets no sustituyen pantallas principales ni navegación primaria.
- El indicador de sincronización puede vivir en app bar o banner, pero no desplaza los controles ni cambia su ubicación entre destinos.

## Screens

### Inicio

- **Objetivo:** responder “¿cómo está mi parcela y qué puedo hacer ahora?”.
- **Jerarquía:** marca/perfil, título “Inicio”, hero climático, acceso a cuadrantes y acciones rápidas.
- **Componentes:** app bar, hero, card navegable y grid de cuatro tiles.
- **Información:** ubicación, temperatura, humedad ambiental, lluvia, pronóstico y hora de actualización.
- **Acciones:** Ver cuadrantes, Registrar, Suelo, Riego y AgroIA.
- **Estados:** clima cargando, sin datos, desactualizado y error; conexión/offline visible cuando corresponda.
- **Regla:** el clima no desplaza las acciones esenciales si no carga; se muestra última actualización conocida.

### Sectores

- **Objetivo:** comparar los cuadrantes y acceder a su detalle.
- **Jerarquía:** título, lista de sectores, mapa de cuadrantes y resumen de historial.
- **Componentes:** tarjetas de cultivo, indicador de estado con texto, preview de mapa, encabezados de sección y cards de evento.
- **Información:** cuadrante, cultivo, estado, último riego y último registro.
- **Acción primaria:** abrir un cuadrante; mapa e historial son accesos secundarios.
- **Estados:** lista vacía, mapa no disponible, registro pendiente y error de carga local.
- **Regla:** la lista textual permanece disponible incluso si el mapa falla.

### Mapa

- **Objetivo:** representar parcela, límites y relación espacial entre cuadrantes.
- **Jerarquía:** app bar, mapa principal, overlays de parcela, polígonos y controles de edición cuando estén activos.
- **Componentes:** mapa de 315 dp de referencia, contorno de parcela, polígonos, pictogramas, etiquetas y vértices.
- **Información:** nombre y cultivo por cuadrante; selección actual.
- **Acciones:** abrir cuadrante, seleccionar vértice y ajustar límites dentro del flujo previsto.
- **Estados:** cargando, mapa base disponible, base remota no disponible, geometría local, error y alternativa de lista.
- **Regla:** la edición nunca depende exclusivamente de arrastre fino ni de color.

### Detalle sector

- **Objetivo:** resumir el estado de un cuadrante y ofrecer sus acciones contextuales.
- **Jerarquía:** identidad del cuadrante, cuatro métricas y grid de acciones.
- **Componentes:** card de cultivo editable, panel de pictogramas, métricas y seis tarjetas de acción.
- **Información:** cultivo, temporada, clima, humedad del suelo, último riego y última medición.
- **Acciones:** Registrar, Riego, Suelo, AgroIA, Cambiar cultivo y Ver historial.
- **Estados:** panel de edición cerrado/abierto, datos no medidos, registros pendientes y métricas desactualizadas.
- **Regla:** al entrar desde un sector, formularios y AgroIA mantienen ese contexto bloqueado o claramente seleccionado.

### Registrar actividad

- **Objetivo:** registrar una labor agrícola manual asociada a cuadrante, cultivo y fecha.
- **Jerarquía:** Paso 1 selección de cultivo, Paso 2 tipo/fecha, Paso 3 detalle condicional y acción Guardar.
- **Componentes:** cards por paso, selector de sector, select, fecha, campos específicos, observaciones y botón primario.
- **Información:** suelo, riego, fertilización, control de enfermedades y plagas, siembra, poda,
  cosecha, apicultura y Otra labor; el Design System no añade categorías distintas a la spec.
- **Acción primaria:** Guardar actividad.
- **Estados:** borrador, validación, guardando localmente, guardado pendiente, sincronizado y error recuperable.
- **Regla:** sólo se muestran preguntas del tipo seleccionado; no se pierde información al cambiar accidentalmente de pantalla.

### Medición de suelo

- **Objetivo:** ingresar manualmente valores del suelo para un cuadrante.
- **Jerarquía:** cuadrante, grid de mediciones y Guardar medición.
- **Componentes:** selector o contexto bloqueado, campos numéricos y botón primario.
- **Información:** pH, humedad, temperatura, conductividad, N, P y K.
- **Estados:** valores iniciales, error de formato/rango, guardado local, pendiente y sincronizado.
- **Regla:** cada valor mantiene unidad, teclado correcto y ayuda; no se presenta interpretación agronómica no validada.

### Riego

- **Objetivo:** registrar parámetros de riego y mostrar un cálculo determinístico separado de cualquier interpretación IA.
- **Jerarquía:** cuadrante, tipo, parámetros, resumen de cálculo y Guardar riego.
- **Componentes:** selector, campos numéricos, card de cálculo y botón primario.
- **Información:** tipo de riego, tipo de suelo, plantas, caudal, duración, humedad, temperatura,
  disponibilidad climática, agua estimada y tiempo recomendado.
- **Estados:** cálculo actualizado, dato inválido, regla agronómica no disponible, guardado local, pendiente y sincronizado.
- **Regla:** el cálculo se etiqueta como determinístico; AgroIA nunca modifica silenciosamente sus valores.

### Historial

- **Objetivo:** revisar actividades por cuadrante, cultivo y temporada.
- **Jerarquía:** contexto de cuadrante, eventos cronológicos y estado vacío.
- **Componentes:** timeline de cards, icono por actividad, etiquetas de temporada/sync cuando aporten valor.
- **Información:** fecha, tipo, cultivo, notas y estado de sincronización relevante.
- **Acciones:** abrir detalle si está contemplado; no inventar edición o borrado fuera del MVP.
- **Estados:** con eventos, vacío, filtrado sin resultados, pendiente y error de sincronización.
- **Regla:** los eventos locales aparecen inmediatamente y no esperan la nube.

### AgroIA

- **Objetivo:** ofrecer consulta contextual sobre el cuadrante seleccionado.
- **Jerarquía:** título/contexto, conversación, aviso consultivo y compositor.
- **Componentes:** lista de mensajes, bubbles, input y enviar.
- **Información:** contexto activo de cuadrante, cultivo, humedad y tipo de riego cuando esté disponible.
- **Acción primaria:** enviar consulta.
- **Estados:** vacío, enviando, respondiendo, error, reintento y offline no disponible para una nueva respuesta.
- **Regla:** el historial visible no desaparece offline; se explica qué requiere conexión y se recuerda verificar en terreno.

### Más

- **Objetivo:** reunir destinos secundarios sin sobrecargar la navegación primaria.
- **Componentes:** cards para Historial agrícola, Respaldo Excel, Conexión y Opciones.
- **Información:** descripción corta de cada destino y flujo de sincronización local → pendiente → sincronizado.
- **Acciones:** abrir historial, exportar, revisar estado de sincronización/reintentar y abrir configuración.
- **Regla:** conexión se presenta como estado y diagnóstico, no como interruptor ambiguo en producción.

### Perfil

- **Objetivo:** identificar a la persona propietaria y acceder a preferencias personales.
- **Jerarquía:** resumen de perfil y tres grupos de ajustes.
- **Componentes:** avatar, acción editar, filas de configuración, valores y chevrons.
- **Información:** nombre visible, dato de acceso para presentación, ubicación/preferencias personales
  autorizadas y resumen de sincronización.
- **Acción primaria:** editar perfil o cerrar sesión dentro del alcance aprobado.
- **Regla:** no introducir empresas, trabajadores, roles ni ERP.

### Configuración

- **Objetivo:** exponer ajustes generales y límites funcionales del producto.
- **Componentes:** banner informativo y filas para permisos/estado de plataforma que tengan un
  resultado real en el MVP.
- **Información:** uso personal, permisos de notificación y acceso al diagnóstico de sincronización.
- **Estados:** normal, offline, pendientes de sincronización y error.
- **Regla:** un ajuste no simula una capacidad inexistente; toda opción debe tener resultado real dentro del MVP.

### Cambiar cultivo

- **Objetivo:** iniciar una nueva temporada conservando el historial anterior.
- **Componentes:** card de contexto y selector de cultivos con pictogramas.
- **Información:** cultivo actual, temporada y opciones permitidas.
- **Acción:** seleccionar el cultivo y confirmar el cambio de temporada según el flujo funcional.
- **Estados:** actual, seleccionado, guardado local, pendiente, sincronizado y error.
- **Regla:** se comunica explícitamente que el historial anterior se conserva.

### Acceso

- **Objetivo:** autenticar al agricultor sin mostrar datos privados antes de validar la sesión.
- **Componentes:** marca, campos de acceso, botón primario, progreso, error recuperable y explicación offline.
- **Estados:** inicial, validando, credenciales inválidas, sin red en primer acceso y sesión recuperada.
- **Regla:** la pantalla no simula acceso offline si el dispositivo nunca validó una sesión.

### Parcelas

- **Objetivo:** seleccionar, crear, editar, archivar o eliminar de forma segura el contexto territorial.
- **Componentes:** selector activo, cards de parcela, formulario, resumen geométrico y diálogo destructivo.
- **Estados:** vacío, activa, archivada, borrador, error, pendiente y eliminación impedida por historial.
- **Regla:** archivo y eliminación se diferencian por copy, consecuencia y confirmación; no dependen sólo del color.

### Catálogo y ficha de cultivo

- **Objetivo:** consultar el catálogo inicial y crear/editar una ficha personalizada cuando corresponda.
- **Componentes:** buscador, cards con pictograma/nombre, ficha informativa, formulario y activo genérico.
- **Información:** siembra, suelo, agua, información agrícola y enfermedades, incluidos estados “sin información”.
- **Estados:** catálogo local, vacío de búsqueda, ficha oficial sólo lectura, ficha personalizada editable y error.
- **Regla:** un cultivo personalizado usa el tratamiento visual canónico genérico; no inventa color ni SVG propio.

### Rotación futura

- **Objetivo:** planificar el próximo cultivo sin confundirlo con el cultivo vigente.
- **Componentes:** card del cultivo actual, selector de próximo cultivo, fecha efectiva y resumen de planificación.
- **Estados:** sin planificación, planificada, cancelada, conflicto de fechas, pendiente y sincronizada.
- **Regla:** “Vigente” y “Planificado para [fecha]” siempre aparecen como etiquetas textuales separadas.

### Producción

- **Objetivo:** registrar una cosecha con cantidad, unidad, calidad, temporada y observaciones.
- **Componentes:** contexto bloqueado, campos métricos, selector de calidad textual y confirmación local.
- **Estados:** borrador, inválido, guardando local, pendiente, sincronizado y error.
- **Regla:** no muestra comparativas calculadas no exigidas; conserva el contexto para comparativas futuras.

### Revisión apícola

- **Objetivo:** registrar el tipo de tarea y la revisión de un sector apícola.
- **Componentes:** contexto apícola, tipo de tarea, fecha, apicultor descriptivo, colmenas y campos de reina,
  postura, enfermedades/plagas, alimentación, alza, observaciones y fotos.
- **Estados:** sector incompatible, borrador, inválido, guardado local, pendiente, sincronizado y error.
- **Regla:** “apicultor” es un dato del registro, nunca una cuenta, trabajador o rol visual.

### Fotografías

- **Objetivo:** adjuntar evidencia desde cámara o galería sin perderla offline.
- **Componentes:** selector de origen, preview, descripción, progreso de guardado/carga y acción cancelar/eliminar.
- **Estados:** permiso, cancelada, preview, local pendiente, subiendo, sincronizada y error recuperable.
- **Regla:** confirmar “adjunta localmente” antes de “respaldada”; una miniatura rota nunca representa éxito.

### Recordatorios

- **Objetivo:** crear y gestionar avisos locales vinculados opcionalmente a un sector.
- **Componentes:** lista, formulario de fecha/hora/tipo, estado, permiso y acciones completar/cancelar.
- **Estados:** programado, vencido, completado, cancelado, permiso denegado, pendiente y sincronizado.
- **Regla:** permiso denegado no convierte el recordatorio en error ni oculta el registro.

### Sincronización y conflictos

- **Objetivo:** explicar respaldo, pendientes, errores y decisiones de conflicto sin lenguaje técnico innecesario.
- **Componentes:** resumen global, lista por estado, última confirmación, reintento y comparación local/remota.
- **Estados:** offline, pendiente, sincronizando, sincronizado, error, conflicto y resolución pendiente.
- **Regla:** la comparación identifica origen/fecha/diferencias con texto; ninguna versión parece descartada antes de confirmar.

### Exportar

- **Objetivo:** generar y guardar el `.xlsx` local con estado honesto del snapshot.
- **Componentes:** alcance resumido, progreso, selector Android, éxito, cancelación y error de espacio/escritura.
- **Estados:** sin datos, preparando, validando, seleccionando destino, completada, cancelada y error.
- **Regla:** cancelar no se presenta como fallo y un archivo parcial nunca recibe confirmación de éxito.

## Offline UX

### Principio rector

La conectividad no determina si la persona puede registrar trabajo. El guardado local es el resultado inmediato y la sincronización es un proceso posterior. La interfaz debe responder por separado a dos preguntas:

1. **¿Mi información quedó guardada en este dispositivo?**
2. **¿Ya fue respaldada en la nube?**

Nunca se usa “Guardado” como sinónimo de “Sincronizado”.

### Representación por nivel

| Nivel | Componente | Contenido |
|---|---|---|
| Global | Chip o banner bajo app bar | Conexión actual y número de pendientes cuando sea relevante |
| Lista | Badge o línea auxiliar por registro | Pendiente, sincronizando o error sólo en elementos afectados |
| Formulario | Feedback tras guardar | “Guardado en este dispositivo” y estado de respaldo |
| Más/Conexión | Resumen detallado | Última sincronización, pendientes y acción de reintento |
| Error persistente | Banner | Causa comprensible, datos afectados y recuperación |

El CSS contiene `.status`, `.sync` y `.sync.off`, pero la cabecera actual no los renderiza. **Corrección canónica:** Flutter debe activar un espacio estable para el estado global sin alterar el título ni producir saltos de layout.

### Máquina visual de estados

1. **Conectado sin pendientes:** estado verde discreto; el contenido opera normalmente.
2. **Guardando localmente:** progreso breve junto a la acción; el botón no admite dobles envíos.
3. **Guardado local:** confirmación inmediata, aun sin red.
4. **Pendiente:** ámbar suave, texto explícito y contador global.
5. **Sincronizando:** azul informativo y progreso no bloqueante.
6. **Sincronizado:** confirmación verde breve y actualización de metadatos.
7. **Error:** rosa suave, causa y acción Reintentar; el registro sigue visible localmente.
8. **Offline:** aviso “Sin conexión · guardado local activo”; las funciones que requieren red explican su limitación.

### Mensajes canónicos

- “Actividad guardada en este dispositivo.”
- “Actividad guardada · pendiente de sincronización.”
- “3 registros pendientes de sincronización.”
- “Sincronizando 2 de 3…”
- “Todo está sincronizado.”
- “Sin conexión · puedes seguir registrando.”
- “No se pudo sincronizar. Tus datos siguen guardados en este dispositivo.”
- “AgroIA necesita conexión para responder. Tu historial sigue disponible.”

Los mensajes indican resultado, ubicación del dato y siguiente paso. No se utilizan mensajes genéricos como “Error” o “Falló”.

### Reglas de comportamiento

- El registro aparece en Historial apenas termina el guardado local.
- El estado pendiente persiste tras reiniciar la aplicación.
- La recuperación de conexión no bloquea la pantalla ni navega automáticamente.
- El contador se actualiza como una frase contextual completa para lectores de pantalla.
- Los estados no se anuncian repetidamente si no cambian.
- El usuario puede reintentar errores sin volver a completar el formulario.
- Si AgroIA, clima, mapa remoto o exportación requieren red, cada pantalla ofrece estado específico y alternativa disponible.
- La última información válida se conserva con fecha y hora; nunca se presenta como actual si está desactualizada.
- Color, animación y badge siempre se acompañan por texto e icono.

## Flutter Implementation Guidelines

### Arquitectura visual del tema

- Usar Material 3 y un único `ThemeData` claro para el MVP.
- Construir `ColorScheme` con el mapeo de este documento.
- Crear una extensión semántica del tema para success, warning, info, offline, syncing y pending.
- Crear tokens centralizados de espaciado, radios, elevación, tamaño de icono y movimiento.
- Acceder al tema desde el contexto; no usar referencias estáticas ni HEX dentro de pantallas.
- Empaquetar Inter y los SVG de cultivo localmente para operación offline.
- Un tema oscuro futuro requiere especificación y aprobación separadas; “Modo claro” es el estado actual del MVP.

### Traducción HTML a Flutter

| Origen HTML/CSS | Adaptación Flutter | Regla |
|---|---|---|
| Variables `:root` | `ColorScheme` + extensión semántica | Roles, no nombres de color crudos en componentes |
| `.card` | Card/surface temática con interacción Material | Radio, borde, padding y elevación centralizados |
| `.hero` | Contenedor temático con layout flexible | Decoración excluida de semántica y sin altura rígida |
| `.quick`, `.actions`, `.metrics`, `.grid2` | Layout adaptable por constraints | Colapsa según ancho y escala, no por modelo de teléfono fijo |
| `.stack`, `.row` | Layout vertical/horizontal con tokens | Gap definido por escala 4/8/12/16/24/32 |
| Inputs HTML | Controles Material de formulario | Label visible, helper/error, teclado y validación semántica |
| `.bottom` y `.tab` | Navegación Material inferior | Cinco destinos, estado seleccionado y safe area |
| `.toast` | Snackbar o banner Material | Anuncio accesible, duración suficiente y recuperación |
| `data-lucide` | Lucide Flutter o Material Symbols equivalentes | Un solo lenguaje de trazo por nivel visual |
| SVG de cultivos | Assets vectoriales locales | Mantener colores y proporciones; semántica según contexto |
| `.map`, `.quad`, `.vertex` | Mapa/overlay/polígono con controles accesibles | Geometría real, blanco táctil y alternativa textual |

### Contrato visual de estado

Este Design System no selecciona librería ni arquitectura de estado. La capa visual recibe estados
semánticos explícitos y renderiza sus variantes canónicas; la decisión técnica correspondiente vive
únicamente en `specs/001-agrocampo-android-mvp/plan.md` y `research.md`.

La capa visual consume estados semánticos, no banderas ambiguas. Un registro distingue guardado local, pendiente, sincronizando, sincronizado y error. La vista no debe inferir “sincronizado” sólo porque existe conexión.

### Iconografía Flutter

- Primera opción: Lucide Flutter para conservar el lenguaje del prototipo.
- Alternativa: Material Symbols para controles nativos Android cuando exista equivalencia clara.
- No mezclar Lucide outline y Material filled en el mismo nivel de navegación.
- Pictogramas de cultivos siguen siendo SVG locales a color.
- Tamaños canónicos: 16 dp auxiliar, 20 dp estándar, 24 dp acción, 32 dp destacado.
- Trazo nominal: 2 dp en iconos outline.
- Todo icon button tiene blanco táctil 48 dp y nombre accesible.
- Icono decorativo junto a texto visible queda fuera del árbol semántico.
- Icono informativo sin texto recibe etiqueta; icono seleccionado anuncia su estado.

### Layout y áreas seguras

- Usar constraints reales del dispositivo, no el ancho fijo de 430 px.
- Respetar status bar, display cutouts, navegación por gestos, teclado y orientación.
- La lista principal aporta inset inferior suficiente para la barra de navegación.
- El compositor de AgroIA y cualquier CTA inferior permanece sobre teclado y safe area.
- En tablets, aumentar gutter y limitar el ancho del texto; no estirar formularios de borde a borde.
- Evitar scrolls anidados. Mapas y listas deben coordinar gestos explícitamente.

### Accesibilidad y semántica

- Contraste AA mínimo y 3:1 para límites/iconos informativos.
- Blanco táctil Android mínimo 48 × 48 dp y separación de 8 dp.
- Orden de lectura igual al orden visual.
- Botones de icono con nombre y estado; pestaña activa, chip seleccionado y panel expandido se anuncian.
- Formularios conectan etiqueta, ayuda, valor y error.
- El primer error recibe foco tras enviar; múltiples errores incluyen resumen navegable.
- El escalado de texto no trunca títulos, métricas críticas ni acciones.
- Movimiento reducido elimina giro continuo, stagger y transiciones no esenciales.
- La vibración se reserva para confirmaciones importantes y errores, nunca para cada tap.
- Snackbar y actualizaciones de sincronización no roban foco.

### Movimiento y feedback

- Feedback de presión dentro de 100 ms.
- Transiciones cortas y consistentes, normalmente 150–200 ms para cambios simples.
- El movimiento comunica causa y efecto; no se animan dimensiones que produzcan saltos.
- Una transición se puede interrumpir y siempre termina en el estado correcto.
- Carga prolongada usa progreso estable o skeleton reservado; no muestra spinners fugaces.
- Salida más rápida que entrada y sin bloquear interacción.

### Calidad visual y pruebas

- Verificar teléfono estrecho, teléfono grande y tablet, en vertical y horizontal.
- Probar escala de texto grande, TalkBack, modo de alto contraste y movimiento reducido.
- Comprobar cada par de foreground/background sobre la superficie real.
- Probar uso offline, cola pendiente, reconexión, error y reintento en todas las pantallas que guardan datos.
- Validar que ninguna lista, mapa, gráfico, formulario o chat quede vacío sin explicación.
- Realizar capturas comparativas contra el prototipo para Inicio, Sectores, Detalle, Registrar, AgroIA y Perfil.

## UX Improvements

### Prioridad crítica

1. **Corregir texto secundario.** Sustituir `#638175` por `#587267` para texto normal en Flutter.
2. **Eliminar ámbar como texto sobre blanco.** Valores de Perfil/Configuración usan `#92400E`, `brand-dark` o `onSurfaceVariant`.
3. **Aumentar blancos táctiles.** Iconos de 42–46 px, enlaces de flecha y vértices de 18 px deben operar dentro de 48 × 48 dp.
4. **Hacer visible la sincronización.** Activar el patrón de estado global y estado por registro; el CSS existente no lo renderiza en la cabecera.
5. **Agregar semántica completa.** Enviar de AgroIA necesita etiqueta; navegación necesita estado seleccionado; conexión necesita estado y no sólo acción.
6. **Formalizar errores y progreso.** Los formularios actuales sólo confirman éxito; Flutter incorpora validación cercana, guardado local, pendiente, error y reintento.

### Legibilidad en terreno

- Subir texto operativo de 12–12,5 px a 14 sp y campos/chat a 16 sp.
- Mantener fondo blanco opaco y `ink` para información esencial.
- Evitar texto encima de fotografía sin scrim medido.
- Usar títulos cortos, valores grandes y unidades adyacentes.
- Aumentar borde o contraste en brillo alto, sin inventar otra paleta.
- Evitar sombras como único separador porque pierden presencia bajo luz intensa.

### Uso con una mano

- Conservar Registrar en posición inferior central.
- Mantener la acción primaria de formularios dentro del flujo y alcanzable al final, sin colocar acciones frecuentes sólo en la esquina superior.
- No ubicar controles críticos en bordes del gesto de sistema.
- Dejar 8 dp entre blancos táctiles para reducir toques accidentales.
- En mapas, separar seleccionar, mover y confirmar para evitar gestos ambiguos.

### Escaneo y carga cognitiva

- Evitar que todo el texto sea 800/900; reservarlo para nombre, acción y valor.
- Mantener estructura “etiqueta → valor → contexto” en todas las métricas.
- Mostrar sólo campos correspondientes a la actividad elegida.
- Reutilizar términos exactos en Inicio, Sector, formulario e Historial.
- No mostrar simultáneamente banner, snackbar y badge para el mismo evento.
- En Historial, agrupar por temporada cuando la lista crezca sin ocultar eventos recientes.

### Estados vacíos y recuperación

- Sectores vacío: explicar que aún no hay cuadrantes y ofrecer sólo la acción permitida por el MVP.
- Mapa vacío/error: conservar lista de cuadrantes y acción Reintentar.
- Historial vacío: mantener el mensaje actual mejorado y, si corresponde, acceso a Registrar.
- AgroIA vacío: sugerir preguntas dentro del alcance, sin prometer diagnóstico.
- Clima sin datos: mostrar última lectura con hora o error; no usar “0” como valor real.
- Clima Open-Meteo: junto a datos provistos, mostrar crédito visible y enlazado a Open-Meteo.com y un aviso
  accesible de que las condiciones/pronósticos son informativos, probabilísticos y no sustituyen
  fuentes oficiales para decisiones críticas. Nunca impedir un flujo local por este aviso.
- Sincronización con error: indicar que los datos siguen locales y permitir reintentar.

### Formularios

- Indicar campos obligatorios y unidades antes de escribir.
- Validar al terminar el campo, no en cada pulsación.
- Conservar borrador ante cierre accidental o pérdida de conexión.
- Enfocar el primer campo inválido y ofrecer resumen si hay varios errores.
- Evitar dos columnas si el label o valor se corta con texto ampliado.
- Hacer del botón Guardar la única acción rellena del formulario.

### Mapas y cuadrantes

- Aumentar hit area de vértices y añadir alternativa a arrastre.
- Proteger legibilidad del nombre sobre zonas claras u oscuras de la fotografía.
- Comunicar claramente modo visualización frente a modo edición.
- Mantener una lista equivalente para TalkBack y fallos de mapa.
- No reducir etiquetas a 9 px en pantallas estrechas; priorizar nombre o abrir detalle.

### AgroIA

- Añadir estado de envío/respuesta y reintento sin duplicar mensajes.
- Mostrar contexto activo de forma compacta y verificable.
- Mantener disclaimer consultivo visible sin interrumpir cada mensaje.
- Deshabilitar enviar si el texto está vacío y explicar offline cuando corresponda.
- Preservar mensajes locales y posición de scroll.

### Alcance de las mejoras

Estas mejoras corrigen presentación, accesibilidad, feedback y adaptación responsive de funcionalidades ya representadas. No incorporan roles, trabajadores, inventario, ERP, automatización física de riego, IA avanzada ni análisis fotográfico.

## Development Rules

### Reglas obligatorias para desarrollo

1. `master.md` es la única fuente visual oficial del MVP.
2. No modificar colores, tipografía, radios, espaciado, iconografía o elevación sin aprobación y actualización previa de este documento.
3. No usar HEX, tamaños, paddings, radios o sombras directos dentro de pantallas; usar tokens del tema.
4. Mantener Inter como única familia tipográfica del MVP y empaquetarla localmente.
5. Mantener la jerarquía verde agrícola + amarillo cosecha + superficies blancas; los colores de cultivo no son colores de estado.
6. Priorizar claridad, contraste y lectura en terreno sobre decoración, transparencia o animación.
7. Toda acción táctil debe tener un blanco mínimo de 48 × 48 dp y separación suficiente.
8. Toda acción tiene estado normal, presionado, enfocado, deshabilitado y cargando cuando aplique.
9. Todo formulario tiene label visible, ayuda/unidad, validación, error cercano, guardado local y feedback de sincronización.
10. Toda información offline o de sincronización usa texto, icono y color; nunca sólo color.
11. “Guardado local” y “Sincronizado” son estados distintos y deben comunicarse como tales.
12. Toda pantalla nueva reutiliza los componentes y tokens existentes antes de crear una variante.
13. Sólo puede existir una acción primaria rellena por pantalla o paso.
14. La navegación inferior mantiene cinco destinos, orden y etiquetas; Registrar conserva la posición central.
15. Las rutas secundarias respetan back de Android, restauran estado y no duplican destinos superiores.
16. Todo icono estructural usa Lucide Flutter o Material Symbols con criterio consistente; no se usan emojis.
17. Los pictogramas de cultivos se sirven desde assets locales y mantienen proporción y color.
18. Todos los controles de icono tienen nombre accesible; los decorativos se excluyen de semántica.
19. El contenido soporta TalkBack, escala de texto, orientación horizontal, movimiento reducido y áreas seguras.
20. No reducir texto crítico para hacerlo caber; adaptar layout, envolver o aumentar altura.
21. No ocultar contenido detrás de app bar, teclado, navegación inferior o barras del sistema.
22. Toda pantalla con datos define carga, vacío, contenido, error y recuperación; las pantallas que guardan también definen pendiente y sincronización.
23. El mapa siempre tiene alternativa textual y los vértices editables disponen de blanco táctil y alternativa al arrastre.
24. AgroIA se presenta como ayuda consultiva y exige verificación en terreno; no toma decisiones ni ejecuta acciones.
25. No implementar tema oscuro, iOS ni variantes visuales fuera del MVP sin especificación aprobada.
26. No agregar roles, empresas, trabajadores, inventario, ERP, automatización física de riego, IA avanzada ni análisis fotográfico.
27. Las decisiones visuales no modifican cálculos, reglas agronómicas, sincronización ni lógica funcional del MVP.
28. Cada cambio visual debe probarse al menos en teléfono estrecho, teléfono grande y landscape, además de contraste y semántica.
29. Las comparaciones visuales usan `agrocampo-highfi.html` como referencia de identidad y este documento como autoridad normativa.
30. Si aparece una necesidad no cubierta, se documenta y aprueba aquí antes de implementarla.
